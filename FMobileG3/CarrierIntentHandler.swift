//
//  CarrierIntentHandler.swift
//  FMobileG3
//
//  Created by PlugN on 03/07/2019.
//  Copyright © 2019 Groupe MINASTE. All rights reserved.
//

import Foundation
import Intents

class CarrierIntentHandler: NSObject, CarrierIntentHandling, IllegalRoamingIntentHandling, GetCurrentMCCIntentHandling, GetCurrentMNCIntentHandling, GetSimMCCIntentHandling, GetSimMNCIntentHandling, GetCurrentCarrierIntentHandling, GetSimCarrierIntentHandling {
    
    
    static func donateInteraction() {
        let carrierIntent = CarrierIntent()
        let roamingIntent = IllegalRoamingIntent()
        let mccIntent = GetCurrentMCCIntent()
        let mncIntent = GetCurrentMNCIntent()
        let simMccIntent = GetSimMCCIntent()
        let simMncIntent = GetSimMNCIntent()
        let currentCarrierIntent = GetCurrentCarrierIntent()
        let simCarrierIntent = GetSimCarrierIntent()
        
        let interaction = INInteraction(intent: carrierIntent, response: nil)
        let interaction2 = INInteraction(intent: roamingIntent, response: nil)
        let interaction3 = INInteraction(intent: mccIntent, response: nil)
        let interaction4 = INInteraction(intent: mncIntent, response: nil)
        let interaction5 = INInteraction(intent: simMccIntent, response: nil)
        let interaction6 = INInteraction(intent: simMncIntent, response: nil)
        let interaction7 = INInteraction(intent: currentCarrierIntent, response: nil)
        let interaction8 = INInteraction(intent: simCarrierIntent, response: nil)
        
        interaction.donate { error in
        
        if let error = error {
            print(error.localizedDescription)
        }
        }
        
        interaction2.donate { error in
        
        if let error = error {
            print(error.localizedDescription)
        }
        }
        
        interaction3.donate { error in
        
        if let error = error {
            print(error.localizedDescription)
        }
        }
        
        interaction4.donate { error in
        
        if let error = error {
            print(error.localizedDescription)
        }
        }
        
        interaction5.donate { error in
        
        if let error = error {
            print(error.localizedDescription)
        }
        }
        
        interaction6.donate { error in
        
        if let error = error {
            print(error.localizedDescription)
        }
        }
        
        interaction7.donate { error in
        
        if let error = error {
            print(error.localizedDescription)
        }
        }
        
        interaction8.donate { error in
        
        if let error = error {
            print(error.localizedDescription)
        }
        }
        
        print("Donated Intents!")
    }
    
    func handle(intent: CarrierIntent, completion: @escaping (CarrierIntentResponse) -> Void) {

        RoamingManager.engine(g3engine: true) { result in
            
            var performOperations = false
            
            if result == "HPLUS" || result == "WCDMA" || result == "EDGE" {
                performOperations = true
            } else if result == "POSSHPLUS" {
                NotificationManager.sendNotification(for: .alertPossibleHPlus)
            } else if result == "POSSWCDMA" {
                NotificationManager.sendNotification(for: .alertPossibleWCDMA)
            }
            
            completion(CarrierIntentResponse.success(carrier: performOperations ? 1 : 0))
        }
        }
    
    func handle(intent: IllegalRoamingIntent, completion: @escaping (IllegalRoamingIntentResponse) -> Void) {

        RoamingManager.checkDataDisabled { result in
            
            if result == true {
                let dataManager = DataManager()
                let country = CarrierIdentification.getIsoCountryCode(String(dataManager.connectedMCC), String(dataManager.connectedMNC)).uppercased()
                    NotificationManager.sendNotification(for: .alertDataDrainG3, with: "data_drain_notification_description_g3".localized().format([dataManager.carrier, country]))
            }
        
            completion(IllegalRoamingIntentResponse.success(roaming: result ? 1 : 0))
        }
    }
    
    func handle(intent: GetCurrentMCCIntent, completion: @escaping (GetCurrentMCCIntentResponse) -> Void) {
        let dataManager = DataManager()
        
        let mcc = dataManager.connectedMCC
        completion(GetCurrentMCCIntentResponse.success(mcc: mcc))
    }
    
    func handle(intent: GetCurrentMNCIntent, completion: @escaping (GetCurrentMNCIntentResponse) -> Void) {
        let dataManager = DataManager()
        
        let mnc = dataManager.connectedMNC
        completion(GetCurrentMNCIntentResponse.success(mnc: mnc))
    }
    
    func handle(intent: GetSimMCCIntent, completion: @escaping (GetSimMCCIntentResponse) -> Void) {
        let dataManager = DataManager()
        
        let mcc = dataManager.targetMCC
        completion(GetSimMCCIntentResponse.success(mcc: mcc))
    }
    
    func handle(intent: GetSimMNCIntent, completion: @escaping (GetSimMNCIntentResponse) -> Void) {
        let dataManager = DataManager()
        
        let mnc = dataManager.targetMNC
        completion(GetSimMNCIntentResponse.success(mnc: mnc))
    }
    
    func handle(intent: GetCurrentCarrierIntent, completion: @escaping (GetCurrentCarrierIntentResponse) -> Void) {
        let dataManager = DataManager()
        
        let carrier = dataManager.carrier
        completion(GetCurrentCarrierIntentResponse.success(carrier: carrier))
    }
    
    func handle(intent: GetSimCarrierIntent, completion: @escaping (GetSimCarrierIntentResponse) -> Void) {
        let dataManager = DataManager()
        
        let carrier = dataManager.carrierName
        completion(GetSimCarrierIntentResponse.success(carrier: carrier))
    }
    
}
