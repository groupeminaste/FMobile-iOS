//
//  WifiNetwork.swift
//  FMobile
//
//  Created by PlugN on 1.1.21..
//  Copyright © 2021 Groupe MINASTE. All rights reserved.
//

import Foundation
import NetworkExtension

class WifiNetwork:NSObject {
    
    var ssid: String
    var bssid: String
    var detailedDataAvailable: Bool
    var signalStrength: Double
    var isSecure: Bool
    var didAutoJoin: Bool
    var didJustJoin: Bool
    var isChoosenHelper: Bool
    
    static var currentWifiNetwork: WifiNetwork?
    
    init(ssid: String, bssid: String) {
        self.ssid = ssid
        self.bssid = bssid
        self.detailedDataAvailable = false
        self.signalStrength = 0
        self.isSecure = false
        self.didAutoJoin = false
        self.didJustJoin = false
        self.isChoosenHelper = false
    }
    
    init(network: NEHotspotNetwork) {
        self.ssid = network.ssid
        self.bssid = network.bssid
        self.detailedDataAvailable = true
        self.signalStrength = network.signalStrength
        self.isSecure = network.isSecure
        self.didAutoJoin = network.didAutoJoin
        self.didJustJoin = network.didJustJoin
        self.isChoosenHelper = network.isChosenHelper
    }
}
