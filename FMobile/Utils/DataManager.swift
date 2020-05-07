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
    let datas = Foundation.UserDefaults.standard
    var modeRadin = false
    var allow013G = true
    var allow012G = true
    var femtoLOWDATA = false
    var femto = true
    var verifyonwifi = false
    var stopverification = false
    var timecode = Date()
    var lastnet = ""
    var count = 0
    var wasEnabled = false
    var isRunning = false
    var lowbat = false
    var didChangeSettings = false
    var ntimer = Date().addingTimeInterval(-15 * 60)
    var dispInfoNotif = true
    var allowCountryDetection = true
    var timeLastCountry = Date().addingTimeInterval(-70 * 60)
    var lastCountry = "FR"
    var url = "http://test-debit.free.fr/512.rnd"
    var urlst = "http://test-debit.free.fr/1048576.rnd"
    var setupDone = false
    var minimalSetup = true
    
    // Carrier vars
    var simData = String()
    var currentNetwork = String()
    var carrier = String()
    var mycarrier: CTCarrier
    var mycarrier2: CTCarrier
    var carrierNetwork = String()
    var carrierNetwork2 = String()
    var carrierName = String()
    
    // Carrier setup
    var hp = "WCDMA"
    var nrp = "HSDPA"
    var targetMCC = "208"
    var targetMNC = "15"
    var itiMNC = "01"
    var nrDEC = true
    var out2G = "yes"
    var chasedMNC = ""
    var connectedMCC = ""
    var connectedMNC = ""
    var ipadMCC = ""
    var ipadMNC = ""
    var itiName = "Orange F"
    var homeName = "Free"
    var stms = 0.768
    
    init() {
        if datas.value(forKey: "modeRadin") != nil {
            modeRadin = datas.value(forKey: "modeRadin") as? Bool ?? false
        }
        if datas.value(forKey: "allow013G") != nil {
            allow013G = datas.value(forKey: "allow013G") as? Bool ?? true
        }
        if datas.value(forKey: "allow012G") != nil {
            allow012G = datas.value(forKey: "allow012G") as? Bool ?? true
        }
        if datas.value(forKey: "femtoLOWDATA") != nil {
            femtoLOWDATA = datas.value(forKey: "femtoLOWDATA") as? Bool ?? false
        }
        if datas.value(forKey: "femto") != nil {
            femto = datas.value(forKey: "femto") as? Bool ?? true
        }
        if datas.value(forKey: "verifyonwifi") != nil {
            verifyonwifi = datas.value(forKey: "verifyonwifi") as? Bool ?? false
        }
        if datas.value(forKey: "stopverification") != nil {
            stopverification = datas.value(forKey: "stopverification") as? Bool ?? false
        }
        if datas.value(forKey: "timecode") != nil {
            timecode = datas.value(forKey: "timecode") as? Date ?? Date()
        }
        if datas.value(forKey: "lastnet") != nil {
            lastnet = datas.value(forKey: "lastnet") as? String ?? ""
        }
        if datas.value(forKey: "count") != nil {
            count = datas.value(forKey: "count") as? Int ?? 0
        }
        if datas.value(forKey: "wasEnabled") != nil {
            wasEnabled = datas.value(forKey: "wasEnabled") as? Bool ?? false
        }
        if datas.value(forKey: "isRunning") != nil {
            isRunning = datas.value(forKey: "isRunning") as? Bool ?? false
        }
        if datas.value(forKey: "lowbat") != nil {
            lowbat = datas.value(forKey: "lowbat") as? Bool ?? false
        }
        if datas.value(forKey: "didChangeSettings") != nil {
            didChangeSettings = datas.value(forKey: "didChangeSettings") as? Bool ?? false
        }
        if datas.value(forKey: "NTimer") != nil {
            ntimer = datas.value(forKey: "NTimer") as? Date ?? Date().addingTimeInterval(-15 * 60)
        }
        if datas.value(forKey: "dispInfoNotif") != nil {
            dispInfoNotif = datas.value(forKey: "dispInfoNotif") as? Bool ?? true
        }
        if datas.value(forKey: "allowCountryDetection") != nil {
            femto = datas.value(forKey: "allowCountryDetection") as? Bool ?? true
        }
        if datas.value(forKey: "timeLastCountry") != nil {
            timeLastCountry = datas.value(forKey: "timeLastCountry") as? Date ?? Date().addingTimeInterval(-70 * 60)
        }
        if datas.value(forKey: "lastCountry") != nil {
            lastCountry = datas.value(forKey: "lastCountry") as? String ?? "FR"
        }
        if(datas.value(forKey: "HP") != nil){
            hp = datas.value(forKey: "HP") as? String ?? "WCDMA"
        }
        if(datas.value(forKey: "NRP") != nil){
            nrp = datas.value(forKey: "NRP") as? String ?? "HSDPA"
        }
        if(datas.value(forKey: "MCC") != nil){
            targetMCC = datas.value(forKey: "MCC") as? String ?? "208"
        }
        if(datas.value(forKey: "MNC") != nil){
            targetMNC = datas.value(forKey: "MNC") as? String ?? "15"
        }
        if(datas.value(forKey: "ITIMNC") != nil){
            itiMNC = datas.value(forKey: "ITIMNC") as? String ?? "01"
        }
        if(datas.value(forKey: "OUT2G") != nil){
            out2G = datas.value(forKey: "OUT2G") as? String ?? "yes"
        }
        if(datas.value(forKey: "ITINAME") != nil){
            itiName = datas.value(forKey: "ITINAME") as? String ?? "Orange F"
        }
        if(datas.value(forKey: "HOMENAME") != nil){
            homeName = datas.value(forKey: "HOMENAME") as? String ?? "Free"
        }
        if(datas.value(forKey: "STMS") != nil){
            stms = datas.value(forKey: "STMS") as? Double ?? 0.768
        }
        if(datas.value(forKey: "URL") != nil){
            url = datas.value(forKey: "URL") as? String ?? "http://test-debit.free.fr/512.rnd"
        }
        if(datas.value(forKey: "URLST") != nil){
            urlst = datas.value(forKey: "URLST") as? String ?? "http://test-debit.free.fr/1048576.rnd"
        }
        if(datas.value(forKey: "setupDone") != nil){
            setupDone = datas.value(forKey: "setupDone") as? Bool ?? false
        }
        if(datas.value(forKey: "minimalSetup") != nil){
            minimalSetup = datas.value(forKey: "minimalSetup") as? Bool ?? true
        }

        
        let operatorPListSymLinkPath = "/var/mobile/Library/Preferences/com.apple.operator.plist"
        let carrierPListSymLinkPath = "/var/mobile/Library/Preferences/com.apple.carrier.plist"
        
        // Déclaration du gestionaire de fichiers
        let fileManager = FileManager.default
        let operatorPListPath = try? fileManager.destinationOfSymbolicLink(atPath: operatorPListSymLinkPath)
        print(operatorPListPath ?? "UNKNOWN")
        
        
        // Obtenir le fichier de configuration de la carte SIM
        let carrierPListPath = try? fileManager.destinationOfSymbolicLink(atPath: carrierPListSymLinkPath)
        print(carrierPListPath ?? "UNKNOWN")
        
        if !(carrierPListPath ?? "unknown").lowercased().contains("unknown") {
            let convertedCarrierPListPath = carrierPListPath?.trimmingCharacters(in: CharacterSet(charactersIn: "1234567890").inverted)
            print(convertedCarrierPListPath ?? "UNKNOWN")
            
            simData = (convertedCarrierPListPath as NSString?)?.substring(to: 5) ?? "No SIM card"
        } else {
            simData = "-----"
        }
        
        if !(operatorPListPath ?? "unknown").lowercased().contains("unknown"){
            let convertedOperatorPListPath = operatorPListPath?.trimmingCharacters(in: CharacterSet(charactersIn: "1234567890").inverted)
            print(convertedOperatorPListPath ?? "UNKNOWN")
            currentNetwork = (convertedOperatorPListPath as NSString?)?.substring(to: 5) ?? "-----"
        } else {
            currentNetwork = "-----"
        }
        
        
        let test = NSMutableDictionary(contentsOfFile: operatorPListPath ?? "Error")
        let array = test?["StatusBarImages"] as? NSArray ?? NSArray.init(array: [0])
        let secondDict = NSMutableDictionary(dictionary: array[0] as? Dictionary ?? NSMutableDictionary.init() as? Dictionary<AnyHashable, Any> ?? Dictionary.init())
        
        carrier = (secondDict["StatusBarCarrierName"] as? String) ?? "Carrier"
        
        connectedMCC = String(currentNetwork.prefix(3))
        connectedMNC = String(currentNetwork.suffix(2))
        
        mycarrier = CTCarrier.init()
        mycarrier2 = CTCarrier.init()
        
        let info = CTTelephonyNetworkInfo()
        
        var simnum = 0
        for (service, carrier) in info.serviceSubscriberCellularProviders ?? [:] {
            simnum += 1
            if simnum == 1{
                mycarrier = carrier
                carrierNetwork = info.serviceCurrentRadioAccessTechnology?[service] ?? ""
            } else if simnum == 2 {
                mycarrier2 = carrier
                carrierNetwork2 = info.serviceCurrentRadioAccessTechnology?[service] ?? ""
            }
            let radio = info.serviceCurrentRadioAccessTechnology?[service] ?? ""
            print("For Carrier " + (carrier.carrierName ?? "null") + ", got " + radio)
            print(service)
        }
        
        
        
        if mycarrier2.mobileCountryCode == targetMCC && mycarrier2.mobileNetworkCode == targetMNC {
            swap(&mycarrier2, &mycarrier)
            swap(&carrierNetwork2, &carrierNetwork)
        }
        
        print(carrierNetwork)
        
        carrierName = mycarrier.carrierName ?? "Carrier"
        
        ipadMCC = connectedMCC
        ipadMNC = connectedMNC
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            
            if (connectedMCC == "---" && connectedMNC == "--"){
                connectedMCC = mycarrier.mobileCountryCode ?? "---"
                connectedMNC = mycarrier.mobileNetworkCode ?? "--"
                
                if (connectedMCC != "---" && connectedMNC != "--"){
                    carrier = homeName
                }
            }
            
            if connectedMCC == targetMCC && connectedMNC == targetMNC && carrierName == "Carrier" {
                carrierName = homeName
            }
            
        }
        
        
        nrDEC = self.isNRDEC()
        print("nrDEC: \(nrDEC)")
        
        if nrDEC {
            chasedMNC = targetMNC
        } else {
            chasedMNC = itiMNC
        }
        
    }
    
    static func isOnPhoneCall() -> Bool {
        for call in CXCallObserver().calls {
            if call.hasEnded == false {
                return true
            }
        }
        return false
    }
    
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
    
    
    static func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags : SCNetworkReachabilityFlags = []
        
        if defaultRouteReachability == nil {
            return false
        }
        
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
    
    static func isEligibleForMinimalSetup() -> Bool {
        let carrierPListSymLinkPath = "/var/mobile/Library/Preferences/com.apple.carrier.plist"
        
        // Déclaration du gestionaire de fichiers
        let fileManager = FileManager.default
        
        // Obtenir le fichier de configuration de la carte SIM
        let carrierPListPath = try? fileManager.destinationOfSymbolicLink(atPath: carrierPListSymLinkPath)
        
        let test = NSMutableDictionary(contentsOfFile: carrierPListPath ?? "Error")
        let array = test?["SupportedPLMNs"] as? NSArray ?? NSArray.init(array: [0])
        
        if array.count <= 1 {
            return true
        } else {
            return false
        }
    }
    
    func isNRDEC() -> Bool {
        var valueToReturn = false
        
        if simData != "-----" && setupDone {
            let carrierPListSymLinkPath = "/var/mobile/Library/Preferences/com.apple.carrier.plist"
            
            // Déclaration du gestionaire de fichiers
            let fileManager = FileManager.default
            
            // Obtenir le fichier de configuration de la carte SIM
            let carrierPListPath = try? fileManager.destinationOfSymbolicLink(atPath: carrierPListSymLinkPath)
            
            let test = NSMutableDictionary(contentsOfFile: carrierPListPath ?? "Error")
            let array = test?["SupportedPLMNs"] as? NSArray ?? NSArray.init(array: [0])
            
            for index in 0..<array.count {
                let value = array[index] as? String ?? "-----"
                let plmnmcc = value.prefix(3)
                let plmnmnc = value.suffix(2)
                
                if plmnmcc == targetMCC && plmnmnc == itiMNC {
                    valueToReturn = true
                }
            }
        }
        return valueToReturn
    }
    
}
