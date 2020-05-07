//
//  TableViewController.swift
//  FMobile
//
//  Created by Nathan FALLET and Michaël NASS on 10/1/18.
//  Copyright © 2018 Groupe MINASTE. All rights reserved.
//

import UserNotifications
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
import FileProvider

class TableViewController: UITableViewController, CLLocationManagerDelegate {
    
    // Variable de class
    var isAUTH = false
    var sections = [Section]()
    var timer: Timer?
    var timernet: Timer?
    var alertInit = false
    let locationManager = CLLocationManager()
    
    // -----
    // FONCTIONS UTILITAIRES
    // -----
    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("GPS ACTIVATED")
        AppDelegate.engineRunning(locations: locations)
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
    
    func resetAllRecords(in entity : String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do {
            try context.execute(deleteRequest)
            try context.save()
            
            let alert = UIAlertController(title: "reset_zones_done".localized(), message: "reset_zones_done_description".localized(), preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "ok".localized(), style: UIAlertAction.Style.default, handler: nil))
            
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        } catch {
            print ("There was an error")
        }
    }
    
    func resetCountriesIncluded(_ dataManager: DataManager = DataManager()) {
            dataManager.resetCountryIncluded()
            let alert = UIAlertController(title: "reset_zones_done".localized(), message: "reset_countries_done_description".localized(), preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "ok".localized(), style: UIAlertAction.Style.default, handler: nil))
            
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func firstStart(){
        let dataManager = DataManager()
        let alert = UIAlertController(title: "first_start_title".localized(), message: "first_start_description".localized(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "video_tutorial".localized(), style: .default) { (UIAlertAction) in
            guard let mailto = URL(string: "https://youtu.be/pTQKVbSE38U") else { return }
            UIApplication.shared.open(mailto)
        })
        alert.addAction(UIAlertAction(title: "install_shortcuts".localized(), style: .default) { (UIAlertAction) in
            guard let discord = URL(string: "http://raccourcis.ios.free.fr/fmobile") else { return }
            UIApplication.shared.open(discord)
        })
        alert.addAction(UIAlertAction(title: "close".localized(), style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "never_show_again".localized(), style: .cancel) { (UIAlertAction) in
            dataManager.datas.set(true, forKey: "didFinishFirstStart")
            dataManager.datas.synchronize()
        })
        present(alert, animated: true, completion: nil)
    }
    
    func seturl(){
        let datas = Foundation.UserDefaults.standard
        
        let alertController = UIAlertController(title: "custom_url_title".localized(), message: "custom_url_description".localized(), preferredStyle: .alert)
        
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "save".localized(), style: .default) { (_) in
            
            guard URL(string: alertController.textFields?[0].text?.lowercased() ?? "s") != nil else {
                let alertController2 = UIAlertController(title: "error".localized(), message: "url_error_message".localized(), preferredStyle: .alert)
                let confirmAction2 = UIAlertAction(title: "retry".localized(), style: .default) { (_) in
                    self.seturl()
                    return
                }
                let cancelAction2 = UIAlertAction(title: "cancel".localized(), style: .cancel) { (_) in
                    return
                }
                
                let defaultAction2 = UIAlertAction(title: "set_default_url".localized(), style: .default) { (_) in
                    datas.set("http://test-debit.free.fr/512.rnd", forKey: "URL")
                    datas.set("http://test-debit.free.fr/1048576.rnd", forKey: "URLST")
                    datas.synchronize()
                    return
                }
                
                alertController2.addAction(confirmAction2)
                alertController2.addAction(defaultAction2)
                alertController2.addAction(cancelAction2)
                
                //finally presenting the dialog box
                self.present(alertController2, animated: true, completion: nil)
                
                return
            }
            guard URL(string: alertController.textFields?[1].text?.lowercased() ?? "s") != nil else {
                let alertController2 = UIAlertController(title: "error".localized(), message: "url_error_message".localized(), preferredStyle: .alert)
                let confirmAction2 = UIAlertAction(title: "retry".localized(), style: .default) { (_) in
                    self.seturl()
                    return
                }
                let cancelAction2 = UIAlertAction(title: "cancel".localized(), style: .cancel) { (_) in
                    return
                }
                
                let defaultAction2 = UIAlertAction(title: "set_default_url".localized(), style: .default) { (_) in
                    datas.set("http://test-debit.free.fr/512.rnd", forKey: "URL")
                    datas.set("http://test-debit.free.fr/1048576.rnd", forKey: "URLST")
                    datas.synchronize()
                    return
                }
                
                alertController2.addAction(confirmAction2)
                alertController2.addAction(defaultAction2)
                alertController2.addAction(cancelAction2)
                
                //finally presenting the dialog box
                self.present(alertController2, animated: true, completion: nil)
                
                return
            }
            
            
            datas.set(alertController.textFields?[0].text?.lowercased() ?? "http://test-debit.free.fr/512.rnd", forKey: "URL")
            datas.set(alertController.textFields?[1].text?.lowercased() ?? "http://test-debit.free.fr/1048576.rnd", forKey: "URLST")
            datas.synchronize()
        }
        
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "cancel".localized(), style: .cancel) { (_) in
            return
        }
        
        let defaultAction = UIAlertAction(title: "set_default_url".localized(), style: .default) { (_) in
            datas.set("http://test-debit.free.fr/512.rnd", forKey: "URL")
            datas.set("http://test-debit.free.fr/1048576.rnd", forKey: "URLST")
            datas.synchronize()
            return
        }
        
        //adding textfields to our dialog box
        alertController.addTextField { (textField) in
            textField.placeholder = "url_for_engine".localized()
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "url_for_speedtest".localized()
        }
        
        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(defaultAction)
        alertController.addAction(cancelAction)
        
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
    }
    
    func manualSetup(_ dataManager: DataManager = DataManager()) {
        let alertController = UIAlertController(title: "setup_title".localized(), message: "setup_description".localized(), preferredStyle: .alert)
        
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "save".localized(), style: .default) { (_) in
            
            dataManager.datas.set((alertController.textFields?[0].text! as NSString?)?.doubleValue ?? 0.768, forKey: "STMS")
            dataManager.datas.set(alertController.textFields?[1].text?.uppercased() ?? "null", forKey: "HP")
            dataManager.datas.set(alertController.textFields?[2].text?.uppercased() ?? "null", forKey: "NRP")
            dataManager.datas.set(dataManager.mycarrier.mobileCountryCode ?? "---", forKey: "MCC")
            dataManager.datas.set(dataManager.mycarrier.mobileNetworkCode ?? "--", forKey: "MNC")
            dataManager.datas.set(dataManager.mycarrier.isoCountryCode?.uppercased() ?? "--", forKey: "LAND")
            dataManager.datas.set(alertController.textFields?[3].text ?? "null", forKey: "ITINAME")
            dataManager.datas.set(alertController.textFields?[4].text ?? "null", forKey: "HOMENAME")
            dataManager.datas.set(alertController.textFields?[5].text ?? "null", forKey: "ITIMNC")
            dataManager.datas.set(alertController.textFields?[6].text?.lowercased() ?? "null", forKey: "NRFEMTO")
            dataManager.datas.set(alertController.textFields?[7].text?.lowercased() ?? "null", forKey: "OUT2G")
            dataManager.datas.set(true, forKey: "setupDone")
            dataManager.datas.set(false, forKey: "minimalSetup")
            dataManager.datas.set(false, forKey: "disableFMobileCore")
            dataManager.datas.synchronize()
        }
        
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "cancel".localized(), style: .cancel) { (_) in
            dataManager.datas.set(false, forKey: "setupDone")
        }
        
        //adding textfields to our dialog box
        alertController.addTextField { (textField) in
            textField.placeholder = "form_nra".localized()
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "form_hp".localized()
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "form_nr".localized()
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "form_name".localized()
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "form_hname".localized()
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "form_mnc".localized()
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "form_femto".localized()
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "form_out2g".localized()
        }
        
        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
    }
    
    func setup(_ dataManager: DataManager = DataManager()) {
        let alert = UIAlertController(title: "detecting_autoconfig".localized(), message:nil, preferredStyle: UIAlertController.Style.alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        alert.view.addSubview(loadingIndicator)
        
        present(alert, animated: true, completion: nil)
        
        // POURQUOI TANT D'ATTENTE ?! (12,7s)
        
        self.delay(4.3){
            UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
        
            if dataManager.mycarrier.mobileCountryCode == "208" && dataManager.mycarrier.mobileNetworkCode == "15"{
                let alert = UIAlertController(title: "Config OK ! [208 15]", message:nil, preferredStyle: UIAlertController.Style.alert)
                
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                
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
                
                self.delay(3){
                    UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
                }
            } else {
                
                let alertController = UIAlertController(title: "choose_setup".localized(), message: "choose_setup_description".localized(), preferredStyle: .alert)
                
                let confirmAction = UIAlertAction(title: "use_minimal_setup".localized(), style: .default) { (_) in
                    dataManager.datas.set(dataManager.mycarrier.mobileCountryCode ?? "---", forKey: "MCC")
                    dataManager.datas.set(dataManager.mycarrier.mobileNetworkCode ?? "--", forKey: "MNC")
                    dataManager.datas.set(dataManager.mycarrier.isoCountryCode?.uppercased() ?? "--", forKey: "LAND")
                    dataManager.datas.synchronize()
                    
                    let alert2 = UIAlertController(title: "checking_eligibility".localized(), message:nil, preferredStyle: UIAlertController.Style.alert)
                    let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 5, width: 50, height: 50))
                    loadingIndicator.hidesWhenStopped = true
                    loadingIndicator.style = UIActivityIndicatorView.Style.gray
                    loadingIndicator.startAnimating();
                    alert2.view.addSubview(loadingIndicator)
                    
                    self.present(alert2, animated: true, completion: nil)
                    
                    self.delay(4){
                        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
                        if DataManager.isEligibleForMinimalSetup(){
                            dataManager.datas.set(true, forKey: "minimalSetup")
                            dataManager.datas.set(false, forKey: "disableFMobileCore")
                            dataManager.datas.set(true, forKey: "setupDone")
                            dataManager.datas.synchronize()
                        } else {
                            let alertController2 = UIAlertController(title: "compatibility_issues".localized(), message: "compatibility_error_message".localized(), preferredStyle: .alert)
                            let confirmAction2 = UIAlertAction(title: "force_minimal_setup".localized(), style: .destructive) { (_) in
                                dataManager.datas.set(true, forKey: "minimalSetup")
                                dataManager.datas.set(false, forKey: "disableFMobileCore")
                                dataManager.datas.set(true, forKey: "setupDone")
                                dataManager.datas.synchronize()
                            }
                            let cancelAction2 = UIAlertAction(title: "run_standard_setup".localized(), style: .default) { (_) in
                                self.manualSetup()
                            }
                            
                            alertController2.addAction(confirmAction2)
                            alertController2.addAction(cancelAction2)
                            
                            self.present(alertController2, animated: true, completion: nil)
                            
                            
                        }
                        
                    }
                }
                
                let cancelAction = UIAlertAction(title: "use_standard_setup".localized(), style: .default) { (_) in
                    self.manualSetup()
                }
                
                alertController.addAction(confirmAction)
                alertController.addAction(cancelAction)
                
                //finally presenting the dialog box
                self.present(alertController, animated: true, completion: nil)
                
            }
        }
                
    }
    
    func warning(){
        let dataManager = DataManager()
        let alert = UIAlertController(title: "warning_title".localized(), message: "warning_description".localized(), preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "uninstall".localized(), style: .destructive) { (UIAlertAction) in
            dataManager.datas.set(false, forKey: "warningApproved")
            dataManager.datas.synchronize()
            UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
        })
        alert.addAction(UIAlertAction(title: "accept_conditions".localized(), style: .cancel) { (UIAlertAction) in
            dataManager.datas.set(true, forKey: "warningApproved")
            dataManager.datas.synchronize()
        })
        
        present(alert, animated: true, completion: nil)
    }
    
