//
//  CarrierIntentHandler.swift
//  FMobileG3
//
//  Created by PlugN on 03/07/2019.
//  Copyright © 2019 Groupe MINASTE. All rights reserved.
//

import Foundation
import Intents

@available(iOS 12.0, *)
class CarrierIntentHandler: NSObject, CarrierIntentHandling, IllegalRoamingIntentHandling, GetCurrentMCCIntentHandling, GetCurrentMNCIntentHandling, GetSimMCCIntentHandling, GetSimMNCIntentHandling, GetCurrentCarrierIntentHandling, GetSimCarrierIntentHandling, FlightModeIntentHandling, IsWifiConnectedIntentHandling, IsNetworkConnectedIntentHandling {
    
    static func deleteInteraction() {
        INInteraction.deleteAll { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        print("Deleted Intents!")
    }
    
    static func donateInteraction() {
        let carrierIntent = CarrierIntent()
        let roamingIntent = IllegalRoamingIntent()
        let mccIntent = GetCurrentMCCIntent()
        let mncIntent = GetCurrentMNCIntent()
        let simMccIntent = GetSimMCCIntent()
        let simMncIntent = GetSimMNCIntent()
        let currentCarrierIntent = GetCurrentCarrierIntent()
        let simCarrierIntent = GetSimCarrierIntent()
        let flightModeIntent = FlightModeIntent()
        let isWifiConnectedIntent = IsWifiConnectedIntent()
        let isNetworkConnectedIntent = IsNetworkConnectedIntent()
        
        let interaction = INInteraction(intent: carrierIntent, response: CarrierIntentResponse())
        let interaction2 = INInteraction(intent: roamingIntent, response: IllegalRoamingIntentResponse())
        let interaction3 = INInteraction(intent: mccIntent, response: GetCurrentMCCIntentResponse())
        let interaction4 = INInteraction(intent: mncIntent, response: GetCurrentMNCIntentResponse())
        let interaction5 = INInteraction(intent: simMccIntent, response: GetSimMCCIntentResponse())
        let interaction6 = INInteraction(intent: simMncIntent, response: GetSimMNCIntentResponse())
        let interaction7 = INInteraction(intent: currentCarrierIntent, response: GetCurrentCarrierIntentResponse())
        let interaction8 = INInteraction(intent: simCarrierIntent, response: GetSimCarrierIntentResponse())
        let interaction9 = INInteraction(intent: flightModeIntent, response: FlightModeIntentResponse())
        let interaction10 = INInteraction(intent: isWifiConnectedIntent, response: IsWifiConnectedIntentResponse())
        let interaction11 = INInteraction(intent: isNetworkConnectedIntent, response: IsNetworkConnectedIntentResponse())
        
        
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
        
        interaction9.donate { error in
        
        if let error = error {
            print(error.localizedDescription)
        }
        }
        
        interaction10.donate { error in
        
        if let error = error {
            print(error.localizedDescription)
        }
        }
        
        interaction11.donate { error in
        
        if let error = error {
            print(error.localizedDescription)
        }
        }
        
        
        print("Donated Intents!")
    }
    
    func handle(intent: CarrierIntent, completion: @escaping (CarrierIntentResponse) -> Void) {

        RoamingManager.engine(g3engine: true) { result in
            
            var performOperations = false
            
            if result == "LTE" || result == "HPLUS" || result == "WCDMA" || result == "EDGE" {
                performOperations = true
            } else if result == "POSSHPLUS" {
                NotificationManager.sendNotification(for: .alertPossibleHPlus)
            } else if result == "POSSWCDMA" {
                NotificationManager.sendNotification(for: .alertPossibleWCDMA)
            } else if result == "POSSLTE" {
                NotificationManager.sendNotification(for: .alertPossibleLTE)
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
    
    func handle(intent: FlightModeIntent, completion: @escaping (FlightModeIntentResponse) -> Void) {
        let flightMode = DataManager.isAirplaneMode()
        
        completion(FlightModeIntentResponse.success(flightMode: flightMode ? 1 : 0))
    }
    
    func handle(intent: IsWifiConnectedIntent, completion: @escaping (IsWifiConnectedIntentResponse) -> Void) {
        let wifi = DataManager.isWifiConnected()
        
        completion(IsWifiConnectedIntentResponse.success(wifi: wifi ? 1 : 0))
    }
    
    func handle(intent: IsNetworkConnectedIntent, completion: @escaping (IsNetworkConnectedIntentResponse) -> Void) {
        let cellular = DataManager.isConnectedToNetwork()
        
        completion(IsNetworkConnectedIntentResponse.success(cellular: cellular ? 1 : 0))
    }
    
}
