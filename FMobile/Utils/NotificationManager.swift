//
//  Notification.swift
//  FMobile
//
//  Created by Nathan FALLET on 16/01/2019.
//  Copyright © 2019 Groupe MINASTE. All rights reserved.
//

import Foundation
import UserNotifications

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
                content.title = "performance_mode_auto_enabled".localized()
                content.subtitle = "performance_mode_auto_enabled_subtitle".localized()
                content.body = "performance_mode_auto_enabled_description".localized()
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
                content.title = "performance_mode_mode_enabled_title".localized()
                content.body = "performance_mode_mode_enabled_description".localized()
                time = 8

//            case .restarting:
//                content.title = "performance_mode_mode_auto_disabled".localized()
//                content.body = "performance_mode_mode_auto_disabled_description".localized()
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
            
            case .alertDataDrainG3:
                content.title = "alert_paid_data_drain_g3".localized()
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
    }
    
}

enum NotificationType {
    
    case allow2G3G, allow2G, allow3G, allowNone, allowDisabled, alertHPlus, alertPossibleHPlus, alertWCDMA, alertPossibleWCDMA, alertEdge, halt, locFailed, saved, batteryLow, newCountryNothingFree, newCountryBasicFree, newCountryInternetFree, newCountryAllFree, newCountryNothing, newCountryBasic, newCountryInternet, newCountryAll, alertDataDrain, alertDataDrainG3, newSIM, update, custom
    
}

