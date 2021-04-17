//
//  CoveragePoint.swift
//  FMobile
//
//  Created by Nathan FALLET on 16/09/2019.
//  Copyright © 2019 Groupe MINASTE. All rights reserved.
//

import Foundation
import MapKit

class CoveragePoint: MKPolygon, Codable {
    
    var latitude: Double?
    var longitude: Double?
    var home: String?
    var connected: String?
    var connected_protocol: String?
    var isRoaming = false
    
    convenience init(latitude: Double?, longitude: Double?, home: String?, connected: String?, connected_protocol: String?) {
        let coordinates = [
            CLLocationCoordinate2D(latitude: (latitude ?? 0) - 0.0005, longitude: (longitude ?? 0) - 0.0005),
            CLLocationCoordinate2D(latitude: (latitude ?? 0) - 0.0005, longitude: (longitude ?? 0) + 0.0005),
            CLLocationCoordinate2D(latitude: (latitude ?? 0) + 0.0005, longitude: (longitude ?? 0) + 0.0005),
            CLLocationCoordinate2D(latitude: (latitude ?? 0) + 0.0005, longitude: (longitude ?? 0) - 0.0005)
        ]
        
        self.init(coordinates: coordinates, count: coordinates.count)
        self.latitude = latitude
        self.longitude = longitude
        self.home = home
        self.connected = connected
        self.connected_protocol = connected_protocol
        let simarray = home?.components(separatedBy: "-") ?? ["000", "000"]
        let netarray = connected?.components(separatedBy: "-") ?? ["000", "000"]
        if simarray[0] == netarray[0] && simarray[1] != netarray[1] {
            self.isRoaming = true // Nathan tu peux me faire la condition avec ton système d'Extopy tout ça (if SIMMCC = MCC && SIMMNC != MNC, true), et vérifie que j'ai pas trop fait de conneries
        }
        
        
    }
    
    func protocolToColor() -> UIColor {
        // LTE
        if connected_protocol == "LTE" && !isRoaming {
            return .purple
        }
        // WCDMA
        if connected_protocol == "WCDMA" && !isRoaming{
            return .magenta
        }
        // HSDPA
        if connected_protocol == "HSDPA" && !isRoaming{
            return .magenta
        }
        // EDGE
        if connected_protocol == "EDGE" && !isRoaming{
            return .blue
        }
        // LTE R
        if connected_protocol == "LTE" && isRoaming {
            return .orange
        }
        // WCDMA R
        if connected_protocol == "WCDMA" && isRoaming {
            return .yellow
        }
        // HSDPA R
        if connected_protocol == "HSDPA" && isRoaming {
            return .yellow
        }
        // EDGE R
        if connected_protocol == "EDGE" && isRoaming{
            return .red
        }
        // BROKEN
        if connected_protocol == "BROKEN" {
            return .black
        }
        
        // TODO: Add more protocols
        
        // Unknown
        return .white
    }
    
}
