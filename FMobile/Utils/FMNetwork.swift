//
//  FMNetwork.swift
//  FMobile
//
//  Created by PlugN on 01/07/2020.
//  Copyright © 2020 Groupe MINASTE. All rights reserved.
//

import Foundation
import CoreTelephony

class FMNetwork {
    
    var card: FMNetworkSIMData
    var network: FMNetworkData
    
    func loadDatas(type: FMNetworkType) {
        
        let datas = UserDefaults(suiteName: "group.fr.plugn.fmobile") ?? Foundation.UserDefaults.standard
        
        if let hp = datas.value(forKey: (type == .esim ? "e" : "") + "HP") as? String {
            self.card.hp = hp
        }
        if let nrp = datas.value(forKey: (type == .esim ? "e" : "") + "NRP") as? String {
            self.card.nrp = nrp
        }
        if let targetMCC = datas.value(forKey: (type == .esim ? "e" : "") + "MCC") as? String {
            self.card.mcc = targetMCC
        }
        if let targetMNC = datas.value(forKey: (type == .esim ? "e" : "") + "MNC") as? String {
            self.card.mnc = targetMNC
        }
        if let itiMNC = datas.value(forKey: (type == .esim ? "e" : "") + "ITIMNC") as? String {
            self.card.itiMNC = itiMNC
        }
        if let out2G = datas.value(forKey: (type == .esim ? "e" : "") + "OUT2G") as? Bool {
            self.card.out2G = out2G
        }
        if let itiName = datas.value(forKey: (type == .esim ? "e" : "") + "ITINAME") as? String {
            self.card.itiName = itiName
        }
        if let homeName = datas.value(forKey: (type == .esim ? "e" : "") + "HOMENAME") as? String {
            self.card.homeName = homeName
        }
        if let stms = datas.value(forKey: (type == .esim ? "e" : "") + "STMS") as? Double {
            self.card.stms = stms
        }
        if let countriesData = datas.value(forKey: (type == .esim ? "e" : "") + "countriesData") as? [String] {
            self.card.countriesData = countriesData
        }
        if let countriesVData = datas.value(forKey: (type == .esim ? "e" : "") + "countriesVData") as? [String] {
            self.card.countriesVData = countriesVData
        }
        if let countriesVoice = datas.value(forKey: (type == .esim ? "e" : "") + "countriesVoice") as? [String] {
            self.card.countriesVoice = countriesVoice
        }
        if let disableFMobileCore = datas.value(forKey: (type == .esim ? "e" : "") + "disableFMobileCore") as? Bool {
            self.card.disableFMobileCore = disableFMobileCore
        }
        if let includedData = datas.value(forKey: (type == .esim ? "e" : "") + "includedData") as? [String] {
            self.card.includedData = includedData
        }
        if let includedVData = datas.value(forKey: (type == .esim ? "e" : "") + "includedVData") as? [String] {
            self.card.includedVData = includedVData
        }
        if let includedVoice = datas.value(forKey: (type == .esim ? "e" : "") + "includedVoice") as? [String] {
            self.card.includedVoice = includedVoice
        }
        if let roamLTE = datas.value(forKey: (type == .esim ? "e" : "") + "roamLTE") as? Bool {
            self.card.roamLTE = roamLTE
        }
        if let roam5G = datas.value(forKey: (type == .esim ? "e" : "") + "roam5G") as? Bool {
            self.card.roam5G = roam5G
        }
        if let setupDone = datas.value(forKey: (type == .esim ? "e" : "") + "setupDone") as? Bool {
            self.card.setupDone = setupDone
        }
        if let minimalSetup = datas.value(forKey: (type == .esim ? "e" : "") + "minimalSetup") as? Bool {
            self.card.minimalSetup = minimalSetup
        }
        if let lastnetr = datas.value(forKey: (type == .esim ? "e" : "") + "lastnetr") as? String {
            self.network.lastnetr = lastnetr
        }
        
        if let carrierServices = datas.value(forKey: (type == .esim ? "e" : "") + "carrierServices") as? [[String]] {
            var newCarrierS = [(String, String, String)]()
            
            for service in carrierServices {
                if service.count >= 3 {
                    if !service[0].isEmpty && !service[1].isEmpty && !service[2].isEmpty {
                        newCarrierS.append((service[0], service[1], service[2]))
                    }
                }
            }
            self.card.carrierServices = newCarrierS
        }
        
        print(self.card.carrierServices)
    }
    
