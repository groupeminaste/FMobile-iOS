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
                                CoverageManager.sendCurrentCoverageData(dataManager)
                                dataManager.datas.set("ABOARD", forKey: "g3lastcompletion")
                                dataManager.datas.synchronize()
                                completionHandler("ABOARD")
                                return
                            }
                            
                        }
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
                        CoverageManager.sendCurrentCoverageData(dataManager)
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
        if dataManager.connectedMCC == dataManager.targetMCC && dataManager.connectedMNC == dataManager.chasedMNC {
            if DataManager.isWifiConnected() {
                if dataManager.verifyonwifi {
                    // Le contrôle d'itinérance démarre.
                    netfetch(dataManager, g3engine, completionHandler: completionHandler)
                    return
                } else {
                    // L'utilisateur est connecté au WiFi et est chez Free, et a demandé à ne pas controler le WiFi
                    print("L'utilisateur a désactivé le contrôle en WiFi")
                    dataManager.datas.set("WIFI", forKey: "g3lastcompletion")
                    dataManager.datas.synchronize()
                    completionHandler("WIFI")
                    return
                }
            } else {
                // L'utilisateur est chez Free et n'est pas connecté au WiFi.
                // Le contrôle d'itinérance démarre.
                print("L'utilisateur est bien sur le bon réseau et n'est pas en WiFi")
                netfetch(dataManager, g3engine, completionHandler: completionHandler)
                return
            }
        } else {
            // L'utilisateur est chez un autre opérateur
            print("L'utilisateur n'est pas connecté sur son réseau propre.")
            CoverageManager.sendCurrentCoverageData(dataManager)
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
        
        if dataManager.isRunning {
            print("ALREADY RUNNING...")
            dataManager.datas.set("RUNNING", forKey: "g3lastcompletion")
            dataManager.datas.synchronize()
            completionHandler("RUNNING")
            return
        } else if dataManager.carrierNetwork != dataManager.lastnet {
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
                        let context = persistentContainer.viewContext
                            guard let entity = NSEntityDescription.entity(forEntityName: "Locations", in: context) else {
                                completionHandler("ERROR")
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
                completionHandler("NOTTIME")
                return
            } else {
                if dataManager.g3lastcompletion == "HPLUS" || dataManager.g3lastcompletion == "WCDMA" || dataManager.g3lastcompletion == "EDGE" || abs(dataManager.g3timecode.timeIntervalSinceNow) < 2*60 {
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
        if dataManager.carrierNetwork == "CTRadioAccessTechnologyLTE" {
            // L'utilisateur est en 4G, tout va bien
            print("LTE: No need to reset.")
            CoverageManager.sendCurrentCoverageData(dataManager)
            dataManager.datas.set("HOME", forKey: "g3lastcompletion")
            dataManager.datas.synchronize()
            completionHandler("HOME")
            return
        } else if dataManager.carrierNetwork == "CTRadioAccessTechnology\(dataManager.hp)" {
            // L'utilisateur est en 3G RP, tout va bien
            print("WCDMA: No need to reset.")
            CoverageManager.sendCurrentCoverageData(dataManager)
            dataManager.datas.set("HOME", forKey: "g3lastcompletion")
            dataManager.datas.synchronize()
            completionHandler("HOME")
            return
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
                                    print("SPEEDTEST IN BACKGROUND SUCCESSFUL!")
                                    if dataManager.nrp == "WCDMA"{
                                        CoverageManager.sendCurrentCoverageData(dataManager, isRoaming: true)
                                        dataManager.datas.set("WCDMA", forKey: "g3lastcompletion")
                                        dataManager.datas.synchronize()
                                        completionHandler("WCDMA")
                                        return
                                    } else if dataManager.nrp == "HSDPA"{
                                        CoverageManager.sendCurrentCoverageData(dataManager, isRoaming: true)
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
                                        
                                        let context = persistentContainer.viewContext
                                        guard let entity = NSEntityDescription.entity(forEntityName: "Locations", in: context) else {
                                            dataManager.datas.set("NOTCOVERED", forKey: "g3lastcompletion")
                                            dataManager.datas.synchronize()
                                            completionHandler("NOTCOVERED")
                                            return
                                        }
                                        
                                        if latitude != 0 && longitude != 0 {
                                            let newCoo = NSManagedObject(entity: entity, insertInto: context)
                                            
                                            newCoo.setValue(latitude, forKey: "lat")
                                            newCoo.setValue(longitude, forKey: "lon")
                                            
                                            CoverageManager.sendCurrentCoverageData(dataManager)
                                            
                                            do {
                                                try context.save()
                                                print("COORDINATES SAVED!")
                                                NotificationManager.sendNotification(for: .saved)
                                                print("SPEEDTEST IN BACKGROUND SUCCESSFUL!")
                                                dataManager.datas.set("NOTCOVERED", forKey: "g3lastcompletion")
                                                dataManager.datas.synchronize()
                                                completionHandler("NOTCOVERED")
                                                return
                                            } catch {
                                                print("Failed saving")
                                                dataManager.datas.set("NOTCOVERED", forKey: "g3lastcompletion")
                                                dataManager.datas.synchronize()
                                                completionHandler("NOTCOVERED")
                                                return
                                            }
                                        } else {
                                            print("No valid coordinates")
                                            dataManager.datas.set("NOTCOVERED", forKey: "g3lastcompletion")
                                            dataManager.datas.synchronize()
                                            completionHandler("NOTCOVERED")
                                            return
                                        }
                                        
                                        
                                    }
                                    
                                }
                                completionHandler("ESCAPED_SPEEDTEST")
                                return
                            }
                        }
                        
                        
                    } else {
                        if dataManager.nrp == "WCDMA"{
                            CoverageManager.sendCurrentCoverageData(dataManager, isRoaming: true)
                            dataManager.datas.set("WCDMA", forKey: "g3lastcompletion")
                            dataManager.datas.synchronize()
                            completionHandler("WCDMA")
                            return
                        } else if dataManager.nrp == "HSDPA"{
                            CoverageManager.sendCurrentCoverageData(dataManager, isRoaming: true)
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
                    if dataManager.femto {
                    if dataManager.nrp == "WCDMA"{
                        dataManager.datas.set("POSSWCDMA", forKey: "g3lastcompletion")
                        dataManager.datas.synchronize()
                        completionHandler("POSSWCDMA")
                        return
                    } else if dataManager.nrp == "HSDPA"{
                        dataManager.datas.set("POSSHPLUS", forKey: "g3lastcompletion")
                        dataManager.datas.synchronize()
                        completionHandler("POSSHPLUS")
                        return
                    }
                    } else {
                        if dataManager.nrp == "WCDMA"{
                            dataManager.datas.set("WCDMA", forKey: "g3lastcompletion")
                            dataManager.datas.synchronize()
                            completionHandler("WCDMA")
                            return
                        } else if dataManager.nrp == "HSDPA"{
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
                print("H+ autorisée")
                dataManager.datas.set("STOP", forKey: "g3lastcompletion")
                dataManager.datas.synchronize()
                completionHandler("STOP")
                return
            }
        } else if dataManager.carrierNetwork == "CTRadioAccessTechnologyEdge" && dataManager.out2G {
            if !dataManager.allow012G{
                print("2G non autorisée")
                CoverageManager.sendCurrentCoverageData(dataManager, isRoaming: true)
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
                    CoverageManager.sendCurrentCoverageData(dataManager, isRoaming: true)
                }
                dataManager.datas.set("STOP", forKey: "g3lastcompletion")
                dataManager.datas.synchronize()
                completionHandler("STOP")
                return
            }
        }
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
    
    static func newCountryCheck(_ dataManager: DataManager = DataManager()){
        let country = CarrierIdentification.getIsoCountryCode(dataManager.connectedMCC, dataManager.connectedMNC).uppercased()
        
        if country == "--"{
            return
        }
        
        let zone = dataManager.zoneCheck()
        
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
        engine(locations: locations, g3engine: false) { result in
            if result == "HPLUS" {
                NotificationManager.sendNotification(for: .alertHPlus)
            } else if result == "POSSHPLUS" {
                NotificationManager.sendNotification(for: .alertPossibleHPlus)
            } else if result == "WCDMA" {
                NotificationManager.sendNotification(for: .alertWCDMA)
            } else if result == "POSSWCDMA" {
                NotificationManager.sendNotification(for: .alertPossibleWCDMA)
            } else if result == "EDGE" {
                NotificationManager.sendNotification(for: .alertEdge)
            } else if result == "NEWSIM" {
                NotificationManager.sendNotification(for: .newSIM)
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
                completionHandler("NEWSIM")
                return
            }
            
            print(dataManager.hp)
            
            
            // Début des vérifications
            if country != land {
                print("Country != land!")
                print(country)
                print(land)
                CoverageManager.sendCurrentCoverageData(dataManager)
                dataManager.datas.set("ABOARD", forKey: "g3lastcompletion")
                dataManager.datas.synchronize()
                completionHandler("ABOARD")
                return
            }
            
            if dataManager.carrierNetwork == "CTRadioAccessTechnology\(dataManager.hp)" || dataManager.carrierNetwork == "CTRadioAccessTechnologyLTE" {
                print("LTE/3G => SKIP")
                dataManager.lastnet = dataManager.carrierNetwork
                dataManager.count = 0
                dataManager.wasEnabled = 0
                dataManager.datas.set(dataManager.lastnet, forKey: "lastnet")
                dataManager.datas.set(dataManager.count, forKey: "count")
                dataManager.datas.set(dataManager.wasEnabled, forKey: "wasEnabled")
                dataManager.datas.set("HOME", forKey: "g3lastcompletion")
                dataManager.datas.synchronize()
                CoverageManager.sendCurrentCoverageData(dataManager)
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
                    completionHandler("TOOFAST")
                    return
                }
                
                let currlat = locations.last?.coordinate.latitude ?? 0
                let currlon = locations.last?.coordinate.longitude ?? 0
                
                if currlat == 0 && currlon == 0 {
                    if dataManager.carrierNetwork == "CTRadioAccessTechnologyHSDPA" {
                        CoverageManager.sendCurrentCoverageData(dataManager, isRoaming: true)
                        dataManager.datas.set("HPLUS", forKey: "g3lastcompletion")
                        dataManager.datas.synchronize()
                        completionHandler("HPLUS")
                        return
                    } else if dataManager.carrierNetwork == "CTRadioAccessTechnologyWCDMA" {
                        CoverageManager.sendCurrentCoverageData(dataManager, isRoaming: true)
                        dataManager.datas.set("WCDMA", forKey: "g3lastcompletion")
                        dataManager.datas.synchronize()
                        completionHandler("WCDMA")
                        return
                    }
                    
                    //                    if dataManager.statisticsAgreement{
                    //                        AppDelegate.sendLocationToServer(latitude: locations.last?.coordinate.latitude ?? 0, longitude: locations.last?.coordinate.longitude ?? 0)
                    //                    }
                    CoverageManager.sendCurrentCoverageData(dataManager)
                    dataManager.datas.set("HOME", forKey: "g3lastcompletion")
                    dataManager.datas.synchronize()
                    completionHandler("HOME")
                    return
                }
                
                let currlocation = CLLocation(latitude: CLLocationDegrees(currlat), longitude: CLLocationDegrees(currlon))
                
                let context = persistentContainer.viewContext
                
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
                        if dataManager.carrierNetwork == "CTRadioAccessTechnologyHSDPA" {
                            CoverageManager.sendCurrentCoverageData(dataManager, isRoaming: true)
                            dataManager.datas.set("HPLUS", forKey: "g3lastcompletion")
                            dataManager.datas.synchronize()
                            completionHandler("HPLUS")
                            return
                        } else if dataManager.carrierNetwork == "CTRadioAccessTechnologyWCDMA" {
                            CoverageManager.sendCurrentCoverageData(dataManager, isRoaming: true)
                            dataManager.datas.set("WCDMA", forKey: "g3lastcompletion")
                            dataManager.datas.synchronize()
                            completionHandler("WCDMA")
                            return
                        }
                        //                        if dataManager.statisticsAgreement{
                        //                            AppDelegate.sendLocationToServer(latitude: locations.last?.coordinate.latitude ?? 0, longitude: locations.last?.coordinate.longitude ?? 0)
                        //                        }
                    } else {
                        print("detected one nearby hotspot, STOPING OPERATIONS.")
                        dataManager.datas.set("NOTCOVERED", forKey: "g3lastcompletion")
                        dataManager.datas.synchronize()
                        completionHandler("NOTCOVERED")
                        return
                    }
                } catch {
                    print("Failed")
                    if dataManager.carrierNetwork == "CTRadioAccessTechnologyHSDPA" {
                        CoverageManager.sendCurrentCoverageData(dataManager, isRoaming: true)
                        dataManager.datas.set("HPLUS", forKey: "g3lastcompletion")
                        dataManager.datas.synchronize()
                        completionHandler("HPLUS")
                        return
                    } else if dataManager.carrierNetwork == "CTRadioAccessTechnologyWCDMA" {
                        CoverageManager.sendCurrentCoverageData(dataManager, isRoaming: true)
                        dataManager.datas.set("WCDMA", forKey: "g3lastcompletion")
                        dataManager.datas.synchronize()
                        completionHandler("WCDMA")
                        return
                    }
                    //                    if dataManager.statisticsAgreement{
                    //                        AppDelegate.sendLocationToServer(latitude: locations.last?.coordinate.latitude ?? 0, longitude: locations.last?.coordinate.longitude ?? 0)
                    //                    }
                }
                
            }
                
            else if dataManager.connectedMCC == dataManager.targetMCC && dataManager.connectedMNC == dataManager.chasedMNC {
                if (dataManager.carrierNetwork == "CTRadioAccessTechnology\(dataManager.nrp)" && !dataManager.allow013G) || (dataManager.carrierNetwork == "CTRadioAccessTechnologyEdge" && !dataManager.allow012G && dataManager.out2G) {
                    let speed = locations.last?.speed ?? 0
                    print("The current speed is ", speed * 3.6, "km/h.")
                    if speed * 3.6 > 80 {
                        print("l'utilisateur va à une vitesse ne le permettant pas de rester accroché à une antenne Free (route de campagne/autoroute/TGV).")
                        dataManager.datas.set("TOOFAST", forKey: "g3lastcompletion")
                        dataManager.datas.synchronize()
                        completionHandler("TOOFAST")
                        return
                    }
                    
                    let currlat = locations.last?.coordinate.latitude ?? 0
                    let currlon = locations.last?.coordinate.longitude ?? 0
                    
                    if currlat == 0 && currlon == 0 {
                        initBackground(dataManager, g3engine, completionHandler: completionHandler)
                        return
                    }
                    
                    let currlocation = CLLocation(latitude: CLLocationDegrees(currlat), longitude: CLLocationDegrees(currlon))
                    
                    let context = persistentContainer.viewContext
                    
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
                    print("L'utilisateur est en 4G/3G propre")
                    dataManager.datas.set("HOME", forKey: "g3lastcompletion")
                    dataManager.datas.synchronize()
                    completionHandler("HOME")
                    return
                }
            } else {
                print("L'utilisateur n\'est pas connecté sur le réseau itinérant")
                dataManager.datas.set("HOME", forKey: "g3lastcompletion")
                dataManager.datas.synchronize()
                completionHandler("HOME")
                return
            }
        }
    }
    
    
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
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
}
