//
//  CarrierConfiguration.swift
//  FMobile
//
//  Created by Nathan FALLET on 01/09/2019.
//  Copyright © 2019 Groupe MINASTE. All rights reserved.
//

import Foundation

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
    
    // On fetch le fichier et retourne les valeurs
    static func fetch(forMCC mcc: String, andMNC mnc: String, completionHandler: @escaping (CarrierConfiguration?) -> ()) {
        // On appel l'API
        APIRequest("GET", path: "/carrierconfiguration/\(mcc)-\(mnc).json").execute(CarrierConfiguration.self) { data, status in
            // On vérifie la validité de la configuration (non nil, avec bon MCC et MNC)
            if let configuration = data, configuration.mcc == mcc, configuration.mnc == mnc {
                // Return
                completionHandler(configuration)
                return
            }
            
            // Sinon soit la configuration n'existe pas, soit le device est hors ligne
            completionHandler(nil)
        }
    }
    
}
