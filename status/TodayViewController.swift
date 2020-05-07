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
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        text?.font = UIFont.preferredFont(forTextStyle: .body)
        text?.numberOfLines = 1
        text?.adjustsFontSizeToFitWidth = true
        
        let dataManager = DataManager()
        let country = CarrierIdentification.getIsoCountryCode(dataManager.connectedMCC)
        var status = ""
        
        dataManager.carrierNetwork = dataManager.carrierNetwork.replacingOccurrences(of: "CTRadioAccessTechnology", with: "", options: NSString.CompareOptions.literal, range: nil)
        dataManager.carrierNetwork2 = dataManager.carrierNetwork2.replacingOccurrences(of: "CTRadioAccessTechnology", with: "", options: NSString.CompareOptions.literal, range: nil)
        
        if dataManager.carrierNetwork == "LTE" {
            dataManager.carrierNetwork = "\(dataManager.carrier) 4G (LTE) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))"
            status = "✅"
        } else if dataManager.carrierNetwork == "WCDMA" {
            if dataManager.connectedMCC == dataManager.targetMCC && dataManager.connectedMNC == dataManager.targetMNC && dataManager.carrierNetwork == dataManager.nrp {
                status = "⚠️"
            } else {
                status = "✅"
            }
            if dataManager.connectedMCC == dataManager.targetMCC && dataManager.connectedMNC == dataManager.targetMNC && !DataManager.isWifiConnected() && dataManager.carrierNetwork == dataManager.nrp && dataManager.nrDEC {
                text?.text = "Veuillez patienter..."
                dataManager.carrierNetwork = "3G (WCDMA) [Vérification...]"
                Speedtest().testDownloadSpeedWithTimout(timeout: 5.0, usingURL: dataManager.url) { (speed, error) in
                    DispatchQueue.main.async {
                        if speed ?? 0 < dataManager.stms {
                            dataManager.carrierNetwork = "\(dataManager.itiName) 3G (WCDMA) [\(dataManager.targetMCC) \(dataManager.itiMNC)] (\(CarrierIdentification.getIsoCountryCode(dataManager.targetMCC)))"
                            guard let link = URL(string: "shortcuts://run-shortcut?name=RRFM") else { return }
                            self.extensionContext?.open(link, completionHandler: { success in
                                print("fun=success=\(success)")
                            })
                        } else {
                            dataManager.carrierNetwork = "\(dataManager.homeName) 3G (WCDMA) [\(dataManager.targetMCC) \(dataManager.targetMCC)] (\(CarrierIdentification.getIsoCountryCode(dataManager.targetMCC))"
                        }
                        self.text?.reloadInputViews()
                    }
                }
            }
            dataManager.carrierNetwork = "\(dataManager.carrier) 3G (WCDMA) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))"
        } else if dataManager.carrierNetwork == "HSDPA" {
            if dataManager.connectedMCC == dataManager.targetMCC && dataManager.connectedMNC == dataManager.targetMNC && dataManager.carrierNetwork == dataManager.nrp {
                status = "⚠️"
            } else {
                status = "✅"
            }
            if dataManager.connectedMCC == dataManager.targetMCC && dataManager.connectedMNC == dataManager.targetMNC && !DataManager.isWifiConnected() && dataManager.carrierNetwork == dataManager.nrp && dataManager.nrDEC {
                text?.text = "Veuillez patienter..."
                dataManager.carrierNetwork = "H+ (HSDPA) [Vérification...]"
                Speedtest().testDownloadSpeedWithTimout(timeout: 5.0, usingURL: dataManager.url) { (speed, error) in
                    DispatchQueue.main.async {
                        if speed ?? 0 < dataManager.stms {
                            dataManager.carrierNetwork = "\(dataManager.itiName) H+ (HSDPA) [\(dataManager.targetMCC) \(dataManager.itiMNC)] (\(CarrierIdentification.getIsoCountryCode(dataManager.targetMCC)))"
                            guard let link = URL(string: "shortcuts://run-shortcut?name=RRFM") else { return }
                            self.extensionContext?.open(link, completionHandler: { success in
                                print("fun=success=\(success)")
                            })
                        } else {
                            dataManager.carrierNetwork = "\(dataManager.homeName) H+ (HSDPA) [\(dataManager.targetMCC) \(dataManager.targetMCC)] (\(CarrierIdentification.getIsoCountryCode(dataManager.targetMCC))"
                        }
                        self.text?.reloadInputViews()
                    }
                }
            }
            dataManager.carrierNetwork = "\(dataManager.carrier) H+ (HSDPA) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))"
        } else if dataManager.carrierNetwork == "Edge"{
            dataManager.carrierNetwork = dataManager.connectedMCC == dataManager.targetMCC && dataManager.connectedMNC == dataManager.chasedMNC && dataManager.out2G == "yes" ?
                "\(dataManager.itiName) 2G (EDGE) [\(dataManager.targetMCC) \(dataManager.itiMNC)] (\(CarrierIdentification.getIsoCountryCode(dataManager.targetMCC)))" : "\(dataManager.carrier) 2G (EDGE) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))"
            status = "🛑"
        } else if dataManager.carrierNetwork == "GPRS"{
            dataManager.carrierNetwork = dataManager.connectedMCC == dataManager.targetMCC && dataManager.connectedMNC == dataManager.chasedMNC && dataManager.out2G == "yes" ?
                "\(dataManager.itiName) G (GPRS) [\(dataManager.targetMCC) \(dataManager.itiMNC)] (\(CarrierIdentification.getIsoCountryCode(dataManager.targetMCC)))" : "\(dataManager.carrier) G (GPRS) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))"
            status = "⛔️"
        } else if dataManager.carrierNetwork == "HRPD"{
            dataManager.carrierNetwork = "\(dataManager.carrier) 3G (HRPD) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))"
            status = "🛂"
        } else if dataManager.carrierNetwork == "HSUPA"{
            dataManager.carrierNetwork = "\(dataManager.carrier) H+ (HSUPA) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))"
            status = "🛂"
        } else if dataManager.carrierNetwork == "CDMA1x"{
            dataManager.carrierNetwork = "\(dataManager.carrier) 3G (CDMA2000) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))"
            status = "🛂"
        } else if dataManager.carrierNetwork == "CDMAEVDORev0"{
            dataManager.carrierNetwork = "\(dataManager.carrier) 3G (EvDO) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))"
            status = "🛂"
        } else if dataManager.carrierNetwork == "CDMAEVDORevA"{
            dataManager.carrierNetwork = "\(dataManager.carrier) 3G (EvDO-A) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))"
            status = "🛂"
        } else if dataManager.carrierNetwork == "CDMAEVDORevB"{
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
        
        if dataManager.carrierNetwork2 == "LTE" {
            dataManager.carrierNetwork2 = "4G (LTE)"
        } else if dataManager.carrierNetwork2 == "WCDMA" {
            dataManager.carrierNetwork2 = "3G (WCDMA)"
        } else if dataManager.carrierNetwork2 == "HSDPA" {
            dataManager.carrierNetwork2 = "H+ (HSDPA)"
        } else if dataManager.carrierNetwork2 == "Edge"{
            dataManager.carrierNetwork2 = "2G (EDGE)"
        } else if dataManager.carrierNetwork2 == "GPRS"{
            dataManager.carrierNetwork2 = "G (GPRS)"
        } else if dataManager.carrierNetwork2 == "HRPD"{
            dataManager.carrierNetwork2 = "3G++ (HRPD)"
        } else if dataManager.carrierNetwork2 == "HSUPA"{
            dataManager.carrierNetwork2 = "H++ (HSUPA)"
        } else if dataManager.carrierNetwork2 == "CDMA1x"{
            dataManager.carrierNetwork2 = "3G/2G+ (CDMA2000)"
        } else if dataManager.carrierNetwork2 == "CDMAEVDORev0"{
            dataManager.carrierNetwork2 = "3G (EvDO)"
        } else if dataManager.carrierNetwork2 == "CDMAEVDORevA"{
            dataManager.carrierNetwork2 = "3G (EvDO-A)"
        } else if dataManager.carrierNetwork2 == "CDMAEVDORevB"{
            dataManager.carrierNetwork2 = "3G (EvDO-B)"
        }
        
        print(dataManager.carrierNetwork)
        print(dataManager.carrierNetwork2)
        
        text?.text = "\(status) \(dataManager.carrierNetwork)"
        text?.textColor = UIColor.white
        text?.font = UIFont.boldSystemFont(ofSize: 17)
        text?.adjustsFontForContentSizeCategory = true
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        completionHandler(NCUpdateResult.newData)
    }
    
}
