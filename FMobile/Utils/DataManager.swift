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
    var url = "http://test-debit.free.fr/512.rnd"
    var urlst = "http://test-debit.free.fr/1048576.rnd"
    var setupDone = false
    var minimalSetup = true
    var modeExpert = false
    var statisticsAgreement = false
    var syncNewSIM = Date().addingTimeInterval(30)
    
    // Carrier vars
    var simData = String()
    var currentNetwork = String()
    var carrier = String()
    var carriersim = String()
    var mycarrier = CTCarrier()
    var mycarrier2 = CTCarrier()
    var carrierNetwork = String()
    var carrierNetwork2 = String()
    var carrierName = String()
    var fullCarrierName = String()
    var airplanemode = false
    var checkSimMCC = "999"
    var checkSimMNC = "99"
    
    // Carrier setup
    var hp = "WCDMA"
    var nrp = "HSDPA"
    var targetMCC = "208"
    var targetMNC = "15"
    var itiMNC = "01"
    var nrDEC = true
    var out2G = true
    var chasedMNC = ""
    var connectedMCC = ""
    var connectedMNC = ""
    var ipadMCC = ""
    var ipadMNC = ""
    var itiName = "Orange F"
    var homeName = "Free"
    var stms = 0.768
    var countriesData = [String]()
    var countriesVoice = [String]()
    var countriesVData = [String]()
    var disableFMobileCore = false
    
    // Custom values
    var includedData = [String]()
    var includedVoice = [String]()
    var includedVData = [String]()
    
    // European lists
    let europe = ["FR", "DE", "AT", "BE", "BG", "CY", "HR", "DK", "ES", "EE", "FI", "GI", "GR", "HU", "IE", "IS", "IT", "LV", "LI", "LT", "LU", "MT", "NO", "NL", "PL", "PT", "CZ", "RO", "GB", "SK", "SI", "SE", "GP", "GF", "MQ", "YT", "RE", "BL", "MF"]
    
    let europeland = ["FR", "DE", "AT", "BE", "BG", "CY", "HR", "DK", "ES", "EE", "FI", "GI", "GR", "HU", "IE", "IS", "IT", "LV", "LI", "LT", "LU", "MT", "NO", "NL", "PL", "PT", "CZ", "RO", "GB", "SK", "SI", "SE"]
    
    init() {
        // Lecture des valeurs depuis la config
        print(Locale.current.languageCode ?? "...");
        if let modeRadin = datas.value(forKey: "modeRadin") as? Bool, Locale.current.languageCode == "fr" {
            self.modeRadin = modeRadin
        }
        if let allow013G = datas.value(forKey: "allow013G") as? Bool {
            self.allow013G = allow013G
        }
        if let allow012G = datas.value(forKey: "allow012G") as? Bool {
            self.allow012G = allow012G
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
        if let hp = datas.value(forKey: "HP") as? String {
            self.hp = hp
        }
        if let nrp = datas.value(forKey: "NRP") as? String {
            self.nrp = nrp
        }
        if let targetMCC = datas.value(forKey: "MCC") as? String {
            self.targetMCC = targetMCC
        }
        if let targetMNC = datas.value(forKey: "MNC") as? String {
            self.targetMNC = targetMNC
        }
        if let itiMNC = datas.value(forKey: "ITIMNC") as? String {
            self.itiMNC = itiMNC
        }
        if let out2G = datas.value(forKey: "OUT2G") as? Bool {
            self.out2G = out2G
        }
        if let itiName = datas.value(forKey: "ITINAME") as? String {
            self.itiName = itiName
        }
        if let homeName = datas.value(forKey: "HOMENAME") as? String {
            self.homeName = homeName
        }
        if let stms = datas.value(forKey: "STMS") as? Double {
            self.stms = stms
        }
        if let url = datas.value(forKey: "URL") as? String {
            self.url = url
        }
        if let urlst = datas.value(forKey: "URLST") as? String {
            self.urlst = urlst
        }
        if let setupDone = datas.value(forKey: "setupDone") as? Bool {
            self.setupDone = setupDone
        }
        if let minimalSetup = datas.value(forKey: "minimalSetup") as? Bool {
            self.minimalSetup = minimalSetup
        }
        if let modeExpert = datas.value(forKey: "modeExpert") as? Bool {
            self.modeExpert = modeExpert
        }
        if let countriesData = datas.value(forKey: "countriesData") as? [String] {
            self.countriesData = countriesData
        }
        if let countriesVData = datas.value(forKey: "countriesVData") as? [String] {
            self.countriesVData = countriesVData
        }
        if let countriesVoice = datas.value(forKey: "countriesVoice") as? [String] {
            self.countriesVoice = countriesVoice
        }
        if let disableFMobileCore = datas.value(forKey: "disableFMobileCore") as? Bool {
            self.disableFMobileCore = disableFMobileCore
        }
        if let statisticsAgreement = datas.value(forKey: "statisticsAgreement") as? Bool {
            self.statisticsAgreement = statisticsAgreement
        }
        if let syncNewSIM = datas.value(forKey: "syncNewSIM") as? Date {
            self.syncNewSIM = syncNewSIM
        }
        if let includedData = datas.value(forKey: "includedData") as? [String] {
            self.includedData = includedData
        }
        if let includedVData = datas.value(forKey: "includedVData") as? [String] {
            self.includedVData = includedVData
        }
        if let includedVoice = datas.value(forKey: "includedVoice") as? [String] {
            self.includedVoice = includedVoice
        }
        
        // Arrondi des valeurs
        if stms <= 0.5 {
            stms *= 2.100 // On arrondit à +110%
        } else if stms <= 1.50 {
            stms *= 1.750 // On arrondit à +75%
        } else if stms <= 2 {
            stms *= 1.500 // On arrondit à +50%
        } else if stms <= 3 {
            stms *= 1.250 // On arrondit à +25%
        }
        
        // Récupération des données depuis la SIM et les fichiers du système
        
        let operatorPListSymLinkPath = "/var/mobile/Library/Preferences/com.apple.operator.plist"
        let carrierPListSymLinkPath = "/var/mobile/Library/Preferences/com.apple.carrier.plist"
        
        // Déclaration du gestionaire de fichiers
        let fileManager = FileManager.default
        let operatorPListPath = try? fileManager.destinationOfSymbolicLink(atPath: operatorPListSymLinkPath)
        print(operatorPListPath ?? "UNKNOWN")
        
        // Obtenir le fichier de configuration de la carte SIM
        let carrierPListPath = try? fileManager.destinationOfSymbolicLink(atPath: carrierPListSymLinkPath)
        print(carrierPListPath ?? "UNKNOWN")
        
        simData = "-----"
        if !(carrierPListPath ?? "unknown").lowercased().contains("unknown") {
            let values = carrierPListPath?.groups(for: "[0-9]+")
            if let group = values?.first {
                simData = group[0]
            }
            
            print(simData)
        }
        
        currentNetwork = "-----"
        if !(operatorPListPath ?? "unknown").lowercased().contains("unknown"){
            let values = operatorPListPath?.groups(for: "[0-9]+")
            if let group = values?.first {
                currentNetwork = group[0]
            }
            
            print(currentNetwork)
        }
        
        carrier = "Carrier"
        fullCarrierName = "Carrier"
        
        let url = URL(fileURLWithPath: operatorPListPath ?? "Error")
        do {
            let test = try NSDictionary(contentsOf: url, error: ())
            let array = test["StatusBarImages"] as? NSArray ?? NSArray.init(array: [0])
            let secondDict = NSDictionary(dictionary: array[0] as? Dictionary ?? NSDictionary() as? Dictionary<AnyHashable, Any> ?? Dictionary())
            
            carrier = (secondDict["StatusBarCarrierName"] as? String) ?? "Carrier"
            fullCarrierName = (secondDict["CarrierName"] as? String) ?? "Carrier"
        } catch {
            print("Une erreur s'est produite : \(error)")
        }
        
        
        carriersim = "Carrier"
        let urlcarrier = URL(fileURLWithPath: carrierPListPath ?? "Error")
        do {
            let testsim = try NSDictionary(contentsOf: urlcarrier, error: ())
            let arraysim = testsim["StatusBarImages"] as? NSArray ?? NSArray.init(array: [0])
            let secondDictsim = NSDictionary(dictionary: arraysim[0] as? Dictionary ?? NSDictionary() as? Dictionary<AnyHashable, Any> ?? Dictionary())
                    
            carriersim = (secondDictsim["StatusBarCarrierName"] as? String) ?? "Carrier"
        } catch {
            print("Une erreur s'est produite : \(error)")
        }
        
        
        let urlairplane = URL(fileURLWithPath: "/var/preferences/SystemConfiguration/com.apple.radios.plist")
        do {
            let test = try NSDictionary(contentsOf: urlairplane, error: ())
            airplanemode = test["AirplaneMode"] as? Bool ?? false
         if airplanemode {
            print("The device is in Airplane mode.")
         } else {
             print("The device is not in Airplane mode.")
         }
        } catch {
            print("Une erreur s'est produite : \(error)")
        }
        
        
        connectedMCC = String(currentNetwork.prefix(3))
        connectedMNC = String(currentNetwork.count == 6 ? currentNetwork.suffix(3) : currentNetwork.suffix(2))
        
        checkSimMCC = String(simData.prefix(3))
        checkSimMNC = String(simData.count == 6 ? simData.suffix(3) : simData.suffix(2))
        
        mycarrier = CTCarrier()
        mycarrier2 = CTCarrier()
        
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
        
        if (mycarrier2.mobileCountryCode == targetMCC && mycarrier2.mobileNetworkCode == targetMNC) || (mycarrier2.mobileCountryCode == checkSimMCC && mycarrier2.mobileNetworkCode == checkSimMNC) {
            swap(&mycarrier2, &mycarrier)
            swap(&carrierNetwork2, &carrierNetwork)
        }
        
        print(carrierNetwork)
        
        carrierName = mycarrier.carrierName ?? "Carrier"
        
        if carrierName == "Carrier" && carriersim != "Carrier" {
            carrierName = carriersim
        }
        
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
            
            if carrierName == "Carrier" && homeName != "null" && !homeName.isEmpty {
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
        
        // On fait le check européen (pays inclus EU)
        europeanCheck()
    }
    
    // Vérification d'un appel en cours
    static func isOnPhoneCall() -> Bool {
        for call in CXCallObserver().calls {
            if call.hasEnded == false {
                return true
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
        
        var array = NSArray.init(array: [0])
        
        let url = URL(fileURLWithPath: carrierPListPath ?? "Error")
        do {
            let test = try NSDictionary(contentsOf: url, error: ())
            array = test["SupportedPLMNs"] as? NSArray ?? NSArray.init(array: [0])
        } catch {
            print("Une erreur est survenue : \(error)")
        }
        
        
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

            let url = URL(fileURLWithPath: carrierPListPath ?? "Error")
            do {
                let test = try NSDictionary(contentsOf: url, error: ())
                let array = test["SupportedPLMNs"] as? NSArray ?? NSArray.init(array: [0])
                    
                for index in 0..<array.count {
                    let value = array[index] as? String ?? "-----"
                    let plmnmcc = value.prefix(3)
                    let plmnmnc = value.suffix(2)
                        
                    if plmnmcc == targetMCC && plmnmnc == itiMNC {
                        valueToReturn = true
                    }
                }
            } catch {
                print("Une erreur est survenue : \(error)")
            }
        }
        return valueToReturn
    }
    
    func isNRDECstatus() -> Bool {
        if simData != "-----" {
            let carrierPListSymLinkPath = "/var/mobile/Library/Preferences/com.apple.carrier.plist"
            
            // Déclaration du gestionaire de fichiers
            let fileManager = FileManager.default
            
            // Obtenir le fichier de configuration de la carte SIM
            let carrierPListPath = try? fileManager.destinationOfSymbolicLink(atPath: carrierPListSymLinkPath)
            
            let url = URL(fileURLWithPath: carrierPListPath ?? "Error")
            do {
                let test = try NSDictionary(contentsOf: url, error: ())
                let array = test["SupportedPLMNs"] as? NSArray ?? []
                    
                for item in array {
                    if let value = item as? String, (value.count == 5 || value.count == 6) {
                        let plmnmcc = value.prefix(3)
                        let plmnmnc = value.count == 6 ? value.suffix(3) : value.suffix(2)
                            
                        if plmnmcc == targetMCC && plmnmnc == itiMNC {
                            return true
                        }
                    }
                }

            } catch {
                print("Une erreur est survenue : \(error)")
            }
        }
        
        return false
    }
    
    // Reset custom lists
    func resetCountryIncluded(){
        let emptyList = [String]()
        
        datas.set(emptyList, forKey: "includedData")
        datas.set(emptyList, forKey: "includedVData")
        datas.set(emptyList, forKey: "includedVoice")
        datas.synchronize()
    }
    
    func zoneCheck() -> String {
        // Current country
        let country = CarrierIdentification.getIsoCountryCode(connectedMCC, connectedMNC).uppercased()
        
        // Check for unknown
        if country == "--"{
            return "UNKNOWN"
        }
        
        // Check if home
        if country == CarrierIdentification.getIsoCountryCode(targetMCC, targetMNC).uppercased() {
            return "HOME"
        }
        
        // Check for all from config
        if countriesVData.contains(country) {
            return "ALL"
        }
        
        // Check for internet from config
        if countriesData.contains(country) {
            return "INTERNET"
        }
        
        // Check for voice from config
        if countriesVoice.contains(country) {
            return "CALLS"
        }
        
        // Check for all from custom
        if includedVData.contains(country) {
            return "ALL"
        }
        
        // Check for internet from custom
        if includedData.contains(country) {
            return "INTERNET"
        }
        
        // Check for voice from custom
        if includedVData.contains(country) {
            return "CALLS"
        }
        
        // Out of countries
        return "OUTZONE"
    }
    
    // Add a country in custom list
    func addCountryIncluded(country: String, list: Int){
        if list == 0 {
            // Voice
            includedVoice.append(country)
            datas.set(includedVoice, forKey: "includedVoice")
            datas.synchronize()
        } else if list == 1 {
            // Internet
            includedData.append(country)
            datas.set(includedData, forKey: "includedData")
            datas.synchronize()
        } else if list == 2 {
            // All
            includedVData.append(country)
            datas.set(includedVData, forKey: "includedVData")
            datas.synchronize()
        }
    }
    
    // Check for identifier EU
    func europeanCheck() {
        
        // Country by MCC
        let country = CarrierIdentification.getIsoCountryCode(targetMCC, targetMNC).uppercased()
        
        // Check european countries
        if europe.contains(country) && !countriesVData.contains("EU") {
            countriesVData.append("EU")
        }
        
        // Check data
        if countriesData.contains("EU") {
            // We have it, add all elements
            countriesData.append(contentsOf: europe)
        }
        
        if countriesData.contains("UE") {
            countriesData.append(contentsOf: europeland)
        }
        
        // Check voice
        if countriesVoice.contains("EU") {
            // We have it, add all elements
            countriesVoice.append(contentsOf: europe)
        }
        
        if countriesVoice.contains("UE") {
            countriesVoice.append(contentsOf: europeland)
        }
        
        // Check all
        if countriesVData.contains("EU") {
            // We have it, add all elements
            countriesVData.append(contentsOf: europe)
        }
        
        if countriesVData.contains("UE") {
            countriesVData.append(contentsOf: europeland)
        }
    }
    
}
