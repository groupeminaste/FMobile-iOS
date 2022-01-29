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
import UserNotifications
import Foundation
import CallKit
import FileProvider
import Intents
import DonateViewController

class GeneralTableViewController: UITableViewController, CLLocationManagerDelegate, DonateViewControllerDelegate {
    
    // Variable de class
    var isAUTH = false
    var sections = [Section]()
    var timer: Timer?
    var timernet: Timer?
    var timersim: Timer?
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
        RoamingManager.engineRunning(locations: locations)
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
    
    func addCountry(country: String, dataManager: DataManager = DataManager()) {
        let alert = UIAlertController(title: "new_country".localized(), message: "new_country_description".localized().format([country]), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "included_voice".localized(), style: .default) { (_) in
            dataManager.addCountryIncluded(country: country, list: 0)
        })
        alert.addAction(UIAlertAction(title: "included_internet".localized(), style: .default) { (_) in
            dataManager.addCountryIncluded(country: country, list: 1)
        })
        alert.addAction(UIAlertAction(title: "included_all".localized(), style: .default) { (_) in
            dataManager.addCountryIncluded(country: country, list: 2)
        })
        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil))
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func resetAllRecords(in entity : String) {
        let context: NSManagedObjectContext
        if #available(iOS 10.0, *) {
            context = RoamingManager.persistentContainer.viewContext
        } else {
            // Fallback on earlier versions
            context = RoamingManager.managedObjectContext
        }
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        context.performAndWait({
            do {
                try context.execute(deleteRequest)
                try context.save()
                
                let alert = UIAlertController(title: "reset_zones_done".localized(), message: "reset_zones_done_description".localized(), preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "ok".localized(), style: UIAlertAction.Style.default, handler: nil))
                
                UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
            } catch {
                print ("There was an error")
            }
        })
    }
    
    func resetCountriesIncluded(_ dataManager: DataManager = DataManager()) {
            dataManager.resetCountryIncluded()
            let alert = UIAlertController(title: "reset_zones_done".localized(), message: "reset_countries_done_description".localized(), preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "ok".localized(), style: UIAlertAction.Style.default, handler: nil))
            
            UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func seturl(){
        let datas = UserDefaults(suiteName: "group.fr.plugn.fmobile") ?? Foundation.UserDefaults.standard
        
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
            dataManager.datas.set([String](), forKey: "countriesData")
            dataManager.datas.set([String](), forKey: "countriesVoice")
            dataManager.datas.set([String](), forKey: "countriesVData")
            dataManager.datas.set(true, forKey: "setupDone")
            dataManager.datas.set(false, forKey: "minimalSetup")
            dataManager.datas.set(false, forKey: "disableFMobileCore")
            dataManager.datas.set(false, forKey: "isSettingUp")
            dataManager.datas.synchronize()
        }
        
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "cancel".localized(), style: .cancel) { (_) in
            dataManager.datas.set(false, forKey: "setupDone")
            dataManager.datas.set(false, forKey: "isSettingUp")
            dataManager.datas.synchronize()
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
    
    func updateSetup(_ dataManager: DataManager = DataManager(), _ wasCalled: Bool = false) {
        // On check que le setup n'est pas déjà en cours
        if dataManager.isSettingUp {
            return
        }
        dataManager.datas.set(true, forKey: "isSettingUp")
        dataManager.datas.synchronize()
        
        let siminventory = DataManager.getSimInventory()
        
        var mcc = ""
        var mnc = ""
        var land = ""
        
        if siminventory.count > 0 {
            mcc = siminventory[0].1.mobileCountryCode ?? "---"
            mnc = siminventory[0].1.mobileNetworkCode ?? "--"
            land = siminventory[0].1.isoCountryCode ?? "--"
        }
        
        // On fetch la configuration depuis le serveur
        CarrierConfiguration.fetch(forMCC: mcc, andMNC: mnc) { configuration in
            // On vérifie si des valeurs sont trouvés
            if let configuration = configuration {
                // On enregistre les valeurs issues du serveur
                dataManager.datas.set(configuration.stms, forKey: "STMS")
                dataManager.datas.set(configuration.hp, forKey: "HP")
                dataManager.datas.set(configuration.nrp, forKey: "NRP")
                dataManager.datas.set(configuration.mcc, forKey: "MCC")
                dataManager.datas.set(configuration.mnc, forKey: "MNC")
                dataManager.datas.set(configuration.land, forKey: "LAND")
                dataManager.datas.set(configuration.itiname, forKey: "ITINAME")
                dataManager.datas.set(configuration.homename, forKey: "HOMENAME")
                dataManager.datas.set(configuration.itimnc, forKey: "ITIMNC")
                dataManager.datas.set(configuration.nrfemto, forKey: "NRFEMTO")
                dataManager.datas.set(configuration.out2G, forKey: "OUT2G")
                dataManager.datas.set(configuration.setupDone, forKey: "setupDone")
                dataManager.datas.set(configuration.minimalSetup, forKey: "minimalSetup")
                dataManager.datas.set(configuration.disableFMobileCore, forKey: "disableFMobileCore")
                dataManager.datas.set(configuration.countriesData, forKey: "countriesData")
                dataManager.datas.set(configuration.countriesVoice, forKey: "countriesVoice")
                dataManager.datas.set(configuration.countriesVData, forKey: "countriesVData")
                dataManager.datas.set(configuration.carrierServices, forKey: "carrierServices")
                dataManager.datas.set(configuration.roamLTE, forKey: "roamLTE")
                dataManager.datas.set(configuration.roam5G, forKey: "roam5G")
                dataManager.datas.set(false, forKey: "isSettingUp")
                dataManager.datas.synchronize()
                // Fin de la configuration depuis le serveur
            } else if !dataManager.setupDone && wasCalled {
                // Aucune valeur trouvée (non existante ou non connecté à internet)
                let alertController = UIAlertController(title: "choose_setup".localized(), message: "choose_setup_description".localized(), preferredStyle: .alert)
                    
                let confirmAction = UIAlertAction(title: "use_minimal_setup".localized(), style: .default) { (_) in
                    dataManager.datas.set(mcc, forKey: "MCC")
                    dataManager.datas.set(mnc, forKey: "MNC")
                    dataManager.datas.set(land, forKey: "LAND")
                    dataManager.datas.set(dataManager.carriersim, forKey: "HOMENAME")
                    dataManager.datas.set(dataManager.carriersim, forKey: "ITINAME")
                    dataManager.datas.set(99, forKey: "ITIMNC")
                    dataManager.datas.set([String](), forKey: "countriesData")
                    dataManager.datas.set([String](), forKey: "countriesVoice")
                    dataManager.datas.set([String](), forKey: "countriesVData")
                    dataManager.datas.synchronize()
                    
                    let alert2 = UIAlertController(title: "checking_eligibility".localized(), message:nil, preferredStyle: UIAlertController.Style.alert)
                    let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 5, width: 50, height: 50))
                    loadingIndicator.hidesWhenStopped = true
                    if #available(iOS 13.0, *) {
                        loadingIndicator.style = UIActivityIndicatorView.Style.medium
                    } else {
                        // Fallback on earlier versions
                        loadingIndicator.style = UIActivityIndicatorView.Style.gray
                    }
                    loadingIndicator.startAnimating()
                    alert2.view.addSubview(loadingIndicator)
                    
                    self.present(alert2, animated: true, completion: nil)
                    
                    self.delay(4){
                        UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
                        if DataManager.isEligibleForMinimalSetup(){
                            dataManager.datas.set(true, forKey: "minimalSetup")
                            dataManager.datas.set(false, forKey: "disableFMobileCore")
                            dataManager.datas.set(true, forKey: "setupDone")
                            dataManager.datas.set(false, forKey: "isSettingUp")
                            dataManager.datas.synchronize()
                        } else {
                            let alertController2 = UIAlertController(title: "compatibility_issues".localized(), message: "compatibility_error_message".localized(), preferredStyle: .alert)
                            let confirmAction2 = UIAlertAction(title: "force_minimal_setup".localized(), style: .destructive) { (_) in
                                dataManager.datas.set(true, forKey: "minimalSetup")
                                dataManager.datas.set(false, forKey: "disableFMobileCore")
                                dataManager.datas.set(true, forKey: "setupDone")
                                dataManager.datas.set(false, forKey: "isSettingUp")
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
            } else {
                dataManager.datas.set(false, forKey: "isSettingUp")
                dataManager.datas.synchronize()
            }
        }
        dataManager.datas.set(false, forKey: "isSettingUp")
        dataManager.datas.synchronize()
    }
    
    func oldios(){
        guard #available(iOS 12.0, *) else {
            let alert = UIAlertController(title: "old_ios_warning".localized().format([UIDevice.current.systemVersion]), message: "old_ios_description".localized(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "close".localized(), style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            
            return
        }
    }
    
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
            locationManager.distanceFilter = kCLDistanceFilterNone
            locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            locationManager.startUpdatingLocation()
            print("STARTING ANALYSIS")
            isAUTH = true
        }
    }
    
    func downgrade(){
        let appVersion = Int(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0") ?? 0
        let datas = UserDefaults(suiteName: "group.fr.plugn.fmobile") ?? Foundation.UserDefaults.standard
        
        datas.set(appVersion, forKey: "version")
        datas.synchronize()
    }
    
    func update(_ version : Int = 0){
        print("UPDATE CALLED")
        
        let dataManager = DataManager()
        let appVersion = Int(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0") ?? 0
        
        // Update protocol list
        
        // BUILD 100 - DELETE USERDEFAULTS
        if version < 100 && version != 0 {
            guard let domain = Bundle.main.bundleIdentifier else { return }
            Foundation.UserDefaults.standard.removePersistentDomain(forName: domain)
            Foundation.UserDefaults.standard.synchronize()
            print(Array(Foundation.UserDefaults.standard.dictionaryRepresentation().keys).count)
        }
        
        // BUILD 105 - RESET STATSPREFS
        if version < 105 && version >= 100 && version != 0 {
            dataManager.datas.set(false, forKey: "coveragemap")
            dataManager.datas.set(false, forKey: "coveragemap_noalert")
            dataManager.datas.set(false, forKey: "statisticsAgreement")
        }
        
        // BUILD 114 - RESET STATSPREFS
         if version < 114 && version != 0 {
            dataManager.datas.set(false, forKey: "didFinishFirstStart")
             let alert = UIAlertController(title: "Action requise - Migration depuis FMobile 1.3", message: "Bienvenue sur FMobile 4. Nous avons fait beaucoup de modifications pour iOS 13. Le raccourci RRFM ne sert plus dans cette version, car il a été remplacé par le raccourci ANIRC. Un tout nouveau tutoriel vidéo est également livré dans cette mise à jour. Pour vous faciliter la tâche, nous avons réinitialisé le statut du premier démarrage afin de vous permettre de visionner le nouveau tutoriel d'installation et d'installer plus rapidement le nouveau raccourci ANIRC (et éventuellement mettre à jour le raccourci CFM pour iOS 13). Il est vivement recommandé de regarder le nouveau tutoriel d'installation, même si vous êtes complètement à l'aise avec les nouveaux outils Automatisations dans Raccourcis.", preferredStyle: .alert)
             alert.addAction(UIAlertAction(title: "ok".localized(), style: .default) { (_) in
                if let tabBar = self.tabBarController as? TabBarController {
                    tabBar.firstStart()
                 }
             })
             present(alert, animated: true, completion: nil)
         }
        
        if version < 163 {
            dataManager.datas.set(false, forKey: "coveragemap")
            dataManager.datas.synchronize()
            
            let alert = UIAlertController(title: "coveragemap_alert_title".localized(), message: "coveragemap_alert_description".localized(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "coveragemap_alert_accept".localized(), style: .default) { _ in
                dataManager.datas.set(true, forKey: "coveragemap")
                dataManager.datas.synchronize()
                self.loadUI()
                self.refreshSections()
            })
            alert.addAction(UIAlertAction(title: "coveragemap_alert_accept2".localized(), style: .default) { _ in
                // Save "Do not show again"
                dataManager.datas.set(true, forKey: "coveragemap")
                dataManager.datas.set(true, forKey: "coveragemap_noalert")
                dataManager.datas.synchronize()
                self.loadUI()
                self.refreshSections()
            })
            alert.addAction(UIAlertAction(title: "coveragemap_alert_deny".localized(), style: .cancel) { _ in
                // Cancel switch
                dataManager.datas.set(false, forKey: "coveragemap")
                dataManager.datas.synchronize()
            })
            self.present(alert, animated: true, completion: nil)
        }
        
        // Nouveau Raccourci ANIRC v4 pour iOS 14
        if #available(iOS 13.0, *) {
            if version < 173 && version != 0 {
                let alert = UIAlertController(title: "Nouveau raccourci ANIRC v4", message: "Un nouveau raccourci ANIRC v4 est disponible et corrige de nombreux bugs et augmente l'efficacité de celui-ci, notamment sur iOS 14. Veuillez le mettre à jour maintenant.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Télécharger ANIRC", style: .default) { (_) in
                    guard let link = URL(string: "http://raccourcis.ios.free.fr/fmobile") else { return }
                    UIApplication.shared.open(link)
                })
                present(alert, animated: true, completion: nil)
            }
        }
             
        
        dataManager.datas.set(appVersion, forKey: "version")
        dataManager.datas.synchronize()
        
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
        tableView.register(AppTableViewCell.self, forCellReuseIdentifier: "appCell")
        
        if #available(iOS 13.0, *) {} else {
            // Ecoute les changements de couleurs
            NotificationCenter.default.addObserver(self, selector: #selector(darkModeEnabled(_:)), name: .darkModeEnabled, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(darkModeDisabled(_:)), name: .darkModeDisabled, object: nil)
            
            // On initialise les couleurs
            isDarkMode() ? enableDarkMode() : disableDarkMode()
        }
        
        // On active certaines fonctionnalitees
        UIDevice.current.isBatteryMonitoringEnabled = true
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        navigationItem.title = "fmobile".localized()
        
        // On demarre le moteur et l'UI
        let dataManager = DataManager()
        
        dataManager.datas.set(false, forKey: "isSettingUp")
        dataManager.datas.synchronize()
        
        start()
        loadUI(dataManager)
        refreshSections()
        
        // On save certaines preferences
        dataManager.datas.set(false, forKey: "didAlertLB")
        dataManager.datas.set(true, forKey: "statusUL")
        dataManager.datas.set(Date().addingTimeInterval(-15 * 60), forKey: "NTimer")
        dataManager.datas.synchronize()
    }
    
    @available(iOS, obsoleted: 13.0)
    deinit {
        NotificationCenter.default.removeObserver(self, name: .darkModeEnabled, object: nil)
        NotificationCenter.default.removeObserver(self, name: .darkModeDisabled, object: nil)
    }
    
    @available(iOS, obsoleted: 13.0)
    @objc override func darkModeEnabled(_ notification: Foundation.Notification) {
        super.darkModeEnabled(notification)
        self.tableView.reloadData()
    }
    
    @available(iOS, obsoleted: 13.0)
    @objc override func darkModeDisabled(_ notification: Foundation.Notification) {
        super.darkModeDisabled(notification)
        self.tableView.reloadData()
    }
    
    @available(iOS, obsoleted: 13.0)
    @objc override func enableDarkMode() {
        super.enableDarkMode()
        self.view.backgroundColor = CustomColor.darkTableBackground
        self.tableView.backgroundColor = CustomColor.darkTableBackground
        self.tableView.separatorColor = CustomColor.darkSeparator
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.backgroundColor = .black
        self.navigationController?.navigationBar.barTintColor = .black
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.largeTitleTextAttributes = textAttributes
        }
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.view.backgroundColor = CustomColor.darkBackground
        self.navigationController?.navigationBar.tintColor = CustomColor.darkActive
    }
    
    @available(iOS, obsoleted: 13.0)
    @objc override func disableDarkMode() {
        super.disableDarkMode()
        self.view.backgroundColor = CustomColor.lightTableBackground
        self.tableView.backgroundColor = CustomColor.lightTableBackground
        self.tableView.separatorColor = CustomColor.lightSeparator
        self.navigationController?.navigationBar.barStyle = .default
        self.navigationController?.navigationBar.backgroundColor = .white
        self.navigationController?.navigationBar.barTintColor = .white
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.largeTitleTextAttributes = textAttributes
        }
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.view.backgroundColor = CustomColor.lightBackground
        self.navigationController?.navigationBar.tintColor = CustomColor.lightActive
    }
    
    @objc func timerschedule() {
        let dataManager = DataManager()
        
        if !self.isAUTH {
            self.start()
        }

        if !self.tableView.isCellVisible(section: 0, row: (self.sections.first?.elements.count ?? 1) - 1){
            print("INVISIBLE, STOP REFRESH !!!")
            return
        }
        print("Refresh started!")
                
        self.loadUI(dataManager)
        self.refreshSections()
    }
    
    @objc func timernetschedule() {
        let dataManager = DataManager()
        
        if !dataManager.setupDone && DataManager.isConnectedToNetwork() {
            self.updateSetup(dataManager, false)
        }
        
        if !dataManager.stopverification {
            print("REFRESH BACKGROUND TASKS FROM UI")
            RoamingManager.engineRunning()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let dataManager = DataManager()
        
        var version = 0
        if dataManager.datas.value(forKey: "version") != nil {
            version = dataManager.datas.value(forKey: "version") as? Int ?? 0
        }
        let appVersion = Int(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0") ?? 0
        
        print("Version: \(version)")
        print("AppVersion: \(appVersion)")
        
        if appVersion > version {
            update(version)
            if dataManager.datas.value(forKey: "version") != nil {
                version = dataManager.datas.value(forKey: "version") as? Int ?? 0
            }
            print("Version after update: \(version)")
        } else if appVersion < version {
            downgrade()
        }
    
        updateSetup(dataManager, false)
        
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.timerschedule), userInfo: nil, repeats: true)
        
        timernet = Timer.scheduledTimer(timeInterval: 20.0, target: self, selector: #selector(self.timernetschedule), userInfo: nil, repeats: true)
    }
        
    
    override func viewDidDisappear(_ animated: Bool) {
        timer?.invalidate()
        timernet?.invalidate()
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    @objc func timersimschedule() {
        let siminventory = DataManager.getSimInventory()
        let dataManager = DataManager()
        var mcc = ""
        var mnc = ""
        
        if siminventory.count > 0 {
            mcc = siminventory[0].1.mobileCountryCode ?? "---"
            mnc = siminventory[0].1.mobileNetworkCode ?? "--"
        }

        let simready = (mcc == "---" || mcc == "null" || mcc.isEmpty || mnc == "--" || mnc == "null" || mnc.isEmpty)
        if !simready {
            self.timersim?.invalidate()
            UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
            self.updateSetup(dataManager, true)
            
        }
    }
    
    func diagPrivacy(source: UIButton) {
        let alert = UIAlertController(title: "privacy".localized(), message: "diag_privacy".localized(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "coveragemap_alert_accept".localized(), style: .default) { (_) in
            self.diag(source: source, privacy: true)
        })
        alert.addAction(UIAlertAction(title: "coveragemap_alert_deny".localized(), style: .default) { (_) in
            self.diag(source: source, privacy: false)
        })
        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func diag(source: UIButton, privacy: Bool = false) {
        let alert = UIAlertController(title: "diagnostic_inprogress".localized(), message:nil, preferredStyle: UIAlertController.Style.alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        if #available(iOS 13.0, *) {
            loadingIndicator.style = UIActivityIndicatorView.Style.medium
        } else {
            loadingIndicator.style = UIActivityIndicatorView.Style.gray
        }
        loadingIndicator.startAnimating()
        alert.view.addSubview(loadingIndicator)
        
        present(alert, animated: true, completion: nil)
        
        RoamingManager.engine(g3engine: false) { resultg2 in
        RoamingManager.engine(g3engine: true) { resultg3 in

        let dataManager = DataManager()
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
        let buildVersion = Int(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0") ?? 0
        // Strings de l'UI
        
        var generation = ""
        if dataManager.ipadMCC == "---" && !dataManager.nrDEC && UIDevice.current.userInterfaceIdiom == .pad {
            generation = "FMobile b\(buildVersion) - Génération A1"
        } else if dataManager.ipadMCC == "---" && UIDevice.current.userInterfaceIdiom == .pad {
            generation = "FMobile b\(buildVersion) - Génération 1"
        } else if !dataManager.nrDEC || !dataManager.setupDone {
            if #available(iOS 13.1, *) {
                generation = "FMobile b\(buildVersion) - Génération A3"
            } else {
                generation = "FMobile b\(buildVersion) - Génération A2"
            }
        } else {
            if #available(iOS 13.1, *) {
                generation = "FMobile b\(buildVersion) - Génération 3"
            } else {
                generation = "FMobile b\(buildVersion) - Génération 2"
            }
        }
            
            let date = Date()
            let hour = Calendar.current.component(.hour, from: date)
            let minutes = Calendar.current.component(.minute, from: date)
            let seconds = Calendar.current.component(.second, from: date)
            let day = Calendar.current.component(.day, from: date)
            let month = Calendar.current.component(.month, from: date)
            let year = Calendar.current.component(.year, from: date)
            let dispDate = "\(day)/\(month)/\(year) à \(hour):\(minutes):\(seconds)"
            var service = ""
            if dataManager.siminventory.count > 0 {
                service = dataManager.siminventory[0].0
            }
            let locationAccuracy = self.locationManager.location?.horizontalAccuracy ?? -1

            var str = "Fichier de diagnostic FMobile \(appVersion)\n\nModèle : \(UIDevice.current.modelName)\nVersion de l'OS : \(UIDevice.current.systemVersion)\nMoteur : \(generation)\nRésultat du moteur G2 : \(resultg2)\nRésultat du moteur G3 : \(resultg3)\nDernier completion G3 : \(dataManager.g3lastcompletion)\nRésultat du moteur G3 international : \(dataManager.zoneCheck())\nDate : \(dispDate)\nsetupDone : \(dataManager.setupDone)\nMinimal setup : \(dataManager.minimalSetup)\n\nDétail du forfait :\nDestinations incluses (ALL) : \(dataManager.countriesVData)\nDestinations incluses (VOIX) : \(dataManager.countriesVoice)\nDestinations incluses (DATA) : \(dataManager.countriesData)\nOptions incluses (ALL) : \(dataManager.includedVData)\nOptions incluses (VOIX) : \(dataManager.includedVoice)\nOption incluses (DATA) : \(dataManager.includedData)\n\nConfiguration :\nmodeRadin : \(dataManager.modeRadin)\nallow013G : \(dataManager.allow013G)\nallow012G : \(dataManager.allow012G)\nallow014G : \(dataManager.allow014G)\nallow015G : \(dataManager.allow015G)\nfemtoLOWDATA : \(dataManager.femtoLOWDATA)\nfemto : \(dataManager.femto)\nverifyonwifi : \(dataManager.verifyonwifi)\nstopverification : \(dataManager.stopverification)\ntimecode : \(dataManager.timecode)\ntimecode G3: \(dataManager.g3timecode)\nlastnet : \(dataManager.lastnet)\ncount : \(dataManager.count)\nwasEnabled : \(dataManager.wasEnabled)\nperfmode : \(dataManager.perfmode)\ndidChangeSettings : \(dataManager.didChangeSettings)\nntimer : \(dataManager.ntimer)\ndispInfoNotif : \(dataManager.dispInfoNotif)\nallowCountryDetection : \(dataManager.allowCountryDetection)\ntimeLastCountry : \(dataManager.timeLastCountry)\nlastCountry : \(dataManager.lastCountry)\n\nStatut opérateur :\nsimData : \(dataManager.simData)\ncurrentNetwork : \(dataManager.currentNetwork)\ncarrier: \(dataManager.carrier)\ncarrierNetwork : \(dataManager.carrierNetwork)\ncarrierNetwork2 : \(dataManager.carrierNetwork2)\ncarrierName : \(dataManager.carrierName)\n\nConfiguration opérateur :\nhp : \(dataManager.hp)\nnrp : \(dataManager.nrp)\ntargetMCC : \(dataManager.targetMCC)\ntargetMNC : \(dataManager.targetMNC)\nitiMNC : \(dataManager.itiMNC)\nnrDEC : \(dataManager.nrDEC)\nout2G : \(dataManager.out2G)\nchasedMNC : \(dataManager.chasedMNC)\nconnectedMCC : \(dataManager.connectedMCC)\nconnectedMNC : \(dataManager.connectedMNC)\nipadMCC : \(dataManager.ipadMCC)\nipadMNC : \(dataManager.ipadMNC)\nitiName : \(dataManager.itiName)\nhomeName : \(dataManager.homeName)\nstms : \(dataManager.stms)\nregisteredService : \(dataManager.registeredService)\nservice : \(service)\nsiminventory : \(dataManager.siminventory)\nCarrier services : \(dataManager.carrierServices)\nroamLTE : \(dataManager.roamLTE)\nroam5G : \(dataManager.roam5G)\n\nCommunications :\nWi-Fi : \(DataManager.isWifiConnected())\nCellulaire : \(DataManager.isConnectedToNetwork())\nMode avion : \(dataManager.airplanemode)\nCommunication en cours : \(DataManager.isOnPhoneCall())\nPrécision de localisation : \(locationAccuracy)"
            
            if privacy {
                str += "\n\nDonnées personnelles :\nLatitude = \(self.locationManager.location?.coordinate.latitude ?? 0)\nLongitude = \(self.locationManager.location?.coordinate.longitude ?? 0)"
            }
            let filename = self.getDocumentsDirectory().appendingPathComponent("diagnostic.txt")
        
        do {
            try str.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
        }
        
            self.delay(3.29){
            // Create the Array which includes the files you want to share
            var filesToShare = [Any]()
            
            // Add the path of the file to the Array
            
            // Show the share-view
            // self.present(activityViewController, animated: true, completion: nil)
            
           //let internalDiagnostic = URL(fileURLWithPath: "/System/Library/Carrier Bundles/iPhone/20815/carrier.plist")
                
            filesToShare.append(filename)
            //filesToShare.append(internalDiagnostic)
            
                print(filesToShare.first as? URL ?? "FILE LOST")
                
                let myCustomActivity = ActivityViewCustomActivity(title: "send_diagnostic_to_developer".localized(), imageName: "IMG_0867-1024", filesToShare: filesToShare) {
                   print("processWillBegin...")
                }
            
                UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
            
            // Make the activityViewContoller which shows the share-view
            let ls = UIActivityViewController(activityItems: filesToShare, applicationActivities: [myCustomActivity])
            ls.popoverPresentationController?.sourceView = source
            ls.popoverPresentationController?.sourceRect = source.frame

            //UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
            // Show the share-view
            self.present(ls, animated: true, completion: nil)
        }
        }
        }
    }
    
    func loadUI(_ dataManager: DataManager = DataManager()) {
        if dataManager.stopverification {
            locationManager.stopUpdatingLocation()
            locationManager.allowsBackgroundLocationUpdates = false
            locationManager.stopMonitoringSignificantLocationChanges()
            print("Should stop ALL KIND OF ACTUALIZATION... [CALLING FROM UI REFRESH]")
        } else {
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.startMonitoringSignificantLocationChanges()
            if !dataManager.perfmode {
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
        
        let lastCountry = dataManager.datas.value(forKey: "lastCountry") as? String ?? "FR"
        var timecoder = dataManager.datas.value(forKey: "timecoder") as? Date ?? Date()
        var lastnetr = dataManager.datas.value(forKey: "lastnetr") as? String ?? "HSDPAO"
        
        print(lastCountry)
        print(lastnetr)
        
        print(dataManager.carrierNetwork)
        
        let countryCode = dataManager.mycarrier.mobileCountryCode ?? "null"
        let mobileNetworkName = dataManager.mycarrier.mobileNetworkCode ?? "null"
        let carrierName = dataManager.carrierName
        let isoCountrycode = dataManager.mycarrier.isoCountryCode?.uppercased() ?? "null"
        
        let countryCode2 = dataManager.mycarrier2.mobileCountryCode ?? "null"
        let mobileNetworkName2 = dataManager.mycarrier2.mobileNetworkCode ?? "null"
        let carrierName2 = dataManager.mycarrier2.carrierName ?? "null"
        let isoCountrycode2 = dataManager.mycarrier2.isoCountryCode?.uppercased() ?? "null"
        
        let country = CarrierIdentification.getIsoCountryCode(dataManager.connectedMCC, dataManager.connectedMNC)
        
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
        
        if (dataManager.carrierNetwork == CTRadioAccessTechnologyLTE && (dataManager.allow014G || (dataManager.modeExpert ? false : !dataManager.roamLTE))) {
            dataManager.carrierNetwork = dataManager.modeRadin ? "4G radine : \(radincarrier) (\(country))" : dataManager.modeExpert ?
                "\(dataManager.carrier) 4G (LTE) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))" :  "\(dataManager.carrier) 4G"
            lastnetr = "LTE"
            dataManager.datas.set(lastnetr, forKey: "lastnetr")
            dataManager.datas.synchronize()
        } else if dataManager.carrierNetwork == CTRadioAccessTechnologyLTE {
                if dataManager.connectedMCC == dataManager.targetMCC && dataManager.connectedMNC == dataManager.chasedMNC && !DataManager.isWifiConnected() && dataManager.nrDEC {
                
                    print(abs(timecoder.timeIntervalSinceNow))
                    
                    if abs(timecoder.timeIntervalSinceNow) < 10*60 && lastnetr == "LTEO" {
                        DispatchQueue.main.async {
                            dataManager.carrierNetwork = dataManager.modeRadin ? "Itinérance Delta S radine : \(radinitiname) (\(country))" : dataManager.modeExpert ?
                                "\(dataManager.itiName) 4G (LTE) [\(dataManager.connectedMCC) \(dataManager.itiMNC)] (\(country))" :  "\(dataManager.itiName) 4G \("itinerance".localized())"
                            self.refreshSections()
                            print("CACHE ORANGE F")
                        }
                    } else if abs(timecoder.timeIntervalSinceNow) < 10*60 && lastnetr == "LTEF" {
                        DispatchQueue.main.async {
                            dataManager.carrierNetwork = dataManager.modeRadin ? "Femto ou mutualisation radine : \(radincarrier) (\(country))" : dataManager.modeExpert ?
                                "\(dataManager.carrier) 4G (LTE) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))" :  "\(dataManager.carrier) 4G (Femto)"
                            self.refreshSections()
                            print("CACHE FEMTO")
                        }
                    } else {
                        Speedtest().testDownloadSpeedWithTimout(timeout: 5.0, usingURL: dataManager.url) { (speed, _) in
                            DispatchQueue.main.async {
                                if speed ?? 0 < dataManager.stms{
                                    dataManager.carrierNetwork = dataManager.modeRadin ? "Itinérance Delta S radine : \(radinitiname) (\(country))" : dataManager.modeExpert ?
                                        "\(dataManager.itiName) 4G (LTE) [\(dataManager.connectedMCC) \(dataManager.itiMNC)] (\(country))" :  "\(dataManager.itiName) 4G \("itinerance".localized())"
                                    lastnetr = "LTEO"
                                } else {
                                    dataManager.carrierNetwork = dataManager.modeRadin ? "Femto ou mutualisation radine : \(radincarrier) (\(country))" : dataManager.modeExpert ?
                                        "\(dataManager.carrier) 4G (LTE) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))" :  "\(dataManager.carrier) 4G (Femto)"
                                    lastnetr = "LTEF"
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
                    lastnetr = "LTE"
                    dataManager.datas.set(lastnetr, forKey: "lastnetr")
                    dataManager.datas.synchronize()
                }
                if dataManager.connectedMCC == dataManager.targetMCC && dataManager.connectedMNC == dataManager.itiMNC && dataManager.carrierNetwork == CTRadioAccessTechnologyLTE {
                    dataManager.carrierNetwork = dataManager.modeRadin ? "Itinérance Delta S radine : \(radinitiname) (\(country))" : dataManager.modeExpert ?
                    "\(dataManager.itiName) 4G (LTE) [\(dataManager.connectedMCC) \(dataManager.itiMNC)] (\(country))" :  "\(dataManager.itiName) 4G \("itinerance".localized())"
                } else {
                dataManager.carrierNetwork = dataManager.modeRadin ? "4G radine : \(radincarrier) (\(country))" : dataManager.modeExpert ?
                    "\(dataManager.carrier) 4G (LTE) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))" :  "\(dataManager.carrier) 4G"
                }
        } else if dataManager.carrierNetwork == CTRadioAccessTechnologyWCDMA {
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
                        Speedtest().testDownloadSpeedWithTimout(timeout: 5.0, usingURL: dataManager.url) { (speed, _) in
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
            if dataManager.connectedMCC == dataManager.targetMCC && dataManager.connectedMNC == dataManager.chasedMNC && dataManager.carrierNetwork == dataManager.nrp {
                dataManager.carrierNetwork = dataManager.modeRadin ? "Itinérance Delta radine : \(radinitiname) (\(country))" : dataManager.modeExpert ?
                "\(dataManager.itiName) 3G (WCDMA) [\(dataManager.connectedMCC) \(dataManager.itiMNC)] (\(country))" :  "\(dataManager.itiName) 3G \("itinerance".localized())"
            } else {
            dataManager.carrierNetwork = dataManager.modeRadin ? "3G radine : \(radincarrier) (\(country))" : dataManager.modeExpert ?
                "\(dataManager.carrier) 3G (WCDMA) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))" :  "\(dataManager.carrier) 3G"
            }
        } else if dataManager.carrierNetwork == CTRadioAccessTechnologyHSDPA {
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
                        Speedtest().testDownloadSpeedWithTimout(timeout: 5.0, usingURL: dataManager.url) { (speed, _) in
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
            if dataManager.connectedMCC == dataManager.targetMCC && dataManager.connectedMNC == dataManager.chasedMNC && dataManager.carrierNetwork == dataManager.nrp {
                dataManager.carrierNetwork = dataManager.modeRadin ? "Itinérance Delta radine : \(radinitiname) (\(country))" : dataManager.modeExpert ?
                "\(dataManager.itiName) 3G (HSDPA) [\(dataManager.connectedMCC) \(dataManager.itiMNC)] (\(country))" :  "\(dataManager.itiName) 3G \("itinerance".localized())"
            } else {
            dataManager.carrierNetwork = dataManager.modeRadin ? "3G radine : \(radincarrier) (\(country))" : dataManager.modeExpert ?
                "\(dataManager.carrier) 3G (HSDPA) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))" :  "\(dataManager.carrier) 3G"
            }
        } else if dataManager.carrierNetwork == CTRadioAccessTechnologyEdge {
            dataManager.carrierNetwork = dataManager.connectedMCC == dataManager.targetMCC && dataManager.connectedMNC == dataManager.chasedMNC && dataManager.out2G ?
                (dataManager.modeRadin ? "Itinérance tupperware radine : \(radinitiname) (\(country))" : dataManager.modeExpert ? "\(dataManager.itiName) 2G (EDGE) [\(dataManager.connectedMCC) \(dataManager.itiMNC)] (\(country))" : "\(dataManager.itiName) 2G \("itinerance".localized())") : (dataManager.modeRadin ? "2G radine : \(radincarrier) (\(country))" : dataManager.modeExpert ? "\(dataManager.carrier) 2G (EDGE) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))" : "\(dataManager.carrier) 2G")
            lastnetr = "Edge"
            dataManager.datas.set(lastnetr, forKey: "lastnetr")
            dataManager.datas.synchronize()
        } else if dataManager.carrierNetwork == CTRadioAccessTechnologyGPRS {
            dataManager.carrierNetwork = dataManager.connectedMCC == dataManager.targetMCC && dataManager.connectedMNC == dataManager.chasedMNC && dataManager.out2G ?
                (dataManager.modeRadin ? "Itinérance VHS radine : \(radinitiname) (\(country))" : dataManager.modeExpert ? "\(dataManager.itiName) G (GPRS) [\(dataManager.connectedMCC) \(dataManager.itiMNC)] (\(country))" : "\(dataManager.itiName) G \("itinerance".localized())") : (dataManager.modeRadin ? "G radin : \(radincarrier) (\(country))" : dataManager.modeExpert ? "\(dataManager.carrier) G (GPRS) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))" : "\(dataManager.carrier) G")
            lastnetr = "GPRS"
            dataManager.datas.set(lastnetr, forKey: "lastnetr")
            dataManager.datas.synchronize()
        } else if dataManager.carrierNetwork == CTRadioAccessTechnologyeHRPD {
            dataManager.carrierNetwork = dataManager.modeRadin ? "3G radine : \(radincarrier) (\(country))" : dataManager.modeExpert ?
                "\(dataManager.carrier) 3G (eHRPD) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))" :  "\(dataManager.carrier) 3G"
            lastnetr = "HRPD"
            dataManager.datas.set(lastnetr, forKey: "lastnetr")
            dataManager.datas.synchronize()
        } else if dataManager.carrierNetwork == CTRadioAccessTechnologyHSUPA {
            dataManager.carrierNetwork = dataManager.modeRadin ? "3G radine : \(radincarrier) (\(country))" : dataManager.modeExpert ?
                "\(dataManager.carrier) 3G (HSUPA) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))" :  "\(dataManager.carrier) 3G"
            lastnetr = "HSUPA"
            dataManager.datas.set(lastnetr, forKey: "lastnetr")
            dataManager.datas.synchronize()
        } else if dataManager.carrierNetwork == CTRadioAccessTechnologyCDMA1x {
            dataManager.carrierNetwork = dataManager.modeRadin ? "3G radine : \(radincarrier) (\(country))" : dataManager.modeExpert ?
                "\(dataManager.carrier) 3G (CDMA2000) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))" :  "\(dataManager.carrier) 3G"
            lastnetr = "CDMA1x"
            dataManager.datas.set(lastnetr, forKey: "lastnetr")
            dataManager.datas.synchronize()
        } else if dataManager.carrierNetwork == CTRadioAccessTechnologyCDMAEVDORev0 {
            dataManager.carrierNetwork = dataManager.modeRadin ? "3G radine : \(radincarrier) (\(country))" : dataManager.modeExpert ?
                "\(dataManager.carrier) 3G (EvDO) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))" :  "\(dataManager.carrier) 3G"
            lastnetr = "CDMAEVDORev0"
            dataManager.datas.set(lastnetr, forKey: "lastnetr")
            dataManager.datas.synchronize()
        } else if dataManager.carrierNetwork == CTRadioAccessTechnologyCDMAEVDORevA {
            dataManager.carrierNetwork = dataManager.modeRadin ? "3G radine : \(radincarrier) (\(country))" : dataManager.modeExpert ?
                "\(dataManager.carrier) 3G (EvDO-A) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))" :  "\(dataManager.carrier) 3G"
            lastnetr = "CDMAEVDORevA"
            dataManager.datas.set(lastnetr, forKey: "lastnetr")
            dataManager.datas.synchronize()
        } else if dataManager.carrierNetwork == CTRadioAccessTechnologyCDMAEVDORevB {
            dataManager.carrierNetwork = dataManager.modeRadin ? "3G radine : \(radincarrier) (\(country))" : dataManager.modeExpert ?
                "\(dataManager.carrier) 3G (EvDO-B) [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(country))" :  "\(dataManager.carrier) 3G"
            lastnetr = "CDMAEVDORevB"
            dataManager.datas.set(lastnetr, forKey: "lastnetr")
            dataManager.datas.synchronize()
        }
        
        if !dataManager.modeRadin && !dataManager.modeExpert && CarrierIdentification.getIsoCountryCode(dataManager.connectedMCC, dataManager.connectedMNC) != CarrierIdentification.getIsoCountryCode(dataManager.targetMCC, dataManager.targetMNC) && CarrierIdentification.getIsoCountryCode(dataManager.connectedMCC, dataManager.connectedMNC) != "--" && dataManager.carrierNetwork != "" && !dataManager.carrierNetwork.isEmpty{
            dataManager.carrierNetwork += " (\(country))"
        }
        
//        if DataManager.isWifiConnected() {
//            if !dataManager.carrierNetwork.isEmpty{
//                dataManager.carrierNetwork = "Wi-Fi + " + dataManager.carrierNetwork
//            } else {
//                dataManager.carrierNetwork = "Wi-Fi"
//            }
//        }
        
        if dataManager.carrierNetwork2 == CTRadioAccessTechnologyLTE {
            dataManager.carrierNetwork2 = dataManager.modeRadin ? "4G" : dataManager.modeExpert ? "4G (LTE)" : "4G"
        } else if dataManager.carrierNetwork2 == CTRadioAccessTechnologyWCDMA {
            dataManager.carrierNetwork2 = dataManager.modeRadin ? "3G" : dataManager.modeExpert ? "3G (WCDMA)" : "3G"
        } else if dataManager.carrierNetwork2 == CTRadioAccessTechnologyHSDPA {
            dataManager.carrierNetwork2 = dataManager.modeRadin ? "3G" : dataManager.modeExpert ? "3G (HSDPA)" : "3G"
        } else if dataManager.carrierNetwork2 == CTRadioAccessTechnologyEdge {
            dataManager.carrierNetwork2 = dataManager.modeRadin ? "2G" : dataManager.modeExpert ? "2G (EDGE)" : "2G"
        } else if dataManager.carrierNetwork2 == CTRadioAccessTechnologyGPRS {
            dataManager.carrierNetwork2 = dataManager.modeRadin ? "G" : dataManager.modeExpert ? "G (GPRS)" : "G"
        } else if dataManager.carrierNetwork2 == CTRadioAccessTechnologyeHRPD {
            dataManager.carrierNetwork2 = dataManager.modeRadin ? "3G" : dataManager.modeExpert ? "3G (eHRPD)" : "3G"
        } else if dataManager.carrierNetwork2 == CTRadioAccessTechnologyHSUPA {
            dataManager.carrierNetwork2 = dataManager.modeRadin ? "3G" : dataManager.modeExpert ? "3G (HSUPA)" : "3G"
        } else if dataManager.carrierNetwork2 == CTRadioAccessTechnologyCDMA1x {
            dataManager.carrierNetwork2 = dataManager.modeRadin ? "3G" : dataManager.modeExpert ? "3G (CDMA2000)" : "3G"
        } else if dataManager.carrierNetwork2 == CTRadioAccessTechnologyCDMAEVDORev0 {
            dataManager.carrierNetwork2 = dataManager.modeRadin ? "3G" : dataManager.modeExpert ? "3G (EvDO)" : "3G"
        } else if dataManager.carrierNetwork2 == CTRadioAccessTechnologyCDMAEVDORevA {
            dataManager.carrierNetwork2 = dataManager.modeRadin ? "3G" : dataManager.modeExpert ? "3G (EvDO-A)" : "3G"
        } else if dataManager.carrierNetwork2 == CTRadioAccessTechnologyCDMAEVDORevB {
            dataManager.carrierNetwork2 = dataManager.modeRadin ? "3G" : dataManager.modeExpert ? "3G (EvDO-B)" : "3G"
        }
        
        print(dataManager.carrierNetwork)
        print(dataManager.carrierNetwork2)
        
        if !dataManager.setupDone && countryCode == "null" && mobileNetworkName == "null" && dataManager.carrierNetwork == "" && !alertInit {
            delay(0.05) {
                let alert = UIAlertController(title: "insert_sim_title".localized(), message:"insert_sim_description".localized(), preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "ok".localized(), style: UIAlertAction.Style.default, handler: nil))
                
                UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
            }
            alertInit = true
        }
        
        var disp: String
        if countryCode == "null" || countryCode.isEmpty {
            disp = dataManager.modeRadin ? "Pas de carte SIM radine détéctée" : "no_sim".localized()
        } else {
            if countryCode == "208" && mobileNetworkName == "15" {
                disp = "\("sim_card".localized()) \(dataManager.modeRadin ? "Radin" : carrierName)"
                if dataManager.modeExpert {
                    disp += " [\(countryCode) \(mobileNetworkName)] (\(isoCountrycode))"
                }
            } else if countryCode == "208" && mobileNetworkName == "01" {
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
            } else if countryCode2 == "208" && mobileNetworkName2 == "01" {
                disp2 = "\("esim".localized()) \(dataManager.modeRadin ? "Agrume France" : carrierName2)"
                if dataManager.modeExpert {
                    disp2 += " [\(countryCode2) \(mobileNetworkName2)] (\(isoCountrycode2))"
                }
            } else if countryCode2 == "208" && mobileNetworkName2 == "10" {
                disp2 = "\("esim".localized()) \(dataManager.modeRadin ? "Patoche has no limits" : carrierName2)"
                if dataManager.modeExpert {
                    disp2 += " [\(countryCode2) \(mobileNetworkName2)] (\(isoCountrycode2))"
                }
            } else if countryCode2 == "208" && mobileNetworkName2 == "20" {
                disp2 = "\("esim".localized()) \(dataManager.modeRadin ? "Béton Télécom" : carrierName2)"
                if dataManager.modeExpert {
                    disp2 += " [\(countryCode2) \(mobileNetworkName2)] (\(isoCountrycode2))"
                }
            } else if countryCode2 == "208" && mobileNetworkName2 == "26" {
                disp2 = "\("esim".localized()) \(dataManager.modeRadin ? "Redbull Mobile" : carrierName2)"
                if dataManager.modeExpert {
                    disp2 += " [\(countryCode2) \(mobileNetworkName2)] (\(isoCountrycode2))"
                }
            } else {
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
            if #available(iOS 13.1, *) {
                generation = "generation".localized().format([String(appVersion), "A3"])
            } else {
                generation = "generation".localized().format([String(appVersion), "A2"])
            }
        } else {
            if #available(iOS 13.1, *) {
                generation = "generation".localized().format([String(appVersion), "3"])
            } else {
                generation = "generation".localized().format([String(appVersion), "2"])
            }
        }
        
        let sta = dataManager.modeRadin ? "État du réseau radin" : "status".localized()
        let prefsnet = dataManager.modeRadin ? "Préférences radines" : "netprefs".localized()
        let prefsstats = dataManager.modeRadin ? "Statistiques radines" : "statsprefs".localized()
        let iti5G = dataManager.modeRadin ? "Itinérance Utopique autorisée" : "allow5g".localized()
        let iti4G = dataManager.modeRadin ? "Itinérance Delta^4 autorisée" : "allow4g".localized()
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
        //let suivi = dataManager.modeRadin ? "Suivi complet de consommation Radine" : "suivi_conso_20815".localized()
        //let c555 = dataManager.modeRadin ? "SMS de conso Radin" : "call_555_sms".localized()
        let help = dataManager.modeRadin ? "Assistance radine" : "help".localized()
        //let c3244 = dataManager.modeRadin ? "Appeler le SAV Radin" : "call_3244".localized()
        let cont = dataManager.modeRadin ? "Contacter le développeur radin" : "contact_developer".localized()
        let lb = dataManager.modeRadin ? "Mode Rocket+" : "performance_mode".localized()
        let perfmodefoo = dataManager.modeRadin ? "Lorsque le mode Rocket+ est activé, votre appareil rafraichit le statut d'itinérance radine toutes les 1 à 10 secondes. Cette option est recommandée pour les utilisateurs trop fidèles à Radin. Il est recommandé de posséder une puce A11 Bionic ou supérieure et d'avoir une bonne récéption GPS pour profiter de cette option tout en limitant la perte d'autonomie de batterie radine." : "performance_mode_footer".localized()
        
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
        
        if #available(iOS 10.3, *) {
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
        }
        
        print(UIDevice.current.modelName)
        let device = (UIDevice.current.modelName.replacingOccurrences(of: "iPhone", with: "").replacingOccurrences(of: "iPad", with: "").replacingOccurrences(of: "iPod", with: "").replacingOccurrences(of: ",", with: ".") as NSString).integerValue
        print(device)
        
        // Chargement des éléments de l'UI
        sections = []
        
        // Section status
        let net = Section(name: sta, elements: [], footer: perfmodefoo)
        
        if !dataManager.setupDone {
            if dataManager.isSettingUp || (abs(dataManager.syncNewSIM.timeIntervalSinceNow) < 20) {
                net.elements += [
                    UIElementLabel(id: "activ", text: "🕗 \("activation".localized())")
                ]
            } else {
                net.elements += [
                    UIElementButton(id: "", text: "⚠️ \("activate".localized())") { (_) in
                        
                        let siminventory = DataManager.getSimInventory()
                        var mcc = "---"
                        var mnc = "--"
                        
                        if siminventory.count > 0 {
                            mcc = siminventory[0].1.mobileCountryCode ?? "---"
                            mnc = siminventory[0].1.mobileNetworkCode ?? "--"
                        }
                        let simready = (mcc == "---" || mcc == "null" || mcc.isEmpty || mnc == "--" || mnc == "null" || mnc.isEmpty)
                            
                            if simready {
                                
                                let alert = UIAlertController(title: "\("insert_sim_title".localized())...", message:nil, preferredStyle: .alert)
                                
                                alert.addAction(UIAlertAction(title: "cancel".localized(), style: .destructive) { (_) in
                                    self.timersim?.invalidate()
                                    return
                                })
                                
                                alert.addAction(UIAlertAction(title: "ignore".localized(), style: .default) { (_) in
                                    self.timersim?.invalidate()
                                    self.updateSetup(dataManager, true)
                                    return
                                })
                                
                                UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
                                //self.present(alert, animated: true, completion: nil)
                                
                                self.timersim = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.timersimschedule), userInfo: nil, repeats: true)
                                
                            } else {
                                self.updateSetup(dataManager, true)
                        }
                        
                        
                    }
                ]
            }
        }
        
        let version = dataManager.datas.value(forKey: "version") as? Int ?? 0
        
        print("Version: \(version)")
        print("AppVersion: \(appVersion)")
        
        if appVersion != version {
             net.elements += [UIElementLabel(id: "activ", text: "🕗 \("updating".localized())")]
        }
        
        // SIM 1
        net.elements += [UIElementLabel(id: "networkstatus", text: disp)]
        // SIM 2 (complète avec ta condition sur ce if et change le texte avec la valeur de la deuxième sim)
        if ((device >= 11 && UIDevice.current.modelName.contains("iPhone")) || (device >= 8 && UIDevice.current.modelName.contains("iPad"))) && (countryCode2 != "null" && !countryCode2.isEmpty) {
            net.elements += [UIElementLabel(id: "networkstatus2", text: disp2)]
        }
        
        // Reste de la section status
        net.elements += [UIElementLabel(id: "connected", text: "") { () -> String in
            if dataManager.airplanemode {
                return dataManager.modeRadin ? "Mode jet radin activé" : "airplane_mode_enabled".localized()
            }
                else if dataManager.carrierNetwork == "null" || dataManager.carrierNetwork.isEmpty  {
                    if countryCode == "null" || countryCode.isEmpty {
                        return dataManager.modeRadin ? "Pas de connexion radine" : "not_connected".localized()
                    } else {
                        return dataManager.modeRadin ? "Réseau radin perdu : \(dataManager.fullCarrierName)" : (dataManager.modeExpert ? "not_connected_searching".localized().format([dataManager.fullCarrierName]) + " [\(dataManager.connectedMCC) \(dataManager.connectedMNC)] (\(CarrierIdentification.getIsoCountryCode(dataManager.connectedMCC, dataManager.connectedMNC)))" : "not_connected_searching".localized().format([dataManager.fullCarrierName]) + (CarrierIdentification.getIsoCountryCode(dataManager.connectedMCC, dataManager.connectedMNC) != CarrierIdentification.getIsoCountryCode(dataManager.targetMCC, dataManager.targetMNC) ? " (\(CarrierIdentification.getIsoCountryCode(dataManager.connectedMCC, dataManager.connectedMNC)))" : ""))
                    }
                } else {
                    return dataManager.modeRadin ? "\(dataManager.carrierNetwork)" : "connected".localized().format([dataManager.carrierNetwork])
                }
            }]
        
        if ((dataManager.connectedMCC == dataManager.targetMCC && dataManager.connectedMNC == dataManager.chasedMNC && dataManager.minimalSetup) || (dataManager.connectedMCC == dataManager.targetMCC && dataManager.connectedMNC == dataManager.chasedMNC)) && (((!dataManager.allow013G || !dataManager.allow014G) && (lastnetr == "LTEE" || lastnetr == "LTEO" || lastnetr == "HSDPA" || lastnetr == "HSDPAE" || lastnetr == "HSDPAO" || lastnetr == "WCDMAO" || lastnetr == "WCDMAE" || lastnetr == "WCDMA")) || (!dataManager.allow012G && dataManager.out2G && lastnetr == "Edge") || (!dataManager.allow014G && dataManager.roamLTE && lastnetr == "LTE")) && DataManager.isConnectedToNetwork() {
            net.elements += [UIElementButton(id: "", text: "exit_roaming".localized()) { (_) in
                dataManager.wasEnabled += 1
                dataManager.datas.set(dataManager.wasEnabled, forKey: "wasEnabled")
                if dataManager.currentNetwork == CTRadioAccessTechnologyLTE {
                    dataManager.datas.set("LTE", forKey: "g3lastcompletion")
                } else if dataManager.nrp == CTRadioAccessTechnologyHSDPA {
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
                }]
        }
        
        let zone = dataManager.zoneCheck()
        if dataManager.connectedMCC != dataManager.targetMCC && (zone == "OUTZONE" || zone == "CALLS") && CarrierIdentification.getIsoCountryCode(String(dataManager.connectedMCC), String(dataManager.connectedMNC)) != "--" && countryCode != "null" && dataManager.setupDone {
            net.elements += [UIElementButton(id: "", text: "country_included_button".localized().format([CarrierIdentification.getIsoCountryCode(String(dataManager.connectedMCC), String(dataManager.connectedMNC))])) { (_) in
                
                let country = CarrierIdentification.getIsoCountryCode(String(dataManager.connectedMCC), String(dataManager.connectedMNC))
                
                if dataManager.europeland.contains(country) {
                    let addEuropeAlert = UIAlertController(title: "add_europe".localized(), message: "add_europe_description".localized().format([country]), preferredStyle: .alert)
                    addEuropeAlert.addAction(UIAlertAction(title: "add_europe_only".localized(), style: .default) { (_) in
                        self.addCountry(country: "UE", dataManager: dataManager)
                    })
                    addEuropeAlert.addAction(UIAlertAction(title: "add_country_only".localized().format([country]), style: .default) { (_) in
                        self.addCountry(country: country, dataManager: dataManager)
                    })
                    addEuropeAlert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil))
                    
                    UIApplication.shared.windows.first?.rootViewController?.present(addEuropeAlert, animated: true, completion: nil)
                    
                } else {
                    self.addCountry(country: country, dataManager: dataManager)
                }
            }]
        }
        if ((device >= 8 && UIDevice.current.modelName.contains("iPad")) || (device >= 11 && UIDevice.current.modelName.contains("iPhone"))) && (countryCode2 != "null" && !countryCode2.isEmpty) {
            net.elements += [UIElementLabel(id: "connected2", text: "") { () -> String in
                if dataManager.airplanemode {
                    return dataManager.modeRadin ? "Mode jet radin activé" : "airplane_mode_enabled".localized()
                }
                if dataManager.carrierNetwork2 == "null" || dataManager.carrierNetwork2.isEmpty {
                    return dataManager.modeRadin ? "Pas de connexion eSIM radine" : "esim_not_connected".localized()
                } else {
                    return dataManager.modeRadin ? "\(dataManager.carrierNetwork2) radine" : "esim_connected".localized().format([dataManager.carrierNetwork2])
                }
            }]
        }
        
        if #available(iOS 13.2, *) {
        net.elements += [UIElementLabel(id: "connected3", text: "") { () -> String in
            
            let locationAccuracy = self.locationManager.location?.horizontalAccuracy ?? -1
            print("GPS : \(locationAccuracy)")
            if locationAccuracy < 0 {
                return "⚪️⚪️⚪️⚪️⚪️ - 🔳 GPS" + (dataManager.modeExpert ? " (\(round(locationAccuracy)) m)" : "")
            } else if locationAccuracy > 600 {
                return "⚫️⚪️⚪️⚪️⚪️ - 🟥 GPS" + (dataManager.modeExpert ? " (\(round(locationAccuracy)) m)" : "")
            } else if locationAccuracy > 300 {
                return "⚫️⚫️⚪️⚪️⚪️ - 🟧 GPS" + (dataManager.modeExpert ? " (\(round(locationAccuracy)) m)" : "")
            } else if locationAccuracy > 150 {
                return "⚫️⚫️⚫️⚪️⚪️ - 🟨 GPS" + (dataManager.modeExpert ? " (\(round(locationAccuracy)) m)" : "")
            } else if locationAccuracy > 50 {
                return "⚫️⚫️⚫️⚫️⚪️ - 🟩 GPS" + (dataManager.modeExpert ? " (\(round(locationAccuracy)) m)" : "")
            } else {
                return "⚫️⚫️⚫️⚫️⚫️ - 🟩 GPS" + (dataManager.modeExpert ? " (\(round(locationAccuracy)) m)" : "")
            }
        }]
        } else {
            net.elements += [UIElementLabel(id: "connected3", text: "") { () -> String in
                
                let locationAccuracy = self.locationManager.location?.horizontalAccuracy ?? -1
                print("GPS : \(locationAccuracy)")
                if locationAccuracy < 0 {
                    return "⚪️⚪️⚪️⚪️⚪️ - ⚫️ GPS" + (dataManager.modeExpert ? " (\(round(locationAccuracy)) m)" : "")
                } else if locationAccuracy > 600 {
                    return "⚫️⚪️⚪️⚪️⚪️ - 🔴 GPS" + (dataManager.modeExpert ? " (\(round(locationAccuracy)) m)" : "")
                } else if locationAccuracy > 300 {
                    return "⚫️⚫️⚪️⚪️⚪️ - 🔶 GPS" + (dataManager.modeExpert ? " (\(round(locationAccuracy)) m)" : "")
                } else if locationAccuracy > 150 {
                    return "⚫️⚫️⚫️⚪️⚪️ - ⚠️ GPS" + (dataManager.modeExpert ? " (\(round(locationAccuracy)) m)" : "")
                } else if locationAccuracy > 50 {
                    return "⚫️⚫️⚫️⚫️⚪️ - ✅ GPS" + (dataManager.modeExpert ? " (\(round(locationAccuracy)) m)" : "")
                } else {
                    return "⚫️⚫️⚫️⚫️⚫️ - ✅ GPS" + (dataManager.modeExpert ? " (\(round(locationAccuracy)) m)" : "")
                }
            }]
        }
        
        let wifistat = DataManager.showWifiConnected()
        
        if wifistat != "null" {
            net.elements += [
                UIElementLabel(id: "wifi", text: dataManager.modeRadin ? "Wi-Fi radin : \(wifistat)" : "wifi_status".localized().format([wifistat]))
            ]
        }
        if dataManager.modeExpert {
            net.elements += [
                UIElementLabel(id: "generation", text: generation)
            ]
        }
        
        if !dataManager.disableFMobileCore || dataManager.modeExpert || (dataManager.connectedMCC == dataManager.targetMCC && dataManager.connectedMNC == dataManager.targetMNC){
            net.elements += [
                UIElementButton(id: "", text: "set_no_network".localized()) { (_) in
                    if CLLocationManager.authorizationStatus() == .authorizedAlways {
                        let locationManager = CLLocationManager()
                        let latitude = locationManager.location?.coordinate.latitude ?? 0
                        let longitude = locationManager.location?.coordinate.longitude ?? 0
                        
                        let context: NSManagedObjectContext
                        if #available(iOS 10.0, *) {
                            context = RoamingManager.persistentContainer.viewContext
                        } else {
                            // Fallback on earlier versions
                            context = RoamingManager.managedObjectContext
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
                                
                                let alert = UIAlertController(title: "no_network_zone_saved".localized(), message: "no_network_zone_saved_description".localized(), preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: nil))
                                UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
                            } catch {
                                print("Failed saving")
                            }
                        })
                    }
                }
            ]
        }
        
        net.elements += [UIElementSwitch(id: "perfmode", text: lb, d: false)]
        
