//
//  CarrierConfiguration.swift
//  FMobile
//
//  Created by Nathan FALLET on 01/09/2019.
//  Copyright © 2019 Groupe MINASTE. All rights reserved.
//

import Foundation
import UIKit

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
        // On appel l'API
        APIRequest("GET", path: "/carrierconfiguration/\(mcc)-\(mnc).json").execute(CarrierConfiguration.self) { data, status in
            // On vérifie la validité de la configuration (non nil, avec bon MCC et MNC)
            if let configuration = data, configuration.mcc == mcc, configuration.mnc == mnc {
                // Return
                
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
                
                completionHandler(configuration)
                return
            }
            
            // Sinon soit la configuration n'existe pas, soit le device est hors ligne
            completionHandler(nil)
        }
    }
    
}