//
//    func geocode(latitude: Double, longitude: Double, completion: @escaping (CLPlacemark?, Error?) -> ())  {
//        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: latitude, longitude: longitude)) { completion($0?.first, $1) }
//    }
//
    func start(){
        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            let authorizationStatus = CLLocationManager.authorizationStatus()
            if authorizationStatus != .authorizedAlways {
                // User has not authorized access to location information.
                print("UNAUTHORIZED")
                isAUTH = false
                return
            }
            
            if !CLLocationManager.significantLocationChangeMonitoringAvailable() {
                // The service is not available.
                print("UNAVAILABLE")
                isAUTH = false
                return
            }
            locationManager.startMonitoringSignificantLocationChanges()
            locationManager.pausesLocationUpdatesAutomatically = false
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.disallowDeferredLocationUpdates()
            locationManager.distanceFilter = kCLDistanceFilterNone
            locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            locationManager.startUpdatingLocation()
            print("STARTING ANALYSIS")
            isAUTH = true
        }
    }
    
    func downgrade(){
        let appVersion = Int(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0") ?? 0
        let datas = Foundation.UserDefaults.standard
        
        datas.set(appVersion, forKey: "version")
        datas.synchronize()
    }
    
    func update(_ version : Int = 0){
        print("UPDATE CALLED")
        let dataManager = DataManager()
        
        let appVersion = Int(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0") ?? 0
        let datas = Foundation.UserDefaults.standard
        
        // Update protocol list
        
        // Fix the STMS value for FM.FRA
        if version < 66 && dataManager.setupDone && dataManager.targetMCC == "208" && dataManager.targetMNC == "15" {
            dataManager.datas.set(0.768, forKey: "STMS")
            dataManager.datas.synchronize()
        }
        
        // NEW MINIMAL SETUP
        if version < 69 && dataManager.setupDone && dataManager.targetMCC == "208" && dataManager.targetMNC == "15" {
            dataManager.datas.set(false, forKey: "minimalSetup")
            dataManager.datas.synchronize()
        }
        
        if version < 73 && dataManager.setupDone && dataManager.targetMCC == "208" {
            dataManager.datas.set(false, forKey: "setupDone")
            dataManager.datas.synchronize()
        }
        
        if version < 75 && dataManager.setupDone && dataManager.targetMCC == "208" && dataManager.targetMNC == "15" && version != 0 {
            let alert = UIAlertController(title: "Mise à jour disponible", message: "Une nouvelle mise à jour du raccrouci CFM est disponible (version 1.1). Cette mise à jour n'est pas incluse dans l'application et doit s'installer manuellement.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Mettre à jour le raccourci CFM", style: .default) { (UIAlertAction) in
                guard let discord = URL(string: "http://raccourcis.ios.free.fr/fmobile") else { return }
                UIApplication.shared.open(discord)
            })
            alert.addAction(UIAlertAction(title: "close".localized(), style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
        
        
        datas.set(appVersion, forKey: "version")
        datas.synchronize()
        
        print(dataManager.dispInfoNotif)
        if dataManager.dispInfoNotif {
            print("should send notification")
            if version == 0{
                NotificationManager.sendNotification(for: .update, with: "first_update_succeeded".localized())
            } else {
                NotificationManager.sendNotification(for: .update, with: "update_succeeded".localized().format([String(version), String(appVersion)]))
            }
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // On enregistre les cellules
        tableView.register(LabelTableViewCell.self, forCellReuseIdentifier: "labelCell")
        tableView.register(SwitchTableViewCell.self, forCellReuseIdentifier: "switchCell")
        tableView.register(ButtonTableViewCell.self, forCellReuseIdentifier: "buttonCell")
        
        // Ecoute les changements de couleurs
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeEnabled(_:)), name: .darkModeEnabled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeDisabled(_:)), name: .darkModeDisabled, object: nil)
        
        // On initialise les couleurs
        isDarkMode() ? enableDarkMode() : disableDarkMode()
        
        // On active certaines fonctionnalitees
        UIDevice.current.isBatteryMonitoringEnabled = true
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "FMobile"
        
        // On demarre le moteur et l'UI
        start()
        loadUI()
        refreshSections()
        
        // On save certaines preferences
        let datas = Foundation.UserDefaults.standard
        datas.set(false, forKey: "didAlertLB")
        datas.set(true, forKey: "statusUL")
        datas.set(Date().addingTimeInterval(-15 * 60), forKey: "NTimer")
        datas.synchronize()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .darkModeEnabled, object: nil)
        NotificationCenter.default.removeObserver(self, name: .darkModeDisabled, object: nil)
    }
    
    @objc override func darkModeEnabled(_ notification: Foundation.Notification) {
        super.darkModeEnabled(notification)
        self.tableView.reloadData()
    }
    
    @objc override func darkModeDisabled(_ notification: Foundation.Notification) {
        super.darkModeDisabled(notification)
        self.tableView.reloadData()
    }
    
    @objc override func enableDarkMode() {
        super.enableDarkMode()
        self.view.backgroundColor = CustomColor.darkTableBackground
        self.tableView.backgroundColor = CustomColor.darkTableBackground
        self.tableView.separatorColor = CustomColor.darkSeparator
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.view.backgroundColor = CustomColor.darkBackground
        self.navigationController?.navigationBar.tintColor = CustomColor.darkActive
    }
    
    @objc override func disableDarkMode() {
        super.disableDarkMode()
        self.view.backgroundColor = CustomColor.lightTableBackground
        self.tableView.backgroundColor = CustomColor.lightTableBackground
        self.tableView.separatorColor = CustomColor.lightSeparator
        self.navigationController?.navigationBar.barStyle = .default
        self.navigationController?.view.backgroundColor = CustomColor.lightBackground
        self.navigationController?.navigationBar.tintColor = CustomColor.lightActive
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let datas = Foundation.UserDefaults.standard
        datas.set(false, forKey: "isRunning")
        datas.synchronize()
        
        var didFinishFirstStart = false
        if(datas.value(forKey: "didFinishFirstStart") != nil){
            didFinishFirstStart = datas.value(forKey: "didFinishFirstStart") as? Bool ?? false
        }
        
        var stopverification = false
        if datas.value(forKey: "stopverification") != nil {
            stopverification = datas.value(forKey: "stopverification") as? Bool ?? false
        }
        
        var warningApproved = false
        if(datas.value(forKey: "warningApproved") != nil){
            warningApproved = datas.value(forKey: "warningApproved") as? Bool ?? false
        }
        
        var version = 0
        if(datas.value(forKey: "version") != nil){
            version = datas.value(forKey: "version") as? Int ?? 0
        }
        let appVersion = Int(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0") ?? 0
        
        print("Version: \(version)")
        print("AppVersion: \(appVersion)")
        
        if appVersion > version {
                update(version)
                if(datas.value(forKey: "version") != nil){
                    version = datas.value(forKey: "version") as? Int ?? 0
                }
                print("Version after update: \(version)")
        } else if appVersion < version {
            downgrade()
        }
        
        if !didFinishFirstStart{
            delay(5) { self.firstStart() }
        }
        
        if !warningApproved{
            delay(2) { self.warning() }
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { timer in
            if !self.isAUTH {
                self.start()
            }
    
            if !self.tableView.isCellVisible(section: 0, row: (self.sections.first?.elements.count ?? 1) - 1){
                print("INVISIBLE, STOP REFRESH !!!")
                return
            }
            print("Refresh started!")
            self.loadUI()
            self.refreshSections()
        }
        
        timernet = Timer.scheduledTimer(withTimeInterval: 20.0, repeats: true) { timernet in
            if !stopverification{
                print("REFRESH BACKGROUND TASKS FROM UI")
                AppDelegate.engineRunning()
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        timer?.invalidate()
        timernet?.invalidate()
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func diag(source: UIButton) {
        let alert = UIAlertController(title: "diagnostic_inprogress".localized(), message:nil, preferredStyle: UIAlertController.Style.alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        alert.view.addSubview(loadingIndicator)
        
        present(alert, animated: true, completion: nil)

        let dataManager = DataManager()
        
        let appVersion = Int(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0") ?? 0
        // Strings de l'UI
        
        var generation = ""
        if dataManager.ipadMCC == "---" && !dataManager.nrDEC && UIDevice.current.userInterfaceIdiom == .pad {
            generation = "FMobile b\(appVersion) - Génération A1"
        } else if dataManager.ipadMCC == "---" && UIDevice.current.userInterfaceIdiom == .pad {
            generation = "FMobile b\(appVersion) - Génération 1"
        } else if !dataManager.nrDEC || !dataManager.setupDone {
            generation = "FMobile b\(appVersion) - Génération A2"
        } else {
            generation = "FMobile b\(appVersion) - Génération 2"
        }
        
        let str = "Fichier de diagnostic FMobile\n\nModèle : \(UIDevice.current.modelName)\nVersion de l'OS : \(UIDevice.current.systemVersion)\nMoteur : \(generation)\nsetupDone : \(dataManager.setupDone)\nMinimal setup : \(dataManager.minimalSetup)\n\nConfiguration :\nmodeRadin : \(dataManager.modeRadin)\nallow013G : \(dataManager.allow013G)\nallow012G : \(dataManager.allow012G)\nfemtoLOWDATA : \(dataManager.femtoLOWDATA)\nfemto : \(dataManager.femto)\nverifyonwifi : \(dataManager.verifyonwifi)\nstopverification : \(dataManager.stopverification)\ntimecode : \(dataManager.timecode)\nlastnet : \(dataManager.lastnet)\ncount : \(dataManager.count)\nwasEnabled : \(dataManager.wasEnabled)\nisRunning : \(dataManager.isRunning)\nlowbat : \(dataManager.lowbat)\ndidChangeSettings : \(dataManager.didChangeSettings)\nntimer : \(dataManager.ntimer)\ndispInfoNotif : \(dataManager.dispInfoNotif)\nallowCountryDetection : \(dataManager.allowCountryDetection)\ntimeLastCountry : \(dataManager.timeLastCountry)\nlastCountry : \(dataManager.lastCountry)\n\nStatut opérateur :\nsimData : \(dataManager.simData)\ncurrentNetwork : \(dataManager.currentNetwork)\ncarrier: \(dataManager.carrier)\ncarrierNetwork : \(dataManager.carrierNetwork)\ncarrierNetwork2 : \(dataManager.carrierNetwork2)\ncarrierName : \(dataManager.carrierName)\n\nConfiguration opérateur :\nhp : \(dataManager.hp)\nnrp : \(dataManager.nrp)\ntargetMCC : \(dataManager.targetMCC)\ntargetMNC : \(dataManager.targetMNC)\nitiMNC : \(dataManager.itiMNC)\nnrDEC : \(dataManager.nrDEC)\nout2G : \(dataManager.out2G)\nchasedMNC : \(dataManager.chasedMNC)\nconnectedMCC : \(dataManager.connectedMCC)\nconnectedMNC : \(dataManager.connectedMNC)\nipadMCC : \(dataManager.ipadMCC)\nipadMNC : \(dataManager.ipadMNC)\nitiName : \(dataManager.itiName)\nhomeName : \(dataManager.homeName)\nstms : \(dataManager.stms)\n\nCommunications :\nWi-Fi : \(DataManager.isWifiConnected())\nCellulaire : \(DataManager.isConnectedToNetwork())\nCommunication en cours : \(DataManager.isOnPhoneCall())"
        let filename = getDocumentsDirectory().appendingPathComponent("diagnostic.txt")
        
        do {
            try str.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
        }
        
        self.delay(6.42){
            UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
            // Create the Array which includes the files you want to share
            var filesToShare = [Any]()
            
            // Add the path of the file to the Array
            
            // Show the share-view
            // self.present(activityViewController, animated: true, completion: nil)
            
           //let internalDiagnostic = URL(fileURLWithPath: "/System/Library/Carrier Bundles/iPhone/20815/carrier.plist")
            
            filesToShare.append(filename)
            //filesToShare.append(internalDiagnostic)
            
            // Make the activityViewContoller which shows the share-view
            let ls = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
            ls.popoverPresentationController?.sourceView = source
            ls.popoverPresentationController?.sourceRect = source.frame

            //UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
            // Show the share-view
            self.present(ls, animated: true, completion: nil)
        }
    }
    
    func loadUI() {
        let dataManager = DataManager()
        
        let datas = Foundation.UserDefaults.standard
        
        if !dataManager.setupDone{
            if dataManager.mycarrier.mobileCountryCode == "208" {
                AppDelegate.autosetup(dataManager)
            }
        }
        
        if dataManager.stopverification {
            locationManager.stopUpdatingLocation()
            locationManager.allowsBackgroundLocationUpdates = false
            locationManager.stopMonitoringSignificantLocationChanges()
            print("Should stop ALL KIND OF ACTUALIZATION... [CALLING FROM UI REFRESH]")
        } else {
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.startMonitoringSignificantLocationChanges()
            if dataManager.lowbat {
                //NotificationManager.sendNotification(for: .batteryLow)
                locationManager.stopUpdatingLocation()
                locationManager.allowsBackgroundLocationUpdates = true
                locationManager.startMonitoringSignificantLocationChanges()
                print("Should stop [CALLING FROM UI REFRESH]...")
            } else {
                //NotificationManager.sendNotification(for: .restarting)
                locationManager.startUpdatingLocation()
                locationManager.allowsBackgroundLocationUpdates = true
                locationManager.startMonitoringSignificantLocationChanges()
                print("Resume... [CALLING FROM UI REFRESH]")
            }
            
        }
        
        var lastCountry = "FR"
        if(dataManager.datas.value(forKey: "lastCountry") != nil){
            lastCountry = dataManager.datas.value(forKey: "lastCountry") as? String ?? "FR"
        }
        
        var timecoder = Date()
        if(dataManager.datas.value(forKey: "timecoder") != nil){
            timecoder = dataManager.datas.value(forKey: "timecoder") as? Date ?? Date()
        }
        
        var lastnetr = "HSDPAO"
        if(dataManager.datas.value(forKey: "lastnetr") != nil){
            lastnetr = dataManager.datas.value(forKey: "lastnetr") as? String ?? "HSDPAO"
        }
        
        print(lastCountry)
        print(lastnetr)
        
        dataManager.carrierNetwork = dataManager.carrierNetwork.replacingOccurrences(of: "CTRadioAccessTechnology", with: "", options: NSString.CompareOptions.literal, range: nil)
        dataManager.carrierNetwork2 = dataManager.carrierNetwork2.replacingOccurrences(of: "CTRadioAccessTechnology", with: "", options: NSString.CompareOptions.literal, range: nil)
        
        print(dataManager.carrierNetwork)
        
        let countryCode = dataManager.mycarrier.mobileCountryCode ?? "null"
        let mobileNetworkName = dataManager.mycarrier.mobileNetworkCode ?? "null"
        let carrierName = dataManager.carrierName
        let isoCountrycode = dataManager.mycarrier.isoCountryCode?.uppercased() ?? "null"
        
        let countryCode2 = dataManager.mycarrier2.mobileCountryCode ?? "null"
        let mobileNetworkName2 = dataManager.mycarrier2.mobileNetworkCode ?? "null"
        let carrierName2 = dataManager.mycarrier2.carrierName ?? "null"
        let isoCountrycode2 = dataManager.mycarrier2.isoCountryCode?.uppercased() ?? "null"
        
        let country = CarrierIdentification.getIsoCountryCode(dataManager.connectedMCC)
        
        var radincarrier = dataManager.carrier
        var radinitiname = dataManager.itiName
        if dataManager.modeRadin {
            if dataManager.connectedMCC == "208" && dataManager.connectedMNC == "01" {
                radincarrier = "Agrume F"
            } else if dataManager.connectedMCC == "208" && dataManager.connectedMNC == "10" {
                radincarrier = "Patoche"
            } else if dataManager.connectedMCC == "208" && dataManager.connectedMNC == "15" {
                radincarrier = "Radin"
            } else if dataManager.connectedMCC == "208" && dataManager.connectedMNC == "20" {
                radincarrier = "Béton"
            } else if dataManager.connectedMCC == "208" && dataManager.connectedMNC == "26" {
                radincarrier = "Redbull"
            }
        }
        if dataManager.modeRadin {
            if dataManager.connectedMCC == "208" && dataManager.itiMNC == "01"{
                radinitiname = "Agrume F"
            } else if dataManager.connectedMCC == "208" && dataManager.itiMNC == "10"{
                radinitiname = "Patoche"
            } else if dataManager.connectedMCC == "208" && dataManager.itiMNC == "15"{
                radinitiname = "Radin"
            } else if dataManager.connectedMCC == "208" && dataManager.itiMNC == "20"{
                radinitiname = "Béton"
            }
            else if dataManager.connectedMCC == "208" && dataManager.itiMNC == "26"{
                radinitiname = "Redbull"
            }
            
        }
        
        if dataManager.carrierNetwork == "LTE" {
            dataManager.carrierNetwork = dataManager.modeRadin ? "4G radine : \(radincarrier) (\(country))" : dataManager.modeExpert ?
                "\(dataManager.carrier) 4G (LTE) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))" :  "\(dataManager.carrier) 4G"
            lastnetr = "LTE"
            dataManager.datas.set(lastnetr, forKey: "lastnetr")
            dataManager.datas.synchronize()
        } else if dataManager.carrierNetwork == "WCDMA" {
            if dataManager.connectedMCC == dataManager.targetMCC && dataManager.connectedMNC == dataManager.chasedMNC && !DataManager.isWifiConnected() && dataManager.carrierNetwork == dataManager.nrp && dataManager.nrDEC {
                
                if dataManager.femto {
                    print(abs(timecoder.timeIntervalSinceNow))
                    
                    if abs(timecoder.timeIntervalSinceNow) < 10*60 && lastnetr == "WCDMAO" {
                        DispatchQueue.main.async {
                            dataManager.carrierNetwork = dataManager.modeRadin ? "Itinérance Delta radine : \(radinitiname) (\(country))" : dataManager.modeExpert ?
                                "\(dataManager.itiName) 3G (WCDMA) [\(dataManager.connectedMCC) \(dataManager.itiMNC)] (\(country))" :  "\(dataManager.itiName) 3G \("itinerance".localized())"
                            self.refreshSections()
                            print("CACHE ORANGE F")
                        }
                    } else if abs(timecoder.timeIntervalSinceNow) < 10*60 && lastnetr == "WCDMAF" {
                        DispatchQueue.main.async {
                            dataManager.carrierNetwork = dataManager.modeRadin ? "Femto ou mutualisation radine : \(radincarrier) (\(country))" : dataManager.modeExpert ?
                                "\(dataManager.carrier) 3G (WCDMA) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))" :  "\(dataManager.carrier) 3G (Femto)"
                            self.refreshSections()
                            print("CACHE FEMTO")
                        }
                    } else {
                        Speedtest().testDownloadSpeedWithTimout(timeout: 5.0, usingURL: dataManager.url) { (speed, error) in
                            DispatchQueue.main.async {
                                if speed ?? 0 < dataManager.stms{
                                    dataManager.carrierNetwork = dataManager.modeRadin ? "Itinérance Delta radine : \(radinitiname) (\(country))" : dataManager.modeExpert ?
                                        "\(dataManager.itiName) 3G (WCDMA) [\(dataManager.connectedMCC) \(dataManager.itiMNC)] (\(country))" :  "\(dataManager.itiName) 3G \("itinerance".localized())"
                                    lastnetr = "WCDMAO"
                                } else {
                                    dataManager.carrierNetwork = dataManager.modeRadin ? "Femto ou mutualisation radine : \(radincarrier) (\(country))" : dataManager.modeExpert ?
                                        "\(dataManager.carrier) 3G (WCDMA) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))" :  "\(dataManager.carrier) 3G (Femto)"
                                    lastnetr = "WCDMAF"
                                }
                                timecoder = Date()
                                dataManager.datas.set(lastnetr, forKey: "lastnetr")
                                dataManager.datas.set(timecoder, forKey: "timecoder")
                                dataManager.datas.synchronize()
                                self.refreshSections()
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        dataManager.carrierNetwork = dataManager.modeRadin ? "Itinérance Delta radine : \(radinitiname) (\(country))" : dataManager.modeExpert ?
                            "\(dataManager.itiName) 3G (WCDMA) [\(dataManager.connectedMCC) \(dataManager.itiMNC)] (\(country))" :  "\(dataManager.itiName) 3G \("itinerance".localized())"
                        self.refreshSections()
                        lastnetr = "WCDMAE"
                        dataManager.datas.set(lastnetr, forKey: "lastnetr")
                        dataManager.datas.synchronize()
                    }
                }
                
            } else {
                lastnetr = "WCDMA"
                dataManager.datas.set(lastnetr, forKey: "lastnetr")
                dataManager.datas.synchronize()
            }
            dataManager.carrierNetwork = dataManager.modeRadin ? "3G radine : \(radincarrier) (\(country))" : dataManager.modeExpert ?
                "\(dataManager.carrier) 3G (WCDMA) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))" :  "\(dataManager.carrier) 3G"
        } else if dataManager.carrierNetwork == "HSDPA" {
            if dataManager.connectedMCC == dataManager.targetMCC && dataManager.connectedMNC == dataManager.chasedMNC && !DataManager.isWifiConnected() && dataManager.carrierNetwork == dataManager.nrp && dataManager.nrDEC {
                
                if dataManager.femto {
                    print(abs(timecoder.timeIntervalSinceNow))
                    
                    if abs(timecoder.timeIntervalSinceNow) < 10*60 && lastnetr == "HSDPAO" {
                        DispatchQueue.main.async {
                            dataManager.carrierNetwork = dataManager.modeRadin ? "Itinérance Delta radine : \(radinitiname) (\(country))" : dataManager.modeExpert ?
                                "\(dataManager.itiName) 3G (HSDPA) [\(dataManager.connectedMCC) \(dataManager.itiMNC)] (\(country))" :  "\(dataManager.itiName) 3G \("itinerance".localized())"
                            self.refreshSections()
                            print("CACHE ORANGE F")
                        }
                    } else if abs(timecoder.timeIntervalSinceNow) < 10*60 && lastnetr == "HSDPAF" {
                        DispatchQueue.main.async {
                            dataManager.carrierNetwork = dataManager.modeRadin ? "Femto ou mutualisation radine : \(radincarrier) (\(country))" : dataManager.modeExpert ?
                                "\(dataManager.carrier) 3G (HSDPA) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))" :  "\(dataManager.carrier) 3G (Femto)"
                            self.refreshSections()
                            print("CACHE FEMTO")
                        }
                    } else {
                        Speedtest().testDownloadSpeedWithTimout(timeout: 5.0, usingURL: dataManager.url) { (speed, error) in
                            DispatchQueue.main.async {
                                if speed ?? 0 < dataManager.stms {
                                    dataManager.carrierNetwork = dataManager.modeRadin ? "Itinérance Delta radine : \(radinitiname) (\(country))" : dataManager.modeExpert ?
                                        "\(dataManager.itiName) 3G (HSDPA) [\(dataManager.connectedMCC) \(dataManager.itiMNC)] (\(country))" :  "\(dataManager.itiName) 3G \("itinerance".localized())"
                                    lastnetr = "HSDPAO"
                                } else {
                                    dataManager.carrierNetwork = dataManager.modeRadin ? "Femto ou mutualisation radine : \(radincarrier) (\(country))" : dataManager.modeExpert ?
                                        "\(dataManager.carrier) 3G (HSDPA) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))" :  "\(dataManager.carrier) 3G (Femto)"
                                    lastnetr = "HSDPAF"
                                }
                                timecoder = Date()
                                dataManager.datas.set(lastnetr, forKey: "lastnetr")
                                dataManager.datas.set(timecoder, forKey: "timecoder")
                                dataManager.datas.synchronize()
                                self.refreshSections()
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        dataManager.carrierNetwork = dataManager.modeRadin ? "Itinérance Delta radine : \(radinitiname) (\(country))" : dataManager.modeExpert ?
                            "\(dataManager.itiName) 3G (HSDPA) [\(dataManager.connectedMCC) \(dataManager.itiMNC)] (\(country))" :  "\(dataManager.itiName) 3G \("itinerance".localized())"
                        self.refreshSections()
                        lastnetr = "HSDPAE"
                        dataManager.datas.set(lastnetr, forKey: "lastnetr")
                        dataManager.datas.synchronize()
                    }
                }
                
            } else {
                lastnetr = "HSDPA"
                dataManager.datas.set(lastnetr, forKey: "lastnetr")
                dataManager.datas.synchronize()
            }
            dataManager.carrierNetwork = dataManager.modeRadin ? "3G radine : \(radincarrier) (\(country))" : dataManager.modeExpert ?
                "\(dataManager.carrier) 3G (HSDPA) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))" :  "\(dataManager.carrier) 3G"
        } else if dataManager.carrierNetwork == "Edge"{
            dataManager.carrierNetwork = dataManager.connectedMCC == dataManager.targetMCC && dataManager.connectedMNC == dataManager.chasedMNC && dataManager.out2G == "yes" ?
                (dataManager.modeRadin ? "Itinérance tupperware radine : \(radinitiname) (\(country))" : dataManager.modeExpert ? "\(dataManager.itiName) 2G (EDGE) [\(dataManager.connectedMCC) \(dataManager.itiMNC)] (\(country))" : "\(dataManager.itiName) 2G \("itinerance".localized())") : (dataManager.modeRadin ? "2G radine : \(radincarrier) (\(country))" : dataManager.modeExpert ? "\(dataManager.carrier) 2G (EDGE) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))" : "\(dataManager.carrier) 2G")
            lastnetr = "Edge"
            dataManager.datas.set(lastnetr, forKey: "lastnetr")
            dataManager.datas.synchronize()
        } else if dataManager.carrierNetwork == "GPRS"{
            dataManager.carrierNetwork = dataManager.connectedMCC == dataManager.targetMCC && dataManager.connectedMNC == dataManager.chasedMNC && dataManager.out2G == "yes" ?
                (dataManager.modeRadin ? "Itinérance VHS radine : \(radinitiname) (\(country))" : dataManager.modeExpert ? "\(dataManager.itiName) G (GPRS) [\(dataManager.connectedMCC) \(dataManager.itiMNC)] (\(country))" : "\(dataManager.itiName) G \("itinerance".localized())") : (dataManager.modeRadin ? "G radin : \(radincarrier) (\(country))" : dataManager.modeExpert ? "\(dataManager.carrier) G (GPRS) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))" : "\(dataManager.carrier) G")
            lastnetr = "GPRS"
            dataManager.datas.set(lastnetr, forKey: "lastnetr")
            dataManager.datas.synchronize()
        } else if dataManager.carrierNetwork == "HRPD"{
            dataManager.carrierNetwork = dataManager.modeRadin ? "3G radine : \(radincarrier) (\(country))" : dataManager.modeExpert ?
                "\(dataManager.carrier) 3G (HRPD) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))" :  "\(dataManager.carrier) 3G"
            lastnetr = "HRPD"
            dataManager.datas.set(lastnetr, forKey: "lastnetr")
            dataManager.datas.synchronize()
        } else if dataManager.carrierNetwork == "HSUPA"{
            dataManager.carrierNetwork = dataManager.modeRadin ? "3G radine : \(radincarrier) (\(country))" : dataManager.modeExpert ?
                "\(dataManager.carrier) 3G (HSUPA) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))" :  "\(dataManager.carrier) 3G"
            lastnetr = "HSUPA"
            dataManager.datas.set(lastnetr, forKey: "lastnetr")
            dataManager.datas.synchronize()
        } else if dataManager.carrierNetwork == "CDMA1x"{
            dataManager.carrierNetwork = dataManager.modeRadin ? "3G radine : \(radincarrier) (\(country))" : dataManager.modeExpert ?
                "\(dataManager.carrier) 3G (CDMA2000) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))" :  "\(dataManager.carrier) 3G"
            lastnetr = "CDMA1x"
            dataManager.datas.set(lastnetr, forKey: "lastnetr")
            dataManager.datas.synchronize()
        } else if dataManager.carrierNetwork == "CDMAEVDORev0"{
            dataManager.carrierNetwork = dataManager.modeRadin ? "3G radine : \(radincarrier) (\(country))" : dataManager.modeExpert ?
                "\(dataManager.carrier) 3G (EvDO) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))" :  "\(dataManager.carrier) 3G"
            lastnetr = "CDMAEVDORev0"
            dataManager.datas.set(lastnetr, forKey: "lastnetr")
            dataManager.datas.synchronize()
        } else if dataManager.carrierNetwork == "CDMAEVDORevA"{
            dataManager.carrierNetwork = dataManager.modeRadin ? "3G radine : \(radincarrier) (\(country))" : dataManager.modeExpert ?
                "\(dataManager.carrier) 3G (EvDO-A) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))" :  "\(dataManager.carrier) 3G"
            lastnetr = "CDMAEVDORevA"
            dataManager.datas.set(lastnetr, forKey: "lastnetr")
            dataManager.datas.synchronize()
        } else if dataManager.carrierNetwork == "CDMAEVDORevB"{
            dataManager.carrierNetwork = dataManager.modeRadin ? "3G radine : \(radincarrier) (\(country))" : dataManager.modeExpert ?
                "\(dataManager.carrier) 3G (EvDO-B) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))" :  "\(dataManager.carrier) 3G"
            lastnetr = "CDMAEVDORevB"
            dataManager.datas.set(lastnetr, forKey: "lastnetr")
            dataManager.datas.synchronize()
        }
        
        if !dataManager.modeRadin && !dataManager.modeExpert && CarrierIdentification.getIsoCountryCode(dataManager.connectedMCC) != CarrierIdentification.getIsoCountryCode(dataManager.targetMCC) && CarrierIdentification.getIsoCountryCode(dataManager.connectedMCC) != "--" && dataManager.carrierNetwork != "" && !dataManager.carrierNetwork.isEmpty{
            dataManager.carrierNetwork += " (\(country))"
        }
        
//        if DataManager.isWifiConnected() {
//            if !dataManager.carrierNetwork.isEmpty{
//                dataManager.carrierNetwork = "Wi-Fi + " + dataManager.carrierNetwork
//            } else {
//                dataManager.carrierNetwork = "Wi-Fi"
//            }
//        }
        
        if dataManager.carrierNetwork2 == "LTE" {
            dataManager.carrierNetwork2 = dataManager.modeRadin ? "4G" : dataManager.modeExpert ? "4G (LTE)" : "4G"
        } else if dataManager.carrierNetwork2 == "WCDMA" {
            dataManager.carrierNetwork2 = dataManager.modeRadin ? "3G" : dataManager.modeExpert ? "3G (WCDMA)" : "3G"
        } else if dataManager.carrierNetwork2 == "HSDPA" {
            dataManager.carrierNetwork2 = dataManager.modeRadin ? "H+" : dataManager.modeExpert ? "H+ (HSDPA)" : "H+"
        } else if dataManager.carrierNetwork2 == "Edge"{
            dataManager.carrierNetwork2 = dataManager.modeRadin ? "2G" : dataManager.modeExpert ? "2G (EDGE)" : "2G"
        } else if dataManager.carrierNetwork2 == "GPRS"{
            dataManager.carrierNetwork2 = dataManager.modeRadin ? "G" : dataManager.modeExpert ? "G (GPRS)" : "G"
        } else if dataManager.carrierNetwork2 == "HRPD"{
            dataManager.carrierNetwork2 = dataManager.modeRadin ? "3G" : dataManager.modeExpert ? "3G (HRPD)" : "3G"
        } else if dataManager.carrierNetwork2 == "HSUPA"{
            dataManager.carrierNetwork2 = dataManager.modeRadin ? "H+" : dataManager.modeExpert ? "H+ (HSUPA)" : "H+"
        } else if dataManager.carrierNetwork2 == "CDMA1x"{
            dataManager.carrierNetwork2 = dataManager.modeRadin ? "3G" : dataManager.modeExpert ? "3G (CDMA2000)" : "3G"
        } else if dataManager.carrierNetwork2 == "CDMAEVDORev0"{
            dataManager.carrierNetwork2 = dataManager.modeRadin ? "3G" : dataManager.modeExpert ? "3G (EvDO)" : "3G"
        } else if dataManager.carrierNetwork2 == "CDMAEVDORevA"{
            dataManager.carrierNetwork2 = dataManager.modeRadin ? "3G" : dataManager.modeExpert ? "3G (EvDO-A)" : "3G"
        } else if dataManager.carrierNetwork2 == "CDMAEVDORevB"{
            dataManager.carrierNetwork2 = dataManager.modeRadin ? "3G" : dataManager.modeExpert ? "3G (EvDO-B)" : "3G"
        }
        
        print(dataManager.carrierNetwork)
        print(dataManager.carrierNetwork2)
        
        if countryCode == "null" && mobileNetworkName == "null" && dataManager.carrierNetwork == "null" && !alertInit {
            delay(0.05) {
                let alert = UIAlertController(title: "insert_sim_title".localized(), message:"insert_sim_description".localized(), preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "ok".localized(), style: UIAlertAction.Style.default, handler: nil))
                
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            }
        }
        
        alertInit = true
        
        var disp: String
        if countryCode == "null" || countryCode.isEmpty {
            disp = dataManager.modeRadin ? "Pas de carte SIM radine détéctée" : "no_sim".localized()
        } else {
            if countryCode == "208" && mobileNetworkName == "15" {
                disp = "\("sim_card".localized()) \(dataManager.modeRadin ? "Radin" : carrierName)"
                if dataManager.modeExpert {
                    disp += " [\(countryCode) \(mobileNetworkName)] (\(isoCountrycode))"
                }
            }
            else if countryCode == "208" && mobileNetworkName == "01" {
                disp = "\("sim_card".localized()) \(dataManager.modeRadin ? "Agrume France" : carrierName)"
                if dataManager.modeExpert {
                    disp += " [\(countryCode) \(mobileNetworkName)] (\(isoCountrycode))"
                }
            } else if countryCode == "208" && mobileNetworkName == "10" {
                disp = "\("sim_card".localized()) \(dataManager.modeRadin ? "Patoche has no limits" : carrierName)"
                if dataManager.modeExpert {
                    disp += " [\(countryCode) \(mobileNetworkName)] (\(isoCountrycode))"
                }
            } else if countryCode == "208" && mobileNetworkName == "20" {
                disp = "\("sim_card".localized()) \(dataManager.modeRadin ? "Béton Télécom" : carrierName)"
                if dataManager.modeExpert {
                    disp += " [\(countryCode) \(mobileNetworkName)] (\(isoCountrycode))"
                }
            } else if countryCode == "208" && mobileNetworkName == "26" {
                disp = "\("sim_card".localized()) \(dataManager.modeRadin ? "Redbull Mobile" : carrierName)"
                if dataManager.modeExpert {
                    disp += " [\(countryCode) \(mobileNetworkName)] (\(isoCountrycode))"
                }
            }
            
            else {
                disp = "\("sim_card".localized()) \(carrierName)"
                if dataManager.modeExpert {
                    disp += " [\(countryCode) \(mobileNetworkName)] (\(isoCountrycode))"
                }
            }
        }
        
        var disp2: String
        if countryCode2 == "null" || countryCode2.isEmpty {
            disp2 = dataManager.modeRadin ? "Pas de eSIM radine activée" : "no_esim".localized()
        } else {
            if countryCode2 == "208" && mobileNetworkName2 == "15" {
                disp2 = "\("esim".localized()) \(dataManager.modeRadin ? "Radin" : carrierName2)"
                if dataManager.modeExpert {
                    disp2 += " [\(countryCode2) \(mobileNetworkName2)] (\(isoCountrycode2))"
                }
            }
            else if countryCode2 == "208" && mobileNetworkName2 == "01" {
                disp2 = "\("esim".localized()) \(dataManager.modeRadin ? "Agrume France" : carrierName2)"
                if dataManager.modeExpert {
                    disp2 += " [\(countryCode2) \(mobileNetworkName2)] (\(isoCountrycode2))"
                }
            }
            else if countryCode2 == "208" && mobileNetworkName2 == "10" {
                disp2 = "\("esim".localized()) \(dataManager.modeRadin ? "Patoche has no limits" : carrierName2)"
                if dataManager.modeExpert {
                    disp2 += " [\(countryCode2) \(mobileNetworkName2)] (\(isoCountrycode2))"
                }
            }
            else if countryCode2 == "208" && mobileNetworkName2 == "20" {
                disp2 = "\("esim".localized()) \(dataManager.modeRadin ? "Béton Télécom" : carrierName2)"
                if dataManager.modeExpert {
                    disp2 += " [\(countryCode2) \(mobileNetworkName2)] (\(isoCountrycode2))"
                }
            }
            else if countryCode2 == "208" && mobileNetworkName2 == "26" {
                disp2 = "\("esim".localized()) \(dataManager.modeRadin ? "Redbull Mobile" : carrierName2)"
                if dataManager.modeExpert {
                    disp2 += " [\(countryCode2) \(mobileNetworkName2)] (\(isoCountrycode2))"
                }
            }
            else {
                disp2 = "\("esim".localized()) \(carrierName2)"
                if dataManager.modeExpert {
                    disp2 += " [\(countryCode2) \(mobileNetworkName2)] (\(isoCountrycode2))"
                }
            }
        }
        
        
        let appVersion = Int(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0") ?? 0
        // Strings de l'UI
        
        var generation = ""
        if dataManager.ipadMCC == "---" && !dataManager.nrDEC && UIDevice.current.userInterfaceIdiom == .pad {
            generation = "generation".localized().format([String(appVersion), "A1"])
        } else if dataManager.ipadMCC == "---" && UIDevice.current.userInterfaceIdiom == .pad {
            generation = "generation".localized().format([String(appVersion), "1"])
        } else if !dataManager.nrDEC || !dataManager.setupDone {
            generation = "generation".localized().format([String(appVersion), "A2"])
        } else {
            generation = "generation".localized().format([String(appVersion), "2"])
        }
        
        let sta = dataManager.modeRadin ? "État du réseau radin" : "status".localized()
        let prefsnet = dataManager.modeRadin ? "Préférences radines" : "netprefs".localized()
        let iti3G = dataManager.modeRadin ? "Itinérance Delta autorisée" : "allow3g".localized()
        let iti2G = dataManager.modeRadin ? "Itinérance tupperware autorisée" : "allow2g".localized()
        let wifiaut = dataManager.modeRadin ? "Vérifier sur ma Radinbox" : "verifywifi".localized()
        let wififoo = dataManager.modeRadin ? "En activant cette option, les vérifications de l'itinérance radine auront lieu même lorsque vous êtes connecté à une Radinbox. Afin d'optimiser la batterie (sauf pour la génération A2), il est recommandé de garder cette option radine désactivée." : dataManager.modeExpert ? "wififooter".localized() : ""
        let stvr = dataManager.modeRadin ? "Arrêter la surveillance radine" : "stop_background_tasks".localized()
        let fmt = dataManager.modeRadin ? "Mutualisation et Femto radins" : dataManager.modeExpert ? "detect_ransharing".localized() : "detect_femto".localized()
        let bkg = dataManager.modeRadin ? "Arrière plan radin" : "background".localized()
        let eco = dataManager.modeRadin ? "Anti-saturation du réseau Radin" : "lowdata_mode".localized()
        var sat = dataManager.modeRadin ? "Pour détecter automatiquement un RadinFemto, nous demandons à iOS de télécharger un fichier radin afin d'effectuer un test de rapidité du réseau Radin. Le mode anti-saturation permet de sauver le réseau de Xavier Radiniel." : "femto_footer".localized()
        let zns = dataManager.modeRadin ? "Réinitialiser les zones radines" : "reset_offline_zones".localized()
        var land = dataManager.modeRadin ? "Anti-racket-super-arnaque" : "extra_cost_protection".localized()
        var fland = dataManager.modeRadin ? "En activant cette option, l'app vérifie en arrière plan dans quelle zone tarifaire vous vous situez et vérifie si vos données cellulaires sont activées (encore une idée de Thomas). Vous receverez plusieurs notifications radines vous invitant à couper vos données cellulaires au plus vite afin de cesser le financement de Radin." : "land_footer".localized()
        var nland = "cost_protection_title".localized()
        let cso = dataManager.modeRadin ? "Services opérateur radin" : "carrier_services".localized()
        let suivi = dataManager.modeRadin ? "Suivi complet de consommation Radine" : "suivi_conso_20815".localized()
        let c555 = dataManager.modeRadin ? "SMS de conso Radin" : "call_555_sms".localized()
        let help = dataManager.modeRadin ? "Assistance radine" : "help".localized()
        let c3244 = dataManager.modeRadin ? "Appeler le SAV Radin" : "call_3244".localized()
        let cont = dataManager.modeRadin ? "Contacter le développeur radin" : "contact_developer".localized()
        let lb = dataManager.modeRadin ? "Mode batterie radine" : "low_energy".localized()
        let lowbatfoo = dataManager.modeRadin ? "Lorsque le mode batterie radine est activé, les vérifications auront lieu après un déplacement d'environ 500m, au moment du changement de l'antenne radine. Si vous quittez de force l'application radine, ce mode s'activera automatiquement." : "low_energy_footer".localized()
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            if (dataManager.ipadMCC == "---" && dataManager.ipadMNC == "--"){
                land = dataManager.modeRadin ? "Vérifier les voyages radins" : "land_g1".localized()
                fland = dataManager.modeRadin ? "En activant cette option, nous allons vérifier en arrière plan que vous vous situez toujours dans votre pays Radin afin d'empêcher les tâches pour sortir de l'itinérance radine lorsque vous êtes à l'étranger car les opérateurs étrangers ne possèdent pas notre réseau révolutionnaire à 768kbps. Votre opérateur Radin n'est pas encore compatible avec la 2ème génération de FMobile sur iPad, mais si un opérateur éligible est disponible, FMobile activera ici les fonctionalités de la 2ème génération automatiquement." : "land_footer_g1".localized()
                nland = "background_loc_g1".localized()
            }
        }
        
        if !dataManager.modeExpert && !(dataManager.targetMCC == "208" && dataManager.targetMNC == "15" && dataManager.setupDone) {
            sat = ""
        }
        
        delay(0.1) {
            if dataManager.modeRadin {
                if UIApplication.shared.alternateIconName == nil {
                    UIApplication.shared.setAlternateIconName("myradin-40"){ error in
                        if let error = error {
                            print(error.localizedDescription)
                        } else {
                            print("Done!")
                        }
                    }
                }
            } else {
                if UIApplication.shared.alternateIconName != nil {
                    UIApplication.shared.setAlternateIconName(nil)
                    print("done")
                }
            }
        }
        
        print(UIDevice.current.modelName)
        let device = (UIDevice.current.modelName.replacingOccurrences(of: "iPhone", with: "").replacingOccurrences(of: "iPad", with: "").replacingOccurrences(of: "iPod", with: "").replacingOccurrences(of: ",", with: ".") as NSString).integerValue
        print(device)
        
        // Chargement des éléments de l'UI
        sections = []
        
        // Section status
        let net = Section(name: sta, elements: [], footer: lowbatfoo)
        
        if !dataManager.setupDone{
            if countryCode == "208" {
                net.elements += [UIElementLabel(id: "activ", text: "activation".localized())]
            } else {
            net.elements += [UIElementButton(id: "", text: "activate".localized()) { (button) in
                self.setup(dataManager)
                }]
            }
        }
        
        var version = 0
        if(datas.value(forKey: "version") != nil){
            version = datas.value(forKey: "version") as? Int ?? 0
        }
        
        print("Version: \(version)")
        print("AppVersion: \(appVersion)")
        
        if appVersion != version {
             net.elements += [UIElementLabel(id: "activ", text: "updating".localized())]
        }
        
        // SIM 1
        net.elements += [UIElementLabel(id: "networkstatus", text: disp)]
        // SIM 2 (complète avec ta condition sur ce if et change le texte avec la valeur de la deuxième sim)
        if device >= 11 && UIDevice.current.modelName.contains("iPhone") && (countryCode2 != "null" && !countryCode2.isEmpty){
            net.elements += [UIElementLabel(id: "networkstatus2", text: disp2)]
        }
        
        // Reste de la section status
        net.elements += [UIElementLabel(id: "connected", text: "") { () -> String in
                if dataManager.carrierNetwork == "null" || dataManager.carrierNetwork.isEmpty  {
                    return dataManager.modeRadin ? "Pas de connexion radine" : "not_connected".localized()
                } else {
                    return dataManager.modeRadin ? "\(dataManager.carrierNetwork)" : "connected".localized().format([dataManager.carrierNetwork])
                }
            }]
        if dataManager.targetMCC == "208" && dataManager.targetMNC != "15" && dataManager.connectedMCC != "208" && (dataManager.zoneCheck() == "OUTZONE" || dataManager.zoneCheck() == "CALLS") && CarrierIdentification.getIsoCountryCode(String(dataManager.connectedMCC)) != "--" && dataManager.setupDone {
            net.elements += [UIElementButton(id: "", text: "country_included_button".localized().format([CarrierIdentification.getIsoCountryCode(String(dataManager.connectedMCC))])) { (button) in
                
                let country = CarrierIdentification.getIsoCountryCode(String(dataManager.connectedMCC))
                
                let alert = UIAlertController(title: "new_country".localized(), message: "new_country_description".localized().format([country]), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "included_voice".localized(), style: .default) { (UIAlertAction) in
                    dataManager.addCountryIncluded(country: country, list: 0)
                })
                alert.addAction(UIAlertAction(title: "included_internet".localized(), style: .default) { (UIAlertAction) in
                    dataManager.addCountryIncluded(country: country, list: 1)
                })
                alert.addAction(UIAlertAction(title: "included_all".localized(), style: .default) { (UIAlertAction) in
                    dataManager.addCountryIncluded(country: country, list: 2)
                })
                alert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil))
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            }]
        }
        if device >= 11 && UIDevice.current.modelName.contains("iPhone") && (countryCode2 != "null" && !countryCode2.isEmpty) {
            net.elements += [UIElementLabel(id: "connected2", text: "") { () -> String in
                if dataManager.carrierNetwork2 == "null" || dataManager.carrierNetwork2.isEmpty {
                    return dataManager.modeRadin ? "Pas de connexion eSIM radine" : "esim_not_connected".localized()
                } else {
                    return dataManager.modeRadin ? "\(dataManager.carrierNetwork2) radine" : "esim_connected".localized().format([dataManager.carrierNetwork2])
                }
            }]
        }
        
        let wifistat = DataManager.showWifiConnected()
        
        if wifistat != "null" {
            net.elements += [UIElementLabel(id: "wifi", text: dataManager.modeRadin ? "Wi-Fi radin : \(wifistat)" : "wifi_status".localized().format([wifistat]))]
        }
        if dataManager.modeExpert {
            net.elements += [UIElementLabel(id: "generation", text: generation)]
        }
        
        if !dataManager.disableFMobileCore || dataManager.modeExpert || (dataManager.connectedMCC == "208" && dataManager.connectedMNC == "15"){
            net.elements += [UIElementButton(id: "", text: "set_no_network".localized()) { (button) in
                if CLLocationManager.authorizationStatus() == .authorizedAlways {
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
                        
                        let alert = UIAlertController(title: "no_network_zone_saved".localized(), message: "no_network_zone_saved_description".localized(), preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: nil))
                        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                    } catch {
                        print("Failed saving")
                    }
                }
                }]
        }
        
        net.elements += [UIElementSwitch(id: "lowbat", text: lb, d: false)]
        
        // Section préférences
        let pref = Section(name: prefsnet, elements: [
            UIElementSwitch(id: "allow013G", text: iti3G, d: true),
            UIElementSwitch(id: "allow012G", text: iti2G, d: true)
            ], footer: wififoo)
        
        if dataManager.modeExpert {
            pref.elements += [UIElementSwitch(id: "verifyonwifi", text: wifiaut, d: false)]
        }
        
        // Section background
        let back = Section(name: bkg, elements: [
            UIElementSwitch(id: "stopverification", text: stvr, d: false)], footer: sat)
        
        if dataManager.modeExpert || (dataManager.targetMCC == "208" && dataManager.targetMNC == "15" && dataManager.setupDone) {
            back.elements += [UIElementSwitch(id: "femto", text: fmt, d: true),
                              UIElementSwitch(id: "femtoLOWDATA", text: eco, d: false)]
        }
        
        let femto = Section(name: "", elements: [])
        
        if !dataManager.disableFMobileCore || dataManager.modeExpert || (dataManager.connectedMCC == "208" && dataManager.connectedMNC == "15"){
            femto.elements += [UIElementButton(id: "", text: zns) { (button) in
                self.resetAllRecords(in: "Locations")
            }]
        }
        
        if dataManager.targetMCC == "208" && dataManager.targetMNC != "15" && dataManager.setupDone{
            femto.elements += [UIElementButton(id: "", text: "reset_countries_included".localized()) { (button) in
                self.resetCountriesIncluded(dataManager)
                }]
        }
        
        // Section country detection
        let cnt = Section(name: nland, elements: [
            UIElementSwitch(id: "allowCountryDetection", text: land, d: true)
        ], footer: fland)
        
        // Section conso
        let conso = Section(name: cso, elements: [])
        if dataManager.targetMCC == "208" && dataManager.targetMNC == "15" && dataManager.setupDone {
            conso.elements += [UIElementButton(id: "", text: suivi) { (button) in
                    guard let link = URL(string: "shortcuts://run-shortcut?name=CFM") else { return }
                    UIApplication.shared.open(link)
                },
                UIElementButton(id: "", text: c555) { (button) in
                    guard let number = URL(string: "tel://555") else { return }
                    UIApplication.shared.open(number)
                },
                UIElementButton(id: "", text: c3244) { (button) in
                    guard let number = URL(string: "tel://3244") else { return }
                    UIApplication.shared.open(number)
                }]
        } else if dataManager.targetMCC == "208" && dataManager.targetMNC == "01" && dataManager.setupDone {
            conso.elements += [UIElementButton(id: "", text: "open_official_app".localized().format(["\"Orange et moi\""])) { (button) in
                guard let link = URL(string: "orangeetmoi://") else { return }
                UIApplication.shared.open(link)
                },
                UIElementButton(id: "", text: "open_official_app".localized().format(["\"MySosh France\""])) { (button) in
                guard let link = URL(string: "mysosh://") else { return }
                UIApplication.shared.open(link)
                },
                UIElementButton(id: "", text: "copy_callcode".localized()) { (button) in
                UIPasteboard.general.string = "#123#"
                
                let alert = UIAlertController(title: "code_copied_confirmation".localized(), message: nil, preferredStyle: UIAlertController.Style.alert)
                
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                
                self.delay(1){
                    UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
                }
                
                },
                               UIElementButton(id: "", text: "call_service".localized().format(["3900"])) { (button) in
                                guard let number = URL(string: "tel://3900") else { return }
                                UIApplication.shared.open(number)
                }]
        } else if dataManager.targetMCC == "208" && dataManager.targetMNC == "10" && dataManager.setupDone {
            conso.elements += [UIElementButton(id: "", text: "open_official_app".localized().format(["\"SFR & Moi\""])) { (button) in
                guard let link = URL(string: "sfrmoncompte://") else { return }
                UIApplication.shared.open(link)
                },
                UIElementButton(id: "", text: "open_official_app".localized().format(["\"RED & Moi\""])) { (button) in
                guard let link = URL(string: "redetmoi://") else { return }
                UIApplication.shared.open(link)
                },
                               UIElementButton(id: "", text: "call_conso".localized().format(["950"])) { (button) in
                                guard let number = URL(string: "tel://950") else { return }
                                UIApplication.shared.open(number)
                },
                               UIElementButton(id: "", text: "call_service".localized().format(["1023"])) { (button) in
                                guard let number = URL(string: "tel://1023") else { return }
                                UIApplication.shared.open(number)
                }]
        } else if dataManager.targetMCC == "208" && dataManager.targetMNC == "20" && dataManager.setupDone {
            conso.elements += [UIElementButton(id: "", text: "open_official_app".localized().format(["\"Espace client\""])) { (button) in
                guard let link = URL(string: "fr.bouyguestelecom.espaceclient://") else { return }
                UIApplication.shared.open(link)
                },
                               UIElementButton(id: "", text: "call_conso".localized().format(["680"])) { (button) in
                                guard let number = URL(string: "tel://680") else { return }
                                UIApplication.shared.open(number)
                },
                               UIElementButton(id: "", text: "call_service".localized().format(["1064"])) { (button) in
                                guard let number = URL(string: "tel://1064") else { return }
                                UIApplication.shared.open(number)
                }]
        }
        else if dataManager.targetMCC == "208" && dataManager.targetMNC == "26" && dataManager.setupDone {
            conso.elements += [UIElementButton(id: "", text: "open_official_app".localized().format(["\"NRJ Mobile\""])) { (button) in
                guard let link = URL(string: "spid://") else { return }
                UIApplication.shared.open(link)
                },
                               UIElementButton(id: "", text: "call_conso".localized().format(["700"])) { (button) in
                                guard let number = URL(string: "tel://700") else { return }
                                UIApplication.shared.open(number)
                },
                               UIElementButton(id: "", text: "call_service".localized().format(["200"])) { (button) in
                                guard let number = URL(string: "tel://200") else { return }
                                UIApplication.shared.open(number)
                }]
        }
        
        // Section aide
        let aide = Section(name: help, elements: [
            UIElementButton(id: "", text: cont) { (button) in
                let alert = UIAlertController(title: "contact_title".localized(), message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Mail", style: .default) { (UIAlertAction) in
                    guard let mailto = URL(string: "mailto:contact@groupe-minaste.org") else { return }
                    UIApplication.shared.open(mailto)
                })
                alert.addAction(UIAlertAction(title: "Discord", style: .default) { (UIAlertAction) in
                    guard let discord = URL(string: "https://www.craftsearch.net/discord") else { return }
                    UIApplication.shared.open(discord)
                })
                alert.addAction(UIAlertAction(title: "Twitter - Michaël Nass", style: .default) { (UIAlertAction) in
                    guard let twitter = URL(string: "https://www.twitter.com/PlugNTweet") else { return }
                    UIApplication.shared.open(twitter)
                })
                alert.addAction(UIAlertAction(title: "Twitter - FMobile", style: .default) { (UIAlertAction) in
                    guard let twitter = URL(string: "https://www.twitter.com/FMobileApp") else { return }
                    UIApplication.shared.open(twitter)
                })
                alert.addAction(UIAlertAction(title: "Twitter - Groupe MINASTE", style: .default) { (UIAlertAction) in
                    guard let twitter = URL(string: "https://www.twitter.com/Groupe_MINASTE") else { return }
                    UIApplication.shared.open(twitter)
                })
                alert.addAction(UIAlertAction(title: "Extopy", style: .default) { (UIAlertAction) in
                    UIApplication.shared.keyWindow?.rootViewController?.present(UIAlertController(title: "extopy_not_available_title".localized(), message: "extopy_not_available_description".localized(), preferredStyle: .alert), animated: true, completion: nil)
                    self.delay(3){
                        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
                    }
                })
                alert.addAction(UIAlertAction(title: "ok".localized(), style: .cancel, handler: nil))
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            },
            UIElementButton(id: "", text: "video_tutorial".localized()) { (button) in
                guard let mailto = URL(string: "https://youtu.be/pTQKVbSE38U") else { return }
                UIApplication.shared.open(mailto)
            },
            UIElementButton(id: "", text: "install_shortcuts".localized()) { (button) in
                guard let mailto = URL(string: "http://raccourcis.ios.free.fr/fmobile/") else { return }
                UIApplication.shared.open(mailto)
            }
        ])
        
        if dataManager.modeExpert {
            aide.elements += [ UIElementButton(id: "", text: "engine_generation_signification".localized()) { (button) in
                let text = "engine_explaination".localized()
                let alert = UIAlertController(title: "engine_generation_title".localized(), message: text, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "explaination_understood".localized(), style: .default, handler: nil))
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                }]
        }
        
        // Section avancé
        let avance = Section(name: "advanced".localized(), elements: [
            UIElementButton(id: "", text: "reset_network".localized()) { (button) in
                guard let link = URL(string: "shortcuts://run-shortcut?name=RRFM") else { return }
                UIApplication.shared.open(link)
            },
            UIElementButton(id: "", text: "do_speedtest".localized()) { (button) in
                let speedtestVC = SpeedtestViewController()
                self.navigationController?.pushViewController(speedtestVC, animated: true)
            },
            UIElementButton(id: "", text: "perform_diagnostic".localized()) { (button) in
                self.diag(source: button)
            },
            UIElementButton(id: "", text: "reset_first_start".localized()) { (button) in
                dataManager.datas.set(false, forKey: "didFinishFirstStart")
                dataManager.datas.set(false, forKey: "warningApproved")
                dataManager.datas.set(false, forKey: "setupDone")
                dataManager.datas.synchronize()
                self.firstStart()
                self.warning()
            },
            UIElementSwitch(id: "dispInfoNotif", text: "disp_notifications".localized(), d: true),
            UIElementSwitch(id: "modeExpert", text: "expert_mode".localized(), d: false),
            UIElementSwitch(id: "isDarkMode", text: "dark_mode".localized(), d: true)
            ], footer: Locale.current.languageCode == "fr" ? "Le mode Radin est un clin d'oeil à Xavier Radiniel (@XRadiniel sur l'oiseau bleu), un compte parodique autour de la galaxie Niel. Il modifie l'interface de l'application mais n'apporte aucune fonctionalité supplémentaire." : "\n\n")
        
        if Locale.current.languageCode == "fr" {
            avance.elements += [UIElementSwitch(id: "modeRadin", text: "Mode Radin", d: false)]
        }
        
        if dataManager.modeExpert {
            avance.elements += [UIElementButton(id: "", text: "copy_field_test".localized()) { (button) in
                UIPasteboard.general.string = "*3001#12345#*"
                
                let alert = UIAlertController(title: "field_test_copied_confirmation".localized(), message: nil, preferredStyle: UIAlertController.Style.alert)
                
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                
                self.delay(1){
                    UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
                }
                },
                UIElementButton(id: "", text: "select_url".localized()) { (button) in
                self.seturl()
                },]
        }
        
        // Section à propos
        let plus = Section(name: "", elements: [
            UIElementButton(id: "", text: "about".localized()) { (button) in
                let text = "about_description".localized()
                let alert = UIAlertController(title: "about".localized(), message: text, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: nil))
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            },
            UIElementButton(id: "", text: "donate_paypal".localized()) { (button) in
                guard let link = URL(string: "https://www.paypal.me/PlugNPay") else { return }
                UIApplication.shared.open(link)
            }
            ], footer: "donate_description".localized())
        
        sections += [net]
        
        if !dataManager.disableFMobileCore || dataManager.modeExpert {
            sections += [pref]
        }
        
        sections += [back, cnt, femto]
        
        if dataManager.targetMCC == "208" && (dataManager.targetMNC == "01" || dataManager.targetMNC == "10" || dataManager.targetMNC == "15" || dataManager.targetMNC == "20" || dataManager.targetMNC == "26") && dataManager.setupDone {
            self.sections += [conso]
        }
        
        sections += [aide, avance, plus]
    }
    
    func refreshSections() {
        for section in sections {
            for el in section.elements {
                el.update()
            }
        }
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].elements.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].name
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return sections[section].footer
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let element = sections[indexPath.section].elements[indexPath.row]
        
        if let e = element as? UIElementLabel {
            return (tableView.dequeueReusableCell(withIdentifier: "labelCell", for: indexPath) as! LabelTableViewCell).with(text: e.text, darkMode: isDarkMode())
        } else if let e = element as? UIElementSwitch {
            let datas = Foundation.UserDefaults.standard
            var enable = e.d
            
            if(datas.value(forKey: e.id) != nil){
                enable = datas.value(forKey: e.id) as? Bool ?? e.d
            }
            
            return (tableView.dequeueReusableCell(withIdentifier: "switchCell", for: indexPath) as! SwitchTableViewCell).with(id: e.id, controller: self, text: e.text, enabled: enable, darkMode: isDarkMode())
        } else if let e = element as? UIElementButton {
            return (tableView.dequeueReusableCell(withIdentifier: "buttonCell", for: indexPath) as! ButtonTableViewCell).with(title: e.text, alignment: .left, handler: e.handler, darkMode: isDarkMode())
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "labelCell", for: indexPath)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let element = sections[indexPath.section].elements[indexPath.row]
        
        if let e = element as? UIElementButton {
            let cell = tableView.cellForRow(at: indexPath as IndexPath) as? ButtonTableViewCell
            e.handler(cell?.button ?? UIButton())
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

}
