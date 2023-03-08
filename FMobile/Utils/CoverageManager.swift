//
//  CoverageManager.swift
//  FMobile
//
//  Created by Nathan FALLET on 16/09/2019.
//  Copyright © 2019 Groupe MINASTE. All rights reserved.
//

import Foundation
import CoreLocation
import APIRequest
import CoreTelephony
import UIKit
import CoreData

class CoverageManager {
    
    // Sending status
    static var sending = false
    
    // Last APIRequest instance
    private static var lastRequest: APIRequest?
    
    #if !FMOBILECOVERAGE
    // Send current data
    static func addCurrentCoverageData(_ dataManager: DataManager = DataManager(), isRoaming: Bool = false, abroad: Bool = false) {
        // Check if user has accepted coverage map
        print("COVERAGE MAP CALLED")
        if dataManager.coveragemap {
            // Get location manager and user location
            let locationManager = CLLocationManager()
            
            if #available(iOS 14.0, *) {
                if locationManager.accuracyAuthorization == .reducedAccuracy {
                    return
                }
            }
            
            // Check if location is valid
            if let location = locationManager.location, location.horizontalAccuracy >= 0, location.coordinate.latitude != 0, location.coordinate.longitude != 0 {
                
                for service in dataManager.simtrays {
                    // Get informations
                    let latitude = location.coordinate.latitude
                    let longitude = location.coordinate.longitude
                    var home = "\(service.card.mcc)-\(service.card.mnc)"
                    var connected = "\(service.network.mcc)-\(isRoaming ? service.card.itiMNC : service.network.mnc)"
                    var connected_protocol = String()
                    
                    if #available(iOS 14.1, *) {
                        if service.network.connected == CTRadioAccessTechnologyNR {
                            connected_protocol = "NR"
                        } else if service.network.connected == CTRadioAccessTechnologyNRNSA {
                            connected_protocol = "NRNSA"
                        }
                    }
                    
                    if connected_protocol.isEmpty {
                        switch service.network.connected {
                        case CTRadioAccessTechnologyLTE:
                            connected_protocol = "LTE"
                        case CTRadioAccessTechnologyWCDMA:
                            connected_protocol = "WCDMA"
                        case CTRadioAccessTechnologyHSDPA:
                            connected_protocol = "HSDPA"
                        case CTRadioAccessTechnologyEdge:
                            connected_protocol = "Edge"
                        case CTRadioAccessTechnologyGPRS:
                            connected_protocol = "GPRS"
                        case CTRadioAccessTechnologyeHRPD:
                            connected_protocol = "eHRPD"
                        case CTRadioAccessTechnologyHSUPA:
                            connected_protocol = "HSUPA"
                        case CTRadioAccessTechnologyCDMA1x:
                            connected_protocol = "CDMA"
                        case CTRadioAccessTechnologyCDMAEVDORev0:
                            connected_protocol = "CDMAEvDoRev0"
                        case CTRadioAccessTechnologyCDMAEVDORevA:
                            connected_protocol = "CDMAEvDoRevA"
                        case CTRadioAccessTechnologyCDMAEVDORevB:
                            connected_protocol = "CDMAEvDoRevB"
                        default:
                            connected_protocol = "UNKNOWN" // In the short run, this will probably be 5G.
                        }
                    }
                    
                    if service.network.connected.isEmpty || service.network.connected == "" {
                        connected_protocol = "NONETWORK"
                    }
                    
                    connected_protocol = connected_protocol.uppercased()
                    
                    // Check for dashes to replace
                    if home == "------" && connected != "------" {
                        // Set home to connected value (cause home is not defined)
                        home = connected
                    }
                    if home != "------" && connected == "------" {
                        // Set connected to home or F-Contact value (cause connected is not defined)
                        if service.card.data != "------" {
                            connected = "999-999"
                        } else {
                            connected = home
                        }
                    }
                    
                    print("PRE - ABOUT TO SEND \(home) \(connected) \(connected_protocol) on location \(latitude) \(longitude)")
                    
                    // Check values
                    if latitude != 0 && longitude != 0 && home != "------" && connected != "------" {
                        // Add to list
                        print("ABOUT TO SEND \(home) \(connected) \(connected_protocol) on location \(latitude) \(longitude)")
                        insertInDatabase(item: CoveragePoint(latitude: latitude, longitude: longitude, home: home, connected: connected, connected_protocol: connected_protocol))
                        
                    }
                }
                
                // Flush
                flushList(abroad: abroad)
            }
        }
    }
    
    // Flush list
    static func flushList(abroad: Bool = false) {
        // Check API configuration
        APIConfiguration.check()
        
        // Check that sending is allowed
        guard abroad ? false : !(DataManager().coverageLowData) else {
            print("Waiting next call to send coverage data! (abroad or coverageLowData)")
            return
        }
        
        // Check data is not sending yet
        guard !sending else {
            print("Already sending!")
            return
        }
        sending = true
        
        // Get waiting list and clear it
        let list = retrieveDatabase()
        clearDatabase()
        
        // Check that list is not empty
        guard !list.isEmpty else {
            print("List is empty!")
            sending = false
            return
        }
        
        // Debug print
        print("CoverageManager: sending waiting list... (\(list.count) items)")
        
        // Send data
        APIRequest("POST", path: "/coverage/map.php").with(body: list).execute(Bool.self) { data, status in
            // Check status
            if status != .ok && status != .badRequest {
                // Not sent, add back to the waiting list
                print("APIRequest CALLBACK with list size : \(list.count)")
                for point in list { insertInDatabase(item: point) }
            }
            
            // No more sending
            sending = false
        }
    }
    
    static func clearDatabase() {
        let context: NSManagedObjectContext
        if #available(iOS 10.0, *) {
            context = PermanentStorage.persistentContainer.viewContext
        } else {
            // Fallback on earlier versions
            context = PermanentStorage.managedObjectContext
        }
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Coverage")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        context.performAndWait({
            do {
                try context.execute(deleteRequest)
                try context.save()
                print("Coverage Database cleared")
            } catch {
                print ("There was an error while saving the Coverage Database")
            }
        })
    }
    
    static func insertInDatabase(item: CoveragePoint) {
        let context: NSManagedObjectContext
        if #available(iOS 10.0, *) {
            context = PermanentStorage.persistentContainer.viewContext
        } else {
            // Fallback on earlier versions
            context = PermanentStorage.managedObjectContext
        }
        guard let entity = NSEntityDescription.entity(forEntityName: "Coverage", in: context) else {
            print("Error: Coverage entity not found in Database!")
            return
        }
        
        guard var latitude = item.latitude, var longitude = item.longitude, let home = item.home, let connected = item.connected, let connected_protocol = item.connected_protocol else {
            print("One item is unexpectedly nil")
            return
        }
        
        latitude = Double(round(1000*latitude)/1000)
        longitude = Double(round(1000*longitude)/1000)
        
        context.performAndWait({
            let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Coverage")
            deleteFetch.predicate = NSPredicate(format: "(latitude == %lf) AND (longitude == %lf) AND (home == %@) AND (connected == %@)", latitude, longitude, item.home ?? "------", item.connected ?? "------")
            deleteFetch.returnsObjectsAsFaults = false
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
            do {
                try context.execute(deleteRequest)
                try context.save()
                print("Coverage Database cleared")
            } catch {
                print ("There was an error while saving the Coverage Database")
            }
        })
        
        context.performAndWait({
            
            let newCoo = NSManagedObject(entity: entity, insertInto: context)
            
            newCoo.setValue(latitude, forKey: "latitude")
            newCoo.setValue(longitude, forKey: "longitude")
            newCoo.setValue(home, forKey: "home")
            newCoo.setValue(connected, forKey: "connected")
            newCoo.setValue(connected_protocol, forKey: "connected_protocol")
            
            do {
                try context.save()
                print("COVERAGE POINT SAVED!")
            } catch {
                print("Failed while saving Coverage Point")
            }
        })
            
    }
    
    static func retrieveDatabase() -> [CoveragePoint] {
        let context: NSManagedObjectContext
        if #available(iOS 10.0, *) {
            context = PermanentStorage.persistentContainer.viewContext
        } else {
            // Fallback on earlier versions
            context = PermanentStorage.managedObjectContext
        }
        
        var CoveragePoints = [CoveragePoint]()
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Coverage")
        request.returnsObjectsAsFaults = false
        
        do {
            print("GOT INTO COVERAGE DB")
            let result = try context.fetch(request)
            for data in result as? [NSManagedObject] ?? [NSManagedObject()] {
                let latitude = data.value(forKey: "latitude") as? Double
                let longitude = data.value(forKey: "longitude") as? Double
                let home = data.value(forKey: "home") as? String
                let connected = data.value(forKey: "connected") as? String
                let connected_protocol = data.value(forKey: "connected_protocol") as? String
                
                CoveragePoints.append(CoveragePoint(latitude: latitude, longitude: longitude, home: home, connected: connected, connected_protocol: connected_protocol))
                
            }
        } catch {
            print("Coverage Database read error")
        }
        
        return CoveragePoints
    }
    #endif
    
    // Get points from the server, centered on a location with a radius
    static func getCoverage(center: CLLocationCoordinate2D, radius: Double, protocols: [String], completionHandler: @escaping (CoverageMap?) -> ()) {
        // Check API configuration
        APIConfiguration.check()
        
        // Cancel last request if needed
        lastRequest?.cancel()
        
        // Query API
        lastRequest = APIRequest("GET", path: "/coverage/map.php").with(name: "latitude", value: center.latitude).with(name: "longitude", value: center.longitude).with(name: "radius", value: radius).with(name: "protocols", value: protocols.joined(separator: ",")).execute(CoverageMap.self) { data, _ in
            // Return data
            completionHandler(data)
        }
    }
    
}
