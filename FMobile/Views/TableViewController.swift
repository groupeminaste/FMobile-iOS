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
            
            let alert = UIAlertController(title: "Réinitialisation effectuée", message: "Toutes les zones de Femto et ran-sharing ont étés réinitialisés.", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        } catch {
            print ("There was an error")
        }
    }
    
    func firstStart(){
        let dataManager = DataManager()
        let alert = UIAlertController(title: "Premier démarrage", message: "Bienvenue sur FMobile ! Commencez par apprendre les bases avant d'utiliser l'application. Vous retrouverez le tutoriel vidéo et les raccourcis à tout moment dans la section aide de FMobile. Quand vous n'en avez plus besoin, fermez la fenêtre avec \"Ne plus afficher\".", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tutoriel vidéo sur FMobile", style: .default) { (UIAlertAction) in
            guard let mailto = URL(string: "https://youtu.be/pTQKVbSE38U") else { return }
            UIApplication.shared.open(mailto)
        })
        alert.addAction(UIAlertAction(title: "Installer les raccourcis", style: .default) { (UIAlertAction) in
            guard let discord = URL(string: "http://raccourcis.ios.free.fr/fmobile") else { return }
            UIApplication.shared.open(discord)
        })
        alert.addAction(UIAlertAction(title: "Fermer", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Ne plus afficher", style: .cancel) { (UIAlertAction) in
            dataManager.datas.set(true, forKey: "didFinishFirstStart")
            dataManager.datas.synchronize()
        })
        present(alert, animated: true, completion: nil)
    }
    
    func seturl(){
        
        let datas = Foundation.UserDefaults.standard
        
        let alertController = UIAlertController(title: "Custom URL", message: "Here you can set your custom URL for the speed test (used in G1, G-A1 and G2). There are two URL to provide: the first one is for the engine. It should be an extremely small file (about 512Kb for optimal use). The second is used for the speed test in the UI. It should be a really large file (like 1Gb). You can take any file you want. The server hosting these files should be near your current location (lower latency). The default files are hosted on servers located in Metropolitan France.", preferredStyle: .alert)
        
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "Save", style: .default) { (_) in
            
            guard URL(string: alertController.textFields?[0].text?.lowercased() ?? "s") != nil else {
                let alertController2 = UIAlertController(title: "Error", message: "The link you specified could not be translated into an URL. Double check that you entered the full URL starting with http:// or https://.", preferredStyle: .alert)
                let confirmAction2 = UIAlertAction(title: "Retry", style: .default) { (_) in
                    self.seturl()
                    return
                }
                let cancelAction2 = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
                    return
                }
                
                let defaultAction2 = UIAlertAction(title: "Set default URL", style: .default) { (_) in
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
                let alertController2 = UIAlertController(title: "Error", message: "The link you specified could not be translated into an URL. Double check that you entered the full URL starting with http:// or https://.", preferredStyle: .alert)
                let confirmAction2 = UIAlertAction(title: "Retry", style: .default) { (_) in
                    self.seturl()
                    return
                }
                let cancelAction2 = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
                    return
                }
                
                let defaultAction2 = UIAlertAction(title: "Set default URL", style: .default) { (_) in
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
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            return
        }
        
        let defaultAction = UIAlertAction(title: "Set default URL", style: .default) { (_) in
            datas.set("http://test-debit.free.fr/512.rnd", forKey: "URL")
            datas.set("http://test-debit.free.fr/1048576.rnd", forKey: "URLST")
            datas.synchronize()
            return
        }
        
        //adding textfields to our dialog box
        alertController.addTextField { (textField) in
            textField.placeholder = "URL for the engine"
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "URL for the speed test"
        }
        
        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(defaultAction)
        alertController.addAction(cancelAction)
        
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
    }
    
    func manualSetup(_ dataManager: DataManager = DataManager()) {
        let alertController = UIAlertController(title: "Application setup", message: "This application is designed to prevent a National Roaming Agreement to be applied on your device. No automatic configuration has been found for your carrier. If your carrier has a 3G+2G National Roaming Agreement that considerably slows your Internet down, you can set this app to help you to stay on your home network in your country. After you provide these informations, you will be able to set your preferences about the NRA. Please note that you cannot use this application with MVNOs. The application will probably not operate that well on a manual setup, so please contact the developer to build the automatic setup for your carrier.", preferredStyle: .alert)
        
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "Save", style: .default) { (_) in
            
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
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            dataManager.datas.set(false, forKey: "setupDone")
        }
        
        //adding textfields to our dialog box
        alertController.addTextField { (textField) in
            textField.placeholder = "Speed of the NRA in Mbps (ex: 0.470)"
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Home 3G protocol (ex: WCDMA)"
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "NR 3G protocol (ex: HSDPA)"
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Roaming name (ex: Ice.net)"
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Home network name (ex: Telenor)"
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Roaming MNC (ex: 01)"
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "NR protocol femto+mutuals? (yes/no)"
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Home without 2G? (yes/no)"
        }
        
        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
    }
    
    func setup(_ dataManager: DataManager = DataManager()) {
        let alert = UIAlertController(title: "Detecting auto config...", message:nil, preferredStyle: UIAlertController.Style.alert)
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
                
                let alertController = UIAlertController(title: "Choose your setup", message: "FMobile has not found any automatic configuration for your carrier. You can choose to run FMobile on a minimal setup without entering any information, or optionally, you can also choose to run FMobile on a normal setup, by providing standard informations about your carrier and it's roaming partner. For most carriers, the minimal setup should run fine, however some carriers that have a more complex roaming structure may require to use the standard setup instead.", preferredStyle: .alert)
                
                let confirmAction = UIAlertAction(title: "Use minimal setup", style: .default) { (_) in
                    dataManager.datas.set(dataManager.mycarrier.mobileCountryCode ?? "---", forKey: "MCC")
                    dataManager.datas.set(dataManager.mycarrier.mobileNetworkCode ?? "--", forKey: "MNC")
                    dataManager.datas.set(dataManager.mycarrier.isoCountryCode?.uppercased() ?? "--", forKey: "LAND")
                    dataManager.datas.synchronize()
                    
                    let alert2 = UIAlertController(title: "Checking eligibility...", message:nil, preferredStyle: UIAlertController.Style.alert)
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
                            let alertController2 = UIAlertController(title: "Compatibility issues", message: "FMobile has detected that the minimal setup may fail on your device. You can set to still use it or start the manual setup instead.", preferredStyle: .alert)
                            let confirmAction2 = UIAlertAction(title: "Force minimal setup", style: .destructive) { (_) in
                                dataManager.datas.set(true, forKey: "minimalSetup")
                                dataManager.datas.set(false, forKey: "disableFMobileCore")
                                dataManager.datas.set(true, forKey: "setupDone")
                                dataManager.datas.synchronize()
                            }
                            let cancelAction2 = UIAlertAction(title: "Run standard setup", style: .default) { (_) in
                                self.manualSetup()
                            }
                            
                            alertController2.addAction(confirmAction2)
                            alertController2.addAction(cancelAction2)
                            
                            self.present(alertController2, animated: true, completion: nil)
                            
                            
                        }
                        
                    }
                }
                
                let cancelAction = UIAlertAction(title: "Use standard setup", style: .default) { (_) in
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
        let alert = UIAlertController(title: "⚠️ RESPONSABILITÉ", message: "IMPORTANT : Cette application est fournie gratuitement sans garantie. Vous en êtes entièrement responsable, autrement dit tous les dommages liés à l'application sont sous votre responsabilité exclusivement (hors-forfait mobile, consommation électrique, surchauffe, etc...). C'est à vous de régulièrement vérifier la consomation de l'application et de la désactiver lorsque vous partez à l'étranger. Ne venez pas m'envoyer vos factures par mail, vous n'obtiendrez aucun remboursement (ça peut paraître évident pour certains mais c'est déjà arrivé...)", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Désinstaller l'application", style: .destructive) { (UIAlertAction) in
            dataManager.datas.set(false, forKey: "warningApproved")
            dataManager.datas.synchronize()
            UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
        })
        alert.addAction(UIAlertAction(title: "J'accepte ces conditions", style: .cancel) { (UIAlertAction) in
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
        
        if version < 75 && dataManager.setupDone && dataManager.targetMCC == "208" && dataManager.targetMNC == "15" {
            let alert = UIAlertController(title: "Mise à jour disponible", message: "Une nouvelle mise à jour du raccrouci CFM est disponible (version 1.1). Cette mise à jour n'est pas incluse dans l'application et doit s'installer manuellement.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Mettre à jour le raccourci CFM", style: .default) { (UIAlertAction) in
                guard let discord = URL(string: "http://raccourcis.ios.free.fr/fmobile") else { return }
                UIApplication.shared.open(discord)
            })
            alert.addAction(UIAlertAction(title: "Fermer", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
        
        
        datas.set(appVersion, forKey: "version")
        datas.synchronize()
        
        print(dataManager.dispInfoNotif)
        if dataManager.dispInfoNotif {
            print("should send notification")
            NotificationManager.sendNotification(for: .update, with: "Le processus de mise à jour depuis la build \(version) vers la build \(appVersion) a réussi. Toutes les tâches de maintenance ont étés effectuées, vous n'avez rien à faire.")
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIDevice.current.isBatteryMonitoringEnabled = true
        navigationController?.navigationBar.prefersLargeTitles = true
        
        start()
        loadUI()
        refreshSections()
        
        let datas = Foundation.UserDefaults.standard
        datas.set(false, forKey: "didAlertLB")
        datas.set(true, forKey: "statusUL")
        datas.set(Date().addingTimeInterval(-15 * 60), forKey: "NTimer")
        datas.synchronize()
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
        let alert = UIAlertController(title: "Diagnostic en cours...", message:nil, preferredStyle: UIAlertController.Style.alert)
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
            }
            else if dataManager.connectedMCC == "208" && dataManager.connectedMNC == "10" {
                radincarrier = "Patoche"
            }
            else if dataManager.connectedMCC == "208" && dataManager.connectedMNC == "15" {
                radincarrier = "Radin"
            }
            else if dataManager.connectedMCC == "208" && dataManager.connectedMNC == "20" {
                radincarrier = "Béton"
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
        }
        
        // TODO: OPTIMISER CE GROS IF BORDELIQUE POUR ISOLER CE QUI EST COMMUN
        if dataManager.carrierNetwork == "LTE" {
            dataManager.carrierNetwork = dataManager.modeRadin ? "4G radine : \(radincarrier) (\(country))" : dataManager.modeExpert ?
                "\(dataManager.carrier) 4G (LTE) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))" :  "\(dataManager.carrier) 4G"
            lastnetr = "LTE"
            dataManager.datas.set(lastnetr, forKey: "lastnetr")
            dataManager.datas.synchronize()
        } else if dataManager.carrierNetwork == "WCDMA" {
            if dataManager.connectedMCC == dataManager.targetMCC && dataManager.connectedMNC == dataManager.chasedMNC && !DataManager.isWifiConnected() && dataManager.carrierNetwork == dataManager.nrp && dataManager.nrDEC {
                
                    print(abs(timecoder.timeIntervalSinceNow))
                    
                    if abs(timecoder.timeIntervalSinceNow) < 10*60 && lastnetr == "WCDMAO" {
                        DispatchQueue.main.async {
                            dataManager.carrierNetwork = dataManager.modeRadin ? "Itinérance Delta radine : \(radinitiname) (\(country))" : dataManager.modeExpert ?
                                "\(dataManager.itiName) 3G (WCDMA) [\(dataManager.connectedMCC) \(dataManager.itiMNC)] (\(country))" :  "\(dataManager.itiName) 3G (itinérance)"
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
                                        "\(dataManager.itiName) 3G (WCDMA) [\(dataManager.connectedMCC) \(dataManager.itiMNC)] (\(country))" :  "\(dataManager.itiName) 3G (itinérance)"
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
                lastnetr = "WCDMA"
                dataManager.datas.set(lastnetr, forKey: "lastnetr")
                dataManager.datas.synchronize()
            }
            dataManager.carrierNetwork = dataManager.modeRadin ? "3G radine : \(radincarrier) (\(country))" : dataManager.modeExpert ?
                "\(dataManager.carrier) 3G (WCDMA) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))" :  "\(dataManager.carrier) 3G"
        } else if dataManager.carrierNetwork == "HSDPA" {
            if dataManager.connectedMCC == dataManager.targetMCC && dataManager.connectedMNC == dataManager.chasedMNC && !DataManager.isWifiConnected() && dataManager.carrierNetwork == dataManager.nrp && dataManager.nrDEC {
                print(abs(timecoder.timeIntervalSinceNow))
                
                if abs(timecoder.timeIntervalSinceNow) < 10*60 && lastnetr == "HSDPAO" {
                    DispatchQueue.main.async {
                        dataManager.carrierNetwork = dataManager.modeRadin ? "Itinérance Delta radine : \(radinitiname) (\(country))" : dataManager.modeExpert ?
                            "\(dataManager.itiName) 3G (HSDPA) [\(dataManager.connectedMCC) \(dataManager.itiMNC)] (\(country))" :  "\(dataManager.itiName) 3G (itinérance)"
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
                                    "\(dataManager.itiName) 3G (HSDPA) [\(dataManager.connectedMCC) \(dataManager.itiMNC)] (\(country))" :  "\(dataManager.itiName) 3G (itinérance)"
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
                lastnetr = "HSDPA"
                dataManager.datas.set(lastnetr, forKey: "lastnetr")
                dataManager.datas.synchronize()
            }
            dataManager.carrierNetwork = dataManager.modeRadin ? "3G radine : \(radincarrier) (\(country))" : dataManager.modeExpert ?
                "\(dataManager.carrier) 3G (HSDPA) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))" :  "\(dataManager.carrier) 3G"
        } else if dataManager.carrierNetwork == "Edge"{
            dataManager.carrierNetwork = dataManager.connectedMCC == dataManager.targetMCC && dataManager.connectedMNC == dataManager.chasedMNC && dataManager.out2G == "yes" ?
                (dataManager.modeRadin ? "Itinérance tupperware radine : \(radinitiname) (\(country))" : dataManager.modeExpert ? "\(dataManager.itiName) 2G (EDGE) [\(dataManager.connectedMCC) \(dataManager.itiMNC)] (\(country))" : "\(dataManager.itiName) 2G (itinérance)") : (dataManager.modeRadin ? "2G radine : \(radincarrier) (\(country))" : dataManager.modeExpert ? "\(dataManager.carrier) 2G (EDGE) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))" : "\(dataManager.carrier) 2G")
            lastnetr = "Edge"
            dataManager.datas.set(lastnetr, forKey: "lastnetr")
            dataManager.datas.synchronize()
        } else if dataManager.carrierNetwork == "GPRS"{
            dataManager.carrierNetwork = dataManager.connectedMCC == dataManager.targetMCC && dataManager.connectedMNC == dataManager.chasedMNC && dataManager.out2G == "yes" ?
                (dataManager.modeRadin ? "Itinérance VHS radine : \(radinitiname) (\(country))" : dataManager.modeExpert ? "\(dataManager.itiName) G (GPRS) [\(dataManager.connectedMCC) \(dataManager.itiMNC)] (\(country))" : "\(dataManager.itiName) G (itinérance)") : (dataManager.modeRadin ? "G radin : \(radincarrier) (\(country))" : dataManager.modeExpert ? "\(dataManager.carrier) G (GPRS) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))" : "\(dataManager.carrier) G")
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
                let alert = UIAlertController(title: "Insert a SIM card", message:"Please insert and unlock a SIM card to start using FMobile. Once the SIM card is inserted, follow the application setup (automatic configuration available for selected carriers).", preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            }
        }
        
        alertInit = true
        
        var disp: String
        if countryCode == "null" || countryCode.isEmpty {
            disp = dataManager.modeRadin ? "Pas de carte SIM radine détéctée" : "Aucune carte SIM valide détéctée"
        } else {
            if countryCode == "208" && mobileNetworkName == "15" {
                disp = "Carte SIM : \(dataManager.modeRadin ? "Radin" : carrierName)"
                if dataManager.modeExpert {
                    disp += " [\(countryCode) \(mobileNetworkName)] (\(isoCountrycode))"
                }
            }
            else if countryCode == "208" && mobileNetworkName == "01" {
                disp = "Carte SIM : \(dataManager.modeRadin ? "Agrume France" : carrierName)"
                if dataManager.modeExpert {
                    disp += " [\(countryCode) \(mobileNetworkName)] (\(isoCountrycode))"
                }
            } else if countryCode == "208" && mobileNetworkName == "10" {
                disp = "Carte SIM : \(dataManager.modeRadin ? "Patoche has no limits" : carrierName)"
                if dataManager.modeExpert {
                    disp += " [\(countryCode) \(mobileNetworkName)] (\(isoCountrycode))"
                }
            } else if countryCode == "208" && mobileNetworkName == "20" {
                disp = "Carte SIM : \(dataManager.modeRadin ? "Béton Télécom" : carrierName)"
                if dataManager.modeExpert {
                    disp += " [\(countryCode) \(mobileNetworkName)] (\(isoCountrycode))"
                }
            }
            
            else {
                disp = "Carte SIM : \(carrierName)"
                if dataManager.modeExpert {
                    disp += " [\(countryCode) \(mobileNetworkName)] (\(isoCountrycode))"
                }
            }
        }
        
        var disp2: String
        if countryCode2 == "null" || countryCode2.isEmpty {
            disp2 = dataManager.modeRadin ? "Pas de eSIM radine activée" : "Aucune eSIM activée"
        } else {
            if countryCode2 == "208" && mobileNetworkName2 == "15" {
                disp2 = "eSIM : \(dataManager.modeRadin ? "Radin" : carrierName2)"
                if dataManager.modeExpert {
                    disp2 += " [\(countryCode2) \(mobileNetworkName2)] (\(isoCountrycode2))"
                }
            }
            else if countryCode2 == "208" && mobileNetworkName2 == "01" {
                disp2 = "eSIM : \(dataManager.modeRadin ? "Agrume France" : carrierName2)"
                if dataManager.modeExpert {
                    disp2 += " [\(countryCode2) \(mobileNetworkName2)] (\(isoCountrycode2))"
                }
            }
            else if countryCode2 == "208" && mobileNetworkName2 == "10" {
                disp2 = "eSIM : \(dataManager.modeRadin ? "Patoche has no limits" : carrierName2)"
                if dataManager.modeExpert {
                    disp2 += " [\(countryCode2) \(mobileNetworkName2)] (\(isoCountrycode2))"
                }
            }
            else if countryCode2 == "208" && mobileNetworkName2 == "20" {
                disp2 = "eSIM : \(dataManager.modeRadin ? "Béton Télécom" : carrierName2)"
                if dataManager.modeExpert {
                    disp2 += " [\(countryCode2) \(mobileNetworkName2)] (\(isoCountrycode2))"
                }
            }
            else {
                disp2 = "eSIM : \(carrierName2)"
                if dataManager.modeExpert {
                    disp2 += " [\(countryCode2) \(mobileNetworkName2)] (\(isoCountrycode2))"
                }
            }
        }
        
        
        let appVersion = Int(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0") ?? 0
        // Strings de l'UI
        
        var generation = ""
        if dataManager.ipadMCC == "---" && !dataManager.nrDEC && UIDevice.current.userInterfaceIdiom == .pad {
            generation = "Moteur : FMobile b\(appVersion) - Génération A1"
        } else if dataManager.ipadMCC == "---" && UIDevice.current.userInterfaceIdiom == .pad {
            generation = "Moteur : FMobile b\(appVersion) - Génération 1"
        } else if !dataManager.nrDEC || !dataManager.setupDone {
            generation = "Moteur : FMobile b\(appVersion) - Génération A2"
        } else {
            generation = "Moteur : FMobile b\(appVersion) - Génération 2"
        }
        
        let sta = dataManager.modeRadin ? "État du réseau radin" : "Statut"
        let prefsnet = dataManager.modeRadin ? "Préférences radines" : "Préférences réseau"
        let iti3G = dataManager.modeRadin ? "Itinérance Delta autorisée" : "Autoriser l'itinérance nationale 3G"
        let iti2G = dataManager.modeRadin ? "Itinérance tupperware autorisée" : "Autoriser l'itinérance nationale 2G"
        let wifiaut = dataManager.modeRadin ? "Vérifier sur ma Radinbox" : "Vérifier même sur Wi-Fi"
        let wififoo = dataManager.modeRadin ? "En activant cette option, les vérifications de l'itinérance radine auront lieu même lorsque vous êtes connecté à une Radinbox. Afin d'optimiser la batterie (sauf pour la génération A2), il est recommandé de garder cette option radine désactivée." : dataManager.modeExpert ? "En activant cette option, les vérifications de l'itinérance auront lieu même lorsque vous êtes connecté à un réseau WiFi. Afin d'optimiser la batterie (sauf pour la génération A2), il est recommandé de garder cette option désactivée." : ""
        let stvr = dataManager.modeRadin ? "Arrêter la surveillance radine" : "Arrêter les tâches en arrière-plan"
        let fmt = dataManager.modeRadin ? "Mutualisation et Femto radins" : dataManager.modeExpert ? "Détecter les Femto & ran-sharing" : "Détecter les Femto"
        let bkg = dataManager.modeRadin ? "Arrière plan radin" : "Arrière plan"
        let eco = dataManager.modeRadin ? "Anti-saturation du réseau Radin" : "Mode économie de données"
        var sat = dataManager.modeRadin ? "Pour détecter automatiquement un RadinFemto, nous demandons à iOS de télécharger un fichier radin afin d'effectuer un test de rapidité du réseau Radin. Le mode anti-saturation permet de sauver le réseau de Xavier Radiniel." : "Pour détecter automatiquement un boîtier Femto, l'app télécharge un petit fichier afin d'effectuer un test de rapidité du réseau. En mode économie de données, l'app attend votre permission pour le télécharger."
        let zns = dataManager.modeRadin ? "Réinitialiser les zones radines" : "Réinitialiser les zones non couvertes"
        var land = dataManager.modeRadin ? "Anti-racket-super-arnaque" : "Protection contre le hors-forfait involontaire"
        var fland = dataManager.modeRadin ? "En activant cette option, l'app vérifie en arrière plan dans quelle zone tarifaire vous vous situez et vérifie si vos données cellulaires sont activées (encore une idée de Thomas). Vous receverez plusieurs notifications radines vous invitant à couper vos données cellulaires au plus vite afin de cesser le financement de Radin." : "En activant cette option, l'app vérifie en arrière plan dans quelle zone tarifaire (pays) vous vous situez. Si vos données cellulaires sont activées alors que vous êtes dans une zone hors-forfait, vous receverez plusieurs notifications vous invitant à couper vos données. Cette option est disponible uniquement pour une séléction d'opérateurs."
        var nland = "Protection hors-forfait"
        let cso = dataManager.modeRadin ? "Services opérateur" : "Services opérateur"
        let suivi = dataManager.modeRadin ? "Suivi complet de consommation Radine" : "Obtenir le suivi détaillé de consommation"
        let c555 = dataManager.modeRadin ? "SMS de conso Radin" : "Appeler le 555 (conso par SMS)"
        let help = dataManager.modeRadin ? "Assistance radine" : "Aide"
        let c3244 = dataManager.modeRadin ? "Appeler le SAV Radin" : "Appeler le 3244 (SAV)"
        let cont = dataManager.modeRadin ? "Contacter le développeur radin" : "Contacter le développeur de l'application"
        let lb = dataManager.modeRadin ? "Mode batterie radine" : "Mode activité réduite"
        let lowbatfoo = dataManager.modeRadin ? "Lorsque le mode batterie radine est activé, les vérifications auront lieu après un déplacement d'environ 500m, au moment du changement de l'antenne radine. Si vous quittez de force l'application radine, ce mode s'activera automatiquement." : "Lorsque le mode activité réduite est activé, les vérifications auront lieu après un déplacement d'environ 500m, au moment du changement de l'antenne réseau. Si vous quittez de force l'application, ce mode s'activera automatiquement."
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            if (dataManager.ipadMCC == "---" && dataManager.ipadMNC == "--"){
                land = dataManager.modeRadin ? "Vérifier les voyages radins" : "Vérifier le pays en arrière plan"
                fland = dataManager.modeRadin ? "En activant cette option, nous allons vérifier en arrière plan que vous vous situez toujours dans votre pays Radin afin d'empêcher les tâches pour sortir de l'itinérance radine lorsque vous êtes à l'étranger car les opérateurs étrangers ne possèdent pas notre réseau révolutionnaire à 768kbps. Votre opérateur Radin n'est pas encore compatible avec la 2ème génération de FMobile sur iPad, mais si un opérateur éligible est disponible, FMobile activera ici les fonctionalités de la 2ème génération automatiquement." : "En activant cette option, FMobile va vérifier en arrière-plan que vous vous situez toujours dans votre pays afin d'empêcher les vérifications d'itinérance lorsque vous êtes à l'étranger. Votre opérateur actuel n'est pas encore compatible avec la 2ème génération de FMobile sur iPad, mais si un opérateur éligible est disponible, FMobile activera ici les fonctionalités de la 2ème génération automatiquement."
                nland = "Localisation en arrière-plan"
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
                net.elements += [UIElementLabel(id: "activ", text: "🕗 Activation du moteur de FMobile en cours...")]
            } else {
            net.elements += [UIElementButton(id: "", text: "⚠️ Activer le moteur de FMobile") { (button) in
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
             net.elements += [UIElementLabel(id: "activ", text: "🕗 Mise à jour du moteur de FMobile en cours...")]
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
                    return dataManager.modeRadin ? "Pas de connexion radine" : "Vous n'êtes pas connecté"
                } else {
                    return dataManager.modeRadin ? "\(dataManager.carrierNetwork)" : "Connecté : \(dataManager.carrierNetwork)"
                }
            }]
        if dataManager.targetMCC == "208" && dataManager.targetMNC != "15" && dataManager.connectedMCC != "208" && (dataManager.zoneCheck() == "OUTZONE" || dataManager.zoneCheck() == "CALLS") && CarrierIdentification.getIsoCountryCode(String(dataManager.connectedMCC)) != "--" && dataManager.setupDone {
            net.elements += [UIElementButton(id: "", text: "Ce pays (\(CarrierIdentification.getIsoCountryCode(String(dataManager.connectedMCC)))) est inclus dans mon forfait") { (button) in
                
                let country = CarrierIdentification.getIsoCountryCode(String(dataManager.connectedMCC))
                
                let alert = UIAlertController(title: "Nouveau pays inclus", message: "Nous allons ajouter le pays US comme inclus dans votre forfait.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Inclus voix/SMS uniquement", style: .default) { (UIAlertAction) in
                    dataManager.addCountryIncluded(country: country, list: 0)
                })
                alert.addAction(UIAlertAction(title: "Inclus Internet uniquement", style: .default) { (UIAlertAction) in
                    dataManager.addCountryIncluded(country: country, list: 1)
                })
                alert.addAction(UIAlertAction(title: "Tout est inclus", style: .default) { (UIAlertAction) in
                    dataManager.addCountryIncluded(country: country, list: 2)
                })
                alert.addAction(UIAlertAction(title: "Annuler", style: .cancel, handler: nil))
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            }]
        }
        if device >= 11 && UIDevice.current.modelName.contains("iPhone") && (countryCode2 != "null" && !countryCode2.isEmpty) {
            net.elements += [UIElementLabel(id: "connected2", text: "") { () -> String in
                if dataManager.carrierNetwork2 == "null" || dataManager.carrierNetwork2.isEmpty {
                    return dataManager.modeRadin ? "Pas de connexion eSIM radine" : "Vous n'êtes pas connecté sur l'eSIM"
                } else {
                    return dataManager.modeRadin ? "\(dataManager.carrierNetwork2) radine" : "Connecté au réseau eSIM \(dataManager.carrierNetwork2)"
                }
            }]}
        
        let wifistat = DataManager.showWifiConnected()
        
        if wifistat != "null" {
            net.elements += [UIElementLabel(id: "wifi", text: dataManager.modeRadin ? "Wi-Fi radin : \(wifistat)" : "Wi-Fi : \(wifistat)")]
        }
        if dataManager.modeExpert {
            net.elements += [UIElementLabel(id: "generation", text: generation)]
        }
        
        if !dataManager.disableFMobileCore || dataManager.modeExpert || (dataManager.connectedMCC == "208" && dataManager.connectedMNC == "15"){
            net.elements += [UIElementButton(id: "", text: "Définir cette zone sans couverture") { (button) in
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
                        
                        let alert = UIAlertController(title: "Zone non couverte enregistrée", message: "Vous ne recevrez plus d'alertes sur l'itinérance dans cette zone.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
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
            femto.elements += [UIElementButton(id: "", text: "Réinitialiser les pays inclus dans le forfait") { (button) in
                dataManager.resetCountryIncluded()
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
            conso.elements += [UIElementButton(id: "", text: "Ouvrir l'app officielle \"Orange et moi\"") { (button) in
                guard let link = URL(string: "orangeetmoi://") else { return }
                UIApplication.shared.open(link)
                },
                UIElementButton(id: "", text: "Ouvrir l'app officielle \"MySosh France\"") { (button) in
                guard let link = URL(string: "mysosh://") else { return }
                UIApplication.shared.open(link)
                },
                UIElementButton(id: "", text: "Copier le code suivi conso dans le presse-papiers") { (button) in
                UIPasteboard.general.string = "#123#"
                
                let alert = UIAlertController(title: "Code copié !", message: nil, preferredStyle: UIAlertController.Style.alert)
                
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                
                self.delay(1){
                    UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
                }
                
                },
                               UIElementButton(id: "", text: "Appeler le 3900 (SAV)") { (button) in
                                guard let number = URL(string: "tel://3900") else { return }
                                UIApplication.shared.open(number)
                }]
        } else if dataManager.targetMCC == "208" && dataManager.targetMNC == "10" && dataManager.setupDone {
            conso.elements += [UIElementButton(id: "", text: "Ouvrir l'app officielle \"SFR & Moi\"") { (button) in
                guard let link = URL(string: "sfrmoncompte://") else { return }
                UIApplication.shared.open(link)
                },
                UIElementButton(id: "", text: "Ouvrir l'app officielle \"RED & Moi\"") { (button) in
                guard let link = URL(string: "redetmoi://") else { return }
                UIApplication.shared.open(link)
                },
                               UIElementButton(id: "", text: "Appeler le 950 (suivi conso)") { (button) in
                                guard let number = URL(string: "tel://950") else { return }
                                UIApplication.shared.open(number)
                },
                               UIElementButton(id: "", text: "Appeler le 1023 (SAV)") { (button) in
                                guard let number = URL(string: "tel://1023") else { return }
                                UIApplication.shared.open(number)
                }]
        } else if dataManager.targetMCC == "208" && dataManager.targetMNC == "20" && dataManager.setupDone {
            conso.elements += [UIElementButton(id: "", text: "Ouvrir l'app officielle \"Espace client\"") { (button) in
                guard let link = URL(string: "fr.bouyguestelecom.espaceclient://") else { return }
                UIApplication.shared.open(link)
                },
                               UIElementButton(id: "", text: "Appeler le 680 (suivi conso)") { (button) in
                                guard let number = URL(string: "tel://680") else { return }
                                UIApplication.shared.open(number)
                },
                               UIElementButton(id: "", text: "Appeler le 1064 (SAV)") { (button) in
                                guard let number = URL(string: "tel://1064") else { return }
                                UIApplication.shared.open(number)
                }]
        }
        
        // Section aide
        let aide = Section(name: help, elements: [
            UIElementButton(id: "", text: cont) { (button) in
                let alert = UIAlertController(title: "Contact", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Mail", style: .default) { (UIAlertAction) in
                    guard let mailto = URL(string: "mailto:contact@groupe-minaste.org") else { return }
                    UIApplication.shared.open(mailto)
                })
                alert.addAction(UIAlertAction(title: "Discord", style: .default) { (UIAlertAction) in
                    guard let discord = URL(string: "https://www.craftsearch.net/discord") else { return }
                    UIApplication.shared.open(discord)
                })
                alert.addAction(UIAlertAction(title: "Twitter de Michaël Nass", style: .default) { (UIAlertAction) in
                    guard let twitter = URL(string: "https://www.twitter.com/PlugNTweet") else { return }
                    UIApplication.shared.open(twitter)
                })
                alert.addAction(UIAlertAction(title: "Twitter de FMobile", style: .default) { (UIAlertAction) in
                    guard let twitter = URL(string: "https://www.twitter.com/FMobileApp") else { return }
                    UIApplication.shared.open(twitter)
                })
                alert.addAction(UIAlertAction(title: "Twitter du Groupe MINASTE", style: .default) { (UIAlertAction) in
                    guard let twitter = URL(string: "https://www.twitter.com/Groupe_MINASTE") else { return }
                    UIApplication.shared.open(twitter)
                })
                alert.addAction(UIAlertAction(title: "Extopy", style: .default) { (UIAlertAction) in
                    UIApplication.shared.keyWindow?.rootViewController?.present(UIAlertController(title: "Extopy n'est pas encore disponible", message: "Pour en savoir plus, rendez-vous sur extopy.com", preferredStyle: .alert), animated: true, completion: nil)
                    self.delay(3){
                        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
                    }
                })
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            },
            UIElementButton(id: "", text: "Tutoriel vidéo sur FMobile") { (button) in
                guard let mailto = URL(string: "https://youtu.be/pTQKVbSE38U") else { return }
                UIApplication.shared.open(mailto)
            },
            UIElementButton(id: "", text: "Installer les raccourcis") { (button) in
                guard let mailto = URL(string: "http://raccourcis.ios.free.fr/fmobile/") else { return }
                UIApplication.shared.open(mailto)
            }
        ])
        
        if dataManager.modeExpert {
            aide.elements += [ UIElementButton(id: "", text: "Que signifient les générations du moteur ?") { (button) in
                let text = "\nFMobile G1\nLe moteur historique de FMobile, depuis la première version. Il se base sur les vérifications via la localisation et le test de débit uniquement, et est réservé aux iPad.\n\nFMobile G-A1\nIl s'agit d'une version améliorée de la 1ère génération, qui peut se passer du test de débit sous certaines conditions, également réservé aux iPad.\n\nFMobile G2\nIl s'agit d'un tout nouveau moteur se basant sur l'état du réseau téléphonique. Elle consomme nettement moins d'énergie mais tous les opérateurs ne sont pas éligibles.\n\nFMobile G-A2\nIl s'agit de la version la plus avancée à ce jour. Elle peut se passer du test de débit, de la localisation et fonctionne de manière totalement native. Elle nécéssite un opérateur et un réseau éligible.\n\nLe basculement d'une génération à l'autre a lieu automatiquement en fonction de l'éligibilité du réseau auquel vous êtes connecté."
                let alert = UIAlertController(title: "Générations du moteur", message: text, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Compris !", style: .default, handler: nil))
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                }]
        }
        
        // Section avancé
        let avance = Section(name: "Avancé", elements: [
            UIElementButton(id: "", text: "Réinitialiser le réseau cellulaire (blocage)") { (button) in
                guard let link = URL(string: "shortcuts://run-shortcut?name=RRFM") else { return }
                UIApplication.shared.open(link)
            },
            UIElementButton(id: "", text: "Effectuer un test de débit") { (button) in
                self.performSegue(withIdentifier: "speedtest", sender: nil)
            },
            UIElementButton(id: "", text: "Démarrer un diagnostic") { (button) in
                self.diag(source: button)
            },
            UIElementButton(id: "", text: "Réinitialiser le statut du premier démarrage") { (button) in
                dataManager.datas.set(false, forKey: "didFinishFirstStart")
                dataManager.datas.set(false, forKey: "warningApproved")
                dataManager.datas.set(false, forKey: "setupDone")
                dataManager.datas.synchronize()
                self.firstStart()
                self.warning()
            },
            UIElementSwitch(id: "dispInfoNotif", text: "Afficher les notifications informatives", d: true),
            UIElementSwitch(id: "modeRadin", text: "Mode Radin", d: false),
            UIElementSwitch(id: "modeExpert", text: "Mode expert", d: false)
        ], footer: "Le mode Radin est un clin d'oeil à Xavier Radiniel (@XRadiniel sur l'oiseau bleu), un compte parodique autour de la galaxie Niel. Il modifie l'interface de l'application mais n'apporte aucune fonctionalité supplémentaire.")
        
        if dataManager.modeExpert {
            avance.elements += [UIElementButton(id: "", text: "Copier le code Field Test dans le presse papier") { (button) in
                UIPasteboard.general.string = "*3001#12345#*"
                
                let alert = UIAlertController(title: "Code copié !", message: nil, preferredStyle: UIAlertController.Style.alert)
                
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                
                self.delay(1){
                    UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
                }
                },
                UIElementButton(id: "", text: "Select a custom URL for the speedtest") { (button) in
                self.seturl()
                },]
        }
        
        // Section à propos
        let plus = Section(name: "", elements: [
            UIElementButton(id: "", text: "À propos") { (button) in
                let text = "Application et Raccourcis créés par Michaël Nass\nUI/UX, test de débit et optimisation par Nathan Fallet\nLogo par Bruno (@brunopaiva_152)\n\nCette application a été développée par des développeurs indépendants et est fournie gratuitement sans aucune garantie.\n\nLe Groupe MINASTE (y compris son application FMobile) n'est, en aucun cas, affilié à quelconque opérateur.\n\n© 2019 Groupe MINASTE"
                let alert = UIAlertController(title: "À propos", message: text, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            },
            UIElementButton(id: "", text: "Faire un don PayPal") { (button) in
                guard let link = URL(string: "https://www.paypal.me/PlugNPay") else { return }
                UIApplication.shared.open(link)
            }
            ], footer: "Quoi qu'il arrive, FMobile restera gratuite et sans publicités. Le don est une manière de me remercier pour l'app, même si je suis déjà super content si vous ne faites que me donner vos retours. Vous contriburez au financeremennt de mon projet Extopy. Merci de bien tester l'application et soyez sûr et certain de vouloir me de laisser un tip avant de le faire.")
        
        sections += [net]
        
        if !dataManager.disableFMobileCore || dataManager.modeExpert {
            sections += [pref]
        }
        
        sections += [back, cnt, femto]
        
        if dataManager.targetMCC == "208" && (dataManager.targetMNC == "01" || dataManager.targetMNC == "10" || dataManager.targetMNC == "15" || dataManager.targetMNC == "20") && dataManager.setupDone {
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "labelCell", for: indexPath) as? LabelTableViewCell
            
            cell?.label?.text = e.text
            
            return cell ?? LabelTableViewCell()
        } else if let e = element as? UIElementSwitch {
            let cell = tableView.dequeueReusableCell(withIdentifier: "switchCell", for: indexPath) as? SwitchTableViewCell
            
            cell?.id = e.id
            cell?.label?.text = e.text
            cell?.controller = self
            
            let datas = Foundation.UserDefaults.standard
            var enable = e.d
            if(datas.value(forKey: e.id) != nil){
                enable = datas.value(forKey: e.id) as? Bool ?? e.d
            }
            cell?.switchElement?.setOn(enable, animated: false)
            
            return cell ?? SwitchTableViewCell()
        } else if let e = element as? UIElementButton {
            let cell = tableView.dequeueReusableCell(withIdentifier: "buttonCell", for: indexPath) as? ButtonTableViewCell
            
            cell?.button?.setTitle(e.text, for: .normal)
            cell?.handler = e.handler
            
            return cell ?? ButtonTableViewCell()
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

}
