//
//  UIElementButton.swift
//  FMobile
//
//  Created by Nathan FALLET on 10/1/18.
//  Copyright © 2018 Groupe MINASTE. All rights reserved.
//

import Foundation
import UIKit

class UIElementButton: UIElement {
    
    var handler: (UIButton) -> Void
    
    init(id: String, text: String, completionHandler: @escaping (UIButton) -> Void) {
        self.handler = completionHandler
        super.init(id: id, text: text)
    }
    
}
