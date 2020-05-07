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
                content.title = "Protection contre l'itinérance désactivée !"
                content.subtitle = "Itinérance 3G et 2G autorisée"
                content.body = "Vous pouvez toujours changer vos préférences dans l'application FMobile."
               
            case .allow2G:
                content.title = "Protection contre l'itinérance activée !"
                content.subtitle = "Surveillance 3G activée."
                content.body = "Vous pouvez toujours changer vos réglages dans l'application FMobile."
                
            case .allow3G:
                content.title = "Protection contre l'itinérance activée !"
                content.subtitle = "Surveillance 2G activée."
                content.body = "Vous pouvez toujours changer vos préférences dans l'application FMobile."
                
            case .allowNone:
                content.title = "Protection contre l'itinérance activée !"
                content.subtitle = "Surveillance 3G et 2G activée."
                content.body = "Vous pouvez toujours changer vos préférences dans l'application FMobile."
                
            case .allowDisabled:
                content.title = "Protection contre l'itinérance désactivée !"
                content.subtitle = "Surveillance non active."
                content.body = "Vous pouvez toujours changer vos préférences dans l'application FMobile."
                
            case .alertHPlus:
                content.title = "ITINÉRANCE H+ (3G) DÉTECTÉE !"
                content.body = "Cliquez sur la notification pour revenir sur le réseau propre."
                
            case .alertPossibleHPlus:
                content.title = "ITINÉRANCE H+ (3G) PROBABLE !"
                content.body = "Lancez maintenant une analyse du réseau et revenez sur le réseau propre si nécéssaire."
                
            case .alertWCDMA:
                content.title = "ITINÉRANCE WCDMA (3G) DÉTECTÉE !"
                content.body = "Cliquez sur la notification pour revenir sur le réseau propre."
                
            case .alertPossibleWCDMA:
                content.title = "ITINÉRANCE WCDMA (3G) PROBABLE !"
                content.body = "Lancez maintenant une analyse du réseau et revenez sur le réseau propre si nécéssaire."
                
            case .alertEdge:
                content.title = "ITINÉRANCE EDGE DÉTECTÉE !"
                content.body = "Cliquez sur la notification pour revenir sur le réseau propre."
                
            case .runningVerification:
                content.title = "Protection contre l'itinérance activée !"
                content.subtitle = "Vérification en cours...."
                content.body = "Vous pouvez toujours changer vos réglages dans l'application FMobile."
                time = 1
                
            case .halt:
                content.title = "Mode activité réduite activé automatiquement"
                content.subtitle = "Vous avez quitté l'application."
                content.body = "L'application va continuer de fonctionner en arrière-plan en mode activité réduite."
                time = 10
                
            case .locFailed:
                content.title = "Localisation en arrière plan désactivée !"
                content.subtitle = "Erreur lors de la vérification du pays !"
                content.body = "Vérifiez dans les réglages de votre appareil que vous avez bien autorisé l'accès à vos données de localisation en arrière plan ou désactivez la vérification de pays dans l'application FMobile."
                time = 2
            
            case .saved:
                content.title = "Lieu non couvert sauvegardé !"
                content.body = "Après plusieurs tentatives, votre iPhone ne s'est pas reconnecté sur le réseau propre. La zone actuelle a été sauvegardée comme non couverte."
                time = 1
                
            case .batteryLow:
                content.title = "Mode activité réduite activé"
                content.body = "L'application va continuer de fonctionner en arrière-plan en mode activité réduite."
                time = 8
                
            case .restarting:
                content.title = "Mode économie d'énergie désactivé."
                content.body = "Vous n'avez plus besoin du mode éco. L'application reprend son mode de fonctionnement normal."
                time = 1
                
            case .newCountryNothing:
                content.title = arg
                content.body = "Aucune communication n'est incluse dans le forfait Free depuis ce pays."
                
            case .newCountryBasic:
                content.title = arg
                content.body = "Les appels, SMS et MMS sont inclus dans le forfait Free. Internet est indisponible."
                
            case .newCountryInternet:
                content.title = arg
                content.body = "25Go d'Internet sont inclus dans le forfait Free ! Les appels, SMS et MMS ne sont pas inclus."
                
            case .newCountryAll:
                content.title = arg
                content.body = "Les appels, SMS, MMS ainsi que 25Go d'Internet sont inclus dans le forfait Free !"
            
            case .alertDataDrain:
                content.title = "🛂⚠️🛑 HORS-FORFAIT EN COURS 🛑⚠️🆘"
                content.body = arg
            
            case .newSIM:
                content.title = "SIM card configuration changed!"
                content.body = "Please configure your new SIM card in the FMobile app."
                
            case .iPad:
                content.title = "Action de votre opérateur requise !"
                content.body = "Votre opérateur doit distribuer un fichier de configuration (Carrier Bundle) pour permettre à FMobile 2ème génération de fonctionner sur les iPad. Si votre opérateur veut aider ses abonnés, il est invité à distribuer ce fichier via une MÀJ opérateur. De plus, pour une compatibilité maximale, il est invité à vérifier la possibilité de retirer tous ses PLMN itinérants de ce même fichier sur iPhone."
                
            case .update:
                content.title = "Mise à jour effectuée"
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
    
    case allow2G3G, allow2G, allow3G, allowNone, allowDisabled, alertHPlus, alertPossibleHPlus, alertWCDMA, alertPossibleWCDMA, alertEdge, runningVerification, halt, locFailed, saved, batteryLow, restarting, newCountryNothing, newCountryBasic, newCountryInternet, newCountryAll, alertDataDrain, newSIM, iPad, update, custom
    
}