//        if dataManager.targetMCC == "208" && dataManager.targetMNC == "15" && dataManager.setupDone {
//            net.elements += [UIElementSwitch(id: "statisticsAgreement", text: "statistics_agreement".localized(), d: false)]
//        }
        
        // Section préférences
        let pref = Section(name: prefsnet, elements: [], footer: wififoo)
        
        if dataManager.roam5G || dataManager.modeExpert {
            pref.elements += [UIElementSwitch(id: "allow015G", text: iti5G, d: true)]
        }
        if dataManager.roamLTE || dataManager.modeExpert {
            pref.elements += [UIElementSwitch(id: "allow014G", text: iti4G, d: true)]
        }
        
        pref.elements += [UIElementSwitch(id: "allow013G", text: iti3G, d: true),
                          UIElementSwitch(id: "allow012G", text: iti2G, d: true)]
        
        if dataManager.modeExpert {
            pref.elements += [UIElementSwitch(id: "verifyonwifi", text: wifiaut, d: false)]
        }
        
        // Section stats
        let stats = Section(name: prefsstats, elements: [
            UIElementSwitch(id: "coveragemap", text: "coveragemap_switch".localized(), d: false),
            UIElementSwitch(id: "coverageLowData", text: "coveragemapLowData_switch".localized(), d: false)
        ])
        
        // Section background
        let back = Section(name: bkg, elements: [
            UIElementSwitch(id: "stopverification", text: stvr, d: false)], footer: sat)
        
        if dataManager.modeExpert || (dataManager.targetMCC == "208" && dataManager.targetMNC == "15" && dataManager.setupDone) {
            back.elements += [
                UIElementSwitch(id: "femto", text: fmt, d: true),
                UIElementSwitch(id: "femtoLOWDATA", text: eco, d: false)
            ]
        }
        
        let femto = Section(name: "", elements: [])
        
        if !dataManager.disableFMobileCore || dataManager.modeExpert || (dataManager.connectedMCC == dataManager.targetMCC && dataManager.connectedMNC == dataManager.targetMNC){
            femto.elements += [
                UIElementButton(id: "", text: zns) { (_) in
                    self.resetAllRecords(in: "Locations")
                }
            ]
        }
        
        if dataManager.setupDone{
            femto.elements += [
                UIElementButton(id: "", text: "reset_countries_included".localized()) { (_) in
                    self.resetCountriesIncluded(dataManager)
                }
            ]
        }
        
        // Section country detection
        let cnt = Section(name: nland, elements: [
            UIElementSwitch(id: "allowCountryDetection", text: land, d: true)
        ], footer: fland)
        
        // Section conso
        let conso = Section(name: cso, elements: [])
        
        
        for service in dataManager.carrierServices {
            if service.2 == "copy_callcode" {
                conso.elements += [
                    UIElementButton(id: "", text: service.2.localized()) { (_) in

                       let ussdCode = "tel://\(service.1)"
                       let app = UIApplication.shared
                       
                       if let encoded = ussdCode.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                           let u = encoded//"tel://\(encoded)"
                           if let url = URL(string:u) {
                               if app.canOpenURL(url) {
                                if #available(iOS 10.0, *) {
                                    app.open(url, options: [:], completionHandler: { (_) in })
                                } else {
                                    // Fallback on earlier versions
                                    app.openURL(url)
                                }
                               }
                           }
                       }
                }]
            } else if service.2 == "open_official_app" || service.2 == "call_service" || service.2 == "call_conso" {
                conso.elements += [
                    UIElementButton(id: "", text: service.2.localized().format([service.0])) { (_) in
                    guard let link = URL(string: service.1) else { return }
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(link)
                        } else {
                            UIApplication.shared.openURL(link)
                        }
                    }
                ]
            } else if service.2 == "open" {
                conso.elements += [
                    UIElementButton(id: "", text: service.2.localized().format([service.0])) { (_) in
                    guard let link = URL(string: service.1) else { return }
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(link)
                        } else {
                            UIApplication.shared.openURL(link)
                        }
                    }
                ]
            } else if service.2 == "copy" {
                conso.elements += [
                    UIElementButton(id: "", text: service.2.localized().format([service.0])) { (_) in
                
                        let ussdCode = "tel://\(service.1)"
                        let app = UIApplication.shared
                        
                        if let encoded = ussdCode.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                            let u = encoded//"tel://\(encoded)"
                            if let url = URL(string:u) {
                                if app.canOpenURL(url) {
                                    if #available(iOS 10.0, *) {
                                        app.open(url, options: [:], completionHandler: { (_) in })
                                    } else {
                                        app.openURL(url)
                                    }
                                }
                            }
                        }
                    }]
            }
        }
        
        // Section aide
        let aide = Section(name: help, elements: [
            UIElementButton(id: "", text: cont) { (_) in
                let alert = UIAlertController(title: "contact_title".localized(), message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Mail", style: .default) { (_) in
                    guard let mailto = URL(string: "mailto:contact@groupe-minaste.org") else { return }
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(mailto)
                    } else {
                        UIApplication.shared.openURL(mailto)
                    }
                })
                alert.addAction(UIAlertAction(title: "Discord", style: .default) { (_) in
                    guard let discord = URL(string: "https://www.craftsearch.net/discord") else { return }
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(discord)
                    } else {
                        UIApplication.shared.openURL(discord)
                    }
                })
                alert.addAction(UIAlertAction(title: "Twitter - Michaël Nass", style: .default) { (_) in
                    guard let twitter = URL(string: "https://www.twitter.com/PlugNTweet") else { return }
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(twitter)
                    } else {
                        UIApplication.shared.openURL(twitter)
                    }
                })
                alert.addAction(UIAlertAction(title: "Twitter - FMobile", style: .default) { (_) in
                    guard let twitter = URL(string: "https://www.twitter.com/FMobileApp") else { return }
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(twitter)
                    } else {
                        UIApplication.shared.openURL(twitter)
                    }
                })
                alert.addAction(UIAlertAction(title: "Twitter - Groupe MINASTE", style: .default) { (_) in
                    guard let twitter = URL(string: "https://www.twitter.com/Groupe_MINASTE") else { return }
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(twitter)
                    } else {
                        UIApplication.shared.openURL(twitter)
                    }
                })
                alert.addAction(UIAlertAction(title: "Extopy", style: .default) { (_) in
                    UIApplication.shared.windows.first?.rootViewController?.present(UIAlertController(title: "extopy_not_available_title".localized(), message: "extopy_not_available_description".localized(), preferredStyle: .alert), animated: true, completion: nil)
                    self.delay(3){
                        UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
                    }
                })
                alert.addAction(UIAlertAction(title: "ok".localized(), style: .cancel, handler: nil))
                UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
            },
            UIElementButton(id: "", text: "video_tutorial".localized()) { (_) in
                guard let mailto = URL(string: "https://youtu.be/GfI5JLqyqiY") else { return }
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(mailto)
                } else {
                    UIApplication.shared.openURL(mailto)
                }
            },
            UIElementButton(id: "", text: "install_shortcuts".localized()) { (_) in
                guard let mailto = URL(string: "http://raccourcis.ios.free.fr/fmobile/") else { return }
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(mailto)
                } else {
                    UIApplication.shared.openURL(mailto)
                }
            }
        ])
        
        if dataManager.modeExpert {
            aide.elements += [
                UIElementButton(id: "", text: "engine_generation_signification".localized()) { (_) in
                    let text = "engine_explaination".localized()
                    let alert = UIAlertController(title: "engine_generation_title".localized(), message: text, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "explaination_understood".localized(), style: .default, handler: nil))
                    UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
                }
            ]
        }
        
        // Section avancé
        let avance = Section(name: "advanced".localized(), elements: [
            UIElementButton(id: "", text: "reset_network".localized()) { (_) in
                if #available(iOS 12.0, *) {
                guard let link = DataManager.getShortcutURL() else { return }
                UIApplication.shared.open(link)
                } else {
                    self.oldios()
                }
            },
            UIElementButton(id: "", text: "perform_diagnostic".localized()) { (button) in
                self.diagPrivacy(source: button)
            },
            UIElementButton(id: "", text: "reset_first_start".localized()) { (_) in
                dataManager.datas.set(false, forKey: "didFinishFirstStart")
                dataManager.datas.set(false, forKey: "warningApproved")
                dataManager.datas.set(false, forKey: "setupDone")
                dataManager.datas.set(false, forKey: "coveragemap")
                dataManager.datas.set(false, forKey: "coveragemap_noalert")
                dataManager.datas.set(false, forKey: "locationAuthorizationAvoided")
                dataManager.datas.set(false, forKey: "locationAuthorizationBadsetup")
                dataManager.datas.synchronize()
                self.updateSetup(dataManager, false)
                self.loadUI()
                self.refreshSections()
                if let tabBar = self.tabBarController as? TabBarController {
                   tabBar.warning()
                }
            },
            UIElementSwitch(id: "dispInfoNotif", text: "disp_notifications".localized(), d: false),
            UIElementSwitch(id: "modeExpert", text: "expert_mode".localized(), d: false),
        ], footer: Locale.current.languageCode == "fr" ? "Le mode Radin est un clin d'oeil à Xavier Radiniel (@XRadiniel sur l'oiseau bleu), un compte parodique autour de la galaxie Niel. Il modifie l'interface de l'application mais n'apporte aucune fonctionalité supplémentaire." : "\n\n")
        
        if #available(iOS 13.0, *) {} else {
            avance.elements += [UIElementSwitch(id: "isDarkMode", text: "dark_mode".localized(), d: true)]
        }
        
        if Locale.current.languageCode == "fr" {
            avance.elements += [UIElementSwitch(id: "modeRadin", text: "Mode Radin", d: false)]
        }
        
        if dataManager.modeExpert {
            avance.elements += [
                UIElementButton(id: "", text: "copy_field_test".localized()) { (_) in
                    UIPasteboard.general.string = "*3001#12345#*"
                    
                    let alert = UIAlertController(title: "field_test_copied_confirmation".localized(), message: nil, preferredStyle: UIAlertController.Style.alert)
                    
                    UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
                    
                    self.delay(1){
                        UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
                    }
                },
                UIElementButton(id: "", text: "select_url".localized()) { (_) in
                    self.seturl()
                }
            ]
        }
        
        // Section à propos
        let plus = Section(name: "", elements: [
            UIElementButton(id: "", text: "about".localized()) { (_) in
                let text = "about_description".localized()
                let alert = UIAlertController(title: "about".localized(), message: text, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: nil))
                UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
            },
            UIElementButton(id: "", text: "donate".localized()) { (_) in
                self.openDonateViewController()
            }
        ], footer: "donate_description".localized())
