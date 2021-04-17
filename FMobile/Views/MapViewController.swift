//
//  MapViewController.swift
//  FMobile
//
//  Created by Nathan FALLET on 01/09/2019.
//  Copyright © 2019 Groupe MINASTE. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    let locationManager = CLLocationManager()
    let map = MKMapView()
    var coverageMap = CoverageMap()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {} else {
            // Notifs de changements de couleur
            NotificationCenter.default.addObserver(self, selector: #selector(darkModeEnabled(_:)), name: .darkModeEnabled, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(darkModeDisabled(_:)), name: .darkModeDisabled, object: nil)
            
            isDarkMode() ? enableDarkMode() : disableDarkMode()
        }
        
        navigationItem.title = "map_view_title".localized()

        view.addSubview(map)
        
        map.translatesAutoresizingMaskIntoConstraints = false
        map.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        map.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        map.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        map.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        map.userTrackingMode = .follow
        map.showsUserLocation = true
        map.showsCompass = true
        map.showsScale = true
        map.delegate = self
    }
    
    func loadCoverageMap() {
        CoverageManager.getCoverage(center: map.centerCoordinate, radius: map.currentRadius()) { coverageMap in
            if let coverageMap = coverageMap {
                self.coverageMap = coverageMap
            }
            
            self.updateOverlays()
        }
    }
    
    func updateOverlays() {
        map.removeOverlays(map.overlays)
        
        for point in coverageMap.points ?? [] {
            map.addOverlay(point, level: .aboveLabels)
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        loadCoverageMap()
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let point = overlay as? CoveragePoint {
            let polygonView = MKPolygonRenderer(overlay: point)
            polygonView.fillColor = point.protocolToColor()
            polygonView.alpha = 0.2
            return polygonView
        }
        
        return MKOverlayRenderer()
    }
    
    @available(iOS, obsoleted: 13.0)
       deinit {
           NotificationCenter.default.removeObserver(self, name: .darkModeEnabled, object: nil)
           NotificationCenter.default.removeObserver(self, name: .darkModeDisabled, object: nil)
       }
       
       @available(iOS, obsoleted: 13.0)
       @objc override func enableDarkMode() {
           super.enableDarkMode()
           navigationController?.navigationBar.barTintColor = .black
           navigationController?.navigationBar.tintColor = CustomColor.darkActive
           navigationController?.navigationBar.barStyle = .blackTranslucent
       }
       
       @available(iOS, obsoleted: 13.0)
       @objc override func disableDarkMode() {
           super.disableDarkMode()
           navigationController?.navigationBar.barTintColor = .white
           navigationController?.navigationBar.tintColor = CustomColor.lightActive
           navigationController?.navigationBar.barStyle = .default
       }

}
