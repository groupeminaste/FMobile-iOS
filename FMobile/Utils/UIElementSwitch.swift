//
//  UIElementSwitch.swift
//  FMobile
//
//  Created by Nathan FALLET on 10/1/18.
//  Copyright © 2018 Groupe MINASTE. All rights reserved.
//

import Foundation

class UIElementSwitch: UIElement {
    
    var d: Bool
    
    init(id: String, text: String, d: Bool) {
        self.d = d
        super.init(id: id, text: text)
    }
    
}
