//
//  FMNetworkData.swift
//  FMobile
//
//  Created by PlugN on 01/07/2020.
//  Copyright © 2020 Groupe MINASTE. All rights reserved.
//

import Foundation
import CoreTelephony

class FMNetworkSIMData {
    
    var mcc: String
    var mnc: String
    var land: String
    var name: String
    var fullname: String
    var simname: String
    var data: String
    var carrier: CTCarrier
    var active: Bool
    var nrdec: Bool
    var eligibleminimalsetup: Bool
    var type: FMNetworkType
    
    var hp = "WCDMA"
    var nrp = "HSDPA"
    var itiMNC = "01"
    var out2G = true
    var chasedMNC = ""
    var itiName = "Orange F"
    var homeName = "Free"
    var stms = 0.768
    var countriesData = [String]()
    var countriesVoice = [String]()
    var countriesVData = [String]()
    var disableFMobileCore = false
    var carrierServices = [(String, String, String)]()
    var roamLTE = false
    var roam5G = false
    var setupDone = false
    var minimalSetup = true
    var nrfemto: Bool
    
    var includedData = [String]()
    var includedVoice = [String]()
    var includedVData = [String]()
    
    init(mcc: String = String(), mnc: String = String(), land: String = String(), name: String = String(), fullname: String = String(), data: String = String(), simname: String = String(), carrier: CTCarrier = CTCarrier(), active: Bool = false, nrdec: Bool = false, eligibleminimalsetup: Bool = false, nrfemto: Bool = false, type: FMNetworkType = .sim) {
        self.mcc = mcc
        self.mnc = mnc
        self.land = land
        self.name = name
        self.fullname = fullname
        self.simname = simname
        self.data = data
        self.carrier = carrier
        self.active = active
        self.nrdec = nrdec
        self.eligibleminimalsetup = eligibleminimalsetup
        self.nrfemto = nrfemto
        self.type = type
    }
    
}
