//
//  APIConfigurationExtension.swift
//  FMobile
//
//  Created by Nathan FALLET on 11/05/2020.
//  Copyright © 2020 Groupe MINASTE. All rights reserved.
//

import Foundation
import APIRequest

extension APIConfiguration {
    
    static let defaultHost = "fmobileapi.groupe-minaste.org"
    
    static func check() {
        // Si l'API n'a pas été init
        if current == nil {
            // On init l'API
            current = APIConfiguration(host: defaultHost)
        }
    }
    
}
