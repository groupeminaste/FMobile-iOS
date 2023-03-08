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
    static func iPadInit(_ dataManager: DataManager = DataManager(), _ g3engine: Bool = false, service: FMNetwork, completionHandler: @escaping (String) -> ()) {
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
                                process(dataManager, g3engine, service: service, completionHandler: completionHandler)
                                return
                            }
                            
                            print("ISO COUNTRY CODE :",  placemark.isoCountryCode?.uppercased() ?? "")
                            
                            if placemark.isoCountryCode?.uppercased() ?? service.card.land == service.card.land {
                                print("L'utilisateur est dans son pays")
                                dataManager.datas.set(placemark.isoCountryCode?.uppercased() ?? service.card.land, forKey: "lastCountry")
                                dataManager.datas.set(Date(), forKey: "timeLastCountry")
                                dataManager.datas.synchronize()
                                process(dataManager, g3engine, service: service, completionHandler: completionHandler)
                                return
                            } else {
                                print("L'utilisateur est à l'étranger")
                                dataManager.datas.set(placemark.isoCountryCode?.uppercased() ?? "ABO", forKey: "lastCountry")
                                dataManager.datas.set(Date(), forKey: "timeLastCountry")
                                dataManager.datas.synchronize()
                                CoverageManager.addCurrentCoverageData(dataManager, aboard: directDataDCheck(dataManager, service: service))
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
                        process(dataManager, g3engine, service: service, completionHandler: completionHandler)
                        return
                    }
                } else {
                    if dataManager.lastCountry == service.card.land {
                        print("Utilisation du cache : Home Network")
                        process(dataManager, g3engine, service: service, completionHandler: completionHandler)
                        return
                    } else {
                        print("Selon le cache, l'utilisateur est à l'étranger")
                        CoverageManager.addCurrentCoverageData(dataManager, aboard: directDataDCheck(dataManager, service: service))
                        dataManager.datas.set("ABOARD", forKey: "g3lastcompletion")
                        dataManager.datas.synchronize()
                        completionHandler("ABOARD")
                        return
                    }
                }
                
            } else {
                // L'utilisateur n'a pas donné son accord
                print("The user has not allowed Country Detection")
                process(dataManager, g3engine, service: service, completionHandler: completionHandler)
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
        // On fetch la configuration depuis le serveur
        
        for service in dataManager.simtrays {
            dataManager.datas.set(true, forKey: "isSettingUp")
            dataManager.datas.synchronize()
            CarrierConfiguration.fetch(forMCC: service.card.carrier.mobileCountryCode ?? "", andMNC: service.card.carrier.mobileNetworkCode ?? "") { configuration in
                // On vérifie si des valeurs sont trouvés
                if let configuration = configuration {
                    // On enregistre les valeurs issues du serveur
                    dataManager.datas.set(configuration.stms, forKey: service.card.active ? "STMS" : "eSTMS")
                    dataManager.datas.set(configuration.hp, forKey: service.card.active ? "HP" : "eHP")
                    dataManager.datas.set(configuration.nrp, forKey: service.card.active ? "NRP" : "eNRP")
                    dataManager.datas.set(configuration.mcc, forKey: service.card.active ? "MCC" : "eMCC")
                    dataManager.datas.set(configuration.mnc, forKey: service.card.active ? "MNC" : "eMNC")
                    dataManager.datas.set(configuration.land, forKey: service.card.active ? "LAND" : "eLAND")
                    dataManager.datas.set(configuration.itiname, forKey: service.card.active ? "ITINAME" : "eITINAME")
                    dataManager.datas.set(configuration.homename, forKey: service.card.active ? "HOMENAME" : "eHOMENAME")
                    dataManager.datas.set(configuration.itimnc, forKey: service.card.active ? "ITIMNC" : "eITIMNC")
                    dataManager.datas.set(configuration.nrfemto, forKey: service.card.active ? "NRFEMTO" : "eNRFEMTO")
                    dataManager.datas.set(configuration.out2G, forKey: service.card.active ? "OUT2G" : "eOUT2G")
                    dataManager.datas.set(configuration.minimalSetup, forKey: service.card.active ? "minimalSetup" : "eminimalSetup")
                    dataManager.datas.set(configuration.disableFMobileCore, forKey: service.card.active ? "disableFMobileCore" : "edisableFMobileCore")
                    dataManager.datas.set(configuration.countriesData, forKey: service.card.active ? "countriesData" : "ecountriesData")
                    dataManager.datas.set(configuration.countriesVoice, forKey: service.card.active ? "countriesVoice" : "ecountriesVoice")
                    dataManager.datas.set(configuration.countriesVData, forKey: service.card.active ? "countriesVData" : "ecountriesVData")
                    dataManager.datas.set(configuration.carrierServices, forKey: service.card.active ? "carrierServices" : "ecarrierServices")
                    dataManager.datas.set(configuration.roamLTE, forKey: service.card.active ? "roamLTE" : "eroamLTE")
                    dataManager.datas.set(configuration.roam5G, forKey: service.card.active ? "roam5G" : "eroam5G")
                    dataManager.datas.set(configuration.setupDone, forKey: service.card.active ? "setupDone" : "esetupDone")
                    dataManager.datas.set(false, forKey: "isSettingUp")
                    dataManager.datas.synchronize()
                    // Fin de la configuration depuis le serveur
                    CoverageManager.addCurrentCoverageData(dataManager)
                }
            }
        }
        
    }
    
    // Initialsation
    static func initBackground(_ dataManager: DataManager = DataManager(), _ g3engine: Bool = false, service: FMNetwork, completionHandler: @escaping (String) -> ()) {
        // Traitement de l'iPad
        if UIDevice.current.userInterfaceIdiom == .pad {
            if (service.network.mcc == "---" && service.network.mnc == "--"){
                iPadInit(dataManager, g3engine, service: service, completionHandler: completionHandler)
                return
            }
        }
        
        let countryCode = service.card.carrier.mobileCountryCode ?? "null"
        let mobileNetworkName = service.card.carrier.mobileNetworkCode ?? "null"
        
        // On vérifie si l'utilisateur a donné son accord pour vérifier le pays en arrière plan
        if !dataManager.stopverification {
            if (countryCode != service.card.mcc || mobileNetworkName != service.card.mnc) && (mobileNetworkName != "null" || countryCode != "null") {
                dataManager.datas.removeObject(forKey: "MCC")
                dataManager.datas.set(false, forKey: "setupDone")
                dataManager.datas.set("NEWSIM", forKey: "g3lastcompletion")
                dataManager.datas.set(Date(), forKey: "syncNewSIM")
                dataManager.resetCountryIncluded(service: service)
                dataManager.datas.synchronize()
                if DataManager.isConnectedToNetwork() {
                    self.bgUpdateSetup()
                }
                completionHandler("NEWSIM")
                return
            }
            
            process(dataManager, g3engine, service: service, completionHandler: completionHandler)
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
    static func process(_ dataManager: DataManager = DataManager(), _ g3engine: Bool = false, service: FMNetwork, completionHandler: @escaping (String) -> ()) {
        
        var request: Bool
        if #available(iOS 14.1, *) {
            request = (service.network.mcc == service.card.mcc && service.network.mnc == service.card.itiMNC && (service.network.connected == CTRadioAccessTechnologyLTE || service.network.connected == CTRadioAccessTechnologyNR || service.network.connected == CTRadioAccessTechnologyNRNSA)) || (service.network.mcc == service.card.mcc && service.network.mnc == service.card.chasedMNC && (service.network.connected == CTRadioAccessTechnologyLTE || service.network.connected == CTRadioAccessTechnologyNR || service.network.connected == CTRadioAccessTechnologyNRNSA))
        } else {
            request = (service.network.mcc == service.card.mcc && service.network.mnc == service.card.itiMNC && service.network.connected == CTRadioAccessTechnologyLTE) || (service.network.mcc == service.card.mcc && service.network.mnc == service.card.chasedMNC && service.network.connected != CTRadioAccessTechnologyLTE)
        }
        
        if request {
                // Le contrôle d'itinérance démarre.
            netfetch(dataManager, g3engine, service: service, completionHandler: completionHandler)
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
    static func netfetch(_ dataManager: DataManager = DataManager(), _ g3engine: Bool = false, service: FMNetwork, completionHandler: @escaping (String) -> ()) {
        let now = Date()
        
        print(abs(dataManager.timecode.timeIntervalSinceNow))
        print(now)
        
        if service.network.connected != dataManager.lastnet {
            print("THE NETWORK HAS CHANGED! PERFORMING NEW CHECK.")
            dataManager.lastnet = service.network.connected
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
                    
                    if #available(iOS 14.0, *) {
                        if locationManager.accuracyAuthorization != .fullAccuracy {
                            completionHandler("BADCONFIG")
                            return
                        }
                    }

                    
                    let latitude = locationManager.location?.coordinate.latitude ?? 0
                    let longitude = locationManager.location?.coordinate.longitude ?? 0
                    
                    if latitude != 0 && longitude != 0 {
                        let context: NSManagedObjectContext
                        if #available(iOS 10.0, *) {
                            context = PermanentStorage.persistentContainer.viewContext
                        } else {
                            // Fallback on earlier versions
                            context = PermanentStorage.managedObjectContext
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
                dataManager.lastnet = service.network.connected
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
                if (dataManager.g3lastcompletion == "NR" || dataManager.g3lastcompletion == "NRNSA" || dataManager.g3lastcompletion == "LTE" || dataManager.g3lastcompletion == "HPLUS" || dataManager.g3lastcompletion == "WCDMA" || dataManager.g3lastcompletion == "EDGE") && abs(dataManager.g3timecode.timeIntervalSinceNow) < 2*60 {
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
        
        print("Network changed, set to \(service.network.connected) at \(now)")
        
        var request: Bool
        var request2: Bool
        var request3: Bool
        if #available(iOS 14.1, *) {
            request = service.network.connected == CTRadioAccessTechnologyNR || service.network.connected == CTRadioAccessTechnologyNRNSA || service.network.connected == service.card.nrp || service.network.connected == CTRadioAccessTechnologyLTE
            request2 = (service.network.connected == service.card.nrp && !dataManager.allow013G) || (service.network.connected == CTRadioAccessTechnologyLTE && !dataManager.allow014G) || (service.network.connected == CTRadioAccessTechnologyNR && !dataManager.allow015G) || (service.network.connected == CTRadioAccessTechnologyNRNSA && !dataManager.allow015G)
            request3 = !dataManager.femtoLOWDATA && (dataManager.femto || service.network.connected == CTRadioAccessTechnologyLTE || service.network.connected == CTRadioAccessTechnologyNR || service.network.connected == CTRadioAccessTechnologyNRNSA) && !DataManager.isWifiConnected()
        } else {
            request = service.network.connected == service.card.nrp || service.network.connected == CTRadioAccessTechnologyLTE
            request2 = (service.network.connected == service.card.nrp && !dataManager.allow013G) || (service.network.connected == CTRadioAccessTechnologyLTE && !dataManager.allow014G)
            request3 = !dataManager.femtoLOWDATA && (dataManager.femto || service.network.connected == CTRadioAccessTechnologyLTE) && !DataManager.isWifiConnected()
        }
        
        // Début des vérifications
        if #available(iOS 14.1, *), service.network.connected == CTRadioAccessTechnologyNR && (dataManager.allow015G || (dataManager.modeExpert ? false : !service.card.roam5G)) {
            // L'utilisateur est en 4G, tout va bien
            print("HOME 5G: No need to reset.")
            CoverageManager.addCurrentCoverageData(dataManager)
            dataManager.datas.set("HOME", forKey: "g3lastcompletion")
            dataManager.datas.synchronize()
            completionHandler("HOME")
            return
        } else if #available(iOS 14.1, *), service.network.connected == CTRadioAccessTechnologyNRNSA && (dataManager.allow015G || (dataManager.modeExpert ? false : !service.card.roam5G)) {
            // L'utilisateur est en 4G, tout va bien
            print("HOME 5G NSA: No need to reset.")
            CoverageManager.addCurrentCoverageData(dataManager)
            dataManager.datas.set("HOME", forKey: "g3lastcompletion")
            dataManager.datas.synchronize()
            completionHandler("HOME")
            return
        } else if service.network.connected == CTRadioAccessTechnologyLTE && (dataManager.allow014G || (dataManager.modeExpert ? false : !service.card.roamLTE)) {
            // L'utilisateur est en 4G, tout va bien
            print("HOME LTE: No need to reset.")
            CoverageManager.addCurrentCoverageData(dataManager)
            dataManager.datas.set("HOME", forKey: "g3lastcompletion")
            dataManager.datas.synchronize()
            completionHandler("HOME")
            return
        } else if service.network.connected == service.card.hp {
            // L'utilisateur est en 3G RP, tout va bien
            print("HOME WCDMA: No need to reset.")
            CoverageManager.addCurrentCoverageData(dataManager)
            dataManager.datas.set("HOME", forKey: "g3lastcompletion")
            dataManager.datas.synchronize()
            completionHandler("HOME")
            return
        } else if request {
            // L'utilisateur est en 3G+ en Itinérance, vérification si autorisée
            if request2 {
                print("H+ ou LTE non autorisée.")
                if request3 {
                    
                    if service.card.nrdec {
                        Speedtest().testDownloadSpeedWithTimout(timeout: 5.0, usingURL: dataManager.url) { (speed, _) in
                            DispatchQueue.main.async {
                                print(speed ?? 0)
                                if speed ?? 0 < service.card.stms {
                                    print("SPEEDTEST IN BACKGROUND SUCCESSFUL!")
                                    
                                    if #available(iOS 14.1, *), service.network.connected == CTRadioAccessTechnologyNR {
                                        CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                                        dataManager.datas.set("NR", forKey: "g3lastcompletion")
                                        dataManager.datas.synchronize()
                                        completionHandler("NR")
                                        return
                                    } else if #available(iOS 14.1, *), service.network.connected == CTRadioAccessTechnologyNRNSA {
                                        CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                                        dataManager.datas.set("NRNSA", forKey: "g3lastcompletion")
                                        dataManager.datas.synchronize()
                                        completionHandler("NRNSA")
                                        return
                                    } else if service.network.connected == CTRadioAccessTechnologyLTE {
                                        CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                                        dataManager.datas.set("LTE", forKey: "g3lastcompletion")
                                        dataManager.datas.synchronize()
                                        completionHandler("LTE")
                                        return
                                    } else if service.card.nrp == CTRadioAccessTechnologyWCDMA {
                                        CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                                        dataManager.datas.set("WCDMA", forKey: "g3lastcompletion")
                                        dataManager.datas.synchronize()
                                        completionHandler("WCDMA")
                                        return
                                    } else if service.card.nrp == CTRadioAccessTechnologyHSDPA {
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
                                        
                                        if #available(iOS 14.0, *) {
                                            if locationManager.accuracyAuthorization != .fullAccuracy {
                                                completionHandler("BADCONFIG")
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
                        if #available(iOS 14.1, *), service.network.connected == CTRadioAccessTechnologyNR && service.network.mnc == service.card.itiMNC {
                            CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                            dataManager.datas.set("NR", forKey: "g3lastcompletion")
                            dataManager.datas.synchronize()
                            completionHandler("NR")
                            return
                        } else if #available(iOS 14.1, *), service.network.connected == CTRadioAccessTechnologyNRNSA && service.network.mnc == service.card.itiMNC {
                            CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                            dataManager.datas.set("NRNSA", forKey: "g3lastcompletion")
                            dataManager.datas.synchronize()
                            completionHandler("NRNSA")
                            return
                        } else if service.network.connected == CTRadioAccessTechnologyLTE && service.network.mnc == service.card.itiMNC {
                            CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                            dataManager.datas.set("LTE", forKey: "g3lastcompletion")
                            dataManager.datas.synchronize()
                            completionHandler("LTE")
                            return
                        } else if service.card.nrp == CTRadioAccessTechnologyWCDMA {
                            CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                            dataManager.datas.set("WCDMA", forKey: "g3lastcompletion")
                            dataManager.datas.synchronize()
                            completionHandler("WCDMA")
                            return
                        } else if service.card.nrp == CTRadioAccessTechnologyHSDPA {
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
                    if #available(iOS 14.1, *), service.network.connected == CTRadioAccessTechnologyNR && service.network.mnc == service.card.itiMNC {
                        CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                        dataManager.datas.set("NR", forKey: "g3lastcompletion")
                        dataManager.datas.synchronize()
                        completionHandler("NR")
                        return
                    } else if #available(iOS 14.1, *), service.network.connected == CTRadioAccessTechnologyNRNSA && service.network.mnc == service.card.itiMNC {
                        CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                        dataManager.datas.set("NRNSA", forKey: "g3lastcompletion")
                        dataManager.datas.synchronize()
                        completionHandler("NRNSA")
                        return
                    } else if service.network.connected == CTRadioAccessTechnologyLTE && service.network.mnc == service.card.itiMNC {
                        CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                        dataManager.datas.set("LTE", forKey: "g3lastcompletion")
                        dataManager.datas.synchronize()
                        completionHandler("LTE")
                        return
                    } else  if #available(iOS 14.1, *), service.network.connected == CTRadioAccessTechnologyNR {
                        CoverageManager.addCurrentCoverageData(dataManager)
                        dataManager.datas.set("POSSNR", forKey: "g3lastcompletion")
                        dataManager.datas.synchronize()
                        completionHandler("POSSNR")
                        return
                    } else if #available(iOS 14.1, *), service.network.connected == CTRadioAccessTechnologyNRNSA {
                        CoverageManager.addCurrentCoverageData(dataManager)
                        dataManager.datas.set("POSSNRNSA", forKey: "g3lastcompletion")
                        dataManager.datas.synchronize()
                        completionHandler("POSSNRNSA")
                        return
                    } else if service.network.connected == CTRadioAccessTechnologyLTE {
                        CoverageManager.addCurrentCoverageData(dataManager)
                        dataManager.datas.set("POSSLTE", forKey: "g3lastcompletion")
                        dataManager.datas.synchronize()
                        completionHandler("POSSLTE")
                        return
                    }
                    if dataManager.femto {
                        if service.card.nrp == CTRadioAccessTechnologyWCDMA {
                            CoverageManager.addCurrentCoverageData(dataManager)
                            dataManager.datas.set("POSSWCDMA", forKey: "g3lastcompletion")
                            dataManager.datas.synchronize()
                            completionHandler("POSSWCDMA")
                            return
                        } else if service.card.nrp == CTRadioAccessTechnologyHSDPA {
                            CoverageManager.addCurrentCoverageData(dataManager)
                            dataManager.datas.set("POSSHPLUS", forKey: "g3lastcompletion")
                            dataManager.datas.synchronize()
                            completionHandler("POSSHPLUS")
                            return
                        }
                    } else {
                        if service.card.nrp == CTRadioAccessTechnologyWCDMA {
                            CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                            dataManager.datas.set("WCDMA", forKey: "g3lastcompletion")
                            dataManager.datas.synchronize()
                            completionHandler("WCDMA")
                            return
                        } else if service.card.nrp == CTRadioAccessTechnologyHSDPA {
                            CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
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
        } else if service.network.connected == CTRadioAccessTechnologyEdge && service.card.out2G {
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
                if service.card.out2G {
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
    
    static func checkDataDisabled(_ dataManager: DataManager = DataManager(), service: FMNetwork, completionHandler: @escaping (Bool) -> ()) {
        
        let zone = dataManager.zoneCheck(service: service)
        
        if DataManager.isConnectedToNetwork() && !DataManager.isWifiConnected() && service.network.mcc != service.card.mcc && (zone == "OUTZONE" || zone == "CALLS") {
            completionHandler(true)
            return
        }
        completionHandler(false)
        return
    }
    
    static func directDataDCheck(_ dataManager: DataManager = DataManager(), service: FMNetwork) -> Bool {
        
        let zone = dataManager.zoneCheck(service: service)
        
        if DataManager.isConnectedToNetwork() && !DataManager.isWifiConnected() && service.network.mcc != service.card.mcc && (zone == "OUTZONE" || zone == "CALLS") {
            return true
        }
        return false
    }
    
    static func newCountryCheck(_ dataManager: DataManager = DataManager(), service: FMNetwork){
        let country = service.network.land
        
        if country == "--"{
            return
        }
        
        let zone = dataManager.zoneCheck(service: service)
        
        var simpleNetwork = ""
        if #available(iOS 14.1, *), service.network.connected == CTRadioAccessTechnologyNR {
            simpleNetwork = "5G"
        } else if #available(iOS 14.1, *), service.network.connected == CTRadioAccessTechnologyNRNSA {
            simpleNetwork = "5G"
        } else if service.network.connected == CTRadioAccessTechnologyLTE {
            simpleNetwork = "4G"
        } else if service.network.connected == CTRadioAccessTechnologyEdge {
            simpleNetwork = "E"
        } else if service.network.connected == CTRadioAccessTechnologyGPRS {
            simpleNetwork = "GPRS"
        } else {
            simpleNetwork = "3G"
        }
        
        if service.card.mcc == "208" && service.card.mnc == "15" && service.network.mcc != "208" {
            // ATTENTION TRAITER LES EXCEPTIONS EN PREMIER ! Changer le country en fonction du MNC !
            
            if zone == "ALL" {
                NotificationManager.sendNotification(for: .newCountryAllFree, with: "new_country_welcome_title".localized().format([service.network.name, simpleNetwork, country]))
            } else if zone == "CALLS"{
                NotificationManager.sendNotification(for: .newCountryBasicFree, with: "new_country_welcome_title".localized().format([service.network.name, simpleNetwork, country]))
            } else if zone == "INTERNET"{
                NotificationManager.sendNotification(for: .newCountryInternetFree, with: "new_country_welcome_title".localized().format([service.network.name, simpleNetwork, country]))
            } else {
                NotificationManager.sendNotification(for: .newCountryNothingFree, with: "new_country_welcome_title".localized().format([service.network.name, simpleNetwork, country]))
            }
        } else if service.network.mcc != service.card.mcc {
            // ATTENTION TRAITER LES EXCEPTIONS EN PREMIER ! Changer le country en fonction du MNC !
            if zone == "ALL" {
                NotificationManager.sendNotification(for: .newCountryAll, with: "new_country_welcome_title".localized().format([service.network.name, simpleNetwork, country]))
            } else if zone == "CALLS"{
                NotificationManager.sendNotification(for: .newCountryBasic, with: "new_country_welcome_title".localized().format([service.network.name, simpleNetwork, country]))
            } else if zone == "INTERNET"{
                NotificationManager.sendNotification(for: .newCountryInternet, with: "new_country_welcome_title".localized().format([service.network.name, simpleNetwork, country]))
            } else {
                NotificationManager.sendNotification(for: .newCountryNothing, with: "new_country_welcome_title".localized().format([service.network.name, simpleNetwork, country]))
            }
        }
        
    }
    
    static func engineRunning(locations: [CLLocation] = [CLLocation]()){
        let dataManager = DataManager()
        engine(locations: locations, g3engine: false, service: dataManager.current) { result in
            if result == "NR" {
                NotificationManager.sendNotification(for: .alert5G)
            } else if result == "NRNSA" {
                NotificationManager.sendNotification(for: .alert5G)
            } else if result == "LTE" {
                NotificationManager.sendNotification(for: .alertLTE)
            } else if result == "HPLUS" {
                NotificationManager.sendNotification(for: .alertHPlus)
            } else if result == "POSSHPLUS" {
                NotificationManager.sendNotification(for: .alertPossibleHPlus)
            } else if result == "WCDMA" {
                NotificationManager.sendNotification(for: .alertWCDMA)
            } else if result == "POSSWCDMA" {
                NotificationManager.sendNotification(for: .alertPossibleWCDMA)
            } else if result == "POSSNR" {
                NotificationManager.sendNotification(for: .alertPossible5G)
            } else if result == "NRNSA" {
                NotificationManager.sendNotification(for: .alertPossible5G)
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
    
    static func engine(locations: [CLLocation] = [CLLocation](), g3engine: Bool = false, service: FMNetwork, completionHandler: @escaping (String) -> ()) {
        print("TRIGGERED")
        
        let dataManager = DataManager()
        
        var allowCountryDetection = true
        if(dataManager.datas.value(forKey: "allowCountryDetection") != nil){
            allowCountryDetection = dataManager.datas.value(forKey: "allowCountryDetection") as? Bool ?? true
        }
        
        // Aucune configuration faite
        if !service.card.setupDone {
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
            
            let country = service.network.land
            
            // Vérification de data
            if allowCountryDetection {
                checkDataDisabled(dataManager, service: service) { result in
                    if result {
                        NotificationManager.sendNotification(for: .alertDataDrain, with: "data_drain_notification_description".localized().format([service.network.name, country]))
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
            
            
            print(service.network.connected)
            
            // Changement de pays
            if lastConnectedCountry != country {
                newCountryCheck(dataManager, service: service)
                dataManager.datas.set(country, forKey: "lastConnectedCountry")
                dataManager.datas.synchronize()
            }
            
            var land = "FR"
            if dataManager.datas.value(forKey: "LAND") != nil {
                land = dataManager.datas.value(forKey: "LAND") as? String ?? "FR"
            }
            
            let countryCode = service.card.carrier.mobileCountryCode ?? "null"
            print(countryCode)
            
            let mobileNetworkName = service.card.carrier.mobileNetworkCode ?? "null"
            print(mobileNetworkName)
            
            // Changement de SIM
            if (countryCode != service.card.mcc || mobileNetworkName != service.card.mnc) && (mobileNetworkName != "null" || countryCode != "null") {
                dataManager.datas.removeObject(forKey: "MCC")
                dataManager.datas.set(false, forKey: "setupDone")
                dataManager.datas.set("NEWSIM", forKey: "g3lastcompletion")
                dataManager.datas.set(Date(), forKey: "syncNewSIM")
                dataManager.resetCountryIncluded(service: service)
                dataManager.datas.synchronize()
                if DataManager.isConnectedToNetwork() {
                    self.bgUpdateSetup()
                }
                completionHandler("NEWSIM")
                return
            }
            
            print(service.card.hp)
            
            
            // Début des vérifications
            if country != land {
                print("Country != land!")
                print(country)
                print(land)
                CoverageManager.addCurrentCoverageData(dataManager, aboard: directDataDCheck(dataManager, service: service))
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
                
                if service.network.mcc == service.card.mcc && service.network.mnc == service.card.itiMNC {
                    CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                } else if service.network.connected == CTRadioAccessTechnologyEdge && service.card.out2G {
                    CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                } else if service.network.connected == service.card.nrp {
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
            
            var request: Bool
            if #available(iOS 14.1, *) {
                request = service.network.connected == service.card.hp || (service.network.connected == CTRadioAccessTechnologyLTE && (dataManager.allow014G || (dataManager.modeExpert ? false : !service.card.roamLTE))) || (service.network.connected == CTRadioAccessTechnologyNR && (dataManager.allow015G || (dataManager.modeExpert ? false : !service.card.roam5G))) || (service.network.connected == CTRadioAccessTechnologyNRNSA && (dataManager.allow015G || (dataManager.modeExpert ? false : !service.card.roam5G)))
            } else {
                request = service.network.connected == service.card.hp || (service.network.connected == CTRadioAccessTechnologyLTE && (dataManager.allow014G || (dataManager.modeExpert ? false : !service.card.roamLTE)))
            }
            
            if request {
                print("HOME 5G/LTE/3G => SKIP")
                dataManager.lastnet = service.network.connected
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
            
            if service.card.minimalSetup && service.network.mcc == service.card.mcc && service.network.mnc != service.card.mnc {
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
                    if #available(iOS 14.1, *), service.network.connected == CTRadioAccessTechnologyNR && !dataManager.allow015G {
                        CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                        dataManager.datas.set("NR", forKey: "g3lastcompletion")
                        dataManager.datas.synchronize()
                        completionHandler("NR")
                        return
                    } else if #available(iOS 14.1, *), service.network.connected == CTRadioAccessTechnologyNRNSA && !dataManager.allow015G {
                        CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                        dataManager.datas.set("NRNSA", forKey: "g3lastcompletion")
                        dataManager.datas.synchronize()
                        completionHandler("NRNSA")
                        return
                    } else if service.network.connected == CTRadioAccessTechnologyLTE && !dataManager.allow014G {
                        CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                        dataManager.datas.set("LTE", forKey: "g3lastcompletion")
                        dataManager.datas.synchronize()
                        completionHandler("LTE")
                        return
                    } else if service.network.connected == CTRadioAccessTechnologyHSDPA && !dataManager.allow013G {
                        CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                        dataManager.datas.set("HPLUS", forKey: "g3lastcompletion")
                        dataManager.datas.synchronize()
                        completionHandler("HPLUS")
                        return
                    } else if service.network.connected == CTRadioAccessTechnologyWCDMA && !dataManager.allow013G {
                        CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                        dataManager.datas.set("WCDMA", forKey: "g3lastcompletion")
                        dataManager.datas.synchronize()
                        completionHandler("WCDMA")
                        return
                    } else if service.network.connected == CTRadioAccessTechnologyEdge && !dataManager.allow012G {
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
                    context = PermanentStorage.persistentContainer.viewContext
                } else {
                    // Fallback on earlier versions
                    context = PermanentStorage.managedObjectContext
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
                    
                    if #available(iOS 14.0, *) {
                        if CLLocationManager().accuracyAuthorization != .fullAccuracy {
                            completionHandler("BADCONFIG")
                            return
                        }
                    }

                    
                    if !detected {
                        if #available(iOS 14.1, *), service.network.connected == CTRadioAccessTechnologyNR && !dataManager.allow015G {
                            CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                            dataManager.datas.set("NR", forKey: "g3lastcompletion")
                            dataManager.datas.synchronize()
                            completionHandler("NR")
                            return
                        } else if #available(iOS 14.1, *), service.network.connected == CTRadioAccessTechnologyNRNSA && !dataManager.allow015G {
                            CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                            dataManager.datas.set("NRNSA", forKey: "g3lastcompletion")
                            dataManager.datas.synchronize()
                            completionHandler("NRNSA")
                            return
                        } else if service.network.connected == CTRadioAccessTechnologyLTE && !dataManager.allow014G {
                            CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                            dataManager.datas.set("LTE", forKey: "g3lastcompletion")
                            dataManager.datas.synchronize()
                            completionHandler("LTE")
                            return
                        } else if service.network.connected == CTRadioAccessTechnologyHSDPA && !dataManager.allow013G {
                            CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                            dataManager.datas.set("HPLUS", forKey: "g3lastcompletion")
                            dataManager.datas.synchronize()
                            completionHandler("HPLUS")
                            return
                        } else if service.network.connected == CTRadioAccessTechnologyWCDMA && !dataManager.allow013G {
                            CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                            dataManager.datas.set("WCDMA", forKey: "g3lastcompletion")
                            dataManager.datas.synchronize()
                            completionHandler("WCDMA")
                            return
                        } else if service.network.connected == CTRadioAccessTechnologyEdge && !dataManager.allow012G {
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
                    if #available(iOS 14.1, *), service.network.connected == CTRadioAccessTechnologyNR && !dataManager.allow015G {
                        CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                        dataManager.datas.set("NR", forKey: "g3lastcompletion")
                        dataManager.datas.synchronize()
                        completionHandler("NR")
                        return
                    } else if #available(iOS 14.1, *), service.network.connected == CTRadioAccessTechnologyNRNSA && !dataManager.allow015G {
                        CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                        dataManager.datas.set("NRNSA", forKey: "g3lastcompletion")
                        dataManager.datas.synchronize()
                        completionHandler("NRNSA")
                        return
                    } else if service.network.connected == CTRadioAccessTechnologyLTE && !dataManager.allow014G {
                        CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                        dataManager.datas.set("LTE", forKey: "g3lastcompletion")
                        dataManager.datas.synchronize()
                        completionHandler("LTE")
                        return
                    }
                    else if service.network.connected == CTRadioAccessTechnologyHSDPA && !dataManager.allow013G {
                        CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                        dataManager.datas.set("HPLUS", forKey: "g3lastcompletion")
                        dataManager.datas.synchronize()
                        completionHandler("HPLUS")
                        return
                    } else if service.network.connected == CTRadioAccessTechnologyWCDMA && !dataManager.allow013G {
                        CoverageManager.addCurrentCoverageData(dataManager, isRoaming: true)
                        dataManager.datas.set("WCDMA", forKey: "g3lastcompletion")
                        dataManager.datas.synchronize()
                        completionHandler("WCDMA")
                        return
                    } else if service.network.connected == CTRadioAccessTechnologyEdge && !dataManager.allow012G {
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
                
            else if service.network.mcc == service.card.mcc && service.network.mnc == service.card.chasedMNC {
                var request: Bool
                if #available(iOS 14.1, *) {
                    request = (service.network.connected == service.card.nrp && !dataManager.allow013G) || (service.network.connected == CTRadioAccessTechnologyEdge && !dataManager.allow012G && service.card.out2G) || (service.network.connected == CTRadioAccessTechnologyLTE && (!dataManager.allow014G && (dataManager.modeExpert ? true : service.card.roamLTE))) || (service.network.connected == CTRadioAccessTechnologyNR && (!dataManager.allow015G && (dataManager.modeExpert ? true : service.card.roam5G))) || (service.network.connected == CTRadioAccessTechnologyNRNSA && (!dataManager.allow015G && (dataManager.modeExpert ? true : service.card.roam5G))) 
                } else {
                    request = (service.network.connected == service.card.nrp && !dataManager.allow013G) || (service.network.connected == CTRadioAccessTechnologyEdge && !dataManager.allow012G && service.card.out2G) || (service.network.connected == CTRadioAccessTechnologyLTE && (!dataManager.allow014G && (dataManager.modeExpert ? true : service.card.roamLTE)))
                }
                if request {
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
                        initBackground(dataManager, g3engine, service: service, completionHandler: completionHandler)
                        return
                    }
                    
                    let currlocation = CLLocation(latitude: CLLocationDegrees(currlat), longitude: CLLocationDegrees(currlon))
                    
                    let context: NSManagedObjectContext
                    if #available(iOS 10.0, *) {
                        context = PermanentStorage.persistentContainer.viewContext
                    } else {
                        // Fallback on earlier versions
                        context = PermanentStorage.managedObjectContext
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
                        
                        if #available(iOS 14.0, *) {
                            if CLLocationManager().accuracyAuthorization != .fullAccuracy {
                                completionHandler("BADCONFIG")
                                return
                            }
                        }
                        
                        if !detected {
                            initBackground(dataManager, g3engine, service: service, completionHandler: completionHandler)
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
                        initBackground(dataManager, g3engine, service: service, completionHandler: completionHandler)
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

}
