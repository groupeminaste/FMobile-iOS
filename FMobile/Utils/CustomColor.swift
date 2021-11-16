//
//  CustomColor.swift
//  FMobile
//
//  Created by PlugN on 26/01/2020.
//  Copyright © 2020 Groupe MINASTE. All rights reserved.
//

import Foundation
import UIKit

@available (iOS, obsoleted: 13.0)
class CustomColor {
    
    // Light theme
    static let lightBackground = UIColor.white
    static let lightTableBackground = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
    static let lightForeground = UIColor.gray
    static let lightSeparator: UIColor? = nil
    static let lightText = UIColor.black
    static let lightText2 = UIColor.darkGray
    static let lightText3 = UIColor.darkGray
    static let lightActive = UIColor(red: 0, green: 0.478431, blue: 1, alpha: 1)
    static let lightShapeBackgroud = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
    
    // Dark theme
    static let darkBackground = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1)
    static let darkTableBackground = UIColor.black
    static let darkForeground = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
    static let darkSeparator = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
    static let darkText = UIColor.white
    static let darkText2 = UIColor.lightText
    static let darkText3 = UIColor.white
    static let darkActive = UIColor(red: 0, green: 0.478431, blue: 1, alpha: 1)
    static let darkShapeBackgroud = UIColor(red: 1, green: 1, blue: 1, alpha: 0.1)
    
    // Shared colors
    static let redButton = UIColor(red: 0, green: 0.478431, blue: 1, alpha: 1)
    static let blueButton = UIColor(red: 0, green: 0.478431, blue: 1, alpha: 1)
    
}
