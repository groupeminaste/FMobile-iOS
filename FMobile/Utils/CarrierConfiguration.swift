//
//  CarrierConfiguration.swift
//  FMobile
//
//  Created by Nathan FALLET on 01/09/2019.
//  Copyright © 2019 Groupe MINASTE. All rights reserved.
//

import Foundation
import UIKit
import APIRequest
import CoreData

class CarrierConfiguration: Codable {
    
    // Variable de configurations issues du fichier en ligne
    var mcc: String?
    var mnc: String?
    var stms: Double?
    var hp: String?
    var nrp: String?
    var land: String?
    var itiname: String?
    var homename: String?
    var itimnc: String?
    var nrfemto: Bool?
    var out2G: Bool?
    var setupDone: Bool?
    var minimalSetup: Bool?
    var disableFMobileCore: Bool?
    var countriesData: [String]?
    var countriesVoice: [String]?
    var countriesVData: [String]?
    var carrierServices: [[String]]?
    var iPadOverwrite: [String:AnyCodable]?
    var roamLTE: Bool?
    var roam5G: Bool?
    
    // On fetch le fichier et retourne les valeurs
    static func fetch(forMCC mcc: String, andMNC mnc: String, completionHandler: @escaping (CarrierConfiguration?) -> ()) {
        
        // On check le cache
//        if let carrier = CarrierConfiguration.getDatabaseCarrier(mcc: mcc, mnc: mnc) {
//            // On return depuis le cache
//            completionHandler(carrier)
//            return
//        }
        
        // Check de l'api
        // APIConfiguration.check()
        
        // On appel l'API
        
        guard let fMobileAPIendpoint = Bundle.main.path(forResource: "\(mcc)-\(mnc)", ofType: "json") else {
            completionHandler(nil)
            return
        }
        guard let fmobileapi = FileManager.default.contents(atPath: fMobileAPIendpoint) else {
            completionHandler(nil)
            return
        }
        
        let data = try? JSONDecoder().decode(CarrierConfiguration.self, from: fmobileapi)
        
        // On vérifie la validité de la configuration (non nil, avec bon MCC et MNC)
        if let configuration = data, configuration.mcc == mcc, configuration.mnc == mnc {
            // Update de la config
            if UIDevice.current.userInterfaceIdiom == .pad {
                if let mcc = configuration.iPadOverwrite?["mcc"]?.value() as? String {
                    configuration.mcc = mcc
                }
                if let mnc = configuration.iPadOverwrite?["mnc"]?.value() as? String {
                    configuration.mnc = mnc
                }
                if let stms = configuration.iPadOverwrite?["stms"]?.value() as? Double {
                    configuration.stms = stms
                }
                if let hp = configuration.iPadOverwrite?["hp"]?.value() as? String {
                    configuration.hp = hp
                }
                if let nrp = configuration.iPadOverwrite?["nrp"]?.value() as? String {
                    configuration.nrp = nrp
                }
                if let land = configuration.iPadOverwrite?["land"]?.value() as? String {
                    configuration.land = land
                }
                if let itiname = configuration.iPadOverwrite?["itiname"]?.value() as? String {
                    configuration.itiname = itiname
                }
                if let homename = configuration.iPadOverwrite?["homename"]?.value() as? String {
                    configuration.homename = homename
                }
                if let itimnc = configuration.iPadOverwrite?["itimnc"]?.value() as? String {
                    configuration.itimnc = itimnc
                }
                if let nrfemto = configuration.iPadOverwrite?["nrfemto"]?.value() as? Bool {
                    configuration.nrfemto = nrfemto
                }
                if let out2G = configuration.iPadOverwrite?["out2G"]?.value() as? Bool {
                    configuration.out2G = out2G
                }
                if let setupDone = configuration.iPadOverwrite?["setupDone"]?.value() as? Bool {
                    configuration.setupDone = setupDone
                }
                if let minimalSetup = configuration.iPadOverwrite?["minimalSetup"]?.value() as? Bool {
                    configuration.minimalSetup = minimalSetup
                }
                if let disableFMobileCore = configuration.iPadOverwrite?["disableFMobileCore"]?.value() as? Bool {
                    configuration.disableFMobileCore = disableFMobileCore
                }
                if let countriesData = configuration.iPadOverwrite?["countriesData"]?.value() as? [String] {
                    configuration.countriesData = countriesData
                }
                if let countriesVoice = configuration.iPadOverwrite?["countriesVoice"]?.value() as? [String] {
                    configuration.countriesVoice = countriesVoice
                }
                if let countriesVData = configuration.iPadOverwrite?["countriesVData"]?.value() as? [String] {
                    configuration.countriesVData = countriesVData
                }
                if let carrierServices = configuration.iPadOverwrite?["carrierServices"]?.value() as? [[String]] {
                    configuration.carrierServices = carrierServices
                }
                if let roamLTE = configuration.iPadOverwrite?["roamLTE"]?.value() as? Bool {
                    configuration.roamLTE = roamLTE
                }
                if let roam5G = configuration.iPadOverwrite?["roam5G"]?.value() as? Bool {
                    configuration.roam5G = roam5G
                }
            }
            
//            // On save en cache
//            CarrierConfiguration.insertInDatabase(item: configuration)
            
            // Return
            completionHandler(configuration)
            return
        }
        
//        APIRequest("GET", path: "/carrierconfiguration/\(mcc)-\(mnc).json").execute(CarrierConfiguration.self) { data, _ in
//        }
    }
    
    func toString(expertMode: Bool) -> String {
        return "\(homename ?? "Carrier") (\(land ?? ""))" + (expertMode ? " [\(mcc ?? "---") \(mnc ?? "--")]" : "")
    }
    
