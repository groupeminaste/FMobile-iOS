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
//  Notification.swift
//  FMobile
//
//  Created by Nathan FALLET on 16/01/2019.
//  Copyright © 2019 Groupe MINASTE. All rights reserved.
//

import Foundation
import UserNotifications
import NotificationCenter

class NotificationManager {
    
    /*
     * Envoyer une notif:
     *
     * Basic
     *  sendNotification(for: .allow2G3G)
     *
     * Avec un titre custom pour les types le suportant
     *  sendNotification(for: .newCountryAll, with: "Bienvenue en \(country) chez \(carrier)")
     *
     */
    static func sendNotification(for type: NotificationType, with arg: String = "", with arg2: String = "") {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                
                guard settings.authorizationStatus == .authorized else { return }
                
                let content = UNMutableNotificationContent()
                var time = 3
                
                content.categoryIdentifier = "protectionItineranceActivee"
                content.sound = UNNotificationSound.default
                
                switch type {
                    
                case .allow2G3G:
                    content.title = "roaming_protect_disabled".localized()
                    content.subtitle = "3g_2g_allowed".localized()
                    content.body = "roaming_notification_description".localized()
                    
                case .allow2G:
                    content.title = "roaming_protect_enabled".localized()
                    content.subtitle = "3g_control_enabled".localized()
                    content.body = "roaming_notification_description".localized()
                    
                case .allow3G:
                    content.title = "roaming_protect_enabled".localized()
                    content.subtitle = "2g_control_enabled".localized()
                    content.body = "roaming_notification_description".localized()
                    
                case .allowNone:
                    content.title = "roaming_protect_enabled".localized()
                    content.subtitle = "3g_2g_control_enabled".localized()
                    content.body = "roaming_notification_description".localized()
                    
                case .allowDisabled:
                    content.title = "roaming_protect_disabled".localized()
                    content.subtitle = "not_controlling".localized()
                    content.body = "roaming_notification_description".localized()
                    
                case .alertHPlus:
                    content.title = "detected_hplus_roaming".localized()
                    content.body = "detected_roaming_description".localized()
                    
                case .alertPossibleHPlus:
                    content.title = "possible_hplus_roaming".localized()
                    content.body = "possible_roaming_description".localized()
                    
                case .alertWCDMA:
                    content.title = "detected_wcdma_roaming".localized()
                    content.body = "detected_roaming_description".localized()
                    
                case .alertPossibleWCDMA:
                    content.title = "possible_wcdma_roaming".localized()
                    content.body = "possible_roaming_description".localized()
                    
                case .alertEdge:
                    content.title = "detected_edge_roaming".localized()
                    content.body = "detected_roaming_description".localized()
                    
                    //            case .runningVerification:
                    //                content.title = "roaming_protect_enabled".localized()
                    //                content.subtitle = "checking_roaming".localized()
                    //                content.body = "roaming_notification_description".localized()
                    //                time = 1
                    
                case .halt:
                    content.title = "low_energy_auto_enabled".localized()
                    content.subtitle = "low_energy_auto_enabled_subtitle".localized()
                    content.body = "low_energy_auto_enabled_description".localized()
                    time = 10
                    
                case .locFailed:
                    content.title = "location_error_title".localized()
                    content.subtitle = "location_error_subtitle".localized()
                    content.body = "location_error_description".localized()
                    time = 2
                    
                case .saved:
                    content.title = "no_network_zone_auto_saved".localized()
                    content.body = "no_network_zone_auto_saved_description".localized()
                    time = 1
                    
                case .batteryLow:
                    content.title = "low_energy_mode_enabled_title".localized()
                    content.body = "low_energy_mode_enabled_description".localized()
                    time = 8
                    
                    //            case .restarting:
                    //                content.title = "low_energy_mode_auto_disabled".localized()
                    //                content.body = "low_energy_mode_auto_disabled_description".localized()
                    //                time = 1
                    
                case .newCountryNothingFree:
                    content.title = arg
                    content.body = "nothing_included_20815".localized()
                    
                case .newCountryBasicFree:
                    content.title = arg
                    content.body = "basic_included_20815".localized()
                    
                case .newCountryInternetFree:
                    content.title = arg
                    content.body = "internet_included_20815".localized()
                    
                case .newCountryAllFree:
                    content.title = arg
                    content.body = "all_included_20815".localized()
                    
                case .newCountryNothing:
                    content.title = arg
                    content.body = "nothing_included".localized()
                    
                case .newCountryBasic:
                    content.title = arg
                    content.body = "basic_included".localized()
                    
                case .newCountryInternet:
                    content.title = arg
                    content.body = "internet_included".localized()
                    
                case .newCountryAll:
                    content.title = arg
                    content.body = "all_included".localized()
                    
                case .alertDataDrain:
                    content.title = "alert_paid_data_drain".localized()
                    content.body = arg
                    
                case .newSIM:
                    content.title = "new_sim_card_detected".localized()
                    content.body = "new_sim_card_detected_description".localized()
                    
                    //            case .iPad:
                    //                content.title = "ipad_carrier_alert".localized()
                    //                content.body = "ipad_carrier_alert_description".localized()
                    
                case .update:
                    content.title = "update_done".localized()
                    content.body = arg
                    
                case .custom:
                    content.title = arg
                    content.body = arg2
                }
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(time), repeats: false)
                
