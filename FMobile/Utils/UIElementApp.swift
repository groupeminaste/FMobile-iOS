//
//  UIElementApp.swift
//  FWi-Fi
//
//  Created by PlugN on 24/02/2020.
//  Copyright © 2020 Groupe MINASTE. All rights reserved.
//

import Foundation
import UIKit

class UIElementApp: UIElement {
    
    var handler: (UIButton) -> Void
    var name: String
    var desc: String
    var icon: UIImage?
    
    init(name: String, desc: String, icon: UIImage?, completionHandler: @escaping (UIButton) -> Void) {
        self.handler = completionHandler
        self.name = name
        self.desc = desc
        self.icon = icon
        super.init(id: name, text: desc)
    }
}
