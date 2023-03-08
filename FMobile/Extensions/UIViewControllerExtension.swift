//
//  UIViewControllerExtension.swift
//  FMobile
//
//  Created by PlugN on 26/01/2020.
//  Copyright © 2020 Groupe MINASTE. All rights reserved.
//

import Foundation
import UIKit

#if !targetEnvironment(macCatalyst)
@available(iOS, obsoleted: 13.0)
extension UIViewController {
    
    func isDarkMode() -> Bool {
        let datas = UserDefaults(suiteName: "group.fr.plugn.fmobile") ?? Foundation.UserDefaults.standard
        
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
#endif
