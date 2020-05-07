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
