//
//  RoamingManager.swift
//  FMobile
//
//  Created by PlugN on 11/07/2019.
//  Copyright © 2019 Groupe MINASTE. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation
import UIKit
import CoreTelephony

class RoamingManager {
    
    // Fonction de géocode
    static func geocode(latitude: Double, longitude: Double, completion: @escaping (CLPlacemark?, Error?) -> ())  {
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: latitude, longitude: longitude)) {
            completion($0?.first, $1)
        }
    }
    
    // Initialisation sur iPad
    static func iPadInit(_ dataManager: DataManager = DataManager(), _ g3engine: Bool = false, completionHandler: @escaping (String) -> ()) {
        // On vérifie si l'utilisateur a donné son accord pour vérifier le pays en arrière plan
        if !dataManager.stopverification {
            if dataManager.allowCountryDetection {
                
                // Le cache a expiré ?
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
                                process(dataManager, g3engine, completionHandler: completionHandler)
                                return
                            }
                            
                            print("ISO COUNTRY CODE :",  placemark.isoCountryCode?.uppercased() ?? "")
                            
                            if placemark.isoCountryCode?.uppercased() ?? CarrierIdentification.getIsoCountryCode(dataManager.targetMCC, dataManager.targetMNC) == CarrierIdentification.getIsoCountryCode(dataManager.targetMCC, dataManager.targetMNC) {
                                print("L'utilisateur est dans son pays")
                                dataManager.datas.set(placemark.isoCountryCode?.uppercased() ?? CarrierIdentification.getIsoCountryCode(dataManager.targetMCC, dataManager.targetMNC), forKey: "lastCountry")
                                dataManager.datas.set(Date(), forKey: "timeLastCountry")
                                dataManager.datas.synchronize()
                                process(dataManager, g3engine, completionHandler: completionHandler)
                                return
                            } else {
                                print("L'utilisateur est à l'étranger")
                                dataManager.datas.set(placemark.isoCountryCode?.uppercased() ?? "ABO", forKey: "lastCountry")
                                dataManager.datas.set(Date(), forKey: "timeLastCountry")
                                dataManager.datas.synchronize()
                                CoverageManager.addCurrentCoverageData(dataManager, aboard: directDataDCheck())
                                dataManager.datas.set("ABOARD", forKey: "g3lastcompletion")
                                dataManager.datas.synchronize()
                                completionHandler("ABOARD")
                                return
                            }
                            
                        }
                        CoverageManager.addCurrentCoverageData(dataManager)
                        completionHandler("ESCAPED_GEOCODE")
                        return
                        
                    } else {
                        // L'utilisateur a demandé à vérifier le pays mais n'a pas autorisé l'app à le faire dans le système
                        print("LOC FETCH failed: wrong permissions")
                        NotificationManager.sendNotification(for: .locFailed)
                        dataManager.datas.set(Date(), forKey: "timeLastCountry")
                        dataManager.datas.synchronize()
                        process(dataManager, g3engine, completionHandler: completionHandler)
                        return
                    }
                } else {
                    if dataManager.lastCountry == CarrierIdentification.getIsoCountryCode(dataManager.targetMCC, dataManager.targetMNC) {
                        print("Utilisation du cache : Home Network")
                        process(dataManager, g3engine, completionHandler: completionHandler)
                        return
                    } else {
                        print("Selon le cache, l'utilisateur est à l'étranger")
                        CoverageManager.addCurrentCoverageData(dataManager, aboard: directDataDCheck())
                        dataManager.datas.set("ABOARD", forKey: "g3lastcompletion")
                        dataManager.datas.synchronize()
                        completionHandler("ABOARD")
                        return
                    }
                }
                
            } else {
                // L'utilisateur n'a pas donné son accord
                print("The user has not allowed Country Detection")
                process(dataManager, g3engine, completionHandler: completionHandler)
                return
            }
        } else {
            print("Background Fetch Disabled in App Preferences.")
            dataManager.datas.set("STOP", forKey: "g3lastcompletion")
            dataManager.datas.synchronize()
            completionHandler("STOP")
            return
        }
    }
    
    static func bgUpdateSetup(_ dataManager: DataManager = DataManager()) {
        // On check que le setup n'est pas déjà en cours
        if dataManager.isSettingUp {
            return
        }
        dataManager.datas.set(true, forKey: "isSettingUp")
        dataManager.datas.synchronize()
        
        
        // On fetch la configuration depuis le serveur
        CarrierConfiguration.fetch(forMCC: dataManager.mycarrier.mobileCountryCode ?? "", andMNC: dataManager.mycarrier.mobileNetworkCode ?? "") { configuration in
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
                CoverageManager.addCurrentCoverageData(dataManager)
            }
        }
        
    }
    
    // Initialsation
    static func initBackground(_ dataManager: DataManager = DataManager(), _ g3engine: Bool = false, completionHandler: @escaping (String) -> ()) {
        // Traitement de l'iPad
        if UIDevice.current.userInterfaceIdiom == .pad {
            if (dataManager.ipadMCC == "---" && dataManager.ipadMNC == "--"){
                iPadInit(dataManager, g3engine, completionHandler: completionHandler)
                return
            }
        }
        
        let countryCode = dataManager.mycarrier.mobileCountryCode ?? "null"
        let mobileNetworkName = dataManager.mycarrier.mobileNetworkCode ?? "null"
        
        // On vérifie si l'utilisateur a donné son accord pour vérifier le pays en arrière plan
        if !dataManager.stopverification {
            if (countryCode != dataManager.targetMCC || mobileNetworkName != dataManager.targetMNC) && (mobileNetworkName != "null" || countryCode != "null") {
                dataManager.datas.removeObject(forKey: "MCC")
                dataManager.datas.set(false, forKey: "setupDone")
                dataManager.datas.set("NEWSIM", forKey: "g3lastcompletion")
                dataManager.datas.set(Date(), forKey: "syncNewSIM")
                dataManager.resetCountryIncluded()
                dataManager.datas.synchronize()
                if DataManager.isConnectedToNetwork() {
                    self.bgUpdateSetup()
                }
                completionHandler("NEWSIM")
                return
            }
            
            process(dataManager, g3engine, completionHandler: completionHandler)
            return
        } else {
            print("User wants the process to stop in background.")
            dataManager.datas.set("STOP", forKey: "g3lastcompletion")
            dataManager.datas.synchronize()
            completionHandler("STOP")
            return
        }
    }
    
    // La fonction qui vérifie si on doit appeler netfetch() ou pas (WiFi, à l'étranger...)
    static func process(_ dataManager: DataManager = DataManager(), _ g3engine: Bool = false, completionHandler: @escaping (String) -> ()) {
        if (dataManager.connectedMCC == dataManager.targetMCC && dataManager.connectedMNC == dataManager.itiMNC && dataManager.carrierNetwork == CTRadioAccessTechnologyLTE) || (dataManager.connectedMCC == dataManager.targetMCC && dataManager.connectedMNC == dataManager.chasedMNC && dataManager.carrierNetwork != CTRadioAccessTechnologyLTE) {
                // Le contrôle d'itinérance démarre.
                netfetch(dataManager, g3engine, completionHandler: completionHandler)
                return
        } else {
            // L'utilisateur est chez un autre opérateur
            print("L'utilisateur n'est pas connecté sur son réseau propre.")
            CoverageManager.addCurrentCoverageData(dataManager)
            dataManager.datas.set("OTHERCARRIER", forKey: "g3lastcompletion")
            dataManager.datas.synchronize()
            completionHandler("OTHERCARRIER")
            return
        }
        
    }
    
    // La fonction clé du programme qui vérifie l'itinérance
    static func netfetch(_ dataManager: DataManager = DataManager(), _ g3engine: Bool = false, completionHandler: @escaping (String) -> ()) {
        let now = Date()
        
        print(abs(dataManager.timecode.timeIntervalSinceNow))
        print(now)
        
        if dataManager.carrierNetwork != dataManager.lastnet {
            print("THE NETWORK HAS CHANGED! PERFORMING NEW CHECK.")
            dataManager.lastnet = dataManager.carrierNetwork
            dataManager.timecode = now
            if g3engine {
                dataManager.g3timecode = now
                dataManager.datas.set(dataManager.g3timecode, forKey: "g3timecode")
            }
            dataManager.count = 0
            dataManager.wasEnabled = 0
            dataManager.datas.set(dataManager.lastnet, forKey: "lastnet")
            dataManager.datas.set(dataManager.timecode, forKey: "timecode")
            dataManager.datas.set(dataManager.count, forKey: "count")
            dataManager.datas.set(dataManager.wasEnabled, forKey: "wasEnabled")
            dataManager.datas.synchronize()
        } else if abs(dataManager.timecode.timeIntervalSinceNow) > 10*60 {
            print("IT HAS BEEN OVER 10 MINUTES.")
            dataManager.timecode = now
            if g3engine {
                dataManager.g3timecode = now
                dataManager.datas.set(dataManager.g3timecode, forKey: "g3timecode")
            } else {
                dataManager.count += 1
                dataManager.datas.set(dataManager.count, forKey: "count")
            }
            dataManager.datas.set(dataManager.timecode, forKey: "timecode")
            dataManager.datas.synchronize()
            if dataManager.count > 5 && dataManager.wasEnabled > 5 && !g3engine {
                print("IT HAS BEEN 5 ATTEMPTS AND THE OPERATION DID NOT SUCCEED.")
                if CLLocationManager.authorizationStatus() == .authorizedAlways {
                    // On verifie la localisation en arrière plan
                    let locationManager = CLLocationManager()
                    let latitude = locationManager.location?.coordinate.latitude ?? 0
                    let longitude = locationManager.location?.coordinate.longitude ?? 0
                    
                    if latitude != 0 && longitude != 0 {
                        let context: NSManagedObjectContext
                        if #available(iOS 10.0, *) {
                            context = persistentContainer.viewContext
                        } else {
                            // Fallback on earlier versions
                            context = managedObjectContext
                        }
                            guard let entity = NSEntityDescription.entity(forEntityName: "Locations", in: context) else {
                                CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                                completionHandler("ERROR")
                                return
                            }
                            let newCoo = NSManagedObject(entity: entity, insertInto: context)
                            
                            newCoo.setValue(latitude, forKey: "lat")
                            newCoo.setValue(longitude, forKey: "lon")
                        
                            context.performAndWait({
                                do {
                                    try context.save()
                                    print("COORDINATES SAVED!")
                                    NotificationManager.sendNotification(for: .saved)
                                } catch {
                                    print("Failed saving")
                                }
                            })
                            
                        }
                    }
                dataManager.lastnet = dataManager.carrierNetwork
                dataManager.timecode = now
                if g3engine {
                    dataManager.g3timecode = now
                    dataManager.datas.set(dataManager.g3timecode, forKey: "g3timecode")
                }
                dataManager.count = 0
                dataManager.wasEnabled = 0
                dataManager.datas.set(dataManager.lastnet, forKey: "lastnet")
                dataManager.datas.set(dataManager.timecode, forKey: "timecode")
                dataManager.datas.set(dataManager.count, forKey: "count")
                dataManager.datas.set(dataManager.wasEnabled, forKey: "wasEnabled")
                dataManager.datas.set("NOTCOVERED", forKey: "g3lastcompletion")
                CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                dataManager.datas.synchronize()
                completionHandler("NOTCOVERED")
                return
            } else if dataManager.count > 6 {
                print("IT HAS BEEN 5 ATTEMPTS BUT THE OPERATION WAS NOT LAUNCHED.")
                dataManager.count = 0
                if g3engine {
                    dataManager.g3timecode = now
                    dataManager.datas.set(dataManager.g3timecode, forKey: "g3timecode")
                }
                dataManager.datas.set(dataManager.count, forKey: "count")
                dataManager.datas.synchronize()
            }
        } else {
            if (!g3engine) {
                print("IT'S NOT TIME YET!")
                CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                completionHandler("NOTTIME")
                return
            } else {
                if (dataManager.g3lastcompletion == "LTE" || dataManager.g3lastcompletion == "HPLUS" || dataManager.g3lastcompletion == "WCDMA" || dataManager.g3lastcompletion == "EDGE") && abs(dataManager.g3timecode.timeIntervalSinceNow) < 2*60 {
                    CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                    completionHandler(dataManager.g3lastcompletion)
                    return
                }
                
                dataManager.g3timecode = now
                dataManager.timecode = now
                dataManager.datas.set(dataManager.g3timecode, forKey: "g3timecode")
                dataManager.datas.set(dataManager.timecode, forKey: "timecode")
                dataManager.datas.synchronize()
            }
        }
        
        // Le script continuera si il a changé de réseau ou que cela fait plus de 15 minutes qu'il n'y a pas eu d'alerte
        // On enregistre les nouvelles valeurs et on continue
        
        print("Network changed, set to \(dataManager.carrierNetwork) at \(now)")
        
        // Début des vérifications
        if dataManager.carrierNetwork == CTRadioAccessTechnologyLTE && (dataManager.allow014G || (dataManager.modeExpert ? false : !dataManager.roamLTE)) {
            // L'utilisateur est en 4G, tout va bien
            print("HOME LTE: No need to reset.")
            CoverageManager.addCurrentCoverageData(dataManager)
            dataManager.datas.set("HOME", forKey: "g3lastcompletion")
            dataManager.datas.synchronize()
            completionHandler("HOME")
            return
        } else if dataManager.carrierNetwork == dataManager.hp {
            // L'utilisateur est en 3G RP, tout va bien
            print("HOME WCDMA: No need to reset.")
            CoverageManager.addCurrentCoverageData(dataManager)
            dataManager.datas.set("HOME", forKey: "g3lastcompletion")
            dataManager.datas.synchronize()
            completionHandler("HOME")
            return
        } else if dataManager.carrierNetwork == dataManager.nrp || dataManager.carrierNetwork == CTRadioAccessTechnologyLTE {
            // L'utilisateur est en 3G+ en Itinérance, vérification si autorisée
            if (dataManager.carrierNetwork == dataManager.nrp && !dataManager.allow013G) || (dataManager.carrierNetwork == CTRadioAccessTechnologyLTE && !dataManager.allow014G) {
                print("H+ ou LTE non autorisée.")
                if !dataManager.femtoLOWDATA && (dataManager.femto || dataManager.carrierNetwork == CTRadioAccessTechnologyLTE) && !DataManager.isWifiConnected() {
                    
                    if dataManager.nrDEC {
                        Speedtest().testDownloadSpeedWithTimout(timeout: 5.0, usingURL: dataManager.url) { (speed, _) in
                            DispatchQueue.main.async {
                                print(speed ?? 0)
                                if speed ?? 0 < dataManager.stms {
                                    print("SPEEDTEST IN BACKGROUND SUCCESSFUL!")
                                    if dataManager.carrierNetwork == CTRadioAccessTechnologyLTE {
                                        CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                                        dataManager.datas.set("LTE", forKey: "g3lastcompletion")
                                        dataManager.datas.synchronize()
                                        completionHandler("LTE")
                                        return
                                    }
                                    else if dataManager.nrp == CTRadioAccessTechnologyWCDMA {
                                        CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                                        dataManager.datas.set("WCDMA", forKey: "g3lastcompletion")
                                        dataManager.datas.synchronize()
                                        completionHandler("WCDMA")
                                        return
                                    } else if dataManager.nrp == CTRadioAccessTechnologyHSDPA {
                                        CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                                        dataManager.datas.set("HPLUS", forKey: "g3lastcompletion")
                                        dataManager.datas.synchronize()
                                        completionHandler("HPLUS")
                                        return
                                    }
                                    //                                    if dataManager.statisticsAgreement{
                                    //                                        let locationManager = CLLocationManager()
                                    //                                        AppDelegate.sendLocationToServer(latitude: locationManager.location?.coordinate.latitude ?? 0, longitude: locationManager.location?.coordinate.longitude ?? 0)
                                    //                                    }
                                    
                                } else {
                                    if CLLocationManager.authorizationStatus() == .authorizedAlways {
                                        // On verifie la localisation en arrière plan
                                        let locationManager = CLLocationManager()
                                        let latitude = locationManager.location?.coordinate.latitude ?? 0
                                        let longitude = locationManager.location?.coordinate.longitude ?? 0
                                        
                                        let context: NSManagedObjectContext
                                        if #available(iOS 10.0, *) {
                                            context = persistentContainer.viewContext
                                        } else {
                                            // Fallback on earlier versions
                                            context = managedObjectContext
                                        }
                                        guard let entity = NSEntityDescription.entity(forEntityName: "Locations", in: context) else {
                                            CoverageManager.addCurrentCoverageData(dataManager)
                                            dataManager.datas.set("NOTCOVERED", forKey: "g3lastcompletion")
                                            dataManager.datas.synchronize()
                                            completionHandler("NOTCOVERED")
                                            return
                                        }
                                        
                                        if latitude != 0 && longitude != 0 {
                                            let newCoo = NSManagedObject(entity: entity, insertInto: context)
                                            
                                            newCoo.setValue(latitude, forKey: "lat")
                                            newCoo.setValue(longitude, forKey: "lon")
                                            
                                            context.performAndWait({
                                                do {
                                                    try context.save()
                                                    print("COORDINATES SAVED!")
                                                    NotificationManager.sendNotification(for: .saved)
                                                    print("SPEEDTEST IN BACKGROUND SUCCESSFUL!")
                                                    CoverageManager.addCurrentCoverageData(dataManager)
                                                    dataManager.datas.set("NOTCOVERED", forKey: "g3lastcompletion")
                                                    dataManager.datas.synchronize()
                                                    completionHandler("NOTCOVERED")
                                                    return
                                                } catch {
                                                    print("Failed saving")
                                                    CoverageManager.addCurrentCoverageData(dataManager)
                                                    dataManager.datas.set("NOTCOVERED", forKey: "g3lastcompletion")
                                                    dataManager.datas.synchronize()
                                                    completionHandler("NOTCOVERED")
                                                    return
                                                }
                                            })
                                        } else {
                                            print("No valid coordinates")
                                            CoverageManager.addCurrentCoverageData(dataManager)
                                            dataManager.datas.set("NOTCOVERED", forKey: "g3lastcompletion")
                                            dataManager.datas.synchronize()
                                            completionHandler("NOTCOVERED")
                                            return
                                        }
                                        
                                        
                                    }
                                    
                                }
                                CoverageManager.addCurrentCoverageData(dataManager)
                                completionHandler("ESCAPED_SPEEDTEST")
                                return
                            }
                        }
                        return
                        
                    } else {
                        if dataManager.carrierNetwork == CTRadioAccessTechnologyLTE && dataManager.targetMNC == dataManager.itiMNC {
                            CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                            dataManager.datas.set("LTE", forKey: "g3lastcompletion")
                            dataManager.datas.synchronize()
                            completionHandler("LTE")
                            return
                        }
                        else if dataManager.nrp == CTRadioAccessTechnologyWCDMA {
                            CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                            dataManager.datas.set("WCDMA", forKey: "g3lastcompletion")
                            dataManager.datas.synchronize()
                            completionHandler("WCDMA")
                            return
                        } else if dataManager.nrp == CTRadioAccessTechnologyHSDPA {
                            CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                            dataManager.datas.set("HPLUS", forKey: "g3lastcompletion")
                            dataManager.datas.synchronize()
                            completionHandler("HPLUS")
                            return
                        }
                        
                        //                        if dataManager.statisticsAgreement{
                        //                            let locationManager = CLLocationManager()
                        //                            AppDelegate.sendLocationToServer(latitude: locationManager.location?.coordinate.latitude ?? 0, longitude: locationManager.location?.coordinate.longitude ?? 0)
                        //                        }
                    }
                    
                    
                } else {
                    if dataManager.carrierNetwork == CTRadioAccessTechnologyLTE && dataManager.targetMNC == dataManager.itiMNC {
                        CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                        dataManager.datas.set("LTE", forKey: "g3lastcompletion")
                        dataManager.datas.synchronize()
                        completionHandler("LTE")
                        return
                    } else if dataManager.carrierNetwork == CTRadioAccessTechnologyLTE {
                        CoverageManager.addCurrentCoverageData(dataManager)
                        dataManager.datas.set("POSSLTE", forKey: "g3lastcompletion")
                        dataManager.datas.synchronize()
                        completionHandler("POSSLTE")
                        return
                    }
                    if dataManager.femto {
                        if dataManager.nrp == CTRadioAccessTechnologyWCDMA {
                            CoverageManager.addCurrentCoverageData(dataManager)
                            dataManager.datas.set("POSSWCDMA", forKey: "g3lastcompletion")
                            dataManager.datas.synchronize()
                            completionHandler("POSSWCDMA")
                            return
                        } else if dataManager.nrp == CTRadioAccessTechnologyHSDPA {
                            CoverageManager.addCurrentCoverageData(dataManager)
                            dataManager.datas.set("POSSHPLUS", forKey: "g3lastcompletion")
                            dataManager.datas.synchronize()
                            completionHandler("POSSHPLUS")
                            return
                        }
                    } else {
                        if dataManager.nrp == CTRadioAccessTechnologyWCDMA {
                            CoverageManager.addCurrentCoverageData(dataManager)
                            dataManager.datas.set("WCDMA", forKey: "g3lastcompletion")
                            dataManager.datas.synchronize()
                            completionHandler("WCDMA")
                            return
                        } else if dataManager.nrp == CTRadioAccessTechnologyHSDPA {
                            CoverageManager.addCurrentCoverageData(dataManager)
                            dataManager.datas.set("HPLUS", forKey: "g3lastcompletion")
                            dataManager.datas.synchronize()
                            completionHandler("HPLUS")
                            return
                        }
                    }
                    //                    if dataManager.statisticsAgreement{
                    //                        let locationManager = CLLocationManager()
                    //                        AppDelegate.sendLocationToServer(latitude: locationManager.location?.coordinate.latitude ?? 0, longitude: locationManager.location?.coordinate.longitude ?? 0)
                    //                    }
                }
            } else {
                print("H+ ou LTE autorisée")
                CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                dataManager.datas.set("STOP", forKey: "g3lastcompletion")
                dataManager.datas.synchronize()
                completionHandler("STOP")
                return
            }
        } else if dataManager.carrierNetwork == CTRadioAccessTechnologyEdge && dataManager.out2G {
            if !dataManager.allow012G {
                print("2G non autorisée")
                CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                dataManager.datas.set("EDGE", forKey: "g3lastcompletion")
                dataManager.datas.synchronize()
                completionHandler("EDGE")
                return
                //                if dataManager.statisticsAgreement{
                //                    let locationManager = CLLocationManager()
                //                    AppDelegate.sendLocationToServer(latitude: locationManager.location?.coordinate.latitude ?? 0, longitude: locationManager.location?.coordinate.longitude ?? 0)
                //                }
            } else {
                print("2G autorisée ou incompatible")
                if dataManager.out2G {
                    CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                }
                dataManager.datas.set("STOP", forKey: "g3lastcompletion")
                dataManager.datas.synchronize()
                completionHandler("STOP")
                return
            }
        }
        CoverageManager.addCurrentCoverageData(dataManager)
        completionHandler("ERROR")
        return
    }
    
    static func checkDataDisabled(_ dataManager: DataManager = DataManager(), completionHandler: @escaping (Bool) -> ()) {
        
        let zone = dataManager.zoneCheck()
        
        if DataManager.isConnectedToNetwork() && !DataManager.isWifiConnected() && dataManager.connectedMCC != dataManager.targetMCC && (zone == "OUTZONE" || zone == "CALLS") {
            completionHandler(true)
            return
        }
        completionHandler(false)
        return
    }
    
    static func directDataDCheck(_ dataManager: DataManager = DataManager()) -> Bool {
        
        let zone = dataManager.zoneCheck()
        
        if DataManager.isConnectedToNetwork() && !DataManager.isWifiConnected() && dataManager.connectedMCC != dataManager.targetMCC && (zone == "OUTZONE" || zone == "CALLS") {
            return true
        }
        return false
    }
    
    static func newCountryCheck(_ dataManager: DataManager = DataManager()){
        let country = CarrierIdentification.getIsoCountryCode(dataManager.connectedMCC, dataManager.connectedMNC).uppercased()
        
        if country == "--"{
            return
        }
        
        let zone = dataManager.zoneCheck()
        
        var simpleNetwork = ""
        
        if #available(iOS 14.1, *), dataManager.currentNetwork == CTRadioAccessTechnologyNR || dataManager.currentNetwork == CTRadioAccessTechnologyNRNSA {
            simpleNetwork = "5G"
            return
        }
        else if dataManager.carrierNetwork == CTRadioAccessTechnologyLTE {
            simpleNetwork = "4G"
        } else if dataManager.carrierNetwork == CTRadioAccessTechnologyEdge {
            simpleNetwork = "E"
        } else if dataManager.carrierNetwork == CTRadioAccessTechnologyGPRS {
            simpleNetwork = "GPRS"
        } else {
            simpleNetwork = "3G"
        }
        
        if dataManager.targetMCC == "208" && dataManager.targetMNC == "15" && dataManager.connectedMCC != "208" {
            // ATTENTION TRAITER LES EXCEPTIONS EN PREMIER ! Changer le country en fonction du MNC !
            
            if zone == "ALL" {
                NotificationManager.sendNotification(for: .newCountryAllFree, with: "new_country_welcome_title".localized().format([dataManager.carrier, simpleNetwork, country]))
            } else if zone == "CALLS"{
                NotificationManager.sendNotification(for: .newCountryBasicFree, with: "new_country_welcome_title".localized().format([dataManager.carrier, simpleNetwork, country]))
            } else if zone == "INTERNET"{
                NotificationManager.sendNotification(for: .newCountryInternetFree, with: "new_country_welcome_title".localized().format([dataManager.carrier, simpleNetwork, country]))
            } else {
                NotificationManager.sendNotification(for: .newCountryNothingFree, with: "new_country_welcome_title".localized().format([dataManager.carrier, simpleNetwork, country]))
            }
        } else if dataManager.connectedMCC != dataManager.targetMCC {
            // ATTENTION TRAITER LES EXCEPTIONS EN PREMIER ! Changer le country en fonction du MNC !
            if zone == "ALL" {
                NotificationManager.sendNotification(for: .newCountryAll, with: "new_country_welcome_title".localized().format([dataManager.carrier, simpleNetwork, country]))
            } else if zone == "CALLS"{
                NotificationManager.sendNotification(for: .newCountryBasic, with: "new_country_welcome_title".localized().format([dataManager.carrier, simpleNetwork, country]))
            } else if zone == "INTERNET"{
                NotificationManager.sendNotification(for: .newCountryInternet, with: "new_country_welcome_title".localized().format([dataManager.carrier, simpleNetwork, country]))
            } else {
                NotificationManager.sendNotification(for: .newCountryNothing, with: "new_country_welcome_title".localized().format([dataManager.carrier, simpleNetwork, country]))
            }
        }
        
    }
    
    static func engineRunning(locations: [CLLocation] = [CLLocation]()){
        let dataManager = DataManager()
        engine(locations: locations, g3engine: false) { result in
            if result == "LTE" {
                NotificationManager.sendNotification(for: .alertLTE)
            } else if result == "HPLUS" {
                NotificationManager.sendNotification(for: .alertHPlus)
            } else if result == "POSSHPLUS" {
                NotificationManager.sendNotification(for: .alertPossibleHPlus)
            } else if result == "WCDMA" {
                NotificationManager.sendNotification(for: .alertWCDMA)
            } else if result == "POSSWCDMA" {
                NotificationManager.sendNotification(for: .alertPossibleWCDMA)
            } else if result == "POSSLTE" {
                NotificationManager.sendNotification(for: .alertPossibleLTE)
            } else if result == "EDGE" {
                NotificationManager.sendNotification(for: .alertEdge)
            } else if result == "NEWSIM" {
                if dataManager.dispInfoNotif {
                    NotificationManager.sendNotification(for: .newSIM)
                }
            }
        }
    }
    
    static func engine(locations: [CLLocation] = [CLLocation](), g3engine: Bool = false, completionHandler: @escaping (String) -> ()) {
        print("TRIGGERED")
        
        let dataManager = DataManager()
        
        var allowCountryDetection = true
        if(dataManager.datas.value(forKey: "allowCountryDetection") != nil){
            allowCountryDetection = dataManager.datas.value(forKey: "allowCountryDetection") as? Bool ?? true
        }
        
        // Aucune configuration faite
        if !dataManager.setupDone {
            dataManager.datas.set("NOSETUP", forKey: "g3lastcompletion")
            dataManager.datas.synchronize()
            completionHandler("NOSETUP")
            return
        }
        
        // On vérifie que la vérification est activée
        if !dataManager.stopverification {
            var lastConnectedCountry = "208"
            if dataManager.datas.value(forKey: "lastConnectedCountry") != nil {
                lastConnectedCountry = dataManager.datas.value(forKey: "lastConnectedCountry") as? String ?? "208"
            }
            
            // Vérification de data
            if allowCountryDetection {
                checkDataDisabled(dataManager) { result in
                let country = CarrierIdentification.getIsoCountryCode(String(dataManager.connectedMCC), String(dataManager.connectedMNC)).uppercased()
                    if result == true {
                        NotificationManager.sendNotification(for: .alertDataDrain, with: "data_drain_notification_description".localized().format([dataManager.carrier, country]))
                    }
                    
                }
            }
            
            //print(lastLocation)
            
            let hour = Calendar.current.component(.hour, from: Date())
            
            // Pas d'update la nuit entre 1 am et 5 am pour le moteur G2 uniquement
            if hour > 0 && hour < 6 && !g3engine {
                print("FMobile fait un gros dodo")
                completionHandler("SLEEP")
                return
            }
            
            // On stop parce que en appel
            if DataManager.isOnPhoneCall() {
                print("IN CALL...")
                completionHandler("INCALL")
                return
            }
            
            if dataManager.airplanemode {
                print("Airplane mode enabled")
                completionHandler("AIRPLANEMODE")
                return
            }
            
            if #available(iOS 14.1, *), dataManager.currentNetwork == CTRadioAccessTechnologyNRNSA || dataManager.currentNetwork == CTRadioAccessTechnologyNR {
                print("5G unsupported")
                completionHandler("UNSUPPORTED")
                return
            }
            
            let country = CarrierIdentification.getIsoCountryCode(String(dataManager.connectedMCC), String(dataManager.connectedMNC)).uppercased()
            
            print(dataManager.carrierNetwork)
            
            // Changement de pays
            if lastConnectedCountry != country {
                newCountryCheck(dataManager)
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
            
            // Changement de SIM
            if (countryCode != dataManager.targetMCC || mobileNetworkName != dataManager.targetMNC) && (mobileNetworkName != "null" || countryCode != "null") {
                dataManager.datas.removeObject(forKey: "MCC")
                dataManager.datas.set(false, forKey: "setupDone")
                dataManager.datas.set("NEWSIM", forKey: "g3lastcompletion")
                dataManager.datas.set(Date(), forKey: "syncNewSIM")
                dataManager.resetCountryIncluded()
                dataManager.datas.synchronize()
                if DataManager.isConnectedToNetwork() {
                    self.bgUpdateSetup()
                }
                completionHandler("NEWSIM")
                return
            }
            
            print(dataManager.hp)
            
            
            // Début des vérifications
            if country != land {
                print("Country != land!")
                print(country)
                print(land)
                CoverageManager.addCurrentCoverageData(dataManager, aboard: directDataDCheck())
                dataManager.datas.set("ABOARD", forKey: "g3lastcompletion")
                dataManager.datas.synchronize()
                completionHandler("ABOARD")
                return
            }
            
            if DataManager.isWifiConnected() && !dataManager.verifyonwifi {
                // L'utilisateur est connecté au WiFi et est chez Free, et a demandé à ne pas controler le WiFi
                print("L'utilisateur a désactivé le contrôle en WiFi")
                dataManager.datas.set("WIFI", forKey: "g3lastcompletion")
                dataManager.datas.synchronize()
                
                if dataManager.connectedMCC == dataManager.targetMCC && dataManager.connectedMCC == dataManager.itiMNC {
                    CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                } else if dataManager.carrierNetwork == CTRadioAccessTechnologyEdge && dataManager.out2G {
                    CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                } else if dataManager.carrierNetwork == dataManager.nrp {
                    if dataManager.femto {
                        CoverageManager.addCurrentCoverageData(dataManager)
                    } else {
                        CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                    }
                } else {
                    CoverageManager.addCurrentCoverageData(dataManager)
                }
                
                completionHandler("WIFI")
                return
            }
            
            if dataManager.carrierNetwork == dataManager.hp || (dataManager.carrierNetwork == CTRadioAccessTechnologyLTE && (dataManager.allow014G || (dataManager.modeExpert ? false : !dataManager.roamLTE))) {
                print("HOME LTE/3G => SKIP")
                dataManager.lastnet = dataManager.carrierNetwork
                dataManager.count = 0
                dataManager.wasEnabled = 0
                dataManager.datas.set(dataManager.lastnet, forKey: "lastnet")
                dataManager.datas.set(dataManager.count, forKey: "count")
                dataManager.datas.set(dataManager.wasEnabled, forKey: "wasEnabled")
                dataManager.datas.set("HOME", forKey: "g3lastcompletion")
                dataManager.datas.synchronize()
                CoverageManager.addCurrentCoverageData(dataManager)
                completionHandler("HOME")
                return
            }
            
            if dataManager.minimalSetup && dataManager.connectedMCC == dataManager.targetMCC && dataManager.connectedMNC != dataManager.targetMNC {
                let speed = locations.last?.speed ?? 0
                print("The current speed is ", speed * 3.6, "km/h.")
                if speed * 3.6 > 80 {
                    print("l'utilisateur va à une vitesse ne le permettant pas de rester accroché à une antenne Free (route de campagne/autoroute/TGV).")
                    dataManager.datas.set("TOOFAST", forKey: "g3lastcompletion")
                    dataManager.datas.synchronize()
                    CoverageManager.addCurrentCoverageData(dataManager)
                    completionHandler("TOOFAST")
                    return
                }
                
                let currlat = locations.last?.coordinate.latitude ?? 0
                let currlon = locations.last?.coordinate.longitude ?? 0
                
                if currlat == 0 || currlon == 0 {
                    if dataManager.carrierNetwork == CTRadioAccessTechnologyLTE && !dataManager.allow014G {
                        CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                        dataManager.datas.set("LTE", forKey: "g3lastcompletion")
                        dataManager.datas.synchronize()
                        completionHandler("LTE")
                        return
                    }
                    else if dataManager.carrierNetwork == CTRadioAccessTechnologyHSDPA && !dataManager.allow013G {
                        CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                        dataManager.datas.set("HPLUS", forKey: "g3lastcompletion")
                        dataManager.datas.synchronize()
                        completionHandler("HPLUS")
                        return
                    } else if dataManager.carrierNetwork == CTRadioAccessTechnologyWCDMA && !dataManager.allow013G {
                        CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                        dataManager.datas.set("WCDMA", forKey: "g3lastcompletion")
                        dataManager.datas.synchronize()
                        completionHandler("WCDMA")
                        return
                    } else if dataManager.carrierNetwork == CTRadioAccessTechnologyEdge && !dataManager.allow012G {
                        CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                        dataManager.datas.set("EDGE", forKey: "g3lastcompletion")
                        dataManager.datas.synchronize()
                        completionHandler("EDGE")
                        return
                    }
                    
                    //                    if dataManager.statisticsAgreement{
                    //                        AppDelegate.sendLocationToServer(latitude: locations.last?.coordinate.latitude ?? 0, longitude: locations.last?.coordinate.longitude ?? 0)
                    //                    }
                    CoverageManager.addCurrentCoverageData(dataManager)
                    dataManager.datas.set("HOME", forKey: "g3lastcompletion")
                    dataManager.datas.synchronize()
                    completionHandler("HOME")
                    return
                }
                
                let currlocation = CLLocation(latitude: CLLocationDegrees(currlat), longitude: CLLocationDegrees(currlon))
                
                let context: NSManagedObjectContext
                if #available(iOS 10.0, *) {
                    context = persistentContainer.viewContext
                } else {
                    // Fallback on earlier versions
                    context = managedObjectContext
                }
                
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
                    
                    if !detected {
                        if dataManager.carrierNetwork == CTRadioAccessTechnologyLTE && !dataManager.allow014G {
                            CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                            dataManager.datas.set("LTE", forKey: "g3lastcompletion")
                            dataManager.datas.synchronize()
                            completionHandler("LTE")
                            return
                        }
                        else if dataManager.carrierNetwork == CTRadioAccessTechnologyHSDPA && !dataManager.allow013G {
                            CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                            dataManager.datas.set("HPLUS", forKey: "g3lastcompletion")
                            dataManager.datas.synchronize()
                            completionHandler("HPLUS")
                            return
                        } else if dataManager.carrierNetwork == CTRadioAccessTechnologyWCDMA && !dataManager.allow013G {
                            CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                            dataManager.datas.set("WCDMA", forKey: "g3lastcompletion")
                            dataManager.datas.synchronize()
                            completionHandler("WCDMA")
                            return
                        } else if dataManager.carrierNetwork == CTRadioAccessTechnologyEdge && !dataManager.allow012G {
                            CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                            dataManager.datas.set("EDGE", forKey: "g3lastcompletion")
                            dataManager.datas.synchronize()
                            completionHandler("EDGE")
                            return
                        }
                        
                        CoverageManager.addCurrentCoverageData(dataManager)
                        dataManager.datas.set("HOME", forKey: "g3lastcompletion")
                        dataManager.datas.synchronize()
                        completionHandler("HOME")
                        return
                        //                        if dataManager.statisticsAgreement{
                        //                            AppDelegate.sendLocationToServer(latitude: locations.last?.coordinate.latitude ?? 0, longitude: locations.last?.coordinate.longitude ?? 0)
                        //                        }
                    } else {
                        print("detected one nearby hotspot, STOPING OPERATIONS.")
                        CoverageManager.addCurrentCoverageData(dataManager)
                        dataManager.datas.set("NOTCOVERED", forKey: "g3lastcompletion")
                        dataManager.datas.synchronize()
                        completionHandler("NOTCOVERED")
                        return
                    }
                } catch {
                    print("Failed")
                    if dataManager.carrierNetwork == CTRadioAccessTechnologyLTE && !dataManager.allow014G {
                        CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                        dataManager.datas.set("LTE", forKey: "g3lastcompletion")
                        dataManager.datas.synchronize()
                        completionHandler("LTE")
                        return
                    }
                    else if dataManager.carrierNetwork == CTRadioAccessTechnologyHSDPA && !dataManager.allow013G {
                        CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                        dataManager.datas.set("HPLUS", forKey: "g3lastcompletion")
                        dataManager.datas.synchronize()
                        completionHandler("HPLUS")
                        return
                    } else if dataManager.carrierNetwork == CTRadioAccessTechnologyWCDMA && !dataManager.allow013G {
                        CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                        dataManager.datas.set("WCDMA", forKey: "g3lastcompletion")
                        dataManager.datas.synchronize()
                        completionHandler("WCDMA")
                        return
                    } else if dataManager.carrierNetwork == CTRadioAccessTechnologyEdge && !dataManager.allow012G {
                        CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                        dataManager.datas.set("EDGE", forKey: "g3lastcompletion")
                        dataManager.datas.synchronize()
                        completionHandler("EDGE")
                        return
                    }
                    CoverageManager.addCurrentCoverageData(dataManager)
                    dataManager.datas.set("HOME", forKey: "g3lastcompletion")
                    dataManager.datas.synchronize()
                    completionHandler("HOME")
                    return
                    //                    if dataManager.statisticsAgreement{
                    //                        AppDelegate.sendLocationToServer(latitude: locations.last?.coordinate.latitude ?? 0, longitude: locations.last?.coordinate.longitude ?? 0)
                    //                    }
                }
                
            }
                
            else if dataManager.connectedMCC == dataManager.targetMCC && dataManager.connectedMNC == dataManager.chasedMNC {
                if (dataManager.carrierNetwork == dataManager.nrp && !dataManager.allow013G) || (dataManager.carrierNetwork == CTRadioAccessTechnologyEdge && !dataManager.allow012G && dataManager.out2G) || dataManager.carrierNetwork == CTRadioAccessTechnologyLTE && (!dataManager.allow014G && (dataManager.modeExpert ? true : dataManager.roamLTE)) {
                    let speed = locations.last?.speed ?? 0
                    print("The current speed is ", speed * 3.6, "km/h.")
                    if speed * 3.6 > 80 {
                        print("l'utilisateur va à une vitesse ne le permettant pas de rester accroché à une antenne Free (route de campagne/autoroute/TGV).")
                        dataManager.datas.set("TOOFAST", forKey: "g3lastcompletion")
                        dataManager.datas.synchronize()
                        CoverageManager.addCurrentCoverageData(dataManager)
                        completionHandler("TOOFAST")
                        return
                    }
                    
                    let currlat = locations.last?.coordinate.latitude ?? 0
                    let currlon = locations.last?.coordinate.longitude ?? 0
                    
                    if currlat == 0 || currlon == 0 {
                        initBackground(dataManager, g3engine, completionHandler: completionHandler)
                        return
                    }
                    
                    let currlocation = CLLocation(latitude: CLLocationDegrees(currlat), longitude: CLLocationDegrees(currlon))
                    
                    let context: NSManagedObjectContext
                    if #available(iOS 10.0, *) {
                        context = persistentContainer.viewContext
                    } else {
                        // Fallback on earlier versions
                        context = managedObjectContext
                    }
                    
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
                        
                        if !detected {
                            initBackground(dataManager, g3engine, completionHandler: completionHandler)
                            return
                        } else {
                            print("detected one nearby hotspot, STOPING OPERATIONS.")
                            CoverageManager.addCurrentCoverageData(dataManager)
                            dataManager.datas.set("NOTCOVERED", forKey: "g3lastcompletion")
                            dataManager.datas.synchronize()
                            completionHandler("NOTCOVERED")
                            return
                        }
                    } catch {
                        print("Failed")
                        initBackground(dataManager, g3engine, completionHandler: completionHandler)
                        return
                    }
                } else {
                    print("L'utilisateur est en 4G/3G itinérance mais autorisée")
                    CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                    dataManager.datas.set("HOME", forKey: "g3lastcompletion")
                    dataManager.datas.synchronize()
                    completionHandler("HOME")
                    return
                }
            } else {
                print("L'utilisateur n\'est pas connecté sur le réseau itinérant")
                CoverageManager.addCurrentCoverageData(dataManager)
                dataManager.datas.set("HOME", forKey: "g3lastcompletion")
                dataManager.datas.synchronize()
                completionHandler("HOME")
                return
            }
        }
    }
    
    
    @available(iOS 10.0, *)
    static var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "DATA")
        
        guard let storeUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.fr.plugn.fmobile")?.appendingPathComponent("DATA.sqlite") else { return NSPersistentContainer() }
        
        
        let description = NSPersistentStoreDescription()
        description.shouldInferMappingModelAutomatically = true
        description.shouldMigrateStoreAutomatically = true
        description.url = storeUrl
        
        container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: storeUrl)]
        
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // iOS 9 and below
    static var applicationDocumentsDirectory: URL = {

        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()

    static var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "DATA", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL) ?? NSManagedObjectModel()
    }()

    static var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let url = applicationDocumentsDirectory.appendingPathComponent("DATA.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }

        return coordinator
    }()

    static var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

}
