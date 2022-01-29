//
//  CoveragePoint.swift
//  FMobile
//
//  Created by Nathan FALLET on 16/09/2019.
//  Copyright © 2019 Groupe MINASTE. All rights reserved.
//

import Foundation
import MapKit

class CoveragePoint: Codable {
    
    var latitude: Double?
    var longitude: Double?
    var home: String?
    var connected: String?
    var connected_protocol: String?
    var isRoaming: Bool {
        get {
            // Calculate roaming
            let simarray = home?.components(separatedBy: "-") ?? ["---", "--"]
            let netarray = connected?.components(separatedBy: "-") ?? ["---", "--"]
            if simarray.count == 2 && netarray.count == 2 {
                return simarray[0] == netarray[0] && simarray[1] != netarray[1]
            } else {
                return false
            }
        }
    }
    var isSending: Bool = false
    
    public enum CodingKeys: String, CodingKey {
        case latitude, longitude, home, connected, connected_protocol
    }
    
    init(latitude: Double?, longitude: Double?, home: String?, connected: String?, connected_protocol: String?) {
        // Store custom variables
        self.latitude = latitude
        self.longitude = longitude
        self.home = home
        self.connected = connected
        self.connected_protocol = connected_protocol?.uppercased()
    }
    
    required convenience init(from decoder: Decoder) throws {
        // Read values
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try? values.decode(Double.self, forKey: .latitude)
        let longitude = try? values.decode(Double.self, forKey: .longitude)
        let home = try? values.decode(String.self, forKey: .home)
        let connected = try? values.decode(String.self, forKey: .connected)
        let connected_protocol = try? values.decode(String.self, forKey: .connected_protocol)
        
        // And init
        self.init(latitude: latitude, longitude: longitude, home: home, connected: connected, connected_protocol: connected_protocol)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        try container.encode(home, forKey: .home)
        try container.encode(connected, forKey: .connected)
        try container.encode(connected_protocol, forKey: .connected_protocol)
    }
    
    func getPolygon(ofSize size: Double) -> MKPolygon {
        // Create coordinates
        let coordinates = [
            CLLocationCoordinate2D(latitude: (latitude ?? 0) - size / 2, longitude: (longitude ?? 0) - size / 2),
            CLLocationCoordinate2D(latitude: (latitude ?? 0) - size / 2, longitude: (longitude ?? 0) + size / 2),
            CLLocationCoordinate2D(latitude: (latitude ?? 0) + size / 2, longitude: (longitude ?? 0) + size / 2),
            CLLocationCoordinate2D(latitude: (latitude ?? 0) + size / 2, longitude: (longitude ?? 0) - size / 2)
        ]
        
        // Return the object
        return MKPolygon(coordinates: coordinates, count: coordinates.count)
    }
    
    func protocolToColor() -> UIColor {
        // Not detectable
        // NONETWORK
        if connected_protocol == "NONETWORK".uppercased() || (connected_protocol?.isEmpty ?? false) {
            return UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.75) // Black
        }
        
