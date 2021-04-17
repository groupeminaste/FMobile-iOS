//
//  Section.swift
//  FMobile
//
//  Created by Nathan FALLET on 10/1/18.
//  Copyright © 2018 Groupe MINASTE. All rights reserved.
//

import Foundation

class Section {
    
    var name: String
    var footer: String
    var elements: [UIElement]
    
    init(name: String, elements: [UIElement], footer: String) {
        self.name = name
        self.elements = elements
        self.footer = footer
    }
    
    init(name: String, elements: [UIElement]) {
        self.name = name
        self.elements = elements
        self.footer = ""
    }
    
}
