//
//  AppDelegate.swift
//  FMobileCoverage
//
//  Created by PlugN on 31.10.20..
//  Copyright © 2020 Groupe MINASTE. All rights reserved.
//

import UIKit
import APIRequest

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // On init l'API
        APIConfiguration.check()
        
        // On init l'UI
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = CoverageController()
        window?.makeKeyAndVisible()
        
        return true
    }

   
}

