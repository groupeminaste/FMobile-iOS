//
//  NotificationNameExtension.swift
//  FMobile
//
//  Created by PlugN on 26/01/2020.
//  Copyright © 2020 Groupe MINASTE. All rights reserved.
//

import Foundation

@available(iOS, obsoleted: 13.0)
extension Notification.Name {
    
    // Dark mode
    static let darkModeEnabled = Notification.Name("fr.plugn.fmobile.darkModeEnabled")
    static let darkModeDisabled = Notification.Name("fr.plugn.fmobile.darkModeDisabled")
    
}