        // Standard
        // LTE
        if connected_protocol == "LTE".uppercased() && !isRoaming {
            return UIColor(red: 0/255, green: 204/255, blue: 0/255, alpha: 0.75) // Strong green
        }
        // WCDMA
        if connected_protocol == "WCDMA".uppercased() && !isRoaming{
            return UIColor(red: 178/255, green: 255/255, blue: 102/255, alpha: 0.6) // Light green
        }
        // HSDPA
        if connected_protocol == "HSDPA".uppercased() && !isRoaming{
            return UIColor(red: 178/255, green: 255/255, blue: 102/255, alpha: 0.6) // Light green
        }
        // EDGE
        if connected_protocol == "EDGE".uppercased() && !isRoaming{
            return UIColor(red: 51/255, green: 255/255, blue: 255/255, alpha: 0.5) // Light blue
        }
        // GPRS
        if connected_protocol == "GPRS".uppercased() && !isRoaming{
            return UIColor(red: 153/255, green: 255/255, blue: 255/255, alpha: 0.4) // Super light blue
        }
        // LTE R
        if connected_protocol == "LTE".uppercased() && isRoaming {
            return UIColor(red: 255/255, green: 255/255, blue: 51/255, alpha: 0.75) // Strong yellow
        }
        // WCDMA R
        if connected_protocol == "WCDMA".uppercased() && isRoaming {
            return UIColor(red: 255/255, green: 153/255, blue: 51/255, alpha: 0.6) // Clear orange
        }
        // HSDPA R
        if connected_protocol == "HSDPA".uppercased() && isRoaming {
            return UIColor(red: 255/255, green: 153/255, blue: 51/255, alpha: 0.6) // Clear orange
        }
        // EDGE R
        if connected_protocol == "EDGE".uppercased() && isRoaming{
            return UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.5) // Light red
        }
        // GPRS R
        if connected_protocol == "GPRS".uppercased() && isRoaming{
            return UIColor(red: 255/255, green: 102/255, blue: 102/255, alpha: 0.4) // Super light red
        }
        
        // Specific protocols (all in light green)
        // eHRPD
        if connected_protocol == "EHRPD".uppercased() && !isRoaming {
            return UIColor(red: 178/255, green: 255/255, blue: 102/255, alpha: 0.6)
        }
        // HSUPA
        if connected_protocol == "HSUPA".uppercased() && !isRoaming {
            return UIColor(red: 178/255, green: 255/255, blue: 102/255, alpha: 0.6)
        }
        // CDMA
        if connected_protocol == "CDMA".uppercased() && !isRoaming {
            return UIColor(red: 178/255, green: 255/255, blue: 102/255, alpha: 0.6)
        }
        // CDMA EvDo Rev 0
        if connected_protocol == "CDMAEvDoRev0".uppercased() && !isRoaming {
            return UIColor(red: 178/255, green: 255/255, blue: 102/255, alpha: 0.6)
        }
        // CDMA EvDo Rev A
        if connected_protocol == "CDMAEvDoRevA".uppercased() && !isRoaming {
            return UIColor(red: 178/255, green: 255/255, blue: 102/255, alpha: 0.6)
        }
        // CDMA EvDo Rev B
        if connected_protocol == "CDMAEvDoRevA".uppercased() && !isRoaming {
            return UIColor(red: 178/255, green: 255/255, blue: 102/255, alpha: 0.6)
        }
        
        // Roaming specific protocols (all in clear orange)
        // eHRPD R
        if connected_protocol == "EHRPD".uppercased() && isRoaming {
            return UIColor(red: 255/255, green: 153/255, blue: 51/255, alpha: 0.6)
        }
        // HSUPA R
        if connected_protocol == "HSUPA".uppercased() && isRoaming {
            return UIColor(red: 255/255, green: 153/255, blue: 51/255, alpha: 0.6)
        }
        // CDMA R
        if connected_protocol == "CDMA".uppercased() && isRoaming {
            return UIColor(red: 255/255, green: 153/255, blue: 51/255, alpha: 0.6)
        }
        // CDMA EvDo Rev 0 R
        if connected_protocol == "CDMAEvDoRev0".uppercased() && isRoaming {
            return UIColor(red: 255/255, green: 153/255, blue: 51/255, alpha: 0.6)
        }
        // CDMA EvDo Rev A R
        if connected_protocol == "CDMAEvDoRevA".uppercased() && isRoaming {
            return UIColor(red: 255/255, green: 153/255, blue: 51/255, alpha: 0.6)
        }
        // CDMA EvDo Rev B R
        if connected_protocol == "CDMAEvDoRevA".uppercased() && isRoaming {
            return UIColor(red: 255/255, green: 153/255, blue: 51/255, alpha: 0.6)
        }
        
        // Default
        return UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 0.75) // Gray
    }
    
}
