//
//  CoverageController.swift
//  FMobileCoverage
//
//  Created by PlugN on 31.10.20..
//  Copyright © 2020 Groupe MINASTE. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class CoverageController: UINavigationController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setViewControllers([MapViewController()], animated: true)
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
    }
}
