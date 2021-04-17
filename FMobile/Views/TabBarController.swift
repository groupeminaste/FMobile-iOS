//
//  TabBarController.swift
//  FMobile
//
//  Created by Nathan FALLET on 01/09/2019.
//  Copyright © 2019 Groupe MINASTE. All rights reserved.
//

import UIKit
import CoreLocation

class TabBarController: UITabBarController {
    
    func locationDeniedCheck() {
        let dataManager = DataManager()
        
        var locationAuthorizationAvoided = false
        if dataManager.datas.value(forKey: "locationAuthorizationAvoided") != nil {
            locationAuthorizationAvoided = dataManager.datas.value(forKey: "locationAuthorizationAvoided") as? Bool ?? false
        }
        
        var locationAuthorizationBadsetup = false
        if dataManager.datas.value(forKey: "locationAuthorizationBadsetup") != nil {
            locationAuthorizationBadsetup = dataManager.datas.value(forKey: "locationAuthorizationBadsetup") as? Bool ?? false
        }
        
        let authorizationStatus = CLLocationManager.authorizationStatus()
        
        if authorizationStatus == .denied && !locationAuthorizationAvoided {
            let alert = UIAlertController(title: "location_denied".localized(), message: "location_denied_description".localized(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "location_denied_change".localized(), style: .default) { (UIAlertAction) in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            })
            alert.addAction(UIAlertAction(title: "location_denied_agree".localized(), style: .destructive, handler: nil))
            alert.addAction(UIAlertAction(title: "location_denied_agree_forever".localized(), style: .destructive) { (UIAlertAction) in
                dataManager.datas.set(true, forKey: "locationAuthorizationAvoided")
                dataManager.datas.synchronize()
            })
            UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
        }
        
        print("AUTHORIZATION STATUS: \(authorizationStatus.rawValue)")
        
        if authorizationStatus == .authorizedWhenInUse && !locationAuthorizationBadsetup {
            let alert = UIAlertController(title: "location_wrong_setting".localized(), message: "location_denied_description".localized(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "location_denied_change".localized(), style: .default) { (UIAlertAction) in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            })
            alert.addAction(UIAlertAction(title: "location_ws_agree".localized(), style: .destructive, handler: nil))
            alert.addAction(UIAlertAction(title: "location_ws_agree_forever".localized(), style: .destructive) { (UIAlertAction) in
                dataManager.datas.set(true, forKey: "locationAuthorizationBadsetup")
                dataManager.datas.synchronize()
            })
            UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func firstStart(){
        
        let dataManager = DataManager()
        dataManager.datas.set(false, forKey: "didFinishFirstStart")
        dataManager.datas.synchronize()
        
        let alert = UIAlertController(title: "first_start_title".localized(), message: "first_start_description".localized(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "video_tutorial".localized(), style: .default) { (UIAlertAction) in
            guard let mailto = URL(string: "https://youtu.be/GfI5JLqyqiY") else { return }
            UIApplication.shared.open(mailto)
        })
        alert.addAction(UIAlertAction(title: "install_shortcuts".localized(), style: .default) { (UIAlertAction) in
            guard let discord = URL(string: "http://raccourcis.ios.free.fr/fmobile") else { return }
            UIApplication.shared.open(discord)
        })
        alert.addAction(UIAlertAction(title: "close".localized(), style: .default) { (UIAlertAction) in
            self.locationDeniedCheck()
               })
        alert.addAction(UIAlertAction(title: "never_show_again".localized(), style: .cancel) { (UIAlertAction) in
            dataManager.datas.set(true, forKey: "didFinishFirstStart")
            dataManager.datas.synchronize()
            self.locationDeniedCheck()
        })
        present(alert, animated: true, completion: nil)
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
            self.firstStart()
        })
        
        present(alert, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        let dataManager = DataManager()
        
        var didFinishFirstStart = false
        if dataManager.datas.value(forKey: "didFinishFirstStart") != nil {
            didFinishFirstStart = dataManager.datas.value(forKey: "didFinishFirstStart") as? Bool ?? false
        }
        
        var warningApproved = false
        if dataManager.datas.value(forKey: "warningApproved") != nil {
            warningApproved = dataManager.datas.value(forKey: "warningApproved") as? Bool ?? false
        }
        
        if !warningApproved{
            self.warning()
        }
        
        if !didFinishFirstStart && warningApproved{
            self.firstStart()
        }
        
        if didFinishFirstStart && warningApproved {
            self.locationDeniedCheck()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {} else {
            // Notifs de changements de couleur
            NotificationCenter.default.addObserver(self, selector: #selector(darkModeEnabled(_:)), name: .darkModeEnabled, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(darkModeDisabled(_:)), name: .darkModeDisabled, object: nil)
            
            isDarkMode() ? enableDarkMode() : disableDarkMode()
        }
        
        // Init general
        let general = UINavigationController(rootViewController: GeneralTableViewController(style: .grouped))
        if #available(iOS 13.0, *) {
            general.tabBarItem = UITabBarItem(title: "general_view_title".localized(), image: UIImage(systemName: "gear"), tag: 0)
        } else {
            // Fallback on earlier versions
            general.tabBarItem = UITabBarItem(title: "general_view_title".localized(), image: UIImage(named: "gear"), tag: 0)
        }
        
        // Init map
        let map = UINavigationController(rootViewController: MapViewController())
        if #available(iOS 13.0, *) {
            map.tabBarItem = UITabBarItem(title: "map_view_title".localized(), image: UIImage(systemName: "map"), tag: 1)
        } else {
            // Fallback on earlier versions
            map.tabBarItem = UITabBarItem(title: "map_view_title".localized(), image: UIImage(named: "map"), tag: 1)
        }
        
        // Init speedtest
        let speedtest = UINavigationController(rootViewController: SpeedtestViewController())
        if #available(iOS 13.0, *) {
            speedtest.tabBarItem = UITabBarItem(title: "speedtest_view_title".localized(), image: UIImage(systemName: "timer"), tag: 2)
        } else {
            // Fallback on earlier versions
            speedtest.tabBarItem = UITabBarItem(title: "speedtest_view_title".localized(), image: UIImage(named: "timer"), tag: 2)
        }
        
        // Add everything to tab bar
      viewControllers = [general, map, speedtest]
//        viewControllers = [general, speedtest]
        
        // Load views
        for viewController in viewControllers ?? [] {
            if let navigationController = viewController as? UINavigationController, let rootVC = navigationController.viewControllers.first {
                let _ = rootVC.view
            } else {
                let _ = viewController.view
            }
        }
    }
    
    @available(iOS, obsoleted: 13.0)
    deinit {
        NotificationCenter.default.removeObserver(self, name: .darkModeEnabled, object: nil)
        NotificationCenter.default.removeObserver(self, name: .darkModeDisabled, object: nil)
    }
    
    @available(iOS, obsoleted: 13.0)
    @objc override func enableDarkMode() {
        super.enableDarkMode()
        tabBar.barTintColor = CustomColor.darkBackground
        tabBar.tintColor = CustomColor.redButton
    }
    
    @available(iOS, obsoleted: 13.0)
    @objc override func disableDarkMode() {
        super.disableDarkMode()
        tabBar.barTintColor = CustomColor.lightBackground
        tabBar.tintColor = CustomColor.blueButton
    }
    
}
