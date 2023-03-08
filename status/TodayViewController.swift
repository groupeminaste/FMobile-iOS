//
//  TodayViewController.swift
//  status
//
//  Created by PlugN on 15/03/2019.
//  Copyright © 2019 Groupe MINASTE. All rights reserved.
//

import UIKit
import NotificationCenter
import CoreLocation
import UIKit
import CoreData
import CoreTelephony
import NetworkExtension
import SystemConfiguration
import SystemConfiguration.CaptiveNetwork
import UserNotifications
import Foundation
import CallKit

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var text: UILabel?
    
    // Petite info importante,
    // Tu vas devoir t'amuser à traduire le widget aussi
    // Pour ça tu fais comme d'habitude
    // "id_de_la_string".localised()
    // Et tu mets les références dans le fichier de traduction habituel
    // (Localizable.strings de FMobile avec les autres trads)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        text?.font = UIFont.preferredFont(forTextStyle: .body)
        text?.numberOfLines = 1
        text?.adjustsFontSizeToFitWidth = true
        
        let dataManager = DataManager()
        let country = dataManager.current.network.land
        var status = ""
        
        DataManager.getCurrentWifi { (wifi) in
            if #available(iOS 14.1, *), (dataManager.current.network.connected == CTRadioAccessTechnologyNR && (dataManager.allow015G || (dataManager.modeExpert ? false : !dataManager.current.card.roam5G))) || (dataManager.current.network.connected == CTRadioAccessTechnologyNRNSA && (dataManager.allow015G || (dataManager.modeExpert ? false : !dataManager.current.card.roam5G))) {
                dataManager.current.network.connected = "\(dataManager.current.network.name) 5G (\(dataManager.current.network.connected == CTRadioAccessTechnologyNR ? "NR" : "NR NSA") [\(dataManager.current.network.mcc) \(dataManager.current.network.mnc)] (\(country))"
                status = "✅"
            } else if #available(iOS 14.1, *), dataManager.current.network.connected == CTRadioAccessTechnologyNR || dataManager.current.network.connected == CTRadioAccessTechnologyNRNSA {
                if dataManager.current.network.mcc == dataManager.current.card.mcc && dataManager.current.network.mnc == dataManager.current.card.mnc && (dataManager.current.network.connected == CTRadioAccessTechnologyNR || dataManager.current.network.connected == CTRadioAccessTechnologyNRNSA) && dataManager.current.card.nrdec {
                    status = "⚠️"
                } else {
                    status = "✅"
                }
                if dataManager.current.network.mcc == dataManager.current.card.mcc && dataManager.current.network.mnc == dataManager.current.card.chasedMNC && wifi == nil && dataManager.current.card.nrdec {
                    self.text?.text = "Veuillez patienter..."
                    dataManager.current.network.connected = "\(dataManager.current.network.name) 5G (\(dataManager.current.network.connected == CTRadioAccessTechnologyNR ? "NR" : "NR NSA") [Vérification...]"
                    Speedtest().testDownloadSpeedWithTimout(timeout: 5.0, usingURL: dataManager.url) { (speed, _) in
                        DispatchQueue.main.async {
                            if speed ?? 0 < dataManager.current.card.stms {
                                dataManager.current.network.connected = "\(dataManager.current.card.itiName) 5G (\(dataManager.current.network.connected == CTRadioAccessTechnologyNR ? "NR" : "NR NSA") [\(dataManager.current.network.mcc) \(dataManager.current.card.itiMNC)] (\(country))"
                                guard let link = DataManager.getShortcutURL() else { return }
                                self.extensionContext?.open(link, completionHandler: { success in
                                    print("fun=success=\(success)")
                                })
                            } else {
                                dataManager.current.network.connected = "\(dataManager.current.network.name) 5G (\(dataManager.current.network.connected == CTRadioAccessTechnologyNR ? "NR" : "NR NSA") [\(dataManager.current.network.mcc) \(dataManager.current.network.mnc)] (\(country)"
                            }
                            self.text?.reloadInputViews()
                        }
                    }
                } else if dataManager.current.network.mcc == dataManager.current.card.mcc && dataManager.current.network.mnc == dataManager.current.card.itiMNC {
                    dataManager.current.network.connected = "\(dataManager.current.card.itiName) 5G (\(dataManager.current.network.connected == CTRadioAccessTechnologyNR ? "NR" : "NR NSA") [\(dataManager.current.network.mcc) \(dataManager.current.card.itiMNC)] (\(country))"
                    guard let link = DataManager.getShortcutURL() else { return }
                    self.extensionContext?.open(link, completionHandler: { success in
                        print("fun=success=\(success)")
                    })
                    self.text?.reloadInputViews()
                } else {
                    dataManager.current.network.connected = "\(dataManager.current.network.name) 5G (\(dataManager.current.network.connected == CTRadioAccessTechnologyNR ? "NR" : "NR NSA") [\(dataManager.current.network.mcc) \(dataManager.current.network.mnc)] (\(country))"
                }
                
            }
            
            
            else if (dataManager.current.network.connected == CTRadioAccessTechnologyLTE && (dataManager.allow014G || (dataManager.modeExpert ? false : !dataManager.current.card.roamLTE))) {
                dataManager.current.network.connected = "\(dataManager.current.network.name) 4G (LTE) [\(dataManager.current.network.mcc) \(dataManager.current.network.mnc)] (\(country))"
                status = "✅"
            } else if dataManager.current.network.connected == CTRadioAccessTechnologyLTE {
                if dataManager.current.network.mcc == dataManager.current.card.mcc && dataManager.current.network.mnc == dataManager.current.card.mnc && dataManager.current.network.connected == CTRadioAccessTechnologyLTE && dataManager.current.card.nrdec {
                    status = "⚠️"
                } else {
                    status = "✅"
                }
                if dataManager.current.network.mcc == dataManager.current.card.mcc && dataManager.current.network.mnc == dataManager.current.card.chasedMNC && wifi == nil && dataManager.current.card.nrdec {
                    self.text?.text = "Veuillez patienter..."
                    dataManager.current.network.connected = "\(dataManager.current.network.name) 4G (LTE) [Vérification...]"
                    Speedtest().testDownloadSpeedWithTimout(timeout: 5.0, usingURL: dataManager.url) { (speed, _) in
                        DispatchQueue.main.async {
                            if speed ?? 0 < dataManager.current.card.stms {
                                dataManager.current.network.connected = "\(dataManager.current.card.itiName) 4G (LTE) [\(dataManager.current.network.mcc) \(dataManager.current.card.itiMNC)] (\(country))"
                                if #available(iOS 12.0, *) {
                                guard let link = DataManager.getShortcutURL() else { return }
                                self.extensionContext?.open(link, completionHandler: { success in
                                    print("fun=success=\(success)")
                                })
                                }
                            } else {
                                dataManager.current.network.connected = "\(dataManager.current.network.name) 4G (LTE) [\(dataManager.current.network.mcc) \(dataManager.current.network.mnc)] (\(country)"
                            }
                            self.text?.reloadInputViews()
                        }
                    }
                } else if dataManager.current.network.mcc == dataManager.current.card.mcc && dataManager.current.network.mnc == dataManager.current.card.itiMNC {
                    dataManager.current.network.connected = "\(dataManager.current.card.itiName) 4G (LTE) [\(dataManager.current.network.mcc) \(dataManager.current.card.itiMNC)] (\(country))"
                    if #available(iOS 12.0, *) {
                    guard let link = DataManager.getShortcutURL() else { return }
                    self.extensionContext?.open(link, completionHandler: { success in
                        print("fun=success=\(success)")
                    })
                    }
                    self.text?.reloadInputViews()
                } else {
                    dataManager.current.network.connected = "\(dataManager.current.network.name) 4G (LTE) [\(dataManager.current.network.mcc) \(dataManager.current.network.mnc)] (\(country))"
                }
                
            } else if dataManager.current.network.connected == CTRadioAccessTechnologyWCDMA {
                if dataManager.current.network.mcc == dataManager.current.card.mcc && dataManager.current.network.mnc == dataManager.current.card.mnc && dataManager.current.network.connected == dataManager.current.card.nrp && dataManager.current.card.nrdec{
                    status = "⚠️"
                } else {
                    status = "✅"
                }
                if dataManager.current.network.mcc == dataManager.current.card.mcc && dataManager.current.network.mnc == dataManager.current.card.mnc && wifi == nil && dataManager.current.network.connected == dataManager.current.card.nrp && dataManager.current.card.nrdec {
                    self.text?.text = "Veuillez patienter..."
                    dataManager.current.network.connected = "\(dataManager.current.network.name) 3G (WCDMA) [Vérification...]"
                    Speedtest().testDownloadSpeedWithTimout(timeout: 5.0, usingURL: dataManager.url) { (speed, _) in
                        DispatchQueue.main.async {
                            if speed ?? 0 < dataManager.current.card.stms {
                                dataManager.current.network.connected = "\(dataManager.current.card.itiName) 3G (WCDMA) [\(dataManager.current.network.mcc) \(dataManager.current.card.itiMNC)] (\(country))"
                                if #available(iOS 12.0, *) {
                                guard let link = DataManager.getShortcutURL() else { return }
                                self.extensionContext?.open(link, completionHandler: { success in
                                    print("fun=success=\(success)")
                                })
                                }
                            } else {
                                dataManager.current.network.connected = "\(dataManager.current.network.name) 3G (WCDMA) [\(dataManager.current.network.mcc) \(dataManager.current.network.mnc)] (\(country)"
                            }
                            self.text?.reloadInputViews()
                        }
                    }
                } else if dataManager.current.network.mcc == dataManager.current.card.mcc && dataManager.current.network.mnc == dataManager.current.card.itiMNC {
                    dataManager.current.network.connected = "\(dataManager.current.card.itiName) 3G (WCDMA) [\(dataManager.current.network.mcc) \(dataManager.current.card.itiMNC)] (\(country))"
                    if #available(iOS 12.0, *) {
                    guard let link = DataManager.getShortcutURL() else { return }
                    self.extensionContext?.open(link, completionHandler: { success in
                        print("fun=success=\(success)")
                    })
                    }
                    self.text?.reloadInputViews()
                } else {
                    dataManager.current.network.connected = "\(dataManager.current.network.name) 3G (WCDMA) [\(dataManager.current.network.mcc) \(dataManager.current.network.mnc)] (\(country))"
                }
                
            } else if dataManager.current.network.connected == CTRadioAccessTechnologyHSDPA {
                if dataManager.current.network.mcc == dataManager.current.card.mcc && dataManager.current.network.mnc == dataManager.current.card.mnc && dataManager.current.network.connected == dataManager.current.card.nrp && dataManager.current.card.nrdec{
                    status = "⚠️"
                } else {
                    status = "✅ \(dataManager.current.card.chasedMNC)"
                }
                if dataManager.current.network.mcc == dataManager.current.card.mcc && dataManager.current.network.mnc == dataManager.current.card.mnc && wifi == nil && dataManager.current.network.connected == dataManager.current.card.nrp && dataManager.current.card.nrdec {
                    self.text?.text = "Veuillez patienter..."
                    dataManager.current.network.connected = "\(dataManager.current.network.name) 3G (HSDPA) [Vérification...]"
                    Speedtest().testDownloadSpeedWithTimout(timeout: 5.0, usingURL: dataManager.url) { (speed, _) in
                        DispatchQueue.main.async {
                            if speed ?? 0 < dataManager.current.card.stms {
                                dataManager.current.network.connected = "\(dataManager.current.card.itiName) 3G (HSDPA) [\(dataManager.current.network.mcc) \(dataManager.current.card.itiMNC)] (\(country))"
                                if #available(iOS 12.0, *) {
                                guard let link = DataManager.getShortcutURL() else { return }
                                self.extensionContext?.open(link, completionHandler: { success in
                                    print("fun=success=\(success)")
                                })
                                }
                            } else {
                                dataManager.current.network.connected = "\(dataManager.current.network.name) 3G (HSDPA) [\(dataManager.current.network.mcc) \(dataManager.current.network.mnc)] (\(country)"
                            }
                            self.text?.reloadInputViews()
                        }
                    }
                } else if dataManager.current.network.mcc == dataManager.current.card.mcc && dataManager.current.network.mnc == dataManager.current.card.itiMNC {
                    dataManager.current.network.connected = "\(dataManager.current.card.itiName) 3G (HSDPA) [\(dataManager.current.network.mcc) \(dataManager.current.card.itiMNC)] (\(country))"
                    if #available(iOS 12.0, *) {
                    guard let link = DataManager.getShortcutURL() else { return }
                    self.extensionContext?.open(link, completionHandler: { success in
                        print("fun=success=\(success)")
                    })
                    }
                    self.text?.reloadInputViews()
                } else {
                    dataManager.current.network.connected = "\(dataManager.current.network.name) 3G (HSDPA) [\(dataManager.current.network.mcc) \(dataManager.current.network.mnc)] (\(country))"
                }
                
            } else if dataManager.current.network.connected == CTRadioAccessTechnologyEdge {
                dataManager.current.network.connected = dataManager.current.network.mcc == dataManager.current.card.mcc && dataManager.current.network.mnc == dataManager.current.card.chasedMNC && dataManager.current.card.out2G ?
                    "\(dataManager.current.card.itiName) 2G (EDGE) [\(dataManager.current.network.mcc) \(dataManager.current.card.itiMNC)] (\(country))" : "\(dataManager.current.network.name) 2G (EDGE) [\(dataManager.current.network.mcc) \(dataManager.current.network.mnc)] (\(country))"
                status = "🛑"
            } else if dataManager.current.network.connected == "GPRS"{
                dataManager.current.network.connected = dataManager.current.network.mcc == dataManager.current.card.mcc && dataManager.current.network.mnc == dataManager.current.card.chasedMNC && dataManager.current.card.out2G ?
                    "\(dataManager.current.card.itiName) G (GPRS) [\(dataManager.current.network.mcc) \(dataManager.current.card.itiMNC)] (\(country))" : "\(dataManager.current.network.name) G (GPRS) [\(dataManager.current.network.mcc) \(dataManager.current.network.mnc)] (\(country))"
                status = "⛔️"
            } else if dataManager.current.network.connected == CTRadioAccessTechnologyeHRPD {
                dataManager.current.network.connected = "\(dataManager.current.network.name) 3G (eHRPD) [\(dataManager.current.network.mcc) \(dataManager.current.network.mnc)] (\(country))"
                status = "🛂"
            } else if dataManager.current.network.connected == CTRadioAccessTechnologyHSUPA {
                dataManager.current.network.connected = "\(dataManager.current.network.name) 3G (HSUPA) [\(dataManager.current.network.mcc) \(dataManager.current.network.mnc)] (\(country))"
                status = "🛂"
            } else if dataManager.current.network.connected == CTRadioAccessTechnologyCDMA1x {
                dataManager.current.network.connected = "\(dataManager.current.network.name) 3G (CDMA2000) [\(dataManager.current.network.mcc) \(dataManager.current.network.mnc)] (\(country))"
                status = "🛂"
            } else if dataManager.current.network.connected == CTRadioAccessTechnologyCDMAEVDORev0 {
                dataManager.current.network.connected = "\(dataManager.current.network.name) 3G (EvDO) [\(dataManager.current.network.mcc) \(dataManager.current.network.mnc)] (\(country))"
                status = "🛂"
            } else if dataManager.current.network.connected == CTRadioAccessTechnologyCDMAEVDORevA {
                dataManager.current.network.connected = "\(dataManager.current.network.name) 3G (EvDO-A) [\(dataManager.current.network.mcc) \(dataManager.current.network.mnc)] (\(country))"
                status = "🛂"
            } else if dataManager.current.network.connected == CTRadioAccessTechnologyCDMAEVDORevB {
                dataManager.current.network.connected = "\(dataManager.current.network.name) 3G (EvDO-B) [\(dataManager.current.network.mcc) \(dataManager.current.network.mnc)] (\(country))"
                status = "🛂"
            }
        
            if dataManager.current.network.connected == "" {
                dataManager.current.network.connected = "Réseau cellulaire indisponible"
                status = "❌"
            }
            if wifi != nil {
                dataManager.current.network.connected = dataManager.current.network.connected + " (Wi-Fi)"
            }
            
            print(dataManager.current.network.connected)
            
            self.text?.text = "\(status) \(dataManager.current.network.connected)"
        }
        
    }
        
    @available(iOSApplicationExtension 10.0, *)
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        completionHandler(NCUpdateResult.newData)
    }
    
}
