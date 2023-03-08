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
import GroupeMINASTE

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
    
    func addCountry(country: String, dataManager: DataManager = DataManager(), service: FMNetwork) {
        let alert = UIAlertController(title: "new_country".localized(), message: "new_country_description".localized().format([country]), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "included_voice".localized(), style: .default) { (_) in
            dataManager.addCountryIncluded(country: country, list: 0, service: service)
        })
        alert.addAction(UIAlertAction(title: "included_internet".localized(), style: .default) { (_) in
            dataManager.addCountryIncluded(country: country, list: 1, service: service)
        })
        alert.addAction(UIAlertAction(title: "included_all".localized(), style: .default) { (_) in
            dataManager.addCountryIncluded(country: country, list: 2, service: service)
        })
        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil))
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func resetAllRecords(in entity : String) {
        let context: NSManagedObjectContext
        if #available(iOS 10.0, *) {
            context = PermanentStorage.persistentContainer.viewContext
        } else {
            // Fallback on earlier versions
            context = PermanentStorage.managedObjectContext
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
    
    func resetCountriesIncluded(_ dataManager: DataManager = DataManager(), service: FMNetwork) {
            dataManager.resetCountryIncluded(service: service)
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
                    datas.set("http://raccourcis.ios.free.fr/fmobile/speedtest/nrcheck.rnd", forKey: "URL")
                    datas.set("http://raccourcis.ios.free.fr/fmobile/speedtest/speedtest.rnd", forKey: "URLST")
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
                    datas.set("http://raccourcis.ios.free.fr/fmobile/speedtest/nrcheck.rnd", forKey: "URL")
                    datas.set("http://raccourcis.ios.free.fr/fmobile/speedtest/speedtest.rnd", forKey: "URLST")
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
            
            
            datas.set(alertController.textFields?[0].text?.lowercased() ?? "http://raccourcis.ios.free.fr/fmobile/speedtest/nrcheck.rnd", forKey: "URL")
            datas.set(alertController.textFields?[1].text?.lowercased() ?? "http://raccourcis.ios.free.fr/fmobile/speedtest/speedtest.rnd", forKey: "URLST")
            datas.synchronize()
        }
        
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "cancel".localized(), style: .cancel) { (_) in
            return
        }
        
        let defaultAction = UIAlertAction(title: "set_default_url".localized(), style: .default) { (_) in
            datas.set("http://raccourcis.ios.free.fr/fmobile/speedtest/nrcheck.rnd", forKey: "URL")
            datas.set("http://raccourcis.ios.free.fr/fmobile/speedtest/speedtest.rnd", forKey: "URLST")
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
    
    func manualSetup(_ dataManager: DataManager = DataManager(), service: FMNetwork) {
        let alertController = UIAlertController(title: "setup_title".localized(), message: "setup_description".localized(), preferredStyle: .alert)
        
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "save".localized(), style: .default) { (_) in
            dataManager.datas.set((alertController.textFields?[0].text! as NSString?)?.doubleValue ?? 0.768, forKey: service.card.active ? "STMS" : "eSTMS")
            dataManager.datas.set(alertController.textFields?[1].text?.uppercased() ?? "null", forKey: service.card.active ? "HP" : "eHP")
            dataManager.datas.set(alertController.textFields?[2].text?.uppercased() ?? "null", forKey: service.card.active ? "NRP" : "eNRP")
            dataManager.datas.set(service.card.carrier.mobileCountryCode ?? "---", forKey: service.card.active ? "MCC" : "eMCC")
            dataManager.datas.set(service.card.carrier.mobileNetworkCode ?? "--", forKey: service.card.active ? "MNC" : "eMNC")
            dataManager.datas.set(service.card.carrier.isoCountryCode?.uppercased() ?? "--", forKey: service.card.active ? "LAND" : "eLAND")
            dataManager.datas.set(alertController.textFields?[3].text ?? "null", forKey: service.card.active ? "ITINAME" : "eITINAME")
            dataManager.datas.set(alertController.textFields?[4].text ?? "null", forKey: service.card.active ? "HOMENAME" : "eHOMENAME")
            dataManager.datas.set(alertController.textFields?[5].text ?? "null", forKey: service.card.active ? "ITIMNC" : "eITIMNC")
            dataManager.datas.set(alertController.textFields?[6].text?.lowercased() ?? "null", forKey: service.card.active ? "NRFEMTO" : "eNRFEMTO")
            dataManager.datas.set(alertController.textFields?[7].text?.lowercased() ?? "null", forKey: service.card.active ? "OUT2G" : "eOUT2G")
            dataManager.datas.set([String](), forKey: service.card.active ? "countriesData" : "ecountriesData")
            dataManager.datas.set([String](), forKey: service.card.active ? "countriesVoice" : "ecountriesVoice")
            dataManager.datas.set([String](), forKey: service.card.active ? "countriesVData" : "ecountriesVData")
            dataManager.datas.set(true, forKey: service.card.active ? "setupDone" : "esetupDone")
            dataManager.datas.set(false, forKey: service.card.active ? "minimalSetup" : "eminimalSetup")
            dataManager.datas.set(false, forKey: service.card.active ? "disableFMobileCore" : "edisableFMobileCore")
            dataManager.datas.set(false, forKey: "isSettingUp")
            dataManager.datas.synchronize()
        }
        
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "cancel".localized(), style: .cancel) { (_) in
            dataManager.datas.set(false, forKey: service.card.active ? "setupDone" : "esetupDone")
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
        
        for service in dataManager.simtrays {
            // On fetch la configuration depuis le serveur
            CarrierConfiguration.fetch(forMCC: service.card.carrier.mobileCountryCode ?? "---", andMNC: service.card.carrier.mobileNetworkCode ?? "--") { configuration in
                // On vérifie si des valeurs sont trouvés
                if let configuration = configuration {
                    // On enregistre les valeurs issues du serveur
                    dataManager.datas.set(configuration.stms, forKey: service.card.type == .sim ? "STMS" : "eSTMS")
                    dataManager.datas.set(configuration.hp, forKey: service.card.type == .sim ? "HP" : "eHP")
                    dataManager.datas.set(configuration.nrp, forKey: service.card.type == .sim ? "NRP" : "eNRP")
                    dataManager.datas.set(configuration.mcc, forKey: service.card.type == .sim ? "MCC" : "eMCC")
                    dataManager.datas.set(configuration.mnc, forKey: service.card.type == .sim ? "MNC" : "eMNC")
                    dataManager.datas.set(configuration.land, forKey: service.card.type == .sim ? "LAND" : "eLAND")
                    dataManager.datas.set(configuration.itiname, forKey: service.card.type == .sim ? "ITINAME" : "eITINAME")
                    dataManager.datas.set(configuration.homename, forKey: service.card.type == .sim ? "HOMENAME" : "eHOMENAME")
                    dataManager.datas.set(configuration.itimnc, forKey: service.card.type == .sim ? "ITIMNC" : "eITIMNC")
                    dataManager.datas.set(configuration.nrfemto, forKey: service.card.type == .sim ? "NRFEMTO" : "eNRFEMTO")
                    dataManager.datas.set(configuration.out2G, forKey: service.card.type == .sim ? "OUT2G" : "eOUT2G")
                    dataManager.datas.set(configuration.setupDone, forKey: service.card.type == .sim ? "setupDone" : "esetupDone")
                    dataManager.datas.set(configuration.minimalSetup, forKey: service.card.type == .sim ? "minimalSetup" : "eminimalSetup")
                    dataManager.datas.set(configuration.disableFMobileCore, forKey: service.card.type == .sim ? "disableFMobileCore" : "edisableFMobileCore")
                    dataManager.datas.set(configuration.countriesData, forKey: service.card.type == .sim ? "countriesData" : "ecountriesData")
                    dataManager.datas.set(configuration.countriesVoice, forKey: service.card.type == .sim ? "countriesVoice" : "ecountriesVoice")
                    dataManager.datas.set(configuration.countriesVData, forKey: service.card.type == .sim ? "countriesVData" : "ecountriesVData")
                    dataManager.datas.set(configuration.carrierServices, forKey: service.card.type == .sim ? "carrierServices" : "ecarrierServices")
                    dataManager.datas.set(configuration.roamLTE, forKey: service.card.type == .sim ? "roamLTE" : "eroamLTE")
                    dataManager.datas.set(configuration.roam5G, forKey: service.card.type == .sim ? "roam5G" : "eroam5G")
                    dataManager.datas.set(false, forKey: "isSettingUp")
                    dataManager.datas.synchronize()
                    // Fin de la configuration depuis le serveur
                } else if !service.card.setupDone && wasCalled {
                    // Aucune valeur trouvée (non existante ou non connecté à internet)
                    let alertController = UIAlertController(title: "choose_setup".localized(), message: "choose_setup_description".localized(), preferredStyle: .alert)
                        
                    let confirmAction = UIAlertAction(title: "use_minimal_setup".localized(), style: .default) { (_) in
                        dataManager.datas.set(service.card.carrier.mobileCountryCode ?? "---", forKey: service.card.type == .sim ? "MCC" : "eMCC")
                        dataManager.datas.set(service.card.carrier.mobileNetworkCode ?? "--", forKey: service.card.type == .sim ? "MNC" : "eMNC")
                        dataManager.datas.set(service.card.carrier.isoCountryCode ?? "--", forKey: service.card.type == .sim ? "LAND" : "eLAND")
                        dataManager.datas.set(service.card.name, forKey: service.card.type == .sim ? "HOMENAME" : "eHOMENAME")
                        dataManager.datas.set(service.card.name, forKey: service.card.type == .sim ? "ITINAME" : "eITINAME")
                        dataManager.datas.set(99, forKey: service.card.type == .sim ? "ITIMNC" : "eITIMNC")
                        dataManager.datas.set([String](), forKey: service.card.type == .sim ? "countriesData" : "ecountriesData")
                        dataManager.datas.set([String](), forKey: service.card.type == .sim ? "countriesVoice" : "ecountriesVoice")
                        dataManager.datas.set([String](), forKey: service.card.type == .sim ? "countriesVData" : "ecountriesVData")
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
                            if service.card.eligibleminimalsetup {
                                dataManager.datas.set(true, forKey: service.card.type == .sim ? "minimalSetup" : "eminimalSetup")
                                dataManager.datas.set(false, forKey: service.card.type == .sim ? "disableFMobileCore" : "edisableFMobileCore")
                                dataManager.datas.set(true, forKey: service.card.type == .sim ? "setupDone" : "esetupDone")
                                dataManager.datas.set(false, forKey: "isSettingUp")
                                dataManager.datas.synchronize()
                            } else {
                                let alertController2 = UIAlertController(title: "compatibility_issues".localized(), message: "compatibility_error_message".localized(), preferredStyle: .alert)
                                let confirmAction2 = UIAlertAction(title: "force_minimal_setup".localized(), style: .destructive) { (_) in
                                    dataManager.datas.set(true, forKey: service.card.type == .sim ? "minimalSetup" : "eminimalSetup")
                                    dataManager.datas.set(false, forKey: service.card.type == .sim ? "disableFMobileCore" : "edisableFMobileCore")
                                    dataManager.datas.set(true, forKey: service.card.type == .sim ? "setupDone" : "esetupDone")
                                    dataManager.datas.set(false, forKey: "isSettingUp")
                                    dataManager.datas.synchronize()
                                }
                                let cancelAction2 = UIAlertAction(title: "run_standard_setup".localized(), style: .default) { (_) in
                                    self.manualSetup(service: service)
                                }
                                
                                alertController2.addAction(confirmAction2)
                                alertController2.addAction(cancelAction2)
                                
                                self.present(alertController2, animated: true, completion: nil)
                            }
                            
                        }
                    }
                    
                    let cancelAction = UIAlertAction(title: "use_standard_setup".localized(), style: .default) { (_) in
                        self.manualSetup(service: service)
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
             let alert = UIAlertController(title: "Action requise - Migration depuis FMobile 1.3", message: "Bienvenue sur FMobile 5. Nous avons fait beaucoup de modifications pour iOS 13. Le raccourci RRFM ne sert plus dans cette version, car il a été remplacé par le raccourci ANIRC. Un tout nouveau tutoriel vidéo est également livré dans cette mise à jour. Pour vous faciliter la tâche, nous avons réinitialisé le statut du premier démarrage afin de vous permettre de visionner le nouveau tutoriel d'installation et d'installer plus rapidement le nouveau raccourci ANIRC (et éventuellement mettre à jour le raccourci CFM pour iOS 13). Il est vivement recommandé de regarder le nouveau tutoriel d'installation, même si vous êtes complètement à l'aise avec les nouveaux outils Automatisations dans Raccourcis.", preferredStyle: .alert)
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
            if version < 174 && version != 0 {
                let alert = UIAlertController(title: "Nouveau raccourci ANIRC v4", message: "Un nouveau raccourci ANIRC v4 est disponible et corrige de nombreux bugs et augmente l'efficacité de celui-ci, notamment sur iOS 14. Veuillez le mettre à jour maintenant.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Télécharger ANIRC", style: .default) { (_) in
                    guard let link = URL(string: "http://raccourcis.ios.free.fr/fmobile") else { return }
                    UIApplication.shared.open(link)
                })
                present(alert, animated: true, completion: nil)
            }
        }
        
        // Nouvelle technologie 5G
        if version < 177 && version != 0 {
            let alert = UIAlertController(title: "La technologie évolue, FMobile aussi.", message: "FMobile est désormais officiellement compatible avec la 5G sur iOS 14.1 ! La carte de couverture mondiale a été mise à jour pour l'accueillir. Si vous aviez configuré l'itinérance 5G précédemment, vos réglages sont désormais actifs. À très vite sur le réseau mobile le plus avancé au monde ! Nous sommes prêts.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Vroooooom !", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
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
        
        if ((dataManager.sim.card.active && !dataManager.sim.card.setupDone) || (dataManager.esim.card.active && !dataManager.esim.card.setupDone)) && DataManager.isConnectedToNetwork() {
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
        
        self.loadUI(dataManager)
        self.refreshSections()
        
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
        let dataManager = DataManager()
        let mcc = dataManager.current.card.carrier.mobileCountryCode ?? "---"
        let mnc = dataManager.current.card.carrier.mobileNetworkCode ?? "--"

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
        
        let dataManager = DataManager()
        
        RoamingManager.engine(g3engine: false, service: dataManager.sim) { resultg2 in
        RoamingManager.engine(g3engine: true, service: dataManager.sim) { resultg3 in

        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
        let buildVersion = Int(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0") ?? 0
        // Strings de l'UI
        
        var generation = ""
            if dataManager.current.network.mcc == "---" && !dataManager.current.card.nrdec && UIDevice.current.userInterfaceIdiom == .pad {
            generation = "FMobile b\(buildVersion) - Génération A1"
        } else if dataManager.current.network.mcc == "---" && UIDevice.current.userInterfaceIdiom == .pad {
            generation = "FMobile b\(buildVersion) - Génération 1"
        } else if !dataManager.current.card.nrdec || !dataManager.current.card.setupDone {
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
            
            let locationAccuracy = self.locationManager.location?.horizontalAccuracy ?? -1

            var str = "Fichier de diagnostic FMobile \(appVersion)\n\nModèle : \(UIDevice.current.modelName)\nVersion de l'OS : \(UIDevice.current.systemVersion)\nMoteur : \(generation)\nRésultat du moteur G2 : \(resultg2)\nRésultat du moteur G3 : \(resultg3)\nDernier completion G3 : \(dataManager.g3lastcompletion)\nRésultat du moteur G3 international : \(dataManager.zoneCheck(service: dataManager.sim))\nDate : \(dispDate)\n\nConfiguration :\nmodeRadin : \(dataManager.modeRadin)\nallow013G : \(dataManager.allow013G)\nallow012G : \(dataManager.allow012G)\nallow014G : \(dataManager.allow014G)\nallow015G : \(dataManager.allow015G)\nfemtoLOWDATA : \(dataManager.femtoLOWDATA)\nfemto : \(dataManager.femto)\nverifyonwifi : \(dataManager.verifyonwifi)\nstopverification : \(dataManager.stopverification)\ntimecode : \(dataManager.timecode)\ntimecode G3: \(dataManager.g3timecode)\nlastnet : \(dataManager.lastnet)\ncount : \(dataManager.count)\nwasEnabled : \(dataManager.wasEnabled)\nperfmode : \(dataManager.perfmode)\ndidChangeSettings : \(dataManager.didChangeSettings)\nntimer : \(dataManager.ntimer)\ndispInfoNotif : \(dataManager.dispInfoNotif)\nallowCountryDetection : \(dataManager.allowCountryDetection)\ntimeLastCountry : \(dataManager.timeLastCountry)\nlastCountry : \(dataManager.lastCountry)\n\n"
            
            for service in dataManager.simtrays {
                str += "Détail du forfait :\nDestinations incluses (ALL) : \(service.card.countriesVData)\nDestinations incluses (VOIX) : \(service.card.countriesVoice)\nDestinations incluses (DATA) : \(service.card.countriesData)\nOptions incluses (ALL) : \(service.card.includedVData)\nOptions incluses (VOIX) : \(service.card.includedVoice)\nOption incluses (DATA) : \(service.card.includedData)\n\nStatut opérateur :\nsimData : \(service.card.data)\ncurrentNetwork : \(service.network.data)\ncarrier: \(service.network.name)\ncarrierNetwork : \(service.network.connected)\ncarrierNetwork2 : \(dataManager.esim.network.connected)\ncarrierName : \(service.network.name)\n\nConfiguration opérateur :\nhp : \(service.card.hp)\nnrp : \(service.card.nrp)\ntargetMCC : \(service.card.mcc)\ntargetMNC : \(service.card.mnc)\nitiMNC : \(service.card.itiMNC)\nnrDEC : \(service.card.nrdec)\nout2G : \(service.card.out2G)\nchasedMNC : \(service.card.chasedMNC)\nconnectedMCC : \(service.network.mcc)\nconnectedMNC : \(service.network.mnc)\nipadMCC : \(service.network.mcc)\nipadMNC : \(service.network.mnc)\nitiName : \(service.card.itiName)\nhomeName : \(service.card.homeName)\nstms : \(service.card.stms)\nCarrier services : \(service.card.carrierServices)\nroamLTE : \(service.card.roamLTE)\nroam5G : \(service.card.roam5G)\nsetupDone : \(service.card.setupDone)\nMinimal setup : \(service.card.minimalSetup)\n\n"
            }
            
            str += "Communications :\nWi-Fi : \(DataManager.isWifiConnected())\nCellulaire : \(DataManager.isConnectedToNetwork())\nMode avion : \(dataManager.airplanemode)\nCommunication en cours : \(DataManager.isOnPhoneCall())\nPrécision de localisation : \(locationAccuracy)"
            
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
    
    func radinCarrierName(mcc: String, mnc: String, carrier: String) -> String {
        if mcc == "208" && mnc == "01" {
            return "Agrume F"
        } else if mcc == "208" && mnc == "10" {
            return "Patoche"
        } else if mcc == "208" && mnc == "15" {
            return "Radin"
        } else if mcc == "208" && mnc == "20" {
            return "Béton"
        } else if mcc == "208" && mnc == "26" {
            return "Redbull"
        }
        return carrier
    }
    
    
    func connected(dataManager: DataManager, sim: FMNetwork, radincarrier: String, radinitiname: String, country: String) -> String {
        
        var timecoder = dataManager.datas.value(forKey: sim.card.type == .esim ? "etimecoder" : "timecoder") as? Date ?? Date()
        var lastnetr = dataManager.datas.value(forKey: sim.card.type == .esim ? "elastnetr" : "lastnetr") as? String ?? "HSDPAO"
        
        
        if #available(iOS 14.1, *), (sim.network.connected == CTRadioAccessTechnologyNR && (dataManager.allow015G || (dataManager.modeExpert ? false : !sim.card.roam5G))) {
            sim.network.connected = dataManager.modeRadin ? "5G radine : \(radincarrier) (\(country))" : dataManager.modeExpert ?
                "\(sim.network.name) 5G (NR) [\(sim.network.mcc) \(sim.network.mnc)] (\(country))" :  "\(sim.network.name) 5G"
            lastnetr = "NR"
            dataManager.datas.set(lastnetr, forKey: sim.card.type == .esim ? "elastnetr" : "lastnetr")
            dataManager.datas.synchronize()
        } else if #available(iOS 14.1, *), sim.network.connected == CTRadioAccessTechnologyNR {
            if sim.network.mcc == sim.card.mcc && sim.network.mnc == sim.card.chasedMNC && !DataManager.isWifiConnected() && sim.card.nrdec {
                    
                    print(abs(timecoder.timeIntervalSinceNow))
                    
                    if abs(timecoder.timeIntervalSinceNow) < 10*60 && lastnetr == "NRO" {
                        DispatchQueue.main.async {
                            sim.network.connected = dataManager.modeRadin ? "Itinérance Pop radine : \(radinitiname) (\(country))" : dataManager.modeExpert ?
                                "\(sim.card.itiName) 5G (NR) [\(sim.network.mcc) \(sim.card.itiMNC)] (\(country))" :  "\(sim.card.itiName) 5G \("itinerance".localized())"
                            self.refreshSections()
                            print("CACHE ORANGE F")
                        }
                    } else if abs(timecoder.timeIntervalSinceNow) < 10*60 && lastnetr == "NRF" {
                        DispatchQueue.main.async {
                            sim.network.connected = dataManager.modeRadin ? "Femto ou mutualisation radine : \(radincarrier) (\(country))" : dataManager.modeExpert ?
                                "\(sim.network.name) 5G (NR) [\(sim.network.mcc) \(sim.network.mnc)] (\(country))" :  "\(sim.network.name) 5G (Femto)"
                            self.refreshSections()
                            print("CACHE FEMTO")
                        }
                    } else {
                        Speedtest().testDownloadSpeedWithTimout(timeout: 5.0, usingURL: dataManager.url) { (speed, _) in
                            DispatchQueue.main.async {
                                if speed ?? 0 < sim.card.stms{
                                    sim.network.connected = dataManager.modeRadin ? "Itinérance Pop radine : \(radinitiname) (\(country))" : dataManager.modeExpert ?
                                        "\(sim.card.itiName) 5G (NR) [\(sim.network.mcc) \(sim.card.itiMNC)] (\(country))" :  "\(sim.card.itiName) 5G \("itinerance".localized())"
                                    lastnetr = "NRO"
                                } else {
                                    sim.network.connected = dataManager.modeRadin ? "Femto ou mutualisation radine : \(radincarrier) (\(country))" : dataManager.modeExpert ?
                                        "\(sim.network.name) 5G (NR) [\(sim.network.mcc) \(sim.network.mnc)] (\(country))" :  "\(sim.network.name) 5G (Femto)"
                                    lastnetr = "NRF"
                                }
                                timecoder = Date()
                                dataManager.datas.set(lastnetr, forKey: sim.card.type == .esim ? "elastnetr" : "lastnetr")
                                dataManager.datas.set(timecoder, forKey: sim.card.type == .esim ? "etimecoder" : "timecoder")
                                dataManager.datas.synchronize()
                                self.refreshSections()
                            }
                        }
                    }
                } else {
                    lastnetr = "NR"
                    dataManager.datas.set(lastnetr, forKey: sim.card.type == .esim ? "elastnetr" : "lastnetr")
                    dataManager.datas.synchronize()
                }
            if sim.network.mcc == sim.card.mcc && sim.network.mnc == sim.card.itiMNC && sim.network.connected == CTRadioAccessTechnologyNR {
                sim.network.connected = dataManager.modeRadin ? "Itinérance Pop radine : \(radinitiname) (\(country))" : dataManager.modeExpert ?
                    "\(sim.card.itiName) 5G (NR) [\(sim.network.mcc) \(sim.card.itiMNC)] (\(country))" : "\(sim.card.itiName) 5G \("itinerance".localized())"
                } else {
                    sim.network.connected = dataManager.modeRadin ? "5G radine : \(radincarrier) (\(country))" : dataManager.modeExpert ?
                        "\(sim.network.name) 5G (NR) [\(sim.network.mcc) \(sim.network.mnc)] (\(country))" :  "\(sim.network.name) 5G"
                }
        } else if #available(iOS 14.1, *), (sim.network.connected == CTRadioAccessTechnologyNRNSA && (dataManager.allow015G || (dataManager.modeExpert ? false : !sim.card.roam5G))) {
            sim.network.connected = dataManager.modeRadin ? "5G radine : \(radincarrier) (\(country))" : dataManager.modeExpert ?
                "\(sim.network.name) 5G (NR NSA) [\(sim.network.mcc) \(sim.network.mnc)] (\(country))" :  "\(sim.network.name) 5G"
            lastnetr = "NRNSA"
            dataManager.datas.set(lastnetr, forKey: sim.card.type == .esim ? "elastnetr" : "lastnetr")
            dataManager.datas.synchronize()
        } else if #available(iOS 14.1, *), sim.network.connected == CTRadioAccessTechnologyNRNSA {
            if sim.network.mcc == sim.card.mcc && sim.network.mnc == sim.card.chasedMNC && !DataManager.isWifiConnected() && sim.card.nrdec {
                    
                    print(abs(timecoder.timeIntervalSinceNow))
                    
                    if abs(timecoder.timeIntervalSinceNow) < 10*60 && lastnetr == "NRNSAO" {
                        DispatchQueue.main.async {
                            sim.network.connected = dataManager.modeRadin ? "Itinérance Pop radine : \(radinitiname) (\(country))" : dataManager.modeExpert ?
                                "\(sim.card.itiName) 5G (NR NSA) [\(sim.network.mcc) \(sim.card.itiMNC)] (\(country))" :  "\(sim.card.itiName) 5G \("itinerance".localized())"
                            self.refreshSections()
                            print("CACHE ORANGE F")
                        }
                    } else if abs(timecoder.timeIntervalSinceNow) < 10*60 && lastnetr == "NRNSAF" {
                        DispatchQueue.main.async {
                            sim.network.connected = dataManager.modeRadin ? "Femto ou mutualisation radine : \(radincarrier) (\(country))" : dataManager.modeExpert ?
                                "\(sim.network.name) 5G (NR NSA) [\(sim.network.mcc) \(sim.network.mnc)] (\(country))" :  "\(sim.network.name) 5G (Femto)"
                            self.refreshSections()
                            print("CACHE FEMTO")
                        }
                    } else {
                        Speedtest().testDownloadSpeedWithTimout(timeout: 5.0, usingURL: dataManager.url) { (speed, _) in
                            DispatchQueue.main.async {
                                if speed ?? 0 < sim.card.stms{
                                    sim.network.connected = dataManager.modeRadin ? "Itinérance Pop radine : \(radinitiname) (\(country))" : dataManager.modeExpert ?
                                        "\(sim.card.itiName) 5G (NR NSA) [\(sim.network.mcc) \(sim.card.itiMNC)] (\(country))" :  "\(sim.card.itiName) 5G \("itinerance".localized())"
                                    lastnetr = "NRNSAO"
                                } else {
                                    sim.network.connected = dataManager.modeRadin ? "Femto ou mutualisation radine : \(radincarrier) (\(country))" : dataManager.modeExpert ?
                                        "\(sim.network.name) 5G (NR NSA) [\(sim.network.mcc) \(sim.network.mnc)] (\(country))" :  "\(sim.network.name) 5G (Femto)"
                                    lastnetr = "NRNSAF"
                                }
                                timecoder = Date()
                                dataManager.datas.set(lastnetr, forKey: sim.card.type == .esim ? "elastnetr" : "lastnetr")
                                dataManager.datas.set(timecoder, forKey: sim.card.type == .esim ? "etimecoder" : "timecoder")
                                dataManager.datas.synchronize()
                                self.refreshSections()
                            }
                        }
                    }
                } else {
                    lastnetr = "NRNSA"
                    dataManager.datas.set(lastnetr, forKey: sim.card.type == .esim ? "elastnetr" : "lastnetr")
                    dataManager.datas.synchronize()
                }
            if sim.network.mcc == sim.card.mcc && sim.network.mnc == sim.card.itiMNC && sim.network.connected == CTRadioAccessTechnologyNRNSA {
                sim.network.connected = dataManager.modeRadin ? "Itinérance Pop radine : \(radinitiname) (\(country))" : dataManager.modeExpert ?
                    "\(sim.card.itiName) 5G (NR NSA) [\(sim.network.mcc) \(sim.card.itiMNC)] (\(country))" : "\(sim.card.itiName) 5G \("itinerance".localized())"
                } else {
                    sim.network.connected = dataManager.modeRadin ? "5G radine : \(radincarrier) (\(country))" : dataManager.modeExpert ?
                        "\(sim.network.name) 5G (NR NSA) [\(sim.network.mcc) \(sim.network.mnc)] (\(country))" :  "\(sim.network.name) 5G"
                }
        } else if (sim.network.connected == CTRadioAccessTechnologyLTE && (dataManager.allow014G || (dataManager.modeExpert ? false : !sim.card.roamLTE))) {
            sim.network.connected = dataManager.modeRadin ? "4G radine : \(radincarrier) (\(country))" : dataManager.modeExpert ?
                "\(sim.network.name) 4G (LTE) [\(sim.network.mcc) \(sim.network.mnc)] (\(country))" :  "\(sim.network.name) 4G"
            lastnetr = "LTE"
            dataManager.datas.set(lastnetr, forKey: sim.card.type == .esim ? "elastnetr" : "lastnetr")
            dataManager.datas.synchronize()
        } else if sim.network.connected == CTRadioAccessTechnologyLTE {
            if sim.network.mcc == sim.card.mcc && sim.network.mnc == sim.card.chasedMNC && !DataManager.isWifiConnected() && sim.card.nrdec {
                    
                    print(abs(timecoder.timeIntervalSinceNow))
                    
                    if abs(timecoder.timeIntervalSinceNow) < 10*60 && lastnetr == "LTEO" {
                        DispatchQueue.main.async {
                            sim.network.connected = dataManager.modeRadin ? "Itinérance Delta S radine : \(radinitiname) (\(country))" : dataManager.modeExpert ?
                                "\(sim.card.itiName) 4G (LTE) [\(sim.network.mcc) \(sim.card.itiMNC)] (\(country))" :  "\(sim.card.itiName) 4G \("itinerance".localized())"
                            self.refreshSections()
                            print("CACHE ORANGE F")
                        }
                    } else if abs(timecoder.timeIntervalSinceNow) < 10*60 && lastnetr == "LTEF" {
                        DispatchQueue.main.async {
                            sim.network.connected = dataManager.modeRadin ? "Femto ou mutualisation radine : \(radincarrier) (\(country))" : dataManager.modeExpert ?
                                "\(sim.network.name) 4G (LTE) [\(sim.network.mcc) \(sim.network.mnc)] (\(country))" :  "\(sim.network.name) 4G (Femto)"
                            self.refreshSections()
                            print("CACHE FEMTO")
                        }
                    } else {
                        Speedtest().testDownloadSpeedWithTimout(timeout: 5.0, usingURL: dataManager.url) { (speed, _) in
                            DispatchQueue.main.async {
                                if speed ?? 0 < sim.card.stms{
                                    sim.network.connected = dataManager.modeRadin ? "Itinérance Delta S radine : \(radinitiname) (\(country))" : dataManager.modeExpert ?
                                        "\(sim.card.itiName) 4G (LTE) [\(sim.network.mcc) \(sim.card.itiMNC)] (\(country))" :  "\(sim.card.itiName) 4G \("itinerance".localized())"
                                    lastnetr = "LTEO"
                                } else {
                                    sim.network.connected = dataManager.modeRadin ? "Femto ou mutualisation radine : \(radincarrier) (\(country))" : dataManager.modeExpert ?
                                        "\(sim.network.name) 4G (LTE) [\(sim.network.mcc) \(sim.network.mnc)] (\(country))" :  "\(sim.network.name) 4G (Femto)"
                                    lastnetr = "LTEF"
                                }
                                timecoder = Date()
                                dataManager.datas.set(lastnetr, forKey: sim.card.type == .esim ? "elastnetr" : "lastnetr")
                                dataManager.datas.set(timecoder, forKey: sim.card.type == .esim ? "etimecoder" : "timecoder")
                                dataManager.datas.synchronize()
                                self.refreshSections()
                            }
                        }
                    }
                } else {
                    lastnetr = "LTE"
                    dataManager.datas.set(lastnetr, forKey: sim.card.type == .esim ? "elastnetr" : "lastnetr")
                    dataManager.datas.synchronize()
                }
            if sim.network.mcc == sim.card.mcc && sim.network.mnc == sim.card.itiMNC && sim.network.connected == CTRadioAccessTechnologyLTE {
                sim.network.connected = dataManager.modeRadin ? "Itinérance Delta S radine : \(radinitiname) (\(country))" : dataManager.modeExpert ?
                    "\(sim.card.itiName) 4G (LTE) [\(sim.network.mcc) \(sim.card.itiMNC)] (\(country))" : "\(sim.card.itiName) 4G \("itinerance".localized())"
                } else {
                    sim.network.connected = dataManager.modeRadin ? "4G radine : \(radincarrier) (\(country))" : dataManager.modeExpert ?
                        "\(sim.network.name) 4G (LTE) [\(sim.network.mcc) \(sim.network.mnc)] (\(country))" :  "\(sim.network.name) 4G"
                }
        } else if sim.network.connected == CTRadioAccessTechnologyWCDMA {
            if sim.network.mcc == sim.card.mcc && sim.network.mnc == sim.card.chasedMNC && !DataManager.isWifiConnected() && sim.network.connected == sim.card.nrp && sim.card.nrdec {
                
                if dataManager.femto {
                    print(abs(timecoder.timeIntervalSinceNow))
                    
                    if abs(timecoder.timeIntervalSinceNow) < 10*60 && lastnetr == "WCDMAO" {
                        DispatchQueue.main.async {
                            sim.network.connected = dataManager.modeRadin ? "Itinérance Delta radine : \(radinitiname) (\(country))" : dataManager.modeExpert ?
                                "\(sim.card.itiName) 3G (WCDMA) [\(sim.network.mcc) \(sim.card.itiMNC)] (\(country))" :  "\(sim.card.itiName) 3G \("itinerance".localized())"
                            self.refreshSections()
                            print("CACHE ORANGE F")
                        }
                    } else if abs(timecoder.timeIntervalSinceNow) < 10*60 && lastnetr == "WCDMAF" {
                        DispatchQueue.main.async {
                            sim.network.connected = dataManager.modeRadin ? "Femto ou mutualisation radine : \(radincarrier) (\(country))" : dataManager.modeExpert ?
                                "\(sim.network.name) 3G (WCDMA) [\(sim.network.mcc) \(sim.network.mnc)] (\(country))" :  "\(sim.network.name) 3G (Femto)"
                            self.refreshSections()
                            print("CACHE FEMTO")
                        }
                    } else {
                        Speedtest().testDownloadSpeedWithTimout(timeout: 5.0, usingURL: dataManager.url) { (speed, _) in
                            DispatchQueue.main.async {
                                if speed ?? 0 < sim.card.stms{
                                    sim.network.connected = dataManager.modeRadin ? "Itinérance Delta radine : \(radinitiname) (\(country))" : dataManager.modeExpert ?
                                        "\(sim.card.itiName) 3G (WCDMA) [\(sim.network.mcc) \(sim.card.itiMNC)] (\(country))" :  "\(sim.card.itiName) 3G \("itinerance".localized())"
                                    lastnetr = "WCDMAO"
                                } else {
                                    sim.network.connected = dataManager.modeRadin ? "Femto ou mutualisation radine : \(radincarrier) (\(country))" : dataManager.modeExpert ?
                                        "\(sim.network.name) 3G (WCDMA) [\(sim.network.mcc) \(sim.network.mnc)] (\(country))" :  "\(sim.network.name) 3G (Femto)"
                                    lastnetr = "WCDMAF"
                                }
                                timecoder = Date()
                                dataManager.datas.set(lastnetr, forKey: sim.card.type == .esim ? "elastnetr" : "lastnetr")
                                dataManager.datas.set(timecoder, forKey: sim.card.type == .esim ? "etimecoder" : "timecoder")
                                dataManager.datas.synchronize()
                                self.refreshSections()
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        sim.network.connected = dataManager.modeRadin ? "Itinérance Delta radine : \(radinitiname) (\(country))" : dataManager.modeExpert ?
                            "\(sim.card.itiName) 3G (WCDMA) [\(sim.network.mcc) \(sim.card.itiMNC)] (\(country))" :  "\(sim.card.itiName) 3G \("itinerance".localized())"
                        self.refreshSections()
                        lastnetr = "WCDMAE"
                        dataManager.datas.set(lastnetr, forKey: sim.card.type == .esim ? "elastnetr" : "lastnetr")
                        dataManager.datas.synchronize()
                    }
                }
                
            } else {
                lastnetr = "WCDMA"
                dataManager.datas.set(lastnetr, forKey: sim.card.type == .esim ? "elastnetr" : "lastnetr")
                dataManager.datas.synchronize()
            }
            if sim.network.mcc == sim.card.mcc && sim.network.mnc == sim.card.chasedMNC && sim.network.connected == sim.card.nrp {
                sim.network.connected = dataManager.modeRadin ? "Itinérance Delta radine : \(radinitiname) (\(country))" : dataManager.modeExpert ?
                    "\(sim.card.itiName) 3G (WCDMA) [\(sim.network.mcc) \(sim.card.itiMNC)] (\(country))" :  "\(sim.card.itiName) 3G \("itinerance".localized())"
            } else {
                sim.network.connected = dataManager.modeRadin ? "3G radine : \(radincarrier) (\(country))" : dataManager.modeExpert ?
                    "\(sim.network.name) 3G (WCDMA) [\(sim.network.mcc) \(sim.network.mnc)] (\(country))" :  "\(sim.network.name) 3G"
            }
        } else if sim.network.connected == CTRadioAccessTechnologyHSDPA {
            if sim.network.mcc == sim.card.mcc && sim.network.mnc == sim.card.chasedMNC && !DataManager.isWifiConnected() && sim.network.connected == sim.card.nrp && sim.card.nrdec {
                
                if dataManager.femto {
                    print(abs(timecoder.timeIntervalSinceNow))
                    
                    if abs(timecoder.timeIntervalSinceNow) < 10*60 && lastnetr == "HSDPAO" {
                        DispatchQueue.main.async {
                            sim.network.connected = dataManager.modeRadin ? "Itinérance Delta radine : \(radinitiname) (\(country))" : dataManager.modeExpert ?
                                "\(sim.card.itiName) 3G (HSDPA) [\(sim.network.mcc) \(sim.card.itiMNC)] (\(country))" :  "\(sim.card.itiName) 3G \("itinerance".localized())"
                            self.refreshSections()
                            print("CACHE ORANGE F")
                        }
                    } else if abs(timecoder.timeIntervalSinceNow) < 10*60 && lastnetr == "HSDPAF" {
                        DispatchQueue.main.async {
                            sim.network.connected = dataManager.modeRadin ? "Femto ou mutualisation radine : \(radincarrier) (\(country))" : dataManager.modeExpert ?
                                "\(sim.network.name) 3G (HSDPA) [\(sim.network.mcc) \(sim.network.mnc)] (\(country))" :  "\(sim.network.name) 3G (Femto)"
                            self.refreshSections()
                            print("CACHE FEMTO")
                        }
                    } else {
                        Speedtest().testDownloadSpeedWithTimout(timeout: 5.0, usingURL: dataManager.url) { (speed, _) in
                            DispatchQueue.main.async {
                                if speed ?? 0 < sim.card.stms {
                                    sim.network.connected = dataManager.modeRadin ? "Itinérance Delta radine : \(radinitiname) (\(country))" : dataManager.modeExpert ?
                                        "\(sim.card.itiName) 3G (HSDPA) [\(sim.network.mcc) \(sim.card.itiMNC)] (\(country))" :  "\(sim.card.itiName) 3G \("itinerance".localized())"
                                    lastnetr = "HSDPAO"
                                } else {
                                    sim.network.connected = dataManager.modeRadin ? "Femto ou mutualisation radine : \(radincarrier) (\(country))" : dataManager.modeExpert ?
                                        "\(sim.network.name) 3G (HSDPA) [\(sim.network.mcc) \(sim.network.mnc)] (\(country))" :  "\(sim.network.name) 3G (Femto)"
                                    lastnetr = "HSDPAF"
                                }
                                timecoder = Date()
                                dataManager.datas.set(lastnetr, forKey: sim.card.type == .esim ? "elastnetr" : "lastnetr")
                                dataManager.datas.set(timecoder, forKey: sim.card.type == .esim ? "etimecoder" : "timecoder")
                                dataManager.datas.synchronize()
                                self.refreshSections()
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        sim.network.connected = dataManager.modeRadin ? "Itinérance Delta radine : \(radinitiname) (\(country))" : dataManager.modeExpert ?
                            "\(sim.card.itiName) 3G (HSDPA) [\(sim.network.mcc) \(sim.card.itiMNC)] (\(country))" :  "\(sim.card.itiName) 3G \("itinerance".localized())"
                        self.refreshSections()
                        lastnetr = "HSDPAE"
                        dataManager.datas.set(lastnetr, forKey: sim.card.type == .esim ? "elastnetr" : "lastnetr")
                        dataManager.datas.synchronize()
                    }
                }
                
            } else {
                lastnetr = "HSDPA"
                dataManager.datas.set(lastnetr, forKey: sim.card.type == .esim ? "elastnetr" : "lastnetr")
                dataManager.datas.synchronize()
            }
            if sim.network.mcc == sim.card.mcc && sim.network.mnc == sim.card.chasedMNC && sim.network.connected == sim.card.nrp {
                sim.network.connected = dataManager.modeRadin ? "Itinérance Delta radine : \(radinitiname) (\(country))" : dataManager.modeExpert ?
                    "\(sim.card.itiName) 3G (HSDPA) [\(sim.network.mcc) \(sim.card.itiMNC)] (\(country))" :  "\(sim.card.itiName) 3G \("itinerance".localized())"
            } else {
                sim.network.connected = dataManager.modeRadin ? "3G radine : \(radincarrier) (\(country))" : dataManager.modeExpert ?
                    "\(sim.network.name) 3G (HSDPA) [\(sim.network.mcc) \(sim.network.mnc)] (\(country))" :  "\(sim.network.name) 3G"
            }
        } else if sim.network.connected == CTRadioAccessTechnologyEdge {
            sim.network.connected = sim.network.mcc == sim.card.mcc && sim.network.mnc == sim.card.chasedMNC && sim.card.out2G ?
                (dataManager.modeRadin ? "Itinérance tupperware radine : \(radinitiname) (\(country))" : dataManager.modeExpert ? "\(sim.card.itiName) 2G (EDGE) [\(sim.network.mcc) \(sim.card.itiMNC)] (\(country))" : "\(sim.card.itiName) 2G \("itinerance".localized())") : (dataManager.modeRadin ? "2G radine : \(radincarrier) (\(country))" : dataManager.modeExpert ? "\(sim.network.name) 2G (EDGE) [\(sim.network.mcc) \(sim.network.mnc)] (\(country))" : "\(sim.network.name) 2G")
            lastnetr = "Edge"
            dataManager.datas.set(lastnetr, forKey: sim.card.type == .esim ? "elastnetr" : "lastnetr")
            dataManager.datas.synchronize()
        } else if sim.network.connected == CTRadioAccessTechnologyGPRS {
            sim.network.connected = sim.network.mcc == sim.card.mcc && sim.network.mnc == sim.card.chasedMNC && sim.card.out2G ?
                (dataManager.modeRadin ? "Itinérance VHS radine : \(radinitiname) (\(country))" : dataManager.modeExpert ? "\(sim.card.itiName) G (GPRS) [\(sim.network.mcc) \(sim.card.itiMNC)] (\(country))" : "\(sim.card.itiName) G \("itinerance".localized())") : (dataManager.modeRadin ? "G radin : \(radincarrier) (\(country))" : dataManager.modeExpert ? "\(sim.network.name) G (GPRS) [\(sim.network.mcc) \(sim.network.mnc)] (\(country))" : "\(sim.network.name) G")
            lastnetr = "GPRS"
            dataManager.datas.set(lastnetr, forKey: sim.card.type == .esim ? "elastnetr" : "lastnetr")
            dataManager.datas.synchronize()
        } else if sim.network.connected == CTRadioAccessTechnologyeHRPD {
            sim.network.connected = dataManager.modeRadin ? "3G radine : \(radincarrier) (\(country))" : dataManager.modeExpert ?
                "\(sim.network.name) 3G (eHRPD) [\(sim.network.mcc) \(sim.network.mnc)] (\(country))" :  "\(sim.network.name) 3G"
            lastnetr = "HRPD"
            dataManager.datas.set(lastnetr, forKey: sim.card.type == .esim ? "elastnetr" : "lastnetr")
            dataManager.datas.synchronize()
        } else if sim.network.connected == CTRadioAccessTechnologyHSUPA {
            sim.network.connected = dataManager.modeRadin ? "3G radine : \(radincarrier) (\(country))" : dataManager.modeExpert ?
                "\(sim.network.name) 3G (HSUPA) [\(sim.network.mcc) \(sim.network.mnc)] (\(country))" :  "\(sim.network.name) 3G"
            lastnetr = "HSUPA"
            dataManager.datas.set(lastnetr, forKey: sim.card.type == .esim ? "elastnetr" : "lastnetr")
            dataManager.datas.synchronize()
        } else if sim.network.connected == CTRadioAccessTechnologyCDMA1x {
            sim.network.connected = dataManager.modeRadin ? "3G radine : \(radincarrier) (\(country))" : dataManager.modeExpert ?
                "\(sim.network.name) 3G (CDMA2000) [\(sim.network.mcc) \(sim.network.mnc)] (\(country))" :  "\(sim.network.name) 3G"
            lastnetr = "CDMA1x"
            dataManager.datas.set(lastnetr, forKey: sim.card.type == .esim ? "elastnetr" : "lastnetr")
            dataManager.datas.synchronize()
        } else if sim.network.connected == CTRadioAccessTechnologyCDMAEVDORev0 {
            sim.network.connected = dataManager.modeRadin ? "3G radine : \(radincarrier) (\(country))" : dataManager.modeExpert ?
                "\(sim.network.name) 3G (EvDO) [\(sim.network.mcc) \(sim.network.mnc)] (\(country))" :  "\(sim.network.name) 3G"
            lastnetr = "CDMAEVDORev0"
            dataManager.datas.set(lastnetr, forKey: sim.card.type == .esim ? "elastnetr" : "lastnetr")
            dataManager.datas.synchronize()
        } else if sim.network.connected == CTRadioAccessTechnologyCDMAEVDORevA {
            sim.network.connected = dataManager.modeRadin ? "3G radine : \(radincarrier) (\(country))" : dataManager.modeExpert ?
                "\(sim.network.name) 3G (EvDO-A) [\(sim.network.mcc) \(sim.network.mnc)] (\(country))" :  "\(sim.network.name) 3G"
            lastnetr = "CDMAEVDORevA"
            dataManager.datas.set(lastnetr, forKey: sim.card.type == .esim ? "elastnetr" : "lastnetr")
            dataManager.datas.synchronize()
        } else if sim.network.connected == CTRadioAccessTechnologyCDMAEVDORevB {
            sim.network.connected = dataManager.modeRadin ? "3G radine : \(radincarrier) (\(country))" : dataManager.modeExpert ?
                "\(sim.network.name) 3G (EvDO-B) [\(sim.network.mcc) \(sim.network.mnc)] (\(country))" :  "\(sim.network.name) 3G"
            lastnetr = "CDMAEVDORevB"
            dataManager.datas.set(lastnetr, forKey: sim.card.type == .esim ? "elastnetr" : "lastnetr")
            dataManager.datas.synchronize()
        }
        
        if !dataManager.modeRadin && !dataManager.modeExpert && sim.network.land != sim.card.land && sim.network.land != "--" && sim.network.connected != "" && !sim.network.connected.isEmpty {
            sim.network.connected += " (\(country))"
        }
        
        if sim.network.connected != "" && !sim.network.connected.isEmpty && ((dataManager.current.card.type == .esim && sim.card.type == .esim) || (dataManager.current.card.type == .sim && sim.card.type == .sim)) && dataManager.esim.card.active && dataManager.sim.card.active {
            sim.network.connected += " ☑️"
        }
        
        return sim.network.connected
        
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
        
        print(dataManager.current.network.connected)
        
        let countryCode = dataManager.sim.card.mcc
        let mobileNetworkName = dataManager.sim.card.mnc
        let carrierName = dataManager.sim.card.name
        let isoCountrycode = dataManager.sim.card.land
        
        let countryCode2 = dataManager.esim.card.mcc
        let mobileNetworkName2 = dataManager.esim.card.mnc
        let carrierName2 = dataManager.esim.card.name
        let isoCountrycode2 = dataManager.esim.card.land
        
        let country = dataManager.sim.network.land
        let country2 = dataManager.esim.network.land
        
        let radincarrier = dataManager.modeRadin ? radinCarrierName(mcc: dataManager.sim.network.mcc, mnc: dataManager.sim.network.mnc, carrier: dataManager.sim.network.name) : dataManager.sim.network.name
        let radinitiname = dataManager.modeRadin ? radinCarrierName(mcc: dataManager.sim.network.mcc, mnc: dataManager.sim.card.itiMNC, carrier: dataManager.sim.card.itiName) : dataManager.sim.card.itiName
        let radincarrier2 = dataManager.modeRadin ? radinCarrierName(mcc: dataManager.esim.network.mcc, mnc: dataManager.esim.network.mnc, carrier: dataManager.esim.network.name) : dataManager.esim.network.name
        let radinitiname2 = dataManager.modeRadin ? radinCarrierName(mcc: dataManager.esim.network.mcc, mnc: dataManager.esim.card.itiMNC, carrier: dataManager.esim.card.itiName) : dataManager.esim.card.itiName
        
        let connected1 = connected(dataManager: dataManager, sim: dataManager.sim, radincarrier: radincarrier, radinitiname: radinitiname, country: country)
        let connected2 = connected(dataManager: dataManager, sim: dataManager.esim, radincarrier: radincarrier2, radinitiname: radinitiname2, country: country2)
        
        let lastnetr = dataManager.datas.value(forKey: dataManager.current.card.type == .esim ? "elastnetr" : "lastnetr") as? String ?? "HSDPAO"
        
        
//        if DataManager.isWifiConnected() {
//            if !dataManager.carrierNetwork.isEmpty{
//                dataManager.carrierNetwork = "Wi-Fi + " + dataManager.carrierNetwork
//            } else {
//                dataManager.carrierNetwork = "Wi-Fi"
//            }
//        }
        
        print(connected1)
        print(connected2)
        
        if !dataManager.current.card.setupDone && countryCode == "null" && mobileNetworkName == "null" && dataManager.current.network.connected == "" && !alertInit {
            delay(0.05) {
                let alert = UIAlertController(title: "insert_sim_title".localized(), message:"insert_sim_description".localized(), preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "ok".localized(), style: UIAlertAction.Style.default, handler: nil))
                
                UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
            }
            alertInit = true
        }
        
        var disp: String
        var disp2: String
        
        if countryCode == "null" || countryCode.isEmpty || !dataManager.sim.card.active {
            disp = dataManager.modeRadin ? "Pas de carte SIM radine détéctée" : "no_sim".localized()
        } else {
            if countryCode == "208" && mobileNetworkName == "15" {
                disp = "\("sim_card".localized()) \(dataManager.modeRadin ? "Radin" : carrierName)"
            } else if countryCode == "208" && mobileNetworkName == "01" {
                disp = "\("sim_card".localized()) \(dataManager.modeRadin ? "Agrume France" : carrierName)"
            } else if countryCode == "208" && mobileNetworkName == "10" {
                disp = "\("sim_card".localized()) \(dataManager.modeRadin ? "Patoche has no limits" : carrierName)"
            } else if countryCode == "208" && mobileNetworkName == "20" {
                disp = "\("sim_card".localized()) \(dataManager.modeRadin ? "Béton Télécom" : carrierName)"
            } else if countryCode == "208" && mobileNetworkName == "26" {
                disp = "\("sim_card".localized()) \(dataManager.modeRadin ? "Redbull Mobile" : carrierName)"
            }
            
            else {
                disp = "\("sim_card".localized()) \(carrierName)"
            }
            
            if dataManager.modeExpert {
                disp += " [\(countryCode) \(mobileNetworkName)] (\(isoCountrycode))"
            }
            
            if dataManager.current.card.type == .sim && dataManager.esim.card.active && dataManager.sim.card.active {
                disp += " ☑️"
            }
        }
        
        
        if countryCode2 == "null" || countryCode2.isEmpty || !dataManager.esim.card.active {
            disp2 = dataManager.modeRadin ? "Pas de eSIM radine activée" : "no_esim".localized()
        } else {
            if countryCode2 == "208" && mobileNetworkName2 == "15" {
                disp2 = "\("esim".localized()) \(dataManager.modeRadin ? "Radin" : carrierName2)"
            } else if countryCode2 == "208" && mobileNetworkName2 == "01" {
                disp2 = "\("esim".localized()) \(dataManager.modeRadin ? "Agrume France" : carrierName2)"
            } else if countryCode2 == "208" && mobileNetworkName2 == "10" {
                disp2 = "\("esim".localized()) \(dataManager.modeRadin ? "Patoche has no limits" : carrierName2)"
            } else if countryCode2 == "208" && mobileNetworkName2 == "20" {
                disp2 = "\("esim".localized()) \(dataManager.modeRadin ? "Béton Télécom" : carrierName2)"
            } else if countryCode2 == "208" && mobileNetworkName2 == "26" {
                disp2 = "\("esim".localized()) \(dataManager.modeRadin ? "Redbull Mobile" : carrierName2)"
            } else {
                disp2 = "\("esim".localized()) \(carrierName2)"
            }
            
            if dataManager.modeExpert {
                disp2 += " [\(countryCode2) \(mobileNetworkName2)] (\(isoCountrycode2))"
            }
            
            if dataManager.current.card.type == .esim && dataManager.esim.card.active && dataManager.sim.card.active {
                disp2 += " ☑️"
            }
        }
        
        let appVersion = Int(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0") ?? 0
        
        // Strings de l'UI
        
        var generation = ""
        if dataManager.current.network.mcc == "---" && !dataManager.current.card.nrdec && UIDevice.current.userInterfaceIdiom == .pad {
            generation = "generation".localized().format([String(appVersion), "A1"])
        } else if dataManager.current.network.mcc == "---" && UIDevice.current.userInterfaceIdiom == .pad {
            generation = "generation".localized().format([String(appVersion), "1"])
        } else if !dataManager.current.card.nrdec || !dataManager.current.card.setupDone {
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
        let iti5G = dataManager.modeRadin ? "Itinérance Pop autorisée" : "allow5g".localized()
        let iti4G = dataManager.modeRadin ? "Itinérance Delta S autorisée" : "allow4g".localized()
        let iti3G = dataManager.modeRadin ? "Itinérance Delta autorisée" : "allow3g".localized()
        let iti2G = dataManager.modeRadin ? "Itinérance tupperware autorisée" : "allow2g".localized()
        let wifiaut = dataManager.modeRadin ? "Vérifier sur ma Radinbox" : "verifywifi".localized()
        let wififoo = dataManager.modeExpert ? (dataManager.modeRadin ? "En activant cette option, les vérifications de l'itinérance radine auront lieu même lorsque vous êtes connecté à une Radinbox. Afin d'optimiser la batterie (sauf pour la génération A2), il est recommandé de garder cette option radine désactivée." : "wififooter".localized()) : ""
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
            if (dataManager.current.network.mcc == "---" && dataManager.current.network.mnc == "--"){
                land = dataManager.modeRadin ? "Vérifier les voyages radins" : "land_g1".localized()
                fland = dataManager.modeRadin ? "En activant cette option, nous allons vérifier en arrière plan que vous vous situez toujours dans votre pays Radin afin d'empêcher les tâches pour sortir de l'itinérance radine lorsque vous êtes à l'étranger car les opérateurs étrangers ne possèdent pas notre réseau révolutionnaire à 768kbps. Votre opérateur Radin n'est pas encore compatible avec la 2ème génération de FMobile sur iPad, mais si un opérateur éligible est disponible, FMobile activera ici les fonctionalités de la 2ème génération automatiquement." : "land_footer_g1".localized()
                nland = "background_loc_g1".localized()
            }
        }
        
        if !dataManager.modeExpert && !(dataManager.current.card.mcc == "208" && dataManager.current.card.mnc == "15" && dataManager.current.card.setupDone) {
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
        
        if !dataManager.current.card.setupDone {
            if dataManager.isSettingUp || (abs(dataManager.syncNewSIM.timeIntervalSinceNow) < 20) {
                net.elements += [
                    UIElementLabel(id: "activ", text: "🕗 \("activation".localized())")
                ]
            } else {
                net.elements += [
                    UIElementButton(id: "", text: "⚠️ \("activate".localized())") { (_) in
 
                        let mcc = dataManager.current.card.carrier.mobileCountryCode ?? "---"
                        let mnc = dataManager.current.card.carrier.mobileNetworkCode ?? "--"

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
        if !dataManager.esim.card.active || dataManager.sim.card.active {
            net.elements += [UIElementLabel(id: "networkstatus", text: disp)]
        }
        // SIM 2 (complète avec ta condition sur ce if et change le texte avec la valeur de la deuxième sim)
        if ((device >= 11 && UIDevice.current.modelName.contains("iPhone")) || (device >= 8 && UIDevice.current.modelName.contains("iPad"))) && (countryCode2 != "null" && !countryCode2.isEmpty) && dataManager.esim.card.active {
            net.elements += [UIElementLabel(id: "networkstatus2", text: disp2)]
        }
        
        // Reste de la section status
        if !dataManager.esim.card.active || dataManager.sim.card.active {
            net.elements += [UIElementLabel(id: "connected", text: "") { () -> String in
                if dataManager.airplanemode {
                    return dataManager.modeRadin ? "Mode jet radin activé" : "airplane_mode_enabled".localized()
                }
                else if connected1 == "null" || connected1.isEmpty || !dataManager.sim.card.active {
                    if countryCode == "null" || countryCode.isEmpty || !dataManager.sim.card.active {
                        return dataManager.modeRadin ? "Pas de connexion radine" : "not_connected".localized()
                    } else {
                        return dataManager.modeRadin ? "Réseau radin perdu : \(dataManager.sim.network.fullname)" : (dataManager.modeExpert ? "not_connected_searching".localized().format([dataManager.sim.network.fullname]) + " [\(dataManager.sim.network.mcc) \(dataManager.sim.network.mnc)] (\(dataManager.sim.network.land))" : "not_connected_searching".localized().format([dataManager.sim.network.fullname]) + (dataManager.sim.network.land != dataManager.sim.card.land ? " (\(dataManager.sim.network.land))" : ""))
                    }
                } else {
                    return dataManager.modeRadin ? "\(connected1)" : "connected".localized().format([connected1])
                }
            }]
        }
        
        if ((device >= 8 && UIDevice.current.modelName.contains("iPad")) || (device >= 11 && UIDevice.current.modelName.contains("iPhone"))) && (countryCode2 != "null" && !countryCode2.isEmpty) && dataManager.esim.card.active {
            net.elements += [UIElementLabel(id: "connected2", text: "") { () -> String in
                if dataManager.airplanemode {
                    return dataManager.modeRadin ? "Mode jet radin activé" : "airplane_mode_enabled".localized()
                }
                else if connected2 == "null" || connected2.isEmpty  {
                        if countryCode2 == "null" || countryCode2.isEmpty {
                            return dataManager.modeRadin ? "Pas de connexion eSIM radine" : "esim_not_connected".localized()
                        } else {
                            return dataManager.modeRadin ? "Réseau eSIM radin perdu : \(dataManager.esim.network.fullname)" : (dataManager.modeExpert ? "esim_not_connected_searching".localized().format([dataManager.esim.network.fullname]) + " [\(dataManager.esim.network.mcc) \(dataManager.esim.network.mnc)] (\(dataManager.esim.network.land))" : "esim_not_connected_searching".localized().format([dataManager.esim.network.fullname]) + (dataManager.esim.network.land != dataManager.esim.card.land ? " (\(dataManager.esim.network.land))" : ""))
                        }
                    } else {
                        return dataManager.modeRadin ? "eSIM en \(connected2)" : "esim_connected".localized().format([connected2])
                    }
            }]
        }
        
//        net.elements += [UIElementLabel(id: "liveSpeed", text: "Down: \(DataUsage.getDataUsage().wifiReceived) | Up = \(DataUsage.getDataUsage().wifiSent)")]
        
        if ((dataManager.current.network.mcc == dataManager.current.card.mcc && dataManager.current.network.mnc == dataManager.current.card.chasedMNC && dataManager.current.card.minimalSetup) || (dataManager.current.network.mcc == dataManager.current.card.mcc && dataManager.current.network.mnc == dataManager.current.card.chasedMNC)) && (((!dataManager.allow013G || !dataManager.allow014G || !dataManager.allow015G) && (lastnetr == "NRE" || lastnetr == "NRO" || lastnetr == "NRNSAE" || lastnetr == "NRNSAO" || lastnetr == "LTEE" || lastnetr == "LTEO" || lastnetr == "HSDPA" || lastnetr == "HSDPAE" || lastnetr == "HSDPAO" || lastnetr == "WCDMAO" || lastnetr == "WCDMAE" || lastnetr == "WCDMA")) || (!dataManager.allow012G && dataManager.current.card.out2G && lastnetr == "Edge") || (!dataManager.allow014G && dataManager.current.card.roamLTE && lastnetr == "LTE") || (!dataManager.allow015G && dataManager.current.card.roam5G && lastnetr == "NR") || (!dataManager.allow015G && dataManager.current.card.roam5G && lastnetr == "NRNSA")) && DataManager.isConnectedToNetwork() {
            net.elements += [UIElementButton(id: "", text: "exit_roaming".localized()) { (_) in
                dataManager.wasEnabled += 1
                dataManager.datas.set(dataManager.wasEnabled, forKey: "wasEnabled")
                if #available(iOS 14.1, *), dataManager.current.network.connected == CTRadioAccessTechnologyNR {
                    dataManager.datas.set("NR", forKey: "g3lastcompletion")
                } else if #available(iOS 14.1, *), dataManager.current.network.connected == CTRadioAccessTechnologyNRNSA {
                    dataManager.datas.set("NRNSA", forKey: "g3lastcompletion")
                } else if dataManager.current.network.data == CTRadioAccessTechnologyLTE {
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
                }]
        }
        
        let zone = dataManager.zoneCheck(service: dataManager.current)
        if dataManager.current.network.mcc != dataManager.current.card.mcc && (zone == "OUTZONE" || zone == "CALLS") && dataManager.current.network.land != "--" && countryCode != "null" && dataManager.current.card.setupDone && dataManager.current.card.active {
            net.elements += [UIElementButton(id: "", text: "country_included_button".localized().format([dataManager.current.network.land])) { (_) in
                
                let country = dataManager.current.network.land
                
                if CarrierIdentification.europeland.contains(country) {
                    let addEuropeAlert = UIAlertController(title: "add_europe".localized(), message: "add_europe_description".localized().format([country]), preferredStyle: .alert)
                    addEuropeAlert.addAction(UIAlertAction(title: "add_europe_only".localized(), style: .default) { (_) in
                        self.addCountry(country: "UE", dataManager: dataManager, service: dataManager.current)
                    })
                    addEuropeAlert.addAction(UIAlertAction(title: "add_country_only".localized().format([country]), style: .default) { (_) in
                        self.addCountry(country: country, dataManager: dataManager, service: dataManager.current)
                    })
                    addEuropeAlert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil))
                    
                    UIApplication.shared.windows.first?.rootViewController?.present(addEuropeAlert, animated: true, completion: nil)
                    
                } else {
                    self.addCountry(country: country, dataManager: dataManager, service: dataManager.current)
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
        
        if !dataManager.current.card.disableFMobileCore || dataManager.modeExpert || (dataManager.current.network.mcc == dataManager.current.card.mcc && dataManager.current.network.mnc == dataManager.current.card.mnc){
            net.elements += [
                UIElementButton(id: "", text: "set_no_network".localized()) { (_) in
                    if CLLocationManager.authorizationStatus() == .authorizedAlways {
                        let locationManager = CLLocationManager()
                        let latitude = locationManager.location?.coordinate.latitude ?? 0
                        let longitude = locationManager.location?.coordinate.longitude ?? 0
                        
                        if #available(iOS 14.0, *) {
                            if locationManager.accuracyAuthorization != .fullAccuracy {
                                return
                            }
                        }

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
        
        if dataManager.current.card.roam5G || dataManager.modeExpert {
            pref.elements += [UIElementSwitch(id: "allow015G", text: iti5G, d: true)]
        }
        if dataManager.current.card.roamLTE || dataManager.modeExpert {
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
        
        if dataManager.modeExpert || (dataManager.current.card.mcc == "208" && dataManager.current.card.mnc == "15" && dataManager.current.card.setupDone) {
            back.elements += [
                UIElementSwitch(id: "femto", text: fmt, d: true),
                UIElementSwitch(id: "femtoLOWDATA", text: eco, d: false)
            ]
        }
        
        let femto = Section(name: "", elements: [])
        
        if !dataManager.current.card.disableFMobileCore || dataManager.modeExpert || (dataManager.current.network.mcc == dataManager.current.card.mcc && dataManager.current.network.mnc == dataManager.current.card.mnc){
            femto.elements += [
                UIElementButton(id: "", text: zns) { (_) in
                    self.resetAllRecords(in: "Locations")
                }
            ]
        }
        
        if dataManager.current.card.setupDone{
            femto.elements += [
                UIElementButton(id: "", text: "reset_countries_included".localized()) { (_) in
                    self.resetCountriesIncluded(dataManager, service: dataManager.current)
                }
            ]
        }
        
        // Section country detection
        let cnt = Section(name: nland, elements: [
            UIElementSwitch(id: "allowCountryDetection", text: land, d: true)
        ], footer: fland)
        
        // Section conso
        let conso = Section(name: cso, elements: [])
        
        
        for service in dataManager.current.card.carrierServices {
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
                dataManager.datas.set(false, forKey: "locationAuthorizationAvoided")
                dataManager.datas.set(false, forKey: "allow014G_noalert")
                dataManager.datas.set(false, forKey: "allow015G_noalert")
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
        
        if #available(iOS 13.0, *) {
            if dataManager.modeExpert {
                avance.elements += [UIElementSwitch(id: "bluetoothOff", text: "shut_bluetooth".localized(), d: false),
                                UIElementSwitch(id: "wifiOff", text: "shut_wifi".localized(), d: false)]
            }
        } else {
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
            UIElementButton(id: "", text: "minaste_center".localized()) { (_) in
                
                let mainController = GroupeMINASTEController()
                mainController.navigationItem.title = "minaste_center".localized()
                
                let close = UIBarButtonItem(title: "close".localized(), style: .done, target: self, action: #selector(self.closeAction))
                mainController.navigationItem.setLeftBarButton(close, animated: true)
                
                let controller = UINavigationController(rootViewController: mainController)
                
                
                self.present(controller, animated: true, completion: nil)
            }
            , UIElementButton(id: "", text: "donate".localized()) { (_) in
                
                self.openDonateViewController()
                
//                let text = "donate_unable_description".localized()
//                let alert = UIAlertController(title: "donate_unable".localized(), message: text, preferredStyle: .alert)
//
//                alert.addAction(UIAlertAction(title: "close".localized(), style: .default, handler: nil))
//                UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
//
//
//                let text = "donate_warning_french_citizenship".localized()
//                let alert = UIAlertController(title: "donate_warning".localized(), message: text, preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "donate_helloasso".localized(), style: .default) { (_) in
//                    guard let link = URL(string: "https://www.helloasso.com/associations/groupe-minaste/formulaires/1") else { return }
//                    if #available(iOS 10.0, *) {
//                        UIApplication.shared.open(link)
//                    } else {
//                        UIApplication.shared.openURL(link)
//                    }
//                    })
//                alert.addAction(UIAlertAction(title: "donate_iap".localized(), style: .default) { (_) in
//                    self.openDonateViewController()
//
//                })
//                alert.addAction(UIAlertAction(title: "cancel".localized(), style: .default, handler: nil))
            }
        ], footer: "donate_description".localized())
//        ], footer: "")
        
        plus.elements += [UIElementApp(name: "fwifi".localized(), desc: "install_fwifi_desc".localized(), icon: UIImage(named: "fwifi"), completionHandler: { (UIButton) in
            print("YES !!!")
            if let url = URL(string: "fwifi://") {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url) { (result) in
                        if !result {
                            if let url2 = URL(string: "https://apps.apple.com/app/fwi-fi-for-ios/id1501218122") {
                                UIApplication.shared.open(url2)
                            }
                        }
                    }
                } else {
                    // Fallback on earlier versions
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.openURL(url)
                    } else {
                        if let url2 = URL(string: "https://apps.apple.com/app/fwi-fi-for-ios/id1501218122") {
                            UIApplication.shared.openURL(url2)
                        }
                    }
                }
            }
        })]
        
        
        
        sections += [net]
        
        if !dataManager.current.card.disableFMobileCore || dataManager.modeExpert {
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
    
    @objc func closeAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func openDonateViewController() {
        // Create the view controller
        let controller:DonateViewController
        
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
        controller.add(identifier: "fr.plugn.fmobile.donation1")
        controller.add(identifier: "fr.plugn.fmobile.donation2")
        controller.add(identifier: "fr.plugn.fmobile.donation3")
        
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
