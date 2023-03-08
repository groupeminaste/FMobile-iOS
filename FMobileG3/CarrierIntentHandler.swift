//
//  CarrierIntentHandler.swift
//  FMobileG3
//
//  Created by PlugN on 03/07/2019.
//  Copyright © 2019 Groupe MINASTE. All rights reserved.
//

import Foundation
import Intents
import AVFoundation

@available(iOS 12.0, *)
class CarrierIntentHandler: NSObject, CarrierIntentHandling, IllegalRoamingIntentHandling, GetCurrentMCCIntentHandling, GetCurrentMNCIntentHandling, GetSimMCCIntentHandling, GetSimMNCIntentHandling, GetCurrentCarrierIntentHandling, GetSimCarrierIntentHandling, FlightModeIntentHandling, IsWifiConnectedIntentHandling, IsNetworkConnectedIntentHandling, ShutWifiIntentHandling, ShutBluetoothIntentHandling, GetCurrentSIMMCCIntentHandling, GetCurrentSIMMNCIntentHandling, GetCurrentSIMCarrierIntentHandling, GetSIMConnectedMCCIntentHandling, GetSIMConnectedMNCIntentHandling, GetSIMConnectedCarrierIntentHandling, GetESIMMCCIntentHandling, GetESIMMNCIntentHandling, GetESIMCarrierIntentHandling, GetESIMConnectedMCCIntentHandling, GetESIMConnectedMNCIntentHandling, GetESIMConnectedCarrierIntentHandling {
    
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
        let shutWifiIntent = ShutWifiIntent()
        let shutBluetoothIntent = ShutBluetoothIntent()
        let getCurrentSIMMCC = GetCurrentSIMMCCIntent()
        let getCurrentSIMMNC = GetCurrentSIMMNCIntent()
        let getCurrentSIMCarrier = GetCurrentSIMCarrierIntent()
        let getSIMConnectedMCC = GetSIMConnectedMCCIntent()
        let getSIMConnectedMNC = GetSIMConnectedMNCIntent()
        let getSIMConnectedCarrier = GetSIMConnectedCarrierIntent()
        let getESIMMCC = GetESIMMCCIntent()
        let getESIMMNC = GetESIMMNCIntent()
        let getESIMCarrier = GetESIMCarrierIntent()
        let getESIMConnectedMCC = GetESIMConnectedMCCIntent()
        let getESIMConnectedMNC = GetESIMConnectedMNCIntent()
        let getESIMConnectedCarrier = GetESIMConnectedCarrierIntent()
        
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
        let interaction12 = INInteraction(intent: shutWifiIntent, response: ShutWifiIntentResponse())
        let interaction13 = INInteraction(intent: shutBluetoothIntent, response: ShutBluetoothIntentResponse())
        let interaction14 = INInteraction(intent: getCurrentSIMMCC, response: GetCurrentSIMMCCIntentResponse())
        let interaction15 = INInteraction(intent: getCurrentSIMMNC, response: GetCurrentSIMMNCIntentResponse())
        let interaction16 = INInteraction(intent: getCurrentSIMCarrier, response: GetCurrentSIMCarrierIntentResponse())
        let interaction17 = INInteraction(intent: getSIMConnectedMCC, response: GetSIMConnectedMCCIntentResponse())
        let interaction18 = INInteraction(intent: getSIMConnectedMNC, response: GetSIMConnectedMNCIntentResponse())
        let interaction19 = INInteraction(intent: getSIMConnectedCarrier, response: GetSIMConnectedCarrierIntentResponse())
        let interaction20 = INInteraction(intent: getESIMMCC, response: GetESIMMCCIntentResponse())
        let interaction21 = INInteraction(intent: getESIMMNC, response: GetESIMMNCIntentResponse())
        let interaction22 = INInteraction(intent: getESIMCarrier, response: GetESIMCarrierIntentResponse())
        let interaction23 = INInteraction(intent: getESIMConnectedMCC, response: GetESIMConnectedMCCIntentResponse())
        let interaction24 = INInteraction(intent: getESIMConnectedMNC, response: GetESIMConnectedMNCIntentResponse())
        let interaction25 = INInteraction(intent: getESIMConnectedCarrier, response: GetESIMConnectedCarrierIntentResponse())
        
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
        
        interaction12.donate { error in
        
        if let error = error {
            print(error.localizedDescription)
        }
        }
        
        interaction13.donate { error in
        
        if let error = error {
            print(error.localizedDescription)
        }
        }
        
        interaction14.donate { error in
        
        if let error = error {
            print(error.localizedDescription)
        }
        }
        