                let uuidString = UUID().uuidString
                let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                
            }
        } else {
            let notification = UILocalNotification()
            var time = 3
            
            switch type {
                
            case .allow2G3G:
                notification.alertTitle = "\("roaming_protect_disabled".localized()) - \("3g_2g_allowed".localized())"
                notification.alertBody = "roaming_notification_description".localized()
                
            case .allow2G:
                notification.alertTitle = "\("roaming_protect_enabled".localized()) - \("3g_control_enabled".localized())"
                notification.alertBody = "roaming_notification_description".localized()
                
            case .allow3G:
                notification.alertTitle = "\("roaming_protect_enabled".localized()) - \("2g_control_enabled".localized())"
                notification.alertBody = "roaming_notification_description".localized()
                
            case .allowNone:
                notification.alertTitle = "\("roaming_protect_enabled".localized()) - \("3g_2g_control_enabled".localized())"
                notification.alertBody = "roaming_notification_description".localized()
                
            case .allowDisabled:
                notification.alertTitle = "\("roaming_protect_disabled".localized()) - \("not_controlling".localized())"
                notification.alertBody = "roaming_notification_description".localized()
                
            case .alertHPlus:
                notification.alertTitle = "detected_hplus_roaming".localized()
                notification.alertBody = "detected_roaming_description".localized()
                
            case .alertPossibleHPlus:
                notification.alertTitle = "possible_hplus_roaming".localized()
                notification.alertBody = "possible_roaming_description".localized()
                
            case .alertWCDMA:
                notification.alertTitle = "detected_wcdma_roaming".localized()
                notification.alertBody = "detected_roaming_description".localized()
                
            case .alertPossibleWCDMA:
                notification.alertTitle = "possible_wcdma_roaming".localized()
                notification.alertBody = "possible_roaming_description".localized()
                
            case .alertEdge:
                notification.alertTitle = "detected_edge_roaming".localized()
                notification.alertBody = "detected_roaming_description".localized()
                
                //            case .runningVerification:
                //                notification.alertTitle = "roaming_protect_enabled".localized()
                //                content.subtitle = "checking_roaming".localized()
                //                notification.alertBody = "roaming_notification_description".localized()
                //                time = 1
                
            case .halt:
                notification.alertTitle = "\("low_energy_auto_enabled".localized()) - \("low_energy_auto_enabled_subtitle".localized())"
                notification.alertBody = "low_energy_auto_enabled_description".localized()
                time = 10
                
            case .locFailed:
                notification.alertTitle = "\("location_error_title".localized()) - \("location_error_subtitle".localized())"
                notification.alertBody = "location_error_description".localized()
                time = 2
                
            case .saved:
                notification.alertTitle = "no_network_zone_auto_saved".localized()
                notification.alertBody = "no_network_zone_auto_saved_description".localized()
                time = 1
                
            case .batteryLow:
                notification.alertTitle = "low_energy_mode_enabled_title".localized()
                notification.alertBody = "low_energy_mode_enabled_description".localized()
                time = 8
                
                //            case .restarting:
                //                notification.alertTitle = "low_energy_mode_auto_disabled".localized()
                //                notification.alertBody = "low_energy_mode_auto_disabled_description".localized()
                //                time = 1
                
            case .newCountryNothingFree:
                notification.alertTitle = arg
                notification.alertBody = "nothing_included_20815".localized()
                
            case .newCountryBasicFree:
                notification.alertTitle = arg
                notification.alertBody = "basic_included_20815".localized()
                
            case .newCountryInternetFree:
                notification.alertTitle = arg
                notification.alertBody = "internet_included_20815".localized()
                
            case .newCountryAllFree:
                notification.alertTitle = arg
                notification.alertBody = "all_included_20815".localized()
                
            case .newCountryNothing:
                notification.alertTitle = arg
                notification.alertBody = "nothing_included".localized()
                
            case .newCountryBasic:
                notification.alertTitle = arg
                notification.alertBody = "basic_included".localized()
                
            case .newCountryInternet:
                notification.alertTitle = arg
                notification.alertBody = "internet_included".localized()
                
            case .newCountryAll:
                notification.alertTitle = arg
                notification.alertBody = "all_included".localized()
                
            case .alertDataDrain:
                notification.alertTitle = "alert_paid_data_drain".localized()
                notification.alertBody = arg
                
            case .newSIM:
                notification.alertTitle = "new_sim_card_detected".localized()
                notification.alertBody = "new_sim_card_detected_description".localized()
                
                //            case .iPad:
                //                notification.alertTitle = "ipad_carrier_alert".localized()
                //                notification.alertBody = "ipad_carrier_alert_description".localized()
                
            case .update:
                notification.alertTitle = "update_done".localized()
                notification.alertBody = arg
                
            case .custom:
                notification.alertTitle = arg
                notification.alertBody = arg2
            }
            
            notification.fireDate = NSDate(timeIntervalSinceNow: TimeInterval(time)) as Date
            notification.soundName = UILocalNotificationDefaultSoundName
            UIApplication.shared.scheduleLocalNotification(notification)
        }
    }
    
}

enum NotificationType {
    
    case allow2G3G, allow2G, allow3G, allowNone, allowDisabled, alertHPlus, alertPossibleHPlus, alertWCDMA, alertPossibleWCDMA, alertEdge, halt, locFailed, saved, batteryLow, newCountryNothingFree, newCountryBasicFree, newCountryInternetFree, newCountryAllFree, newCountryNothing, newCountryBasic, newCountryInternet, newCountryAll, alertDataDrain, newSIM, update, custom
    
}

