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
//  UIViewControllerExtension.swift
//  FMobile
//
//  Created by Nathan FALLET on 15/05/2019.
//  Copyright © 2019 Groupe MINASTE. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func isDarkMode() -> Bool {
        let datas = UserDefaults.standard
        
        if datas.value(forKey: "isDarkMode") != nil {
            return datas.value(forKey: "isDarkMode") as! Bool
        }
        return true
    }
    
    @objc func darkModeEnabled(_ notification: Foundation.Notification) {
        enableDarkMode()
    }
    
    @objc func darkModeDisabled(_ notification: Foundation.Notification) {
        disableDarkMode()
    }
    
    @objc func enableDarkMode() {
        self.view.backgroundColor = CustomColor.darkBackground
        var preferredStatusBarStyle: UIStatusBarStyle {
            return .lightContent
        }
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    @objc func disableDarkMode() {
        self.view.backgroundColor = CustomColor.lightBackground
        var preferredStatusBarStyle: UIStatusBarStyle {
            return .default
        }
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
}
