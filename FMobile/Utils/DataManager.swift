//
//  DataManager.swift
//  FMobile
//
//  Created by Nathan FALLET on 31/03/2019.
//  Copyright © 2019 Groupe MINASTE. All rights reserved.
//

import Foundation
import CoreTelephony
import SystemConfiguration.CaptiveNetwork
import CallKit
import UIKit

class DataManager {
    
    // Configuration
    let datas = UserDefaults(suiteName: "group.fr.plugn.fmobile") ?? Foundation.UserDefaults.standard
    var modeRadin = false
    var allow015G = true
    var allow014G = true
    var allow013G = true
    var allow012G = true
    var femtoLOWDATA = false
    var femto = true
    var verifyonwifi = false
    var coveragemap = false
    var stopverification = false
    var timecode = Date()
    var g3timecode = Date()
    var lastnet = ""
    var g3lastcompletion = "HOME"
    var count = 0
    var wasEnabled = 0
    var perfmode = false
    var didChangeSettings = false
    var ntimer = Date().addingTimeInterval(-15 * 60)
    var dispInfoNotif = false
    var allowCountryDetection = true
    var timeLastCountry = Date().addingTimeInterval(-70 * 60)
    var lastCountry = "FR"
    var url = "http://raccourcis.ios.free.fr/fmobile/speedtest/nrcheck.rnd"
    var urlst = "http://raccourcis.ios.free.fr/fmobile/speedtest/speedtest.rnd"
    var modeExpert = false
    var statisticsAgreement = false
    var syncNewSIM = Date().addingTimeInterval(30)
    var isSettingUp = false
    var coverageLowData = false
    var bluetoothOff = false
    var wifiOff = false
    
    var sim = FMNetwork(type: .sim)
    var esim = FMNetwork(type: .esim)
    var current = FMNetwork(type: .current)
    var simtrays = [FMNetwork]()
    var airplanemode = false
    
    init() {
        // Lecture des valeurs depuis la config
        print(Locale.current.languageCode ?? "...")
        if let modeRadin = datas.value(forKey: "modeRadin") as? Bool, Locale.current.languageCode == "fr" {
            self.modeRadin = modeRadin
        }
        if let allow013G = datas.value(forKey: "allow013G") as? Bool {
            self.allow013G = allow013G
        }
        if let allow012G = datas.value(forKey: "allow012G") as? Bool {
            self.allow012G = allow012G
        }
        if let allow014G = datas.value(forKey: "allow014G") as? Bool {
            self.allow014G = allow014G
        }
        if let allow015G = datas.value(forKey: "allow015G") as? Bool {
            self.allow015G = allow015G
        }
        if let femtoLOWDATA = datas.value(forKey: "femtoLOWDATA") as? Bool {
            self.femtoLOWDATA = femtoLOWDATA
        }
        if let femto = datas.value(forKey: "femto") as? Bool {
            self.femto = femto
        }
        if let verifyonwifi = datas.value(forKey: "verifyonwifi") as? Bool {
            self.verifyonwifi = verifyonwifi
        }
        if let coveragemap = datas.value(forKey: "coveragemap") as? Bool {
            self.coveragemap = coveragemap
        }
        if let stopverification = datas.value(forKey: "stopverification") as? Bool {
            self.stopverification = stopverification
        }
        if let timecode = datas.value(forKey: "timecode") as? Date {
            self.timecode = timecode
        }
        if let g3timecode = datas.value(forKey: "g3timecode") as? Date {
            self.g3timecode = g3timecode
        }
        if let lastnet = datas.value(forKey: "lastnet") as? String {
            self.lastnet = lastnet
        }
        if let g3lastcompletion = datas.value(forKey: "g3lastcompletion") as? String {
            self.g3lastcompletion = g3lastcompletion
        }
        if let count = datas.value(forKey: "count") as? Int {
            self.count = count
        }
        if let wasEnabled = datas.value(forKey: "wasEnabled") as? Int {
            self.wasEnabled = wasEnabled
        }
        if let perfmode = datas.value(forKey: "perfmode") as? Bool {
            self.perfmode = perfmode
        }
        if let didChangeSettings = datas.value(forKey: "didChangeSettings") as? Bool {
            self.didChangeSettings = didChangeSettings
        }
        if let ntimer = datas.value(forKey: "NTimer") as? Date {
            self.ntimer = ntimer
        }
        if let dispInfoNotif = datas.value(forKey: "dispInfoNotif") as? Bool {
            self.dispInfoNotif = dispInfoNotif
        }
        if let allowCountryDetection = datas.value(forKey: "allowCountryDetection") as? Bool {
            self.allowCountryDetection = allowCountryDetection
        }
        if let timeLastCountry = datas.value(forKey: "timeLastCountry") as? Date {
            self.timeLastCountry = timeLastCountry
        }
        if let lastCountry = datas.value(forKey: "lastCountry") as? String {
            self.lastCountry = lastCountry
        }
        if let url = datas.value(forKey: "URL") as? String {
            self.url = url
        }
        if let urlst = datas.value(forKey: "URLST") as? String {
            self.urlst = urlst
        }
        if let modeExpert = datas.value(forKey: "modeExpert") as? Bool {
            self.modeExpert = modeExpert
        }
        if let bluetoothOff = datas.value(forKey: "bluetoothOff") as? Bool {
            self.bluetoothOff = bluetoothOff
        }
        if let wifiOff = datas.value(forKey: "wifiOff") as? Bool {
            self.wifiOff = wifiOff
        }
        if let statisticsAgreement = datas.value(forKey: "statisticsAgreement") as? Bool {
            self.statisticsAgreement = statisticsAgreement
        }
        if let syncNewSIM = datas.value(forKey: "syncNewSIM") as? Date {
            self.syncNewSIM = syncNewSIM
        }
        if let isSettingUp = datas.value(forKey: "isSettingUp") as? Bool {
            self.isSettingUp = isSettingUp
        }
        if let coverageLowData = datas.value(forKey: "coverageLowData") as? Bool {
            self.coverageLowData = coverageLowData
        }
//        if let registeredService = datas.value(forKey: "registeredService") as? String {
//            self.registeredService = registeredService
//        }

        
        airplanemode = DataManager.isAirplaneMode()

        if sim.card.active {
            simtrays.append(sim)
        }
        
        if esim.card.active {
            simtrays.append(esim)
        }

    }
    
