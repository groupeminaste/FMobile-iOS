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
import BackgroundTasks
import APIRequest

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, CLLocationManagerDelegate {

    // Variables de la classe
    var window: UIWindow?
    var timer: Timer?
   
    // -----
    // FONCTIONS UTILITAIRES
    // -----
    
    func oldios(){
        guard #available(iOS 12.0, *) else {
            let alert = UIAlertController(title: "old_ios_warning".localized().format([UIDevice.current.systemVersion]), message: "old_ios_description".localized(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "close".localized(), style: .cancel, handler: nil))
            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
            
            return
        }
    }
    
    func delay(_ delay:Double, closure: @escaping () -> ()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
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
        
        saveContext()
        
        DispatchQueue.global(qos: .background).async {
            let dataManager = DataManager()
            
            if dataManager.dispInfoNotif && dataManager.perfmode{
                NotificationManager.sendNotification(for: .halt)
            }
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
   
    func WIFIDIS(){
        let dataManager = DataManager()
        
        DataManager.getCurrentWifi { (wifi) in
            if wifi != nil {
                print("STILL CONNECTED")
                return
            } else {
                print("ABORTED WIFI")
                
                self.timer?.invalidate()
                
                DispatchQueue.main.async {
                    self.window?.rootViewController?.dismiss(animated: true, completion: nil)
                }
                
                self.delay(0.5){
                    let alert = UIAlertController(title: "Préparation en cours...", message: nil, preferredStyle: UIAlertController.Style.alert)
                    let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 3, y: 5, width: 50, height: 50))
                    loadingIndicator.hidesWhenStopped = true
                    if #available(iOS 13.0, *) {
                        loadingIndicator.style = UIActivityIndicatorView.Style.medium
                    } else {
                        loadingIndicator.style = UIActivityIndicatorView.Style.gray
                    }
                    loadingIndicator.startAnimating()
                    alert.view.addSubview(loadingIndicator)
                    
                    self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                    
                    Speedtest().testDownloadSpeedWithTimout(timeout: 5.0, usingURL: dataManager.url) { (speed, _) in
                        DispatchQueue.main.async {
                            print(speed ?? 0)
                            if speed ?? 0 < dataManager.current.card.stms {
                                print("ITI 35")
                                dataManager.wasEnabled += 1
                                dataManager.datas.set(dataManager.wasEnabled, forKey: "wasEnabled")
                                if #available(iOS 14.1, *), dataManager.current.network.connected == CTRadioAccessTechnologyNR {
                                    dataManager.datas.set("NR", forKey: "g3lastcompletion")
                                } else if #available(iOS 14.1, *), dataManager.current.network.connected == CTRadioAccessTechnologyNRNSA {
                                    dataManager.datas.set("NRNSA", forKey: "g3lastcompletion")
                                } else if dataManager.current.network.connected == CTRadioAccessTechnologyLTE {
                                    dataManager.datas.set("LTE", forKey: "g3lastcompletion")
                                } else if dataManager.current.card.nrp == CTRadioAccessTechnologyHSDPA {
                                    dataManager.datas.set("HPLUS", forKey: "g3lastcompletion")
                                } else {
                                    dataManager.datas.set("WCDMA", forKey: "g3lastcompletion")
                                }
                                dataManager.datas.set(Date(), forKey: "timecode")
                                dataManager.datas.synchronize()
                                if #available(iOS 12.0, *) {
                                guard let link = DataManager.getShortcutURL() else { return }
                                    UIApplication.shared.open(link)
                                } else {
                                    self.oldios()
                                }
                            } else {
                                print("S65")
                                if CLLocationManager.authorizationStatus() == .authorizedAlways {
                                    // On verifie la localisation en arrière plan
                                    let locationManager = CLLocationManager()
                                    
                                    if #available(iOS 14.0, *) {
                                        if locationManager.accuracyAuthorization != .fullAccuracy {
                                            return
                                        }
                                    }
                                    
                                    let latitude = locationManager.location?.coordinate.latitude ?? 0
                                    let longitude = locationManager.location?.coordinate.longitude ?? 0
                                    
                                    let context: NSManagedObjectContext
                                    if #available(iOS 10.0, *) {
                                        context = PermanentStorage.persistentContainer.viewContext
                                    } else {
                                        // Fallback on earlier versions
                                        context = PermanentStorage.managedObjectContext
                                    }
                                    guard let entity = NSEntityDescription.entity(forEntityName: "Locations", in: context) else {
                                        return
                                    }
                                    let newCoo = NSManagedObject(entity: entity, insertInto: context)
                                    
                                    newCoo.setValue(latitude, forKey: "lat")
                                    newCoo.setValue(longitude, forKey: "lon")
                                    
                                    context.performAndWait({
                                        do {
                                            try context.save()
                                            print("COORDINATES SAVED!")
                                        } catch {
                                            print("Failed saving")
                                        }
                                    })
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

    }
    
    // -----
    // GESTION DES NOTIFICATIONS
    // -----
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Determine the user action
        switch response.actionIdentifier {
            
        case UNNotificationDismissActionIdentifier:
            print("Dismiss Action")
        case UNNotificationDefaultActionIdentifier:
            let dataManager = DataManager()
            
            DataManager.getCurrentWifi { (wifi) in
                let result = RoamingManager.directDataDCheck(dataManager, service: dataManager.current, wifi: wifi)
                    if result {
                        if #available(iOS 13.0, *) {} else {
                            NotificationManager.sendNotification(for: .alertDataDrainG3, with: "data_drain_notification_description_g3".localized().format([dataManager.current.network.name, dataManager.current.network.land]))
                        }
                        if #available(iOS 12.0, *) {
                        guard let link = DataManager.getShortcutURL(international: true) else { return }
                            UIApplication.shared.open(link)
                        } else {
                            self.oldios()
                        }
                        completionHandler()
                        return
                }
                    
                    
                
                
                if dataManager.current.card.minimalSetup && dataManager.current.network.mcc == dataManager.current.card.mcc && dataManager.current.network.mnc != dataManager.current.card.mnc {
                    dataManager.wasEnabled += 1
                    dataManager.datas.set(dataManager.wasEnabled, forKey: "wasEnabled")
                    if #available(iOS 14.1, *), dataManager.current.network.connected == CTRadioAccessTechnologyNR {
                        dataManager.datas.set("NR", forKey: "g3lastcompletion")
                    } else if #available(iOS 14.1, *), dataManager.current.network.connected == CTRadioAccessTechnologyNRNSA {
                        dataManager.datas.set("NRNSA", forKey: "g3lastcompletion")
                    } else if dataManager.current.network.connected == CTRadioAccessTechnologyLTE {
                        dataManager.datas.set("LTE", forKey: "g3lastcompletion")
                    } else if dataManager.current.network.connected == CTRadioAccessTechnologyHSDPA {
                        dataManager.datas.set("HPLUS", forKey: "g3lastcompletion")
                    } else {
                        dataManager.datas.set("WCDMA", forKey: "g3lastcompletion")
                    }
                    dataManager.datas.set(Date(), forKey: "timecode")
                    dataManager.datas.synchronize()
                    if #available(iOS 12.0, *) {
                    guard let link = DataManager.getShortcutURL() else { return }
                        UIApplication.shared.open(link)
                    } else {
                        self.oldios()
                    }
                    completionHandler()
                    return
                }
                
                if dataManager.current.network.mcc == dataManager.current.card.mcc && dataManager.current.network.mnc == dataManager.current.card.chasedMNC && !DataManager.isOnPhoneCall() {
                    if dataManager.current.network.connected == dataManager.current.card.nrp && !dataManager.allow013G {
                        if dataManager.verifyonwifi && wifi != nil && dataManager.current.card.nrdec && dataManager.femto {
                            let alerteW = UIAlertController(title: "disconnect_from_wifi".localized(), message:nil, preferredStyle: UIAlertController.Style.alert)
                            
                            alerteW.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel) { (_) in
                                self.timer?.invalidate()
                            })
                            
                            self.window?.rootViewController?.present(alerteW, animated: true, completion: nil)
                            
                            self.timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
                                self.WIFIDIS()
                            }
                            
                            // NOW I NEED TO WAIT THAT THE USER IS INDEED DISCONNECTED TO WIFI BEFORE CONTINIUNG!
                        } else if dataManager.femtoLOWDATA && dataManager.femto && dataManager.current.card.nrdec {
                            let alert = UIAlertController(title: "preparation_inprogress".localized(), message:nil, preferredStyle: UIAlertController.Style.alert)
                            
                            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 3, y: 5, width: 50, height: 50))
                            loadingIndicator.hidesWhenStopped = true
                            if #available(iOS 13.0, *) {
                                loadingIndicator.style = UIActivityIndicatorView.Style.medium
                            } else {
                                // Fallback on earlier versions
                                loadingIndicator.style = UIActivityIndicatorView.Style.gray
                            }
                            loadingIndicator.startAnimating()
                            
                            alert.view.addSubview(loadingIndicator)
                            
                            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                            
                            Speedtest().testDownloadSpeedWithTimout(timeout: 5.0, usingURL: dataManager.url) { (speed, _) in
                                print("THIS SHOULD NOT BE CALLED...")
                                DispatchQueue.main.async {
                                    print(speed ?? 0)
                                    if speed ?? 0 < dataManager.current.card.stms {
                                        dataManager.wasEnabled += 1
                                        dataManager.datas.set(dataManager.wasEnabled, forKey: "wasEnabled")
                                        if #available(iOS 14.1, *), dataManager.current.network.connected == CTRadioAccessTechnologyNR {
                                            dataManager.datas.set("NR", forKey: "g3lastcompletion")
                                        } else if #available(iOS 14.1, *), dataManager.current.network.connected == CTRadioAccessTechnologyNRNSA {
                                            dataManager.datas.set("NRNSA", forKey: "g3lastcompletion")
                                        } else if dataManager.current.network.connected == CTRadioAccessTechnologyLTE {
                                            dataManager.datas.set("LTE", forKey: "g3lastcompletion")
                                        } else if dataManager.current.card.nrp == CTRadioAccessTechnologyHSDPA {
                                            dataManager.datas.set("HPLUS", forKey: "g3lastcompletion")
                                        } else {
                                            dataManager.datas.set("WCDMA", forKey: "g3lastcompletion")
                                        }
                                        dataManager.datas.set(Date(), forKey: "timecode")
                                        dataManager.datas.synchronize()
                                        if #available(iOS 12.0, *) {
                                            guard let link = DataManager.getShortcutURL() else { completionHandler(); return }
                                            UIApplication.shared.open(link)
                                        } else {
                                            self.oldios()
                                        }
                                    } else {
                                        if CLLocationManager.authorizationStatus() == .authorizedAlways {
                                            // On verifie la localisation en arrière plan
                                            let locationManager = CLLocationManager()
                                            
                                            if #available(iOS 14.0, *) {
                                                if locationManager.accuracyAuthorization != .fullAccuracy {
                                                    completionHandler()
                                                    return
                                                }
                                            }
                                            
                                            let latitude = locationManager.location?.coordinate.latitude ?? 0
                                            let longitude = locationManager.location?.coordinate.longitude ?? 0
                                            
                                            let context = PermanentStorage.persistentContainer.viewContext
                                            guard let entity = NSEntityDescription.entity(forEntityName: "Locations", in: context) else {
                                                completionHandler()
                                                return
                                            }
                                            let newCoo = NSManagedObject(entity: entity, insertInto: context)
                                            
                                            newCoo.setValue(latitude, forKey: "lat")
                                            newCoo.setValue(longitude, forKey: "lon")
                                            
                                            context.performAndWait({
                                                do {
                                                    try context.save()
                                                    print("COORDINATES SAVED!")
                                                } catch {
                                                    print("Failed saving")
                                                }
                                            })
                                            
                                        }
                                        
                                    }
                                    self.delay(0.3){
                                        self.window?.rootViewController?.dismiss(animated: true, completion: nil)
                                        UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
                                    }
                                }
                            }
                        } else {
                            dataManager.wasEnabled += 1
                            dataManager.datas.set(dataManager.wasEnabled, forKey: "wasEnabled")
                            if #available(iOS 14.1, *), dataManager.current.network.connected == CTRadioAccessTechnologyNR {
                                dataManager.datas.set("NR", forKey: "g3lastcompletion")
                            } else if #available(iOS 14.1, *), dataManager.current.network.connected == CTRadioAccessTechnologyNRNSA {
                                dataManager.datas.set("NRNSA", forKey: "g3lastcompletion")
                            } else if dataManager.current.network.connected == CTRadioAccessTechnologyLTE {
                                dataManager.datas.set("LTE", forKey: "g3lastcompletion")
                            }
                            if dataManager.current.card.nrp == CTRadioAccessTechnologyHSDPA {
                                dataManager.datas.set("HPLUS", forKey: "g3lastcompletion")
                            } else {
                                dataManager.datas.set("WCDMA", forKey: "g3lastcompletion")
                            }
                            dataManager.datas.set(Date(), forKey: "timecode")
                            dataManager.datas.synchronize()
                            if #available(iOS 12.0, *) {
                                guard let link = DataManager.getShortcutURL() else { completionHandler(); return }
                                UIApplication.shared.open(link)
                            } else {
                                self.oldios()
                            }
                        }
                    } else if dataManager.current.network.connected == CTRadioAccessTechnologyEdge && !dataManager.allow012G && dataManager.current.card.out2G {
                        dataManager.wasEnabled += 1
                        dataManager.datas.set(dataManager.wasEnabled, forKey: "wasEnabled")
                        dataManager.datas.set("EDGE", forKey: "g3lastcompletion")
                        dataManager.datas.set(Date(), forKey: "timecode")
                        dataManager.datas.synchronize()
                        if #available(iOS 12.0, *) {
                            guard let link = DataManager.getShortcutURL() else { completionHandler(); return }
                            UIApplication.shared.open(link)
                        } else {
                            self.oldios()
                        }
                    }
                } else if dataManager.current.network.mcc == dataManager.current.card.mcc && dataManager.current.network.mnc == dataManager.current.card.chasedMNC && DataManager.isOnPhoneCall() {
                    let alerteS = UIAlertController(title: "end_phonecall".localized(), message:nil, preferredStyle: UIAlertController.Style.alert)
                    
                    alerteS.addAction(UIAlertAction(title: "ok".localized(), style: UIAlertAction.Style.default, handler: nil))
                    
                    self.window?.rootViewController?.present(alerteS, animated: true, completion: nil)
                } else {
                    print("L'utilisateur n'est pas chez Free ou est en communication.")
                }
            }

        default:
            print("Unknown action")
            
        }
        
        completionHandler()
    }
    
    // -----
    // GESTION DE L'ARRIERE PLAN
    // -----
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        RoamingManager.engineRunning()
        completionHandler(.newData)
    }
    
    @available(iOS 13.0, *)
    func scheduleAppRefresh(){
        print("Will start schedule App Refresh")
        
        let request = BGAppRefreshTaskRequest(identifier: "fr.plugn.fmobile.iticheck")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 30)
        do {
            print("Requesting App Refresh request...")
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("La tache AppRefresh en arrière-plan n'a pas pu être demandée: \(error)")
        }
        print("App Refresh schedule done.")
    }
    
    @available(iOS 13.0, *)
    func scheduleAppExecution(){
        print("Will start schedule App Execution")
        let request = BGProcessingTaskRequest(identifier: "fr.plugn.fmobile.heavycheck")
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = false
        request.earliestBeginDate = Date(timeIntervalSinceNow: 10 * 60)
        
        do {
            print("Requesting App Execution task...")
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("La tache AppExecution en arrière-plan n'a pas pu être demandée: \(error)")
        }
        print("App Execution schedule done.")
    }
    
    @available(iOS 13.0, *)
    func handleAppExecution(task: BGProcessingTask) {
        scheduleAppExecution()
        scheduleAppRefresh()
        
        task.expirationHandler = {
            task.setTaskCompleted(success: true)
            return
        }
        
        RoamingManager.engineRunning()
        
        task.setTaskCompleted(success: true)
    }
    
    @available(iOS 13.0, *)
    func handleAppRefresh(task: BGAppRefreshTask) {
        scheduleAppRefresh()
        scheduleAppExecution()
        
        task.expirationHandler = {
            task.setTaskCompleted(success: true)
            return
        }
        
        RoamingManager.engineRunning()
        
        task.setTaskCompleted(success: true)
    }
    
    @available(iOS 13.0, *)
    private func registerBackgroundTasks() {
        let test = BGTaskScheduler.shared.register(forTaskWithIdentifier: "fr.plugn.fmobile.iticheck", using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        
        let test2 = BGTaskScheduler.shared.register(forTaskWithIdentifier: "fr.plugn.fmobile.heavycheck", using: nil) { task in
            self.handleAppExecution(task: task as! BGProcessingTask)
        }
        
        print("BGTasks status: \(test) + \(test2)")
        
        print("Should have registered the BGTasks...")
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // On init l'API
        APIConfiguration.check()
        
        // Override point for customization after application launch.
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        
        if #available(iOS 12.0, *) {
            //CarrierIntentHandler.deleteInteraction()
            CarrierIntentHandler.donateInteraction()
        }
        
        if #available(iOS 13.0, *) {
            registerBackgroundTasks()
        }
        
        //CustomDNS().refreshManager()
        
        if #available(iOS 10.0, *) {
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
        } else {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }

        
        // On init l'UI
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = TabBarController()
        window?.makeKeyAndVisible()
        
        return true
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // To call viewDidDisappear and invalidate timer
        
        window?.rootViewController?.beginAppearanceTransition(false, animated: false)
        window?.rootViewController?.endAppearanceTransition()
        
        print("APP FOUNDATIONS READY FOR BACKGROUND")
        
        DispatchQueue.global(qos: .background).async {
            
            if #available(iOS 13.0, *) {
                print("Did enter background")
                self.scheduleAppRefresh()
                print("STEP 1/2 OK")
                self.scheduleAppExecution()
                print("STEP 2/2 OK")
            }
            
            let dataManager = DataManager()
            
            if dataManager.dispInfoNotif {
                
                if abs(dataManager.ntimer.timeIntervalSinceNow) < 10*60 && !dataManager.didChangeSettings{
                    print(abs(dataManager.ntimer.timeIntervalSinceNow))
                    print("Either before 10 minutes, or didn't change any setting.")
                    return
                }
                
                dataManager.datas.set(Date(), forKey: "NTimer")
                dataManager.datas.set(false, forKey: "didChangeSettings")
                dataManager.datas.synchronize()
                
                let countryCode = dataManager.current.card.carrier.mobileCountryCode ?? "null"
                let mobileNetworkName = dataManager.current.card.carrier.mobileNetworkCode ?? "null"
                let carrierName = dataManager.current.card.carrier.carrierName ?? "null"
                let isoCountrycode = dataManager.current.card.carrier.isoCountryCode ?? "null"
                
                print(countryCode)
                print(mobileNetworkName)
                print(carrierName)
                print(isoCountrycode)
                
                if !dataManager.stopverification {
                    if dataManager.perfmode{
                        NotificationManager.sendNotification(for: .batteryLow)
                    }
                    if dataManager.current.network.mcc == dataManager.current.card.mcc {
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
    
    func saveContext () {
        if #available(iOS 10.0, *) {
            let context = PermanentStorage.persistentContainer.viewContext
            if context.hasChanges {
                context.performAndWait({
                do {
                    try context.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
                })
            }
        } else {
            // iOS 9.0 and below - however you were previously handling it
            if PermanentStorage.managedObjectContext.hasChanges {
                PermanentStorage.managedObjectContext.performAndWait({
                    do {
                        try PermanentStorage.managedObjectContext.save()
                    } catch {
                        // Replace this implementation with code to handle the error appropriately.
                        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                        let nserror = error as NSError
                        NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                        abort()
                    }
                })
            }
        }
    }
}
