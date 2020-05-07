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
//  CustomColor.swift
//  FMobile
//
//  Created by Nathan FALLET on 15/05/2019.
//  Copyright © 2019 Groupe MINASTE. All rights reserved.
//

import Foundation
import UIKit

class CustomColor {
    
    // Light theme
    static let lightBackground = UIColor.white
    static let lightTableBackground = UIColor.white
    static let lightForeground = UIColor.gray
    static let lightSeparator: UIColor? = nil
    static let lightText = UIColor.black
    static let lightText2 = UIColor.darkGray
    static let lightText3 = UIColor.darkGray
    static let lightActive = UIColor(red: 0, green: 0.478431, blue: 1, alpha: 1)
    static let lightShapeBackgroud = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
    
    // Dark theme
    static let darkBackground = UIColor(red: 34/255, green: 34/255, blue: 34/255, alpha: 1)
    static let darkTableBackground = UIColor.black
    static let darkForeground = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
    static let darkSeparator = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
    static let darkText = UIColor.white
    static let darkText2 = UIColor(red: 119/255, green: 119/255, blue: 119/255, alpha: 1)
    static let darkText3 = UIColor.white
    static let darkActive = UIColor(red: 217/255, green: 83/255, blue: 79/255, alpha: 1)
    static let darkShapeBackgroud = UIColor(red: 1, green: 1, blue: 1, alpha: 0.1)
    
    // Shared colors
    static let redButton = UIColor(red: 217/255, green: 83/255, blue: 79/255, alpha: 1)
    static let blueButton = UIColor(red: 0, green: 0.478431, blue: 1, alpha: 1)
    
}