    // Vérification d'un appel en cours
    static func isOnPhoneCall() -> Bool {
        if #available(iOS 10.0, *) {
            for call in CXCallObserver().calls {
                if call.hasEnded == false {
                    return true
                }
            }
        } else {
            let callCenter = CTCallCenter()
            for call in callCenter.currentCalls ?? [] {
                if call.callState == CTCallStateConnected {
                    return true
                }
            }
        }
        return false
    }
    
    // Vérification de la connexion au wifi
    static func isWifiConnected() -> Bool {
        if let interface = CNCopySupportedInterfaces() {
            for i in 0 ..< CFArrayGetCount(interface) {
                let interfaceName: UnsafeRawPointer = CFArrayGetValueAtIndex(interface, i)
                let rec = unsafeBitCast(interfaceName, to: AnyObject.self)
                if let unsafeInterfaceData = CNCopyCurrentNetworkInfo("\(rec)" as CFString), let interfaceData = unsafeInterfaceData as? [String : AnyObject] {
                    print("BSSID: \(interfaceData["BSSID"] ?? "null" as AnyObject), SSID: \(interfaceData["SSID"] ?? "null" as AnyObject), SSIDDATA: \(interfaceData["SSIDDATA"] ?? "null" as AnyObject)")
                    return true
                } else {
                    print("Not connected to wifi.")
                    return false
                }
            }
        }
        return false
    }
    
    // Même chose avec des strings
    static func showWifiConnected() -> String {
        if let interface = CNCopySupportedInterfaces() {
            for i in 0 ..< CFArrayGetCount(interface) {
                let interfaceName: UnsafeRawPointer = CFArrayGetValueAtIndex(interface, i)
                let rec = unsafeBitCast(interfaceName, to: AnyObject.self)
                if let unsafeInterfaceData = CNCopyCurrentNetworkInfo("\(rec)" as CFString), let interfaceData = unsafeInterfaceData as? [String : AnyObject] {
                    print("BSSID: \(interfaceData["BSSID"] ?? "null" as AnyObject), SSID: \(interfaceData["SSID"] ?? "null" as AnyObject), SSIDDATA: \(interfaceData["SSIDDATA"] ?? "null" as AnyObject)")
                    return interfaceData["SSID"] as? String ?? "null"
                } else {
                    print("Not connected to wifi.")
                    return "null"
                }
            }
        }
        return "null"
    }
    
    static func getShortcutURL(international: Bool = false) -> URL? {
        // NORMAL SHPRTCUTS
        let anirc12 = "shortcuts://run-shortcut?name=ANIRC12&input=text&text=NAT"
        let anirc = "shortcuts://run-shortcut?name=ANIRC"
        
        // INTERNATIONAL ROAMING SHORTCUT
        let anirc12inter = "shortcuts://run-shortcut?name=ANIRC12&input=text&text=INTER"
        
        if international {
            if #available(iOS 13.0, *) {
                if let url = URL(string: anirc) {
                    return url
                }
            } else if #available(iOS 12.0, *){
                if let url = URL(string: anirc12inter) {
                    return url
                }
            }
        } else {
            if #available(iOS 13.0, *) {
                if let url = URL(string: anirc) {
                    return url
                }
            } else if #available(iOS 12.0, *){
                if let url = URL(string: anirc12) {
                    return url
                }
            }
        }
        
        return nil
    }
    
    static func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        if let defaultRouteReachability = defaultRouteReachability {
            var flags : SCNetworkReachabilityFlags = []

            if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
                return false
            }
            
            let isReachable = flags.contains(.reachable)
            let needsConnection = flags.contains(.connectionRequired)
            return (isReachable && !needsConnection)
        }
        
        return false
    }
    
    static func isAirplaneMode() -> Bool {
        let urlairplane = URL(fileURLWithPath: "/var/preferences/SystemConfiguration/com.apple.radios.plist")
        do {
            let test: NSDictionary
            if #available(iOS 11.0, *) {
                test = try NSDictionary(contentsOf: urlairplane, error: ())
            } else {
                // Fallback on earlier versions
                test = NSDictionary(contentsOf: urlairplane) ?? NSDictionary()
            }
            let airplanemode = test["AirplaneMode"] as? Bool ?? false
            return airplanemode
        } catch {
            return false
        }
    }
    
    
    // Reset custom lists
    func resetCountryIncluded(service: FMNetwork){
        let emptyList = [String]()
        datas.set(emptyList, forKey: (service.card.type == .esim ? "e" : "") + "includedData")
        datas.set(emptyList, forKey: (service.card.type == .esim ? "e" : "") + "includedVData")
        datas.set(emptyList, forKey: (service.card.type == .esim ? "e" : "") + "includedVoice")
        datas.synchronize()
    }
    
    func zoneCheck(service: FMNetwork) -> String {
        // Current country
        let country = service.network.land
        
        // Check for unknown
        if country == "--"{
            return "UNKNOWN"
        }
        
        // Check if home
        if country == service.card.land {
            return "HOME"
        }
        
        // Check for all from config
        if service.card.countriesVData.contains(country) {
            return "ALL"
        }
        
        // Check for internet from config
        if service.card.countriesData.contains(country) {
            return "INTERNET"
        }
        
        // Check for voice from config
        if service.card.countriesVoice.contains(country) {
            return "CALLS"
        }
        
        // Check for all from custom
        if service.card.includedVData.contains(country) {
            return "ALL"
        }
        
        // Check for internet from custom
        if service.card.includedData.contains(country) {
            return "INTERNET"
        }
        
        // Check for voice from custom
        if service.card.includedVData.contains(country) {
            return "CALLS"
        }
        
        // Out of countries
        return "OUTZONE"
    }
    
    // Add a country in custom list
    func addCountryIncluded(country: String, list: Int, service: FMNetwork){
        if list == 0 {
            // Voice
            service.card.includedVoice.append(country)
            datas.set(service.card.includedVoice, forKey: service.card.type == .sim ? "includedVoice" : "eincludedVoice")
            datas.synchronize()
        } else if list == 1 {
            // Internet
            service.card.includedData.append(country)
            datas.set(service.card.includedData, forKey: service.card.type == .sim ? "includedData" : "eincludedData")
            datas.synchronize()
        } else if list == 2 {
            // All
            service.card.includedVData.append(country)
            datas.set(service.card.includedVData, forKey: service.card.type == .sim ? "includedVData" : "eincludedVData")
            datas.synchronize()
        }
    }
    
}
