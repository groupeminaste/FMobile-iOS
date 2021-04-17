//
//  UIElement.swift
//  FMobile
//
//  Created by Nathan FALLET on 10/1/18.
//  Copyright © 2018 Groupe MINASTE. All rights reserved.
//

import Foundation

class UIElement {
    
    var id: String
    var text: String
    var getter: () -> String
    
    init(id: String, text: String) {
        self.id = id
        self.text = text
        self.getter = { () -> String in
            return text
        }
    }
    
    init(id: String, text: String, getter: @escaping () -> String) {
        self.id = id
        self.getter = getter
        self.text = self.getter()
    }
    
    func update() {
        self.text = self.getter()
    }
    
}