//        ], footer: "")
        
//        plus.elements += [UIElementApp(name: T##String, desc: T##String, icon: T##UIImage, completionHandler: T##(UIButton) -> Void)]
        
        sections += [net]
        
        if !dataManager.disableFMobileCore || dataManager.modeExpert {
            sections += [pref]
        }
        
        sections += [stats, back, cnt, femto]
        // sections += [back, cnt, femto]
        
        if !conso.elements.isEmpty {
            sections += [conso]
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
    
    func openDonateViewController() {
        // Create the view controller
        let controller: DonateViewController
        
        if #available(iOS 13.0, *) {
            controller = DonateViewController()
        } else {
            controller = DonateViewControllerExtension(cellClass: DonateCellExtension.self)
        }
        
        // Customize view title, header and footer (optional)
        controller.title = "donate".localized()
        controller.header = "select_donation".localized()
        controller.footer = "donate_description".localized()
        
        // Add a delegate to get notified when a donation ends
        controller.delegate = self
        
        // Add donations
        controller.add(identifier: "fr.plugn.fmobile.donation01")
        controller.add(identifier: "fr.plugn.fmobile.donation02")
        controller.add(identifier: "fr.plugn.fmobile.donation03")
        
        // ... (add as many donations as you want)
        
        // And open your view controller: (two ways)
        
        // 1. In your navigation controller
        navigationController?.pushViewController(controller, animated: true)
        
        // 2. In a modal
        //present(UINavigationController(rootViewController: controller), animated: true, completion: nil)
    }
    
    func donateViewController(_ controller: DonateViewController, didDonationSucceed donation: Donation) {
        // Handle when the donation succeed
        print("Donation successed!")
        
        let text = "donate_thank_you_description".localized()
        let alert = UIAlertController(title: "donate_thank_you".localized(), message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "close".localized(), style: .default, handler: nil))
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
        
    }
    
    func donateViewController(_ controller: DonateViewController, didDonationFailed donation: Donation) {
        // Handle when the donation failed
        print("Donation cancelled.")
        
        let text = "donate_aborted_description".localized()
        let alert = UIAlertController(title: "donate_aborted".localized(), message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "close".localized(), style: .default, handler: nil))
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
        
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
            if #available(iOS 13.0, *) {
                return (tableView.dequeueReusableCell(withIdentifier: "labelCell", for: indexPath) as! LabelTableViewCell).with(text: e.text)
            } else {
                // Fallback on earlier versions
                return (tableView.dequeueReusableCell(withIdentifier: "labelCell", for: indexPath) as! LabelTableViewCell).with(text: e.text, darkMode: isDarkMode())
            }
        } else if let e = element as? UIElementSwitch {
            let datas = UserDefaults(suiteName: "group.fr.plugn.fmobile") ?? Foundation.UserDefaults.standard
            var enable = e.d
            
            if let value = datas.value(forKey: e.id) as? Bool {
                enable = value
            }
            
            if #available(iOS 13.0, *) {
                return (tableView.dequeueReusableCell(withIdentifier: "switchCell", for: indexPath) as! SwitchTableViewCell).with(id: e.id, controller: self, text: e.text, enabled: enable)
            } else {
                // Fallback on earlier versions
                return (tableView.dequeueReusableCell(withIdentifier: "switchCell", for: indexPath) as! SwitchTableViewCell).with(id: e.id, controller: self, text: e.text, enabled: enable, darkMode: isDarkMode())
            }
        } else if let e = element as? UIElementButton {
            if #available(iOS 13.0, *) {
                return (tableView.dequeueReusableCell(withIdentifier: "buttonCell", for: indexPath) as! ButtonTableViewCell).with(title: e.text, alignment: .left, handler: e.handler)
            } else {
                // Fallback on earlier versions
                return (tableView.dequeueReusableCell(withIdentifier: "buttonCell", for: indexPath) as! ButtonTableViewCell).with(title: e.text, alignment: .left, handler: e.handler, darkMode: isDarkMode())
            }
        }  else if let e = element as? UIElementApp {
                   if #available(iOS 13.0, *) {
                       return (tableView.dequeueReusableCell(withIdentifier: "appCell", for: indexPath) as! AppTableViewCell).with(name: e.name, desc: e.desc, icon: e.icon, handler: e.handler)
                   } else {
                       // Fallback on earlier versions
                       return (tableView.dequeueReusableCell(withIdentifier: "appCell", for: indexPath) as! AppTableViewCell).with(name: e.name, desc: e.desc, icon: e.icon, handler: e.handler, darkMode: isDarkMode())
                   }
               }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "labelCell", for: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let element = sections[indexPath.section].elements[indexPath.row]
        
        if let e = element as? UIElementButton {
            let cell = tableView.cellForRow(at: indexPath as IndexPath) as? ButtonTableViewCell
            e.handler(cell?.button ?? UIButton())
        }
        
        if let e = element as? UIElementApp {
            let cell = tableView.cellForRow(at: indexPath as IndexPath) as? AppTableViewCell
            e.handler(cell?.button ?? UIButton())
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let element = sections[indexPath.section].elements[indexPath.row]

        if element is UIElementApp {
            return 85
        }
        return 48
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if #available(iOS 13.0, *) {} else {
            let header = view as! UITableViewHeaderFooterView
            
            if isDarkMode() {
                header.textLabel?.textColor = CustomColor.darkText2
            } else {
                header.textLabel?.textColor = CustomColor.lightText2
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if #available(iOS 13.0, *) {} else {
            let footer = view as! UITableViewHeaderFooterView
            
            if isDarkMode() {
                footer.textLabel?.textColor = CustomColor.darkText2
            } else {
                footer.textLabel?.textColor = CustomColor.lightText2
            }
        }
        
    }

}
