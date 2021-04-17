//
//  CoverageManager.swift
//  FMobile
//
//  Created by Nathan FALLET on 16/09/2019.
//  Copyright © 2019 Groupe MINASTE. All rights reserved.
//

import Foundation
import CoreLocation

class CoverageManager {
    
    // Send current data
    static func sendCurrentCoverageData(_ dataManager: DataManager = DataManager(), isRoaming: Bool = false) {
        // Check if user has accepted coverage map
        if dataManager.coveragemap {
            // Get location manager and user location
            let locationManager = CLLocationManager()
            
            // Check if location is valid
            if let location = locationManager.location?.coordinate {
                // Get informations
                let latitude = location.latitude
                let longitude = location.longitude
                let home = "\(dataManager.targetMCC)-\(dataManager.targetMNC)"
                let connected = "\(dataManager.connectedMCC)-\(isRoaming ? dataManager.itiMNC : dataManager.connectedMNC)"
                let connected_protocol = dataManager.carrierNetwork.replacingOccurrences(of: "CTRadioAccessTechnology", with: "", options: NSString.CompareOptions.literal, range: nil)
                
                // Check values
                if (latitude, longitude) != (0, 0) && home != "------" && connected != "------" {
                    // Send to API
                    APIRequest("POST", path: "/coverage/map.php").with(body: [
                        "latitude": latitude,
                        "longitude": longitude,
                        "home": home,
                        "connected": connected,
                        "connected_protocol": connected_protocol
                    ]).execute(Bool.self) { _, _ in }
                }
            }
        }
    }
    
    // Get points from the server, centered on a location with a radius
    static func getCoverage(center: CLLocationCoordinate2D, radius: Double, completionHandler: @escaping (CoverageMap?) -> ()) {
        // Query API
        APIRequest("GET", path: "/coverage/map.php").with(name: "latitude", value: center.latitude).with(name: "longitude", value: center.longitude).with(name: "radius", value: radius).execute(CoverageMap.self) { data, status in
            // Return data
            completionHandler(data)
        }
    }
    
}
