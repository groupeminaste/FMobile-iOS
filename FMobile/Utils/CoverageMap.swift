//
//  CoverageMap.swift
//  FMobile
//
//  Created by Nathan FALLET on 17/09/2019.
//  Copyright © 2019 Groupe MINASTE. All rights reserved.
//

import Foundation

class CoverageMap: Codable {
    
    // Variables
    var total: Int64?
    var points: [CoveragePoint]?
    var size: Double?
    
    // Extract carrier list
    func getCarrierList() -> [String] {
        // Create a list
        var list = [String]()
        
        // Iterate points
        for point in points ?? [] {
            // Check if carriers are in the list
            if let connected = point.connected, !list.contains(where: { $0 == connected }) {
                // Add it
                list.append(connected)
            }
        }
        
        // Return the final list
        return list
    }
    
}
