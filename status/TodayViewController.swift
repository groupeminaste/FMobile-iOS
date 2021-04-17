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
        let country = CarrierIdentification.getIsoCountryCode(dataManager.connectedMCC, dataManager.connectedMNC)
        var status = ""
        
        if dataManager.carrierNetwork == CTRadioAccessTechnologyLTE {
            dataManager.carrierNetwork = "\(dataManager.carrier) 4G (LTE) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))"
            status = "✅"
        } else if dataManager.carrierNetwork == CTRadioAccessTechnologyWCDMA {
            if dataManager.connectedMCC == dataManager.targetMCC && dataManager.connectedMNC == dataManager.targetMNC && dataManager.carrierNetwork == dataManager.nrp && dataManager.isNRDECstatus(){
                status = "⚠️"
            } else {
                status = "✅"
            }
            if dataManager.connectedMCC == dataManager.targetMCC && dataManager.connectedMNC == dataManager.targetMNC && !DataManager.isWifiConnected() && dataManager.carrierNetwork == dataManager.nrp && dataManager.isNRDECstatus() {
                text?.text = "Veuillez patienter..."
                dataManager.carrierNetwork = "\(dataManager.carrier) 3G (WCDMA) [Vérification...]"
                Speedtest().testDownloadSpeedWithTimout(timeout: 5.0, usingURL: dataManager.url) { (speed, error) in
                    DispatchQueue.main.async {
                        if speed ?? 0 < dataManager.stms {
                            dataManager.carrierNetwork = "\(dataManager.itiName) 3G (WCDMA) [\(dataManager.connectedMCC) \(dataManager.itiMNC)] (\(country))"
                            if #available(iOS 12.0, *) {
                            guard let link = URL(string: "shortcuts://run-shortcut?name=ANIRC") else { return }
                            self.extensionContext?.open(link, completionHandler: { success in
                                print("fun=success=\(success)")
                            })
                            }
                        } else {
                            dataManager.carrierNetwork = "\(dataManager.carrier) 3G (WCDMA) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country)"
                        }
                        self.text?.reloadInputViews()
                    }
                }
            } else if dataManager.connectedMCC == dataManager.targetMCC && dataManager.connectedMNC == dataManager.itiMNC {
                dataManager.carrierNetwork = "\(dataManager.itiName) 3G (WCDMA) [\(dataManager.connectedMCC) \(dataManager.itiMNC)] (\(country))"
                if #available(iOS 12.0, *) {
                guard let link = URL(string: "shortcuts://run-shortcut?name=ANIRC") else { return }
                self.extensionContext?.open(link, completionHandler: { success in
                    print("fun=success=\(success)")
                })
                }
                self.text?.reloadInputViews()
            } else {
                dataManager.carrierNetwork = "\(dataManager.carrier) 3G (WCDMA) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))"
            }
            
        } else if dataManager.carrierNetwork == CTRadioAccessTechnologyHSDPA {
            if dataManager.connectedMCC == dataManager.targetMCC && dataManager.connectedMNC == dataManager.targetMNC && dataManager.carrierNetwork == dataManager.nrp && dataManager.isNRDECstatus(){
                status = "⚠️"
            } else {
                status = "✅ \(dataManager.chasedMNC)"
            }
            if dataManager.connectedMCC == dataManager.targetMCC && dataManager.connectedMNC == dataManager.targetMNC && !DataManager.isWifiConnected() && dataManager.carrierNetwork == dataManager.nrp && dataManager.isNRDECstatus() {
                text?.text = "Veuillez patienter..."
                dataManager.carrierNetwork = "\(dataManager.carrier) 3G (HSDPA) [Vérification...]"
                Speedtest().testDownloadSpeedWithTimout(timeout: 5.0, usingURL: dataManager.url) { (speed, error) in
                    DispatchQueue.main.async {
                        if speed ?? 0 < dataManager.stms {
                            dataManager.carrierNetwork = "\(dataManager.itiName) 3G (HSDPA) [\(dataManager.connectedMCC) \(dataManager.itiMNC)] (\(country))"
                            if #available(iOS 12.0, *) {
                            guard let link = URL(string: "shortcuts://run-shortcut?name=ANIRC") else { return }
                            self.extensionContext?.open(link, completionHandler: { success in
                                print("fun=success=\(success)")
                            })
                            }
                        } else {
                            dataManager.carrierNetwork = "\(dataManager.carrier) 3G (HSDPA) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country)"
                        }
                        self.text?.reloadInputViews()
                    }
                }
            } else if dataManager.connectedMCC == dataManager.targetMCC && dataManager.connectedMNC == dataManager.itiMNC {
                dataManager.carrierNetwork = "\(dataManager.itiName) 3G (HSDPA) [\(dataManager.connectedMCC) \(dataManager.itiMNC)] (\(country))"
                if #available(iOS 12.0, *) {
                guard let link = URL(string: "shortcuts://run-shortcut?name=ANIRC") else { return }
                self.extensionContext?.open(link, completionHandler: { success in
                    print("fun=success=\(success)")
                })
                }
                self.text?.reloadInputViews()
            } else {
                dataManager.carrierNetwork = "\(dataManager.carrier) 3G (HSDPA) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))"
            }
            
        } else if dataManager.carrierNetwork == CTRadioAccessTechnologyEdge {
            dataManager.carrierNetwork = dataManager.connectedMCC == dataManager.targetMCC && dataManager.connectedMNC == dataManager.chasedMNC && dataManager.out2G ?
                "\(dataManager.itiName) 2G (EDGE) [\(dataManager.connectedMCC) \(dataManager.itiMNC)] (\(country))" : "\(dataManager.carrier) 2G (EDGE) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))"
            status = "🛑"
        } else if dataManager.carrierNetwork == "GPRS"{
            dataManager.carrierNetwork = dataManager.connectedMCC == dataManager.targetMCC && dataManager.connectedMNC == dataManager.chasedMNC && dataManager.out2G ?
                "\(dataManager.itiName) G (GPRS) [\(dataManager.connectedMCC) \(dataManager.itiMNC)] (\(country))" : "\(dataManager.carrier) G (GPRS) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))"
            status = "⛔️"
        } else if dataManager.carrierNetwork == CTRadioAccessTechnologyeHRPD {
            dataManager.carrierNetwork = "\(dataManager.carrier) 3G (eHRPD) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))"
            status = "🛂"
        } else if dataManager.carrierNetwork == CTRadioAccessTechnologyHSUPA {
            dataManager.carrierNetwork = "\(dataManager.carrier) 3G (HSUPA) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))"
            status = "🛂"
        } else if dataManager.carrierNetwork == CTRadioAccessTechnologyCDMA1x {
            dataManager.carrierNetwork = "\(dataManager.carrier) 3G (CDMA2000) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))"
            status = "🛂"
        } else if dataManager.carrierNetwork == CTRadioAccessTechnologyCDMAEVDORev0 {
            dataManager.carrierNetwork = "\(dataManager.carrier) 3G (EvDO) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))"
            status = "🛂"
        } else if dataManager.carrierNetwork == CTRadioAccessTechnologyCDMAEVDORevA {
            dataManager.carrierNetwork = "\(dataManager.carrier) 3G (EvDO-A) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))"
            status = "🛂"
        } else if dataManager.carrierNetwork == CTRadioAccessTechnologyCDMAEVDORevB {
            dataManager.carrierNetwork = "\(dataManager.carrier) 3G (EvDO-B) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))"
            status = "🛂"
        }
    
        if dataManager.carrierNetwork == "" {
            dataManager.carrierNetwork = "Réseau cellulaire indisponible"
            status = "❌"
        }
        if DataManager.isWifiConnected() {
            dataManager.carrierNetwork = dataManager.carrierNetwork + " (Wi-Fi)"
        }
        
        print(dataManager.carrierNetwork)
        
        text?.text = "\(status) \(dataManager.carrierNetwork)"
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        completionHandler(NCUpdateResult.newData)
    }
    
}