    static func clearDatabase() {
        let context: NSManagedObjectContext
        if #available(iOS 10.0, *) {
            context = PermanentStorage.persistentContainer.viewContext
        } else {
            // Fallback on earlier versions
            context = PermanentStorage.managedObjectContext
        }
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Carriers")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        context.performAndWait({
            do {
                try context.execute(deleteRequest)
                try context.save()
                print("Carriers Database cleared")
            } catch {
                print ("There was an error while saving the Carriers Database")
            }
        })
    }
    
    static func insertInDatabase(item: CarrierConfiguration) {
        let context: NSManagedObjectContext
        if #available(iOS 10.0, *) {
            context = PermanentStorage.persistentContainer.viewContext
        } else {
            // Fallback on earlier versions
            context = PermanentStorage.managedObjectContext
        }
        guard let entity = NSEntityDescription.entity(forEntityName: "Carriers", in: context) else {
            print("Error: Carriers entity not found in Database!")
            return
        }
        
        guard let mcc = item.mcc, let mnc = item.mnc, let itiname = item.itiname, let homename = item.homename else {
            print("One essential item is unexpectedly nil")
            return
        }
        
        context.performAndWait({
            let newCoo = NSManagedObject(entity: entity, insertInto: context)
            
            newCoo.setValue(mcc, forKey: "mcc")
            newCoo.setValue(mnc, forKey: "mnc")
            newCoo.setValue(item.stms ?? 5000, forKey: "stms")
            newCoo.setValue(item.hp ?? "WCDMA", forKey: "hp")
            newCoo.setValue(item.nrp ?? "HSDPA", forKey: "nrp")
            newCoo.setValue(item.land ?? "FR", forKey: "land")
            newCoo.setValue(itiname, forKey: "itiname")
            newCoo.setValue(homename, forKey: "homename")
            newCoo.setValue(item.itimnc ?? "00", forKey: "itimnc")
            newCoo.setValue(item.nrfemto ?? false, forKey: "nrfemto")
            newCoo.setValue(item.out2G ?? false, forKey: "out2G")
            newCoo.setValue(item.setupDone ?? true, forKey: "setupDone")
            newCoo.setValue(item.minimalSetup ?? true, forKey: "minimalSetup")
            newCoo.setValue(item.disableFMobileCore ?? true, forKey: "disableFMobileCore")
            newCoo.setValue(item.countriesData?.toJSON() ?? "[]", forKey: "countriesData")
            newCoo.setValue(item.countriesVoice?.toJSON() ?? "[]", forKey: "countriesVoice")
            newCoo.setValue(item.countriesVData?.toJSON() ?? "[]", forKey: "countriesVData")
            newCoo.setValue(item.carrierServices?.toJSON() ?? "[]", forKey: "carrierServices")
            newCoo.setValue(item.iPadOverwrite?.toJSON() ?? "{}", forKey: "iPadOverwrite")
            newCoo.setValue(item.roamLTE ?? false, forKey: "roamLTE")
            newCoo.setValue(item.roam5G ?? false, forKey: "roam5G")
        
            do {
                try context.save()
                print("Carriers POINT SAVED!")
            } catch {
                print("Failed while saving Carriers Point")
            }
        })
            
    }
    
    static func getDatabaseCarrier(mcc: String, mnc: String) -> CarrierConfiguration? {
        let context: NSManagedObjectContext
        if #available(iOS 10.0, *) {
            context = PermanentStorage.persistentContainer.viewContext
        } else {
            // Fallback on earlier versions
            context = PermanentStorage.managedObjectContext
        }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Carriers")
        request.predicate = NSPredicate(format: "(mcc == %@) AND (mnc == %@)", mcc, mnc)
        request.returnsObjectsAsFaults = false
        
        if let result = try? (context.fetch(request) as? [NSManagedObject] ?? [NSManagedObject()]).first {
            let final = CarrierConfiguration()
            final.mcc = result.value(forKey: "mcc") as? String
            final.mnc = result.value(forKey: "mnc") as? String
            final.stms = result.value(forKey: "stms") as? Double
            final.hp = result.value(forKey: "hp") as? String
            final.nrp = result.value(forKey: "nrp") as? String
            final.land = result.value(forKey: "land") as? String
            final.itiname = result.value(forKey: "itiname") as? String
            final.homename = result.value(forKey: "homename") as? String
            final.itimnc = result.value(forKey: "itimnc") as? String
            final.nrfemto = result.value(forKey: "nrfemto") as? Bool
            final.out2G = result.value(forKey: "out2G") as? Bool
            final.setupDone = result.value(forKey: "setupDone") as? Bool
            final.minimalSetup = result.value(forKey: "minimalSetup") as? Bool
            final.disableFMobileCore = result.value(forKey: "disableFMobileCore") as? Bool
            final.countriesData = (result.value(forKey: "countriesData") as? String)?.fromJSON(as: [String].self) ?? []
            final.countriesVoice = (result.value(forKey: "countriesVoice") as? String)?.fromJSON(as: [String].self) ?? []
            final.countriesVData = (result.value(forKey: "countriesVData") as? String)?.fromJSON(as: [String].self) ?? []
            final.carrierServices = (result.value(forKey: "carrierServices") as? String)?.fromJSON(as: [[String]].self) ?? []
            final.iPadOverwrite = (result.value(forKey: "iPadOverwrite") as? String)?.fromJSON(as: [String:AnyCodable].self) ?? [:]
            final.roamLTE = result.value(forKey: "roamLTE") as? Bool
            final.roam5G = result.value(forKey: "roam5G") as? Bool
            
            return final
        }
        print("COULD NOT FETCH REQUEST.")
        return nil
    }
    
}
