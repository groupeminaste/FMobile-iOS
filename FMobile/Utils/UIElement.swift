/*
Copyright (C) 2020 Groupe MINASTE

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*/
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
