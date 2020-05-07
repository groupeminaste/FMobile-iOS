//
//  AppDelegate.swift
//  FMobile
//
//  Created by Michaël Nass on 29/09/2018.
//  Copyright © 2018 Groupe MINASTE. All rights reserved.
//

import UIKit
import CoreData
import CoreTelephony
import NetworkExtension
import SystemConfiguration
import SystemConfiguration.CaptiveNetwork
import UserNotifications
import Foundation
import CoreLocation
import CallKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, CLLocationManagerDelegate {

    // Variables de la classe
    var window: UIWindow?
    var timer: Timer?
   
    // -----
    // FONCTIONS UTILITAIRES
    // -----
    
    func delay(_ delay:Double, closure: @escaping () -> ()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
    
    static func geocode(latitude: Double, longitude: Double, completion: @escaping (CLPlacemark?, Error?) -> ())  {
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: latitude, longitude: longitude)) {
            completion($0?.first, $1)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let error = error as? CLError, error.code == .denied {
            // Location updates are not authorized.
            manager.stopMonitoringSignificantLocationChanges()
            return
        }
        print(error)
        // Notify the user of any errors.
    }
    
    static func checkDataDisabled(_ dataManager: DataManager = DataManager()){
        let country = CarrierIdentification.getIsoCountryCode(String(dataManager.connectedMCC)).uppercased()
        
        if DataManager.isConnectedToNetwork() && !DataManager.isWifiConnected() && dataManager.connectedMCC != "208" && dataManager.targetMCC == "208" && dataManager.targetMNC == "15" && dataManager.freeZoneCheck() == "OUTZONE" {
            NotificationManager.sendNotification(for: .alertDataDrain, with: "data_drain_notification_description".localized().format([dataManager.carrier, country]))
            return
        }
        
        if DataManager.isConnectedToNetwork() && !DataManager.isWifiConnected() && dataManager.connectedMCC != "208" && dataManager.targetMCC == "208" && dataManager.targetMNC != "15" && (dataManager.zoneCheck() == "OUTZONE" || dataManager.zoneCheck() == "CALLS") {
            NotificationManager.sendNotification(for: .alertDataDrain, with: "data_drain_notification_description".localized().format([dataManager.carrier, country]))
            return
        }
    }
    
    static func newCountryCheck(_ dataManager: DataManager = DataManager()){
        let country = CarrierIdentification.getIsoCountryCode(dataManager.connectedMCC).uppercased()
        
        if country == "--"{
            return
        }
        
        var simpleNetwork = ""
        if dataManager.carrierNetwork == "CTRadioAccessTechnologyLTE" {
            simpleNetwork = "4G"
        } else if dataManager.carrierNetwork == "CTRadioAccessTechnologyEdge" {
            simpleNetwork = "E"
        } else if dataManager.carrierNetwork == "CTRadioAccessTechnologyGPRS" {
            simpleNetwork = "GPRS"
        } else {
            simpleNetwork = "3G"
        }
        
        if dataManager.targetMCC == "208" && dataManager.targetMNC == "15" && dataManager.connectedMCC != "208" {
            // ATTENTION TRAITER LES EXCEPTIONS EN PREMIER ! Changer le country en fonction du MNC !
            if dataManager.freeZoneCheck() == "ALL" {
                NotificationManager.sendNotification(for: .newCountryAllFree, with: "new_country_welcome_title".localized().format([dataManager.carrier, simpleNetwork, country]))
            } else if dataManager.freeZoneCheck() == "CALLS"{
                NotificationManager.sendNotification(for: .newCountryBasicFree, with: "new_country_welcome_title".localized().format([dataManager.carrier, simpleNetwork, country]))
            } else if dataManager.freeZoneCheck() == "INTERNET"{
                NotificationManager.sendNotification(for: .newCountryInternetFree, with: "new_country_welcome_title".localized().format([dataManager.carrier, simpleNetwork, country]))
            } else {
                NotificationManager.sendNotification(for: .newCountryNothingFree, with: "new_country_welcome_title".localized().format([dataManager.carrier, simpleNetwork, country]))
            }
        } else if dataManager.targetMCC == "208" && dataManager.connectedMCC != "208" && dataManager.targetMNC != "15" {
            // ATTENTION TRAITER LES EXCEPTIONS EN PREMIER ! Changer le country en fonction du MNC !
            if dataManager.zoneCheck() == "ALL" {
                NotificationManager.sendNotification(for: .newCountryAll, with: "new_country_welcome_title".localized().format([dataManager.carrier, simpleNetwork, country]))
            } else if dataManager.zoneCheck() == "CALLS"{
                NotificationManager.sendNotification(for: .newCountryBasic, with: "new_country_welcome_title".localized().format([dataManager.carrier, simpleNetwork, country]))
            } else if dataManager.zoneCheck() == "INTERNET"{
                NotificationManager.sendNotification(for: .newCountryInternet, with: "new_country_welcome_title".localized().format([dataManager.carrier, simpleNetwork, country]))
            } else {
                NotificationManager.sendNotification(for: .newCountryNothing, with: "new_country_welcome_title".localized().format([dataManager.carrier, simpleNetwork, country]))
            }
        }
        
    }
    
    static func autosetup(_ dataManager: DataManager = DataManager()){
        if dataManager.mycarrier.mobileCountryCode == "208" && dataManager.mycarrier.mobileNetworkCode == "15"{
            
            dataManager.datas.set(0.768, forKey: "STMS")
            dataManager.datas.set("WCDMA", forKey: "HP")
            dataManager.datas.set("HSDPA", forKey: "NRP")
            dataManager.datas.set(dataManager.mycarrier.mobileCountryCode ?? "---", forKey: "MCC")
            dataManager.datas.set(dataManager.mycarrier.mobileNetworkCode ?? "--", forKey: "MNC")
            dataManager.datas.set(dataManager.mycarrier.isoCountryCode?.uppercased() ?? "--", forKey: "LAND")
            dataManager.datas.set("Orange F", forKey: "ITINAME")
            dataManager.datas.set("Free", forKey: "HOMENAME")
            dataManager.datas.set("01", forKey: "ITIMNC")
            dataManager.datas.set("yes", forKey: "NRFEMTO")
            dataManager.datas.set("yes", forKey: "OUT2G")
            dataManager.datas.set(true, forKey: "setupDone")
            dataManager.datas.set(false, forKey: "minimalSetup")
            dataManager.datas.set(false, forKey: "disableFMobileCore")
            dataManager.datas.synchronize()
        } else if dataManager.mycarrier.mobileCountryCode == "208" {
            dataManager.datas.set(50000, forKey: "STMS")
            dataManager.datas.set("NONE", forKey: "HP")
            dataManager.datas.set("NONE", forKey: "NRP")
            dataManager.datas.set(dataManager.mycarrier.mobileCountryCode ?? "---", forKey: "MCC")
            dataManager.datas.set(dataManager.mycarrier.mobileNetworkCode ?? "--", forKey: "MNC")
            dataManager.datas.set(dataManager.mycarrier.isoCountryCode?.uppercased() ?? "--", forKey: "LAND")
            dataManager.datas.set("FMobile", forKey: "ITINAME")
            dataManager.datas.set("FMobile", forKey: "HOMENAME")
            dataManager.datas.set("99", forKey: "ITIMNC")
            dataManager.datas.set("no", forKey: "NRFEMTO")
            dataManager.datas.set("no", forKey: "OUT2G")
            dataManager.datas.set(true, forKey: "setupDone")
            dataManager.datas.set(true, forKey: "minimalSetup")
            dataManager.datas.set(true, forKey: "disableFMobileCore")
            dataManager.datas.synchronize()
        }
    }
    
    static func sendLocationToServer(latitude: Double, longitude: Double) {
        // Envoi des coordonnées à l'API
        
        print("Envoie des coordonnées à l'API : (\(latitude), \(longitude))")
        APIRequest("GET", path: "/roaming/location.php").with(name: "latitude", value: latitude).with(name: "longitude", value: longitude).execute(Bool.self, completionHandler: { (data, status) in
            if let data = data, data {
                print("Coordonnées envoyées avec succès !")
            } else {
                print("Une erreur est survenue lors de l'envoi des coordonnées (status: \(status)")
            }
        })
    }
    
    static func engineRunning(locations: [CLLocation] = [CLLocation]()){
        print("TRIGGERED")
        
        let dataManager = DataManager()
        
        var allowCountryDetection = true
        if(dataManager.datas.value(forKey: "allowCountryDetection") != nil){
            allowCountryDetection = dataManager.datas.value(forKey: "allowCountryDetection") as? Bool ?? true
        }
        
        if !dataManager.setupDone {
            if dataManager.mycarrier.mobileCountryCode == "208" && dataManager.mycarrier.mobileNetworkCode == "15" {
                AppDelegate.autosetup(dataManager)
            }
            return
        }
        
        if !dataManager.stopverification {
            var lastConnectedCountry = "208"
            if dataManager.datas.value(forKey: "lastConnectedCountry") != nil {
                lastConnectedCountry = dataManager.datas.value(forKey: "lastConnectedCountry") as? String ?? "208"
            }
            
            //print(lastLocation)
            
            let hour = Calendar.current.component(.hour, from: Date())
            
            if hour > 0 && hour < 6{
                print("FMobile fait un gros dodo")
                return
            }
            
            if allowCountryDetection{
                AppDelegate.checkDataDisabled(dataManager)
            }
            
            if DataManager.isOnPhoneCall() {
                print("IN CALL...")
                return
            }
            
            let country = CarrierIdentification.getIsoCountryCode(String(dataManager.connectedMCC)).uppercased()
            
            print(dataManager.carrierNetwork)
            
            if lastConnectedCountry != country{
                AppDelegate.newCountryCheck(dataManager)
                dataManager.datas.set(country, forKey: "lastConnectedCountry")
                dataManager.datas.synchronize()
            }
            
            var land = "FR"
            if dataManager.datas.value(forKey: "LAND") != nil {
                land = dataManager.datas.value(forKey: "LAND") as? String ?? "FR"
            }
            
            let countryCode = dataManager.mycarrier.mobileCountryCode ?? "null"
            print(countryCode)
            
            let mobileNetworkName = dataManager.mycarrier.mobileNetworkCode ?? "null"
            print(mobileNetworkName)
            
            if (countryCode != dataManager.targetMCC || mobileNetworkName != dataManager.targetMNC) && (mobileNetworkName != "null" || countryCode != "null") {
                dataManager.datas.removeObject(forKey: "MCC")
                dataManager.datas.set(false, forKey: "setupDone")
                dataManager.datas.synchronize()
                NotificationManager.sendNotification(for: .newSIM)
                return
            }
            
            print(dataManager.hp)
            if dataManager.carrierNetwork == "CTRadioAccessTechnology\(dataManager.hp)" || dataManager.carrierNetwork == "CTRadioAccessTechnologyLTE" {
                print("LTE/3G => SKIP")
                dataManager.lastnet = dataManager.carrierNetwork
                dataManager.count = 0
                dataManager.wasEnabled = false
                dataManager.datas.set(dataManager.lastnet, forKey: "lastnet")
                dataManager.datas.set(dataManager.count, forKey: "count")
                dataManager.datas.set(dataManager.wasEnabled, forKey: "wasEnabled")
                dataManager.datas.synchronize()
                return
            }
            
            if country != land {
                print("Country != land!")
                print(country)
                print(land)
                return
            }
            
            if dataManager.minimalSetup && dataManager.connectedMCC == dataManager.targetMCC && dataManager.connectedMNC != dataManager.targetMNC {
                let speed = locations.last?.speed ?? 0
                print("The current speed is ", speed * 3.6, "km/h.")
                if speed * 3.6 > 80 {
                    print("l'utilisateur va à une vitesse ne le permettant pas de rester accroché à une antenne Free (route de campagne/autoroute/TGV).")
                    return
                }
                
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                    if dataManager.carrierNetwork == "CTRadioAccessTechnologyHSDPA" {
                        NotificationManager.sendNotification(for: .alertHPlus)
                    } else if dataManager.carrierNetwork == "CTRadioAccessTechnologyWCDMA" {
                       NotificationManager.sendNotification(for: .alertWCDMA)
                    }
                    
                    if dataManager.statisticsAgreement{
                        AppDelegate.sendLocationToServer(latitude: locations.last?.coordinate.latitude ?? 0, longitude: locations.last?.coordinate.longitude ?? 0)
                    }
                    
                    return
                }
                
                let currlat = locations.last?.coordinate.latitude ?? 0
                let currlon = locations.last?.coordinate.longitude ?? 0
                
                if currlat == 0 && currlon == 0 {
                    if dataManager.carrierNetwork == "CTRadioAccessTechnologyHSDPA" {
                        NotificationManager.sendNotification(for: .alertHPlus)
                    } else if dataManager.carrierNetwork == "CTRadioAccessTechnologyWCDMA" {
                        NotificationManager.sendNotification(for: .alertWCDMA)
                    }
                    
                    if dataManager.statisticsAgreement{
                        AppDelegate.sendLocationToServer(latitude: locations.last?.coordinate.latitude ?? 0, longitude: locations.last?.coordinate.longitude ?? 0)
                    }
                    
                    return
                }
                
                let currlocation = CLLocation(latitude: CLLocationDegrees(currlat), longitude: CLLocationDegrees(currlon))
                
                let context = appDelegate.persistentContainer.viewContext
                
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Locations")
                request.returnsObjectsAsFaults = false
                
                do {
                    print("GOT INTO DB")
                    let result = try context.fetch(request)
                    var detected = false
                    for data in result as? [NSManagedObject] ?? [NSManagedObject()] {
                        print(data.value(forKey: "lat") as? Float ?? 0)
                        print(data.value(forKey: "lon") as? Float ?? 0)
                        
                        let reqlocation = CLLocation(latitude: CLLocationDegrees(data.value(forKey: "lat") as? Float ?? 0), longitude: CLLocationDegrees(data.value(forKey: "lon") as? Float ?? 0))
                        
                        let distance = currlocation.distance(from: reqlocation)
                        print("You are \(distance)m away from a recognized zone.")
                        
                        if distance < 300 {
                            detected = true
                            print("Close to recognized hotspot, not initiating.")
                            break
                        }
                    }
                    
                    if !detected{
                        if dataManager.carrierNetwork == "CTRadioAccessTechnologyHSDPA" {
                            NotificationManager.sendNotification(for: .alertHPlus)
                        } else if dataManager.carrierNetwork == "CTRadioAccessTechnologyWCDMA" {
                            NotificationManager.sendNotification(for: .alertWCDMA)
                        }
                        if dataManager.statisticsAgreement{
                            AppDelegate.sendLocationToServer(latitude: locations.last?.coordinate.latitude ?? 0, longitude: locations.last?.coordinate.longitude ?? 0)
                        }
                    } else {
                        print("detected one nearby hotspot, STOPING OPERATIONS.")
                    }
                } catch {
                    print("Failed")
                    if dataManager.carrierNetwork == "CTRadioAccessTechnologyHSDPA" {
                        NotificationManager.sendNotification(for: .alertHPlus)
                    } else if dataManager.carrierNetwork == "CTRadioAccessTechnologyWCDMA" {
                        NotificationManager.sendNotification(for: .alertWCDMA)
                    }
                    if dataManager.statisticsAgreement{
                        AppDelegate.sendLocationToServer(latitude: locations.last?.coordinate.latitude ?? 0, longitude: locations.last?.coordinate.longitude ?? 0)
                    }
                }
                
            }
            
            else if dataManager.connectedMCC == dataManager.targetMCC && dataManager.connectedMNC == dataManager.chasedMNC {
                if (dataManager.carrierNetwork == "CTRadioAccessTechnology\(dataManager.nrp)" && !dataManager.allow013G) || (dataManager.carrierNetwork == "CTRadioAccessTechnologyEdge" && !dataManager.allow012G && dataManager.out2G == "yes") {
                    let speed = locations.last?.speed ?? 0
                    print("The current speed is ", speed * 3.6, "km/h.")
                    if speed * 3.6 > 80 {
                        print("l'utilisateur va à une vitesse ne le permettant pas de rester accroché à une antenne Free (route de campagne/autoroute/TGV).")
                        return
                    }
                    
                    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                        AppDelegate.initBackground(dataManager)
                        return
                    }
                    
                    let currlat = locations.last?.coordinate.latitude ?? 0
                    let currlon = locations.last?.coordinate.longitude ?? 0
                    
                    if currlat == 0 && currlon == 0 {
                        AppDelegate.initBackground()
                        return
                    }
                    
                    let currlocation = CLLocation(latitude: CLLocationDegrees(currlat), longitude: CLLocationDegrees(currlon))
                    
                    let context = appDelegate.persistentContainer.viewContext
                    
                    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Locations")
                    request.returnsObjectsAsFaults = false
                    
                    do {
                        print("GOT INTO DB")
                        let result = try context.fetch(request)
                        var detected = false
                        for data in result as? [NSManagedObject] ?? [NSManagedObject()] {
                            print(data.value(forKey: "lat") as? Float ?? 0)
                            print(data.value(forKey: "lon") as? Float ?? 0)
                            
                            let reqlocation = CLLocation(latitude: CLLocationDegrees(data.value(forKey: "lat") as? Float ?? 0), longitude: CLLocationDegrees(data.value(forKey: "lon") as? Float ?? 0))
                            
                            let distance = currlocation.distance(from: reqlocation)
                            print("You are \(distance)m away from a recognized zone.")
                            
                            if distance < 300 {
                                detected = true
                                print("Close to recognized hotspot, not initiating.")
                                break
                            }
                        }
                        
                        if !detected{
                            AppDelegate.initBackground(dataManager)
                        } else {
                            print("detected one nearby hotspot, STOPING OPERATIONS.")
                        }
                    } catch {
                        print("Failed")
                        AppDelegate.initBackground(dataManager)
                    }
                } else {
                    print("L'utilisateur est en 4G/3G propre")
                }
            } else {
                print("L'utilisateur n\'est pas connecté sur le réseau itinérant")
            }
        }
    }
    
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Re create timer
        window?.rootViewController?.beginAppearanceTransition(true, animated: false)
        window?.rootViewController?.endAppearanceTransition()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        let dataManager = DataManager()
        
        if dataManager.dispInfoNotif && !dataManager.lowbat{
            NotificationManager.sendNotification(for: .halt)
        }
        saveContext()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
   
    func WIFIDIS(){
        let dataManager = DataManager()
        
        if DataManager.isWifiConnected() {
            print("STILL CONNECTED")
            return
        } else {
            print("ABORTED WIFI")
            
            self.timer?.invalidate()
            
            DispatchQueue.main.async {
                self.window?.rootViewController?.dismiss(animated: true, completion: nil)
            }
            
            delay(0.5){
                let alert = UIAlertController(title: "Préparation en cours...", message: nil, preferredStyle: UIAlertController.Style.alert)
                let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 3, y: 5, width: 50, height: 50))
                loadingIndicator.hidesWhenStopped = true
                loadingIndicator.style = UIActivityIndicatorView.Style.gray
                loadingIndicator.startAnimating();
                alert.view.addSubview(loadingIndicator)
                
                self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                
                Speedtest().testDownloadSpeedWithTimout(timeout: 5.0, usingURL: dataManager.url) { (speed, error) in
                    DispatchQueue.main.async {
                        print(speed ?? 0)
                        if speed ?? 0 < dataManager.stms {
                            print("ITI 35")
                           
                            dataManager.datas.set(true, forKey: "wasEnabled")
                            dataManager.datas.set(true, forKey: "isRunning")
                            dataManager.datas.synchronize()
                            guard let link = URL(string: "shortcuts://run-shortcut?name=RRFM") else { return }
                            UIApplication.shared.open(link)
                        } else {
                            print("S65")
                            if CLLocationManager.authorizationStatus() == .authorizedAlways {
                                // On verifie la localisation en arrière plan
                                let locationManager = CLLocationManager()
                                let latitude = locationManager.location?.coordinate.latitude ?? 0
                                let longitude = locationManager.location?.coordinate.longitude ?? 0
                                
                                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                                    return
                                }
                                let context = appDelegate.persistentContainer.viewContext
                                guard let entity = NSEntityDescription.entity(forEntityName: "Locations", in: context) else {
                                    return
                                }
                                let newCoo = NSManagedObject(entity: entity, insertInto: context)
                                
                                newCoo.setValue(latitude, forKey: "lat")
                                newCoo.setValue(longitude, forKey: "lon")
                                
                                do {
                                    try context.save()
                                    print("COORDINATES SAVED!")
                                } catch {
                                    print("Failed saving")
                                }
                            }
                        }
                        self.delay(0.3){
                            self.window?.rootViewController?.dismiss(animated: true, completion: nil)
                            UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
                        }
                    }
                }
            }
        }
    }
    
    // -----
    // GESTION DES NOTIFICATIONS
    // -----
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Determine the user action
        switch response.actionIdentifier {
            
        case UNNotificationDismissActionIdentifier:
            print("Dismiss Action")
        case UNNotificationDefaultActionIdentifier:
            let dataManager = DataManager()
            
            if dataManager.minimalSetup && dataManager.connectedMCC == dataManager.targetMCC && dataManager.connectedMNC != dataManager.targetMNC {
                dataManager.datas.set(true, forKey: "wasEnabled")
                dataManager.datas.set(true, forKey: "isRunning")
                dataManager.datas.synchronize()
                guard let link = URL(string: "shortcuts://run-shortcut?name=RRFM") else { return }
                UIApplication.shared.open(link)
                return
            }
            
            if dataManager.connectedMCC == dataManager.targetMCC && dataManager.connectedMNC == dataManager.chasedMNC && !DataManager.isOnPhoneCall() {
                if dataManager.carrierNetwork == "CTRadioAccessTechnology\(dataManager.nrp)" && !dataManager.allow013G {
                    if dataManager.verifyonwifi && DataManager.isWifiConnected() && dataManager.nrDEC && dataManager.femto {
                        let alerteW = UIAlertController(title: "disconnect_from_wifi".localized(), message:nil, preferredStyle: UIAlertController.Style.alert)
                        
                        alerteW.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel) { (UIAlertAction) in
                            self.timer?.invalidate()
                        })
                        
                        self.window?.rootViewController?.present(alerteW, animated: true, completion: nil)
                        
                        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { timer in
                            self.WIFIDIS()
                        }
                        
                        // NOW I NEED TO WAIT THAT THE USER IS INDEED DISCONNECTED TO WIFI BEFORE CONTINIUNG!
                    } else if dataManager.femtoLOWDATA && dataManager.femto && dataManager.nrDEC {
                        let alert = UIAlertController(title: "preparation_inprogress".localized(), message:nil, preferredStyle: UIAlertController.Style.alert)
                        
                        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 3, y: 5, width: 50, height: 50))
                        loadingIndicator.hidesWhenStopped = true
                        loadingIndicator.style = UIActivityIndicatorView.Style.gray
                        loadingIndicator.startAnimating();
                        
                        alert.view.addSubview(loadingIndicator)
                        
                        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                        
                        Speedtest().testDownloadSpeedWithTimout(timeout: 5.0, usingURL: dataManager.url) { (speed, error) in
                            print("THIS SHOULD NOT BE CALLED...")
                            DispatchQueue.main.async {
                                print(speed ?? 0)
                                if speed ?? 0 < dataManager.stms {
                                    dataManager.datas.set(true, forKey: "wasEnabled")
                                    dataManager.datas.set(true, forKey: "isRunning")
                                    dataManager.datas.synchronize()
                                    guard let link = URL(string: "shortcuts://run-shortcut?name=RRFM") else { return }
                                    UIApplication.shared.open(link)
                                } else {
                                    if CLLocationManager.authorizationStatus() == .authorizedAlways {
                                        // On verifie la localisation en arrière plan
                                        let locationManager = CLLocationManager()
                                        let latitude = locationManager.location?.coordinate.latitude ?? 0
                                        let longitude = locationManager.location?.coordinate.longitude ?? 0
                                        
                                        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                                            return
                                        }
                                        let context = appDelegate.persistentContainer.viewContext
                                        guard let entity = NSEntityDescription.entity(forEntityName: "Locations", in: context) else {
                                            return
                                        }
                                        let newCoo = NSManagedObject(entity: entity, insertInto: context)
                                        
                                        newCoo.setValue(latitude, forKey: "lat")
                                        newCoo.setValue(longitude, forKey: "lon")
                                        
                                        do {
                                            try context.save()
                                            print("COORDINATES SAVED!")
                                        } catch {
                                            print("Failed saving")
                                        }
                                        
                                    }
                                    
                                }
                                self.delay(0.3){
                                    self.window?.rootViewController?.dismiss(animated: true, completion: nil)
                                    UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
                                }
                            }
                        }
                    } else {
                        dataManager.datas.set(true, forKey: "wasEnabled")
                        dataManager.datas.set(true, forKey: "isRunning")
                        dataManager.datas.synchronize()
                        guard let link = URL(string: "shortcuts://run-shortcut?name=RRFM") else { return }
                        UIApplication.shared.open(link)
                    }
                } else if dataManager.carrierNetwork == "CTRadioAccessTechnologyEdge" && !dataManager.allow012G && dataManager.out2G == "yes" {
                    dataManager.datas.set(true, forKey: "wasEnabled")
                    dataManager.datas.set(true, forKey: "isRunning")
                    dataManager.datas.synchronize()
                    guard let link = URL(string: "shortcuts://run-shortcut?name=RRFM") else { return }
                    UIApplication.shared.open(link)
                }
            } else if dataManager.connectedMCC == dataManager.targetMCC && dataManager.connectedMNC == dataManager.chasedMNC && DataManager.isOnPhoneCall() {
                let alerteS = UIAlertController(title: "end_phonecall".localized(), message:nil, preferredStyle: UIAlertController.Style.alert)
                
                alerteS.addAction(UIAlertAction(title: "ok".localized(), style: UIAlertAction.Style.default, handler: nil))
                
                self.window?.rootViewController?.present(alerteS, animated: true, completion: nil)
            } else {
                print("L'utilisateur n'est pas chez Free ou est en communication.")
            }

        default:
            print("Unknown action")
            
        }
        
        completionHandler()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Notifications permission granted.")
                UNUserNotificationCenter.current().delegate = self
            } else {
                print("Notifications permission denied because: \(String(describing: error?.localizedDescription)).")
            }
            
        }
        
        let notifications = UNNotificationCategory(identifier: "protectionItineranceActivee", actions: [], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([notifications])
        
        // On init l'UI
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController(rootViewController: TableViewController(style: .grouped))
        window?.makeKeyAndVisible()
        
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    // -----
    // GESTION DE L'ARRIERE PLAN
    // -----
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        AppDelegate.engineRunning()
        completionHandler(.newData)
    }
    
    static func iPadInit(_ dataManager: DataManager = DataManager()){
        
        // On vérifie si l'utilisateur a donné son accord pour vérifier le pays en arrière plan
        if !dataManager.stopverification{
            if dataManager.allowCountryDetection {
                
                if abs(dataManager.timeLastCountry.timeIntervalSinceNow) > 15*60 {
                    
                    if CLLocationManager.authorizationStatus() == .authorizedAlways {
                        // On verifie la localisation en arrière plan
                        let locationManager = CLLocationManager()
                        let latitude = locationManager.location?.coordinate.latitude ?? 0
                        let longitude = locationManager.location?.coordinate.longitude ?? 0
                        
                        print("Coordonnées : ", latitude, " ", longitude)
                        
                        geocode(latitude: latitude, longitude: longitude) { placemark, error in
                            guard let placemark = placemark, error == nil else {
                                print("Erreur geocode, on admet que l'utilisateur est dans son pays")
                                process(dataManager)
                                return
                            }
                            
                            print("ISO COUNTRY CODE :",  placemark.isoCountryCode?.uppercased() ?? "")
                            
                            if placemark.isoCountryCode?.uppercased() ?? CarrierIdentification.getIsoCountryCode(dataManager.targetMCC) == CarrierIdentification.getIsoCountryCode(dataManager.targetMCC) {
                                print("L'utilisateur est dans son pays")
                                dataManager.datas.set(placemark.isoCountryCode?.uppercased() ?? CarrierIdentification.getIsoCountryCode(dataManager.targetMCC), forKey: "lastCountry")
                                dataManager.datas.set(Date(), forKey: "timeLastCountry")
                                dataManager.datas.synchronize()
                                process(dataManager)
                            } else {
                                print("L'utilisateur est à l'étranger")
                                dataManager.datas.set(placemark.isoCountryCode?.uppercased() ?? "ABO", forKey: "lastCountry")
                                dataManager.datas.set(Date(), forKey: "timeLastCountry")
                                dataManager.datas.synchronize()
                                return
                            }
                            
                        }
                        
                    } else {
                        // L'utilisateur a demandé à vérifier le pays mais n'a pas autorisé l'app à le faire dans le système
                        print("LOC FETCH failed : wrong permissions")
                        NotificationManager.sendNotification(for: .locFailed)
                        dataManager.datas.set(Date(), forKey: "timeLastCountry")
                        dataManager.datas.synchronize()
                        process()
                    }
                } else {
                    if dataManager.lastCountry == CarrierIdentification.getIsoCountryCode(dataManager.targetMCC) {
                        print("Utilisation du cache : Home Network")
                        process(dataManager)
                    } else {
                        print("Selon le cache, l'utilisateur est à l'étranger")
                        return
                    }
                }
                
            } else {
                // L'utilisateur n'a pas donné son accord
                print("The user has not allowed Country Detection")
                process(dataManager)
                
            }
        } else {
            print("Background Fetch Disabled in App Preferences.")
        }
        
    }
    
    static func initBackground(_ dataManager: DataManager = DataManager()){
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            if (dataManager.ipadMCC == "---" && dataManager.ipadMNC == "--"){
            AppDelegate.iPadInit(dataManager)
            return
          }
        }
        
        
        let countryCode = dataManager.mycarrier.mobileCountryCode ?? "null"
        let mobileNetworkName = dataManager.mycarrier.mobileNetworkCode ?? "null"
        
        // On vérifie si l'utilisateur a donné son accord pour vérifier le pays en arrière plan
        if !dataManager.stopverification{
            if (countryCode != dataManager.targetMCC || mobileNetworkName != dataManager.targetMNC) && (mobileNetworkName != "null" || countryCode != "null") {
                dataManager.datas.removeObject(forKey: "MCC")
                dataManager.datas.set(false, forKey: "setupDone")
                dataManager.datas.synchronize()
                NotificationManager.sendNotification(for: .newSIM)
                return
            }
            
            process(dataManager)
        } else {
            print("User wants the process to stop in background.")
        }
    }
    
    static func process(_ dataManager: DataManager = DataManager()) {
        // La fonction qui vérifie si on doit appeler netfetch() ou pas (WiFi, à l'étranger...)
        if dataManager.connectedMCC == dataManager.targetMCC && dataManager.connectedMNC == dataManager.chasedMNC {
            if DataManager.isWifiConnected() {
                if dataManager.verifyonwifi {
                    // Le contrôle d'itinérance démarre.
                    netfetch(dataManager)
                } else {
                    // L'utilisateur est connecté au WiFi et est chez Free, et a demandé à ne pas controler le WiFi
                    print("L'utilisateur a désactivé le contrôle en WiFi")
                }
            } else {
                // L'utilisateur est chez Free et n'est pas connecté au WiFi.
                // Le contrôle d'itinérance démarre.
                print("L'utilisateur est bien sur le bon réseau et n'est pas en WiFi")
                netfetch(dataManager)
            }
        } else {
            // L'utilisateur est chez un autre opérateur
            print("L'utilisateur n'est pas connecté sur son réseau propre.")
        }
        
    }
    
    static func netfetch(_ dataManager: DataManager = DataManager()) {
        // La fonction clé du programme qui vérifie l'itinérance
        let now = Date()
        
        print(abs(dataManager.timecode.timeIntervalSinceNow))
        print(now)
        
        if dataManager.isRunning {
            print("ALREADY RUNNING...")
            return
        } else if dataManager.carrierNetwork != dataManager.lastnet {
            print("THE NETWORK HAS CHANGED! PERFORMING NEW CHECK.")
            dataManager.lastnet = dataManager.carrierNetwork
            dataManager.timecode = now
            dataManager.count = 0
            dataManager.wasEnabled = false
            dataManager.datas.set(dataManager.lastnet, forKey: "lastnet")
            dataManager.datas.set(dataManager.timecode, forKey: "timecode")
            dataManager.datas.set(dataManager.count, forKey: "count")
            dataManager.datas.set(dataManager.wasEnabled, forKey: "wasEnabled")
            dataManager.datas.synchronize()
        } else if abs(dataManager.timecode.timeIntervalSinceNow) > 10*60 {
            print("IT HAS BEEN OVER 10 MINUTES.")
            dataManager.timecode = now
            dataManager.count += 1
            dataManager.datas.set(dataManager.timecode, forKey: "timecode")
            dataManager.datas.set(dataManager.count, forKey: "count")
            dataManager.datas.synchronize()
            if dataManager.count > 5 && dataManager.wasEnabled {
                print("IT HAS BEEN 5 ATTEMPTS AND THE OPERATION DID NOT SUCCEED.")
                if CLLocationManager.authorizationStatus() == .authorizedAlways {
                    // On verifie la localisation en arrière plan
                    let locationManager = CLLocationManager()
                    let latitude = locationManager.location?.coordinate.latitude ?? 0
                    let longitude = locationManager.location?.coordinate.longitude ?? 0
                    
                    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                        return
                    }
                    let context = appDelegate.persistentContainer.viewContext
                    guard let entity = NSEntityDescription.entity(forEntityName: "Locations", in: context) else {
                        return
                    }
                    let newCoo = NSManagedObject(entity: entity, insertInto: context)
                    
                    newCoo.setValue(latitude, forKey: "lat")
                    newCoo.setValue(longitude, forKey: "lon")
                    
                    do {
                        try context.save()
                        print("COORDINATES SAVED!")
                        NotificationManager.sendNotification(for: .saved)
                    } catch {
                        print("Failed saving")
                    }
                    
                }
                dataManager.lastnet = dataManager.carrierNetwork
                dataManager.timecode = now
                dataManager.count = 0
                dataManager.wasEnabled = false
                dataManager.datas.set(dataManager.lastnet, forKey: "lastnet")
                dataManager.datas.set(dataManager.timecode, forKey: "timecode")
                dataManager.datas.set(dataManager.count, forKey: "count")
                dataManager.datas.set(dataManager.wasEnabled, forKey: "wasEnabled")
                dataManager.datas.synchronize()
                return
            } else if dataManager.count > 6 {
                print("IT HAS BEEN 5 ATTEMPTS BUT THE OPERATION WAS NOT LAUNCHED.")
                dataManager.count = 0
                dataManager.datas.set(dataManager.count, forKey: "count")
                dataManager.datas.synchronize()
            }
        } else {
            print("IT'S NOT TIME YET!")
            return
        }
        
        // Le script continuera si il a changé de réseau ou que cela fait plus de 15 minutes qu'il n'y a pas eu d'alerte
        // On enregistre les nouvelles valeurs et on continue
        
        print("Network changed, set to \(dataManager.carrierNetwork) at \(now)")
        
        if dataManager.carrierNetwork == "CTRadioAccessTechnologyLTE" {
            // L'utilisateur est en 4G, tout va bien
            print("LTE: No need to reset.")
        } else if dataManager.carrierNetwork == "CTRadioAccessTechnology\(dataManager.hp)" {
            // L'utilisateur est en 3G RP, tout va bien
            print("WCDMA: No need to reset.")
        } else if dataManager.carrierNetwork == "CTRadioAccessTechnology\(dataManager.nrp)" {
            // L'utilisateur est en 3G+ en Itinérance, vérification si autorisée
            if !dataManager.allow013G{
                print("H+ non autorisée.")
                if !dataManager.femtoLOWDATA && dataManager.femto && !DataManager.isWifiConnected() {
                    
                    if dataManager.nrDEC {
                        Speedtest().testDownloadSpeedWithTimout(timeout: 5.0, usingURL: dataManager.url) { (speed, error) in
                            DispatchQueue.main.async {
                                print(speed ?? 0)
                                if speed ?? 0 < dataManager.stms {
                                    if dataManager.nrp == "WCDMA"{
                                        NotificationManager.sendNotification(for: .alertWCDMA)
                                    } else if dataManager.nrp == "HSDPA"{
                                        NotificationManager.sendNotification(for: .alertHPlus)
                                    }
                                    if dataManager.statisticsAgreement{
                                        let locationManager = CLLocationManager()
                                        AppDelegate.sendLocationToServer(latitude: locationManager.location?.coordinate.latitude ?? 0, longitude: locationManager.location?.coordinate.longitude ?? 0)
                                    }
                                    print("SPEEDTEST IN BACKGROUND SUCCESSFUL!")
                                } else {
                                    if CLLocationManager.authorizationStatus() == .authorizedAlways {
                                        // On verifie la localisation en arrière plan
                                        let locationManager = CLLocationManager()
                                        let latitude = locationManager.location?.coordinate.latitude ?? 0
                                        let longitude = locationManager.location?.coordinate.longitude ?? 0
                                        
                                        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                                            return
                                        }
                                        let context = appDelegate.persistentContainer.viewContext
                                        guard let entity = NSEntityDescription.entity(forEntityName: "Locations", in: context) else {
                                            return
                                        }
                                        let newCoo = NSManagedObject(entity: entity, insertInto: context)
                                        
                                        newCoo.setValue(latitude, forKey: "lat")
                                        newCoo.setValue(longitude, forKey: "lon")
                                        
                                        do {
                                            try context.save()
                                            print("COORDINATES SAVED!")
                                            print("SPEEDTEST IN BACKGROUND SUCCESSFUL!")
                                        } catch {
                                            print("Failed saving")
                                        }
                                        
                                    }
                                    
                                }
                            }
                        }
                    } else {
                        if dataManager.nrp == "WCDMA"{
                            NotificationManager.sendNotification(for: .alertWCDMA)
                        } else if dataManager.nrp == "HSDPA"{
                            NotificationManager.sendNotification(for: .alertHPlus)
                        }
                        
                        if dataManager.statisticsAgreement{
                            let locationManager = CLLocationManager()
                            AppDelegate.sendLocationToServer(latitude: locationManager.location?.coordinate.latitude ?? 0, longitude: locationManager.location?.coordinate.longitude ?? 0)
                        }
                    }
                    
                    
                } else {
                    if dataManager.nrp == "WCDMA"{
                        NotificationManager.sendNotification(for: .alertPossibleWCDMA)
                    } else if dataManager.nrp == "HSDPA"{
                        NotificationManager.sendNotification(for: .alertPossibleHPlus)
                    }
                    if dataManager.statisticsAgreement{
                        let locationManager = CLLocationManager()
                        AppDelegate.sendLocationToServer(latitude: locationManager.location?.coordinate.latitude ?? 0, longitude: locationManager.location?.coordinate.longitude ?? 0)
                    }
                }
            } else {
                print("H+ autorisée")
            }
        } else if dataManager.carrierNetwork == "CTRadioAccessTechnologyEdge" && dataManager.out2G == "yes"{
            if !dataManager.allow012G{
                print("2G non autorisée")
                NotificationManager.sendNotification(for: .alertEdge)
                if dataManager.statisticsAgreement{
                    let locationManager = CLLocationManager()
                    AppDelegate.sendLocationToServer(latitude: locationManager.location?.coordinate.latitude ?? 0, longitude: locationManager.location?.coordinate.longitude ?? 0)
                }
            } else {
                print("2G autorisée ou incompatible")
            }
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // To call viewDidDisappear and invalidate timer
        window?.rootViewController?.beginAppearanceTransition(false, animated: false)
        window?.rootViewController?.endAppearanceTransition()
        let dataManager = DataManager()
        
        if dataManager.dispInfoNotif {
            DispatchQueue.global(qos: .background).async {
                
                
                if abs(dataManager.ntimer.timeIntervalSinceNow) < 10*60 && !dataManager.didChangeSettings{
                    print(abs(dataManager.ntimer.timeIntervalSinceNow))
                    print("Either before 10 minutes, or didn't change any setting.")
                    return
                }
                
                dataManager.datas.set(Date(), forKey: "NTimer")
                dataManager.datas.set(false, forKey: "didChangeSettings")
                dataManager.datas.synchronize()
                
                let countryCode = dataManager.mycarrier.mobileCountryCode ?? "null"
                let mobileNetworkName = dataManager.mycarrier.mobileNetworkCode ?? "null"
                let carrierName = dataManager.mycarrier.carrierName ?? "null"
                let isoCountrycode = dataManager.mycarrier.isoCountryCode ?? "null"
                
                print(countryCode)
                print(mobileNetworkName)
                print(carrierName)
                print(isoCountrycode)
                
                if !dataManager.stopverification {
                    if dataManager.lowbat{
                        NotificationManager.sendNotification(for: .batteryLow)
                    }
                    if dataManager.connectedMCC == dataManager.targetMCC {
                        if dataManager.allow012G && dataManager.allow013G {
                            NotificationManager.sendNotification(for: .allow2G3G)
                        } else if dataManager.allow013G {
                            NotificationManager.sendNotification(for: .allow3G)
                        } else if dataManager.allow012G {
                            NotificationManager.sendNotification(for: .allow2G)
                        } else if !dataManager.allow013G && !dataManager.allow012G {
                            NotificationManager.sendNotification(for: .allowNone)
                        } else {
                            NotificationManager.sendNotification(for: .allowDisabled)
                        }
                    }
                } else {
                    NotificationManager.sendNotification(for: .allowDisabled)
                }
                
            }
        }
    }

    // -----
    // GESTION DE CORE DATA
    // -----

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "DATA")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

