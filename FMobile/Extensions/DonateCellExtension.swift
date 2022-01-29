//
//  DonateCellExtension.swift
//  FMobile
//
//  Created by Nathan FALLET on 22/06/2020.
//  Copyright © 2020 Groupe MINASTE. All rights reserved.
//

import Foundation
import UIKit
import DonateViewController

@available(iOS, obsoleted: 13.0)
class DonateCellExtension: DonateCell {

    override func with(donation: Donation) -> DonateCell {
        // Apply current theme to cell
        if isDarkMode() {
            backgroundColor = CustomColor.darkBackground
            textLabel?.textColor = CustomColor.darkText
            loading.style = .white
        } else {
            backgroundColor = CustomColor.lightBackground
            textLabel?.textColor = CustomColor.lightText
            loading.style = .gray
        }
        
        // Call super
        return super.with(donation: donation)
    }
    
    func isDarkMode() -> Bool {
        let datas = UserDefaults(suiteName: "group.fr.plugn.fmobile") ?? Foundation.UserDefaults.standard
        
        if datas.value(forKey: "isDarkMode") != nil {
            return datas.value(forKey: "isDarkMode") as! Bool
        }
        return true
    }
    
}