        interaction15.donate { error in
        
        if let error = error {
            print(error.localizedDescription)
        }
        }
        
        interaction16.donate { error in
        
        if let error = error {
            print(error.localizedDescription)
        }
        }
        
        interaction17.donate { error in
        
        if let error = error {
            print(error.localizedDescription)
        }
        }
        
        interaction18.donate { error in
        
        if let error = error {
            print(error.localizedDescription)
        }
        }
        
        interaction19.donate { error in
        
        if let error = error {
            print(error.localizedDescription)
        }
        }
        
        interaction20.donate { error in
        
        if let error = error {
            print(error.localizedDescription)
        }
        }
        
        interaction21.donate { error in
        
        if let error = error {
            print(error.localizedDescription)
        }
        }
        
        interaction22.donate { error in
        
        if let error = error {
            print(error.localizedDescription)
        }
        }
        
        interaction23.donate { error in
        
        if let error = error {
            print(error.localizedDescription)
        }
        }
        
        interaction24.donate { error in
        
        if let error = error {
            print(error.localizedDescription)
        }
        }
        
        interaction25.donate { error in
        
        if let error = error {
            print(error.localizedDescription)
        }
        }
        
        print("Donated Intents!")
    }
    
    func handle(intent: CarrierIntent, completion: @escaping (CarrierIntentResponse) -> Void) {
        
        let dataManager = DataManager()
        var performOperations = false
        
        RoamingManager.engine(g3engine: true, service: dataManager.current) { result in
            
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
        let dataManager = DataManager()
        DataManager.getCurrentWifi { (wifi) in
            let result = RoamingManager.directDataDCheck(service: dataManager.current, wifi: wifi)
            
            if result {
                let country = dataManager.current.network.land
                NotificationManager.sendNotification(for: .alertDataDrainG3, with: "data_drain_notification_description_g3".localized().format([dataManager.current.network.name, country]))
            }
            
            completion(IllegalRoamingIntentResponse.success(roaming: result ? 1 : 0))
        }
    }
    
    func handle(intent: GetCurrentMCCIntent, completion: @escaping (GetCurrentMCCIntentResponse) -> Void) {
        let dataManager = DataManager()
        
        let mcc = dataManager.current.network.mcc
        completion(GetCurrentMCCIntentResponse.success(mcc: mcc))
    }
    
    func handle(intent: GetCurrentMNCIntent, completion: @escaping (GetCurrentMNCIntentResponse) -> Void) {
        let dataManager = DataManager()
        
        let mnc = dataManager.current.network.mnc
        completion(GetCurrentMNCIntentResponse.success(mnc: mnc))
    }
    
    func handle(intent: GetCurrentCarrierIntent, completion: @escaping (GetCurrentCarrierIntentResponse) -> Void) {
        let dataManager = DataManager()
        
        let carrier = dataManager.current.network.name
        completion(GetCurrentCarrierIntentResponse.success(carrier: carrier))
    }
    
    func handle(intent: GetSimMCCIntent, completion: @escaping (GetSimMCCIntentResponse) -> Void) {
        let dataManager = DataManager()
        
        
        
        let mcc = dataManager.sim.card.mcc
        completion(GetSimMCCIntentResponse.success(mcc: mcc))
    }
    
    func handle(intent: GetSimMNCIntent, completion: @escaping (GetSimMNCIntentResponse) -> Void) {
        let dataManager = DataManager()
        
        let mnc = dataManager.sim.card.mnc
        completion(GetSimMNCIntentResponse.success(mnc: mnc))
    }
    
    func handle(intent: GetSimCarrierIntent, completion: @escaping (GetSimCarrierIntentResponse) -> Void) {
        let dataManager = DataManager()
        
        let carrier = dataManager.sim.network.name
        completion(GetSimCarrierIntentResponse.success(carrier: carrier))
    }
    
    func handle(intent: FlightModeIntent, completion: @escaping (FlightModeIntentResponse) -> Void) {
        let flightMode = DataManager.isAirplaneMode()
        
        completion(FlightModeIntentResponse.success(flightMode: flightMode ? 1 : 0))
    }
    
    func handle(intent: IsWifiConnectedIntent, completion: @escaping (IsWifiConnectedIntentResponse) -> Void) {
        DataManager.getCurrentWifi { (wifi) in
            completion(IsWifiConnectedIntentResponse.success(wifi: wifi != nil ? 1 : 0))
        }
    }
    
    func handle(intent: IsNetworkConnectedIntent, completion: @escaping (IsNetworkConnectedIntentResponse) -> Void) {
        let cellular = DataManager.isConnectedToNetwork()
        
        completion(IsNetworkConnectedIntentResponse.success(cellular: cellular ? 1 : 0))
    }
    
    func handle(intent: ShutWifiIntent, completion: @escaping (ShutWifiIntentResponse) -> Void) {
        let dataManager = DataManager()
        
        completion(ShutWifiIntentResponse.success(wifiOff: dataManager.wifiOff ? 1 : 0))
    }
    
    func handle(intent: ShutBluetoothIntent, completion: @escaping (ShutBluetoothIntentResponse) -> Void) {
        let dataManager = DataManager()
        
        completion(ShutBluetoothIntentResponse.success(bluetoothOff: dataManager.bluetoothOff ? 1 : 0))
    }
    
    func handle(intent: GetCurrentSIMMCCIntent, completion: @escaping (GetCurrentSIMMCCIntentResponse) -> Void) {
        let dataManager = DataManager()
        
        let mcc = dataManager.current.card.mcc
        completion(GetCurrentSIMMCCIntentResponse.success(mcc: mcc))
    }
    
    func handle(intent: GetCurrentSIMMNCIntent, completion: @escaping (GetCurrentSIMMNCIntentResponse) -> Void) {
        let dataManager = DataManager()
        
        let mnc = dataManager.current.card.mnc
        completion(GetCurrentSIMMNCIntentResponse.success(mnc: mnc))
    }
    
    func handle(intent: GetCurrentSIMCarrierIntent, completion: @escaping (GetCurrentSIMCarrierIntentResponse) -> Void) {
        let dataManager = DataManager()
        
        let carrier = dataManager.current.card.name
        completion(GetCurrentSIMCarrierIntentResponse.success(carrier: carrier))
    }
    
    func handle(intent: GetSIMConnectedMCCIntent, completion: @escaping (GetSIMConnectedMCCIntentResponse) -> Void) {
        let dataManager = DataManager()
        
        let mcc = dataManager.sim.network.mcc
        completion(GetSIMConnectedMCCIntentResponse.success(mcc: mcc))
    }
    
    func handle(intent: GetSIMConnectedMNCIntent, completion: @escaping (GetSIMConnectedMNCIntentResponse) -> Void) {
        let dataManager = DataManager()
        
        let mnc = dataManager.sim.network.mnc
        completion(GetSIMConnectedMNCIntentResponse.success(mnc: mnc))
    }
    
    func handle(intent: GetSIMConnectedCarrierIntent, completion: @escaping (GetSIMConnectedCarrierIntentResponse) -> Void) {
        let dataManager = DataManager()
        
        let carrier = dataManager.sim.network.name
        completion(GetSIMConnectedCarrierIntentResponse.success(carrier: carrier))
    }
    
    func handle(intent: GetESIMMCCIntent, completion: @escaping (GetESIMMCCIntentResponse) -> Void) {
        let dataManager = DataManager()
        
        let mcc = dataManager.esim.network.mcc
        completion(GetESIMMCCIntentResponse.success(mcc: mcc))
    }
    
    func handle(intent: GetESIMMNCIntent, completion: @escaping (GetESIMMNCIntentResponse) -> Void) {
        let dataManager = DataManager()
        
        let mnc = dataManager.esim.network.mnc
        completion(GetESIMMNCIntentResponse.success(mnc: mnc))
    }
    
    func handle(intent: GetESIMCarrierIntent, completion: @escaping (GetESIMCarrierIntentResponse) -> Void) {
        let dataManager = DataManager()
        
        let carrier = dataManager.esim.network.name
        completion(GetESIMCarrierIntentResponse.success(carrier: carrier))
    }
    
    func handle(intent: GetESIMConnectedMCCIntent, completion: @escaping (GetESIMConnectedMCCIntentResponse) -> Void) {
        let dataManager = DataManager()
        
        let mcc = dataManager.esim.network.mcc
        completion(GetESIMConnectedMCCIntentResponse.success(mcc: mcc))
    }
    
    func handle(intent: GetESIMConnectedMNCIntent, completion: @escaping (GetESIMConnectedMNCIntentResponse) -> Void) {
        let dataManager = DataManager()
        
        let mnc = dataManager.esim.network.mnc
        completion(GetESIMConnectedMNCIntentResponse.success(mnc: mnc))
    }
    
    func handle(intent: GetESIMConnectedCarrierIntent, completion: @escaping (GetESIMConnectedCarrierIntentResponse) -> Void) {
        let dataManager = DataManager()
        
        let carrier = dataManager.esim.network.name
        completion(GetESIMConnectedCarrierIntentResponse.success(carrier: carrier))
    }
    
}
