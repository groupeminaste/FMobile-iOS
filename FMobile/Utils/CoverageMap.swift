//
//  CoverageMap.swift
//  FMobile
//
//  Created by Nathan FALLET on 17/09/2019.
//  Copyright © 2019 Groupe MINASTE. All rights reserved.
//

import Foundation

class CoverageMap: Codable {
    
    var status: Bool?
    var carriers: [CarrierConfiguration]?
    var points: [CoveragePoint]?
    
}