    // Check for identifier EU
    func europeanCheck() {
        // European lists
        
        let europe = CarrierIdentification.europe
        let europeland = CarrierIdentification.europeland
        
        // Country by MCC
        let country = card.land
            
        // Check european countries
        if europe.contains(country) && !card.countriesVData.contains("EU") {
            card.countriesVData.append("EU")
        }
        
        // Check data
        if card.countriesData.contains("EU") {
            // We have it, add all elements
            card.countriesData.append(contentsOf: europe)
        }
        
        if card.countriesData.contains("UE") {
            card.countriesData.append(contentsOf: europeland)
        }
        
        // Check voice
        if card.countriesVoice.contains("EU") {
            // We have it, add all elements
            card.countriesVoice.append(contentsOf: europe)
        }
        
        if card.countriesVoice.contains("UE") {
            card.countriesVoice.append(contentsOf: europeland)
        }
        
        // Check all
        if card.countriesVData.contains("EU") {
            // We have it, add all elements
            card.countriesVData.append(contentsOf: europe)
        }
        
        if card.countriesVData.contains("UE") {
            card.countriesVData.append(contentsOf: europeland)
        }
        
        
        // Check for included manually
        // Check data
        if card.includedData.contains("EU") {
            // We have it, add all elements
            card.includedData.append(contentsOf: europe)
        }
        
        if card.includedData.contains("UE") {
            card.includedData.append(contentsOf: europeland)
        }
        
        // Check voice
        if card.includedVoice.contains("EU") {
            // We have it, add all elements
            card.includedVoice.append(contentsOf: europe)
        }
        
        if card.includedVoice.contains("UE") {
            card.includedVoice.append(contentsOf: europeland)
        }
        
        // Check all
        if card.includedVData.contains("EU") {
            // We have it, add all elements
            card.includedVData.append(contentsOf: europe)
        }
        
        if card.includedVData.contains("UE") {
            card.includedVData.append(contentsOf: europeland)
        }
    }

    
    init(type: FMNetworkType) {
        
        var type = type
        
        var operatorPListSymLinkPath: String
        var carrierPListSymLinkPath: String
        var targetSIM: String
        
        if type == .current {
            
            operatorPListSymLinkPath = "/var/mobile/Library/Preferences/com.apple.operator.plist"
            carrierPListSymLinkPath = "/var/mobile/Library/Preferences/com.apple.carrier.plist"
            
            if #available(iOS 12.0, *) {
                
                let operatorPListSymLinkPath_1 = "/var/mobile/Library/Preferences/com.apple.operator_1.plist"
                let carrierPListSymLinkPath_1 = "/var/mobile/Library/Preferences/com.apple.carrier_1.plist"
                
                let operatorPListSymLinkPath_2 = "/var/mobile/Library/Preferences/com.apple.operator_2.plist"
                let carrierPListSymLinkPath_2 = "/var/mobile/Library/Preferences/com.apple.carrier_2.plist"
                
                let fileManager = FileManager.default
                let operatorPListPath = try? fileManager.destinationOfSymbolicLink(atPath: operatorPListSymLinkPath)
                let carrierPListPath = try? fileManager.destinationOfSymbolicLink(atPath: carrierPListSymLinkPath)
                
                let operatorPListPath_1 = try? fileManager.destinationOfSymbolicLink(atPath: operatorPListSymLinkPath_1)
                let carrierPListPath_1 = try? fileManager.destinationOfSymbolicLink(atPath: carrierPListSymLinkPath_1)
                
                let operatorPListPath_2 = try? fileManager.destinationOfSymbolicLink(atPath: operatorPListSymLinkPath_2)
                let carrierPListPath_2 = try? fileManager.destinationOfSymbolicLink(atPath: carrierPListSymLinkPath_2)
                
                if operatorPListPath == operatorPListPath_2 && carrierPListPath == carrierPListPath_2 {
                    type = .esim
                } else if operatorPListPath == operatorPListPath_1 && carrierPListPath == carrierPListPath_1 {
                    type = .sim
                } else {
                    type = .current
                }
            } else {
                type = .sim
            }
            
        }
        
        self.card = FMNetworkSIMData(type: type)
        self.network = FMNetworkData()
        
        loadDatas(type: type)
        
        if type == .sim || type == .current {
            
            if type == .current {
                operatorPListSymLinkPath = "/var/mobile/Library/Preferences/com.apple.operator.plist"
                carrierPListSymLinkPath = "/var/mobile/Library/Preferences/com.apple.carrier.plist"
            } else {
                if #available(iOS 12.0, *) {
                    operatorPListSymLinkPath = "/var/mobile/Library/Preferences/com.apple.operator_1.plist"
                    carrierPListSymLinkPath = "/var/mobile/Library/Preferences/com.apple.carrier_1.plist"
                } else {
                    operatorPListSymLinkPath = "/var/mobile/Library/Preferences/com.apple.operator.plist"
                    carrierPListSymLinkPath = "/var/mobile/Library/Preferences/com.apple.carrier.plist"
                }
            }
            targetSIM = "0000000100000001"
            
