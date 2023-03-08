//
//  FMNetworkData.swift
//  FMobile
//
//  Created by PlugN on 01/07/2020.
//  Copyright © 2020 Groupe MINASTE. All rights reserved.
//

import Foundation

class FMNetworkData {
    
    var mcc: String
    var mnc: String
    var land: String
    var name: String
    var fullname: String
    var data: String
    var connected: String
    var lastnetr: String
    
    init(mcc: String = String(), mnc: String = String(), land: String = String(), name: String = String(), fullname: String = String(), data: String = String(), connected: String = String(), lastnetr: String = String()) {
        self.mcc = mcc
        self.mnc = mnc
        self.land = land
        self.name = name
        self.fullname = fullname
        self.data = data
        self.connected = connected
        self.lastnetr = lastnetr
    }
    
}