            print(card.carrierServices)
            
        } else {
            operatorPListSymLinkPath = "/var/mobile/Library/Preferences/com.apple.operator_2.plist"
            carrierPListSymLinkPath = "/var/mobile/Library/Preferences/com.apple.carrier_2.plist"
            targetSIM = "0000000100000002"
            
        }
        
        // Déclaration du gestionaire de fichiers
        let fileManager = FileManager.default
        let operatorPListPath = try? fileManager.destinationOfSymbolicLink(atPath: operatorPListSymLinkPath)
        print(operatorPListPath ?? "UNKNOWN")
        
        // Obtenir le fichier de configuration de la carte SIM
        let carrierPListPath = try? fileManager.destinationOfSymbolicLink(atPath: carrierPListSymLinkPath)
        print(carrierPListPath ?? "UNKNOWN")
        
        card.data = "-----"
        if !(carrierPListPath ?? "unknown").lowercased().contains("unknown") {
            let values = carrierPListPath?.groups(for: "[0-9]+")
            if let group = values?.first {
                card.data = group[0]
            }
            
            print(card.data)
        }
        
        network.data = "-----"
        if !(operatorPListPath ?? "unknown").lowercased().contains("unknown"){
            let values = operatorPListPath?.groups(for: "[0-9]+")
            if let group = values?.first {
                network.data = group[0]
            }
            
            print(network.data)
        }
        
        network.name = "Carrier"
        network.fullname = "Carrier"
        
        let url = URL(fileURLWithPath: operatorPListPath ?? "Error")
        do {
            let test: NSDictionary
            if #available(iOS 11.0, *) {
                test = try NSDictionary(contentsOf: url, error: ())
            } else {
                // Fallback on earlier versions
                test = NSDictionary(contentsOf: url) ?? NSDictionary()
            }
            let array = test["StatusBarImages"] as? NSArray ?? NSArray.init(array: [0])
            let secondDict = NSDictionary(dictionary: array[0] as? Dictionary ?? NSDictionary() as? Dictionary<AnyHashable, Any> ?? Dictionary())
            
            network.name = (secondDict["StatusBarCarrierName"] as? String) ?? "Carrier"
            network.fullname = (secondDict["CarrierName"] as? String) ?? "Carrier"
        } catch {
            print("Une erreur s'est produite : \(error)")
        }
        
        
        card.simname = "Carrier"
        card.fullname = "Carrier"
        let urlcarrier = URL(fileURLWithPath: carrierPListPath ?? "Error")
        do {
            let testsim: NSDictionary
            if #available(iOS 11.0, *) {
                testsim = try NSDictionary(contentsOf: urlcarrier, error: ())
            } else {
                // Fallback on earlier versions
                testsim = NSDictionary(contentsOf: urlcarrier) ?? NSDictionary()
            }
            let arraysim = testsim["StatusBarImages"] as? NSArray ?? NSArray.init(array: [0])
            let secondDictsim = NSDictionary(dictionary: arraysim[0] as? Dictionary ?? NSDictionary() as? Dictionary<AnyHashable, Any> ?? Dictionary())
            
            let array = testsim["SupportedPLMNs"] as? NSArray ?? NSArray.init(array: [0])
            
            if array.count <= 1 {
                card.eligibleminimalsetup = true
            }
            
            for item in array {
                if let value = item as? String, (value.count == 5 || value.count == 6) {
                    let plmnmcc = value.prefix(3)
                    let plmnmnc = value.count == 6 ? value.suffix(3) : value.suffix(2)
                        
                    if plmnmcc == card.mcc && plmnmnc == card.itiMNC {
                        card.nrdec = true
                    }
                }
            }
                    
            card.simname = (secondDictsim["StatusBarCarrierName"] as? String) ?? "Carrier"
            card.fullname = (secondDictsim["CarrierName"] as? String) ?? "Carrier"
        } catch {
            print("Une erreur s'est produite : \(error)")
        }
        
        network.mcc = String(network.data.prefix(3))
        network.mnc = String(network.data.count == 6 ? network.data.suffix(3) : network.data.suffix(2))
        
        let checkmcc = String(card.data.prefix(3))
        let checkmnc = String(card.data.count == 6 ? card.data.suffix(3) : card.data.suffix(2))
        
        if (card.mcc != checkmcc || card.mnc != checkmnc) && (card.data != "-----") {
            card.mcc = checkmcc
            card.mnc = checkmnc
        }
        
        let info = CTTelephonyNetworkInfo()
        
        if #available(iOS 12.0, *) {
        for (service, carrier) in info.serviceSubscriberCellularProviders ?? [:] {
            if service == targetSIM {
                let radio = info.serviceCurrentRadioAccessTechnology?[service] ?? ""
                card.carrier = carrier
                network.connected = radio
                if let mobileCountryCode = card.carrier.mobileCountryCode, let mobileNetworkCode = card.carrier.mobileNetworkCode {
                    if card.mcc != mobileCountryCode || card.mnc != mobileNetworkCode {
                        card.mcc = mobileCountryCode
                        card.mnc = mobileNetworkCode
                    }
                    card.active = true
                }
                print("For Carrier " + (carrier.carrierName ?? "null") + ", got " + radio)
                print(service)
            }
        }
        } else {
            if type == .sim {
                card.active = true
            }
            card.carrier = info.subscriberCellularProvider ?? CTCarrier()
            network.connected = info.currentRadioAccessTechnology ?? ""
        }
        
        print(network.connected)
        
        card.name = card.carrier.carrierName ?? "Carrier"
        
        if card.name == "Carrier" && card.simname != "Carrier" {
            card.name = card.simname
        }
        
        if card.name == "Carrier" && card.fullname != "Carrier" {
            card.name = card.fullname
        }
        
        if network.name == "Carrier" && network.fullname != "Carrier" {
            network.name = network.fullname
        }
        
        if card.name == "Carrier" && card.homeName != "null" && !card.homeName.isEmpty {
            card.name = card.homeName
            
            if (network.mcc == "---" && network.mnc == "--"){
                network.mcc = card.carrier.mobileCountryCode ?? "---"
                network.mnc = card.carrier.mobileNetworkCode ?? "--"
                
                if (network.mcc != "---" && network.mnc != "--"){
                    network.name = card.homeName
                }
            }
        }
        
        card.land = CarrierIdentification.getIsoCountryCode(card.mcc, card.mnc)
        network.land = CarrierIdentification.getIsoCountryCode(network.mcc, network.mnc)
        
        print("nrDEC: \(card.nrdec)")
        if card.nrdec {
            card.chasedMNC = card.mnc
        } else {
            card.chasedMNC = card.itiMNC
        }
        
        // Arrondi des valeurs
        if card.stms <= 0.5 {
            card.stms *= 2.100 // On arrondit à +110%
        } else if card.stms <= 1.50 {
            card.stms *= 1.750 // On arrondit à +75%
        } else if card.stms <= 2 {
            card.stms *= 1.500 // On arrondit à +50%
        } else if card.stms <= 3 {
            card.stms *= 1.250 // On arrondit à +25%
        }
        
        
        let replace: (String, (String) -> (), String) -> () = { input, output, def in
            
            if #available(iOS 14.1, *) {
                if input == "NR" {
                    output(CTRadioAccessTechnologyNR)
                    return
                } else if input == "NRNSA" {
                    output(CTRadioAccessTechnologyNRNSA)
                    return
                }
            }
            switch input {
                case "LTE":
                    output(CTRadioAccessTechnologyLTE)
                case "WCDMA":
                    output(CTRadioAccessTechnologyWCDMA)
                case "HSDPA":
                    output(CTRadioAccessTechnologyHSDPA)
                case "EDGE":
                    output(CTRadioAccessTechnologyEdge)
                case "GPRS":
                    output(CTRadioAccessTechnologyGPRS)
                case "EHRPD":
                    output(CTRadioAccessTechnologyeHRPD)
                case "HRPD":
                    output(CTRadioAccessTechnologyeHRPD)
                case "HSUPA":
                    output(CTRadioAccessTechnologyHSUPA)
                case "CDMA1X":
                    output(CTRadioAccessTechnologyCDMA1x)
                case "CDMA":
                    output(CTRadioAccessTechnologyCDMA1x)
                case "CDMAEVDOREV0":
                    output(CTRadioAccessTechnologyCDMAEVDORev0)
                case "EVDO":
                    output(CTRadioAccessTechnologyCDMAEVDORev0)
                case "CDMAEVDOREVA":
                    output(CTRadioAccessTechnologyCDMAEVDORevA)
                case "EVDOA":
                    output(CTRadioAccessTechnologyCDMAEVDORevA)
                case "CDMAEVDOREVB":
                    output(CTRadioAccessTechnologyCDMAEVDORevB)
                case "EVDOB":
                    output(CTRadioAccessTechnologyCDMAEVDORevB)
                default:
                    output(def)
            }
        }
        
        replace(card.hp, { card.hp = $0 }, CTRadioAccessTechnologyWCDMA)
        replace(card.nrp, { card.nrp = $0 }, CTRadioAccessTechnologyHSDPA)
        
        // On fait le check européen (pays inclus EU)
        europeanCheck()
        
    }
    
}
