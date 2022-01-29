//
//  MapViewController.swift
//  FMobile
//
//  Created by Nathan FALLET on 01/09/2019.
//  Copyright © 2019 Groupe MINASTE. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, MapCarrierContainer {
    
    // Map view
    let map = MKMapView()
    let total = UILabel()
    
    // Location
    let locationManager = CLLocationManager()
    
    // Map and data
    var coverageMap = CoverageMap()
    var carriers = [CarrierConfiguration]()
    var current: CarrierConfiguration? {
        didSet { if current != nil { updateOverlays() } }
    }
    
    // Search
    var resultSearchController: UISearchController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {} else {
            // Notifs de changements de couleur
            NotificationCenter.default.addObserver(self, selector: #selector(darkModeEnabled(_:)), name: .darkModeEnabled, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(darkModeDisabled(_:)), name: .darkModeDisabled, object: nil)
            
            isDarkMode() ? enableDarkMode() : disableDarkMode()
        }
        
        // Add the view
        view.addSubview(map)
        
        // Init the contraints and properties
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
        
        // Init the search controller
        let locationSearchTableViewController = LocationSearchTableViewController()
        locationSearchTableViewController.mapView = map
        resultSearchController = UISearchController(searchResultsController: locationSearchTableViewController)
        resultSearchController?.searchResultsUpdater = locationSearchTableViewController
        definesPresentationContext = true
        
        // Nav bar
        navigationItem.title = "map_view_title".localized()
        navigationItem.leftBarButtonItems = [
            UIBarButtonItem(customView: total)
        ]
        navigationItem.rightBarButtonItems = [
            InfoBarButtonItem(target: self, action: #selector(openInfo(_:))),
            MKUserTrackingBarButtonItem(mapView: map)
        ]
        
        if #available(iOS 11.0, *) {
            navigationItem.hidesSearchBarWhenScrolling = false
            navigationItem.searchController = resultSearchController
        }
    }
    
    @objc func openInfo(_ sender: UIBarButtonItem) {
        // Create an info view controller and open it
        let mapInfoVC = MapInfoTableViewController(style: .grouped)
        mapInfoVC.delegate = self
        present(UINavigationController(rootViewController: mapInfoVC), animated: true, completion: nil)
    }
    
    func loadCoverageMap() {
        // Fetch map
        CoverageManager.getCoverage(center: map.centerCoordinate, radius: map.currentRadius()) { coverageMap in
            // Save map if exists
            if let coverageMap = coverageMap {
                self.coverageMap = coverageMap
            }
            
            // Update overlays
            self.updateOverlays()
        }
    }
    
    func updateOverlays() {
        // Update points count
        self.total.text = Double(coverageMap.total ?? 0).simplify()
        self.total.sizeToFit()
        
        // Fetch carrier data
        let list = coverageMap.getCarrierList().map({ $0.components(separatedBy: "-") })
        for e in list {
            // Check if carrier is loaded
            if !carriers.contains(where: { e[0] == $0.mcc && e[1] == $0.mnc }) {
                // Load it
                CarrierConfiguration.fetch(forMCC: e[0], andMNC: e[1]) { config in
                    // Check that config is valid and not already saved
                    if let config = config, !self.carriers.contains(where: { config.mcc == $0.mcc && config.mnc == $0.mnc }) {
                        self.carriers.append(config)
                    }
                }
            }
        }
        
        // Remove no longer needed carriers
        carriers.removeAll(where: { a in !list.contains(where: { b in a.mcc == b[0] && a.mnc == b[1] }) })
        
        // Check if a carrier is selected
        if current == nil {
            // Get carrier from data manager
            let dataManager = DataManager()
            self.current = carriers.first(where: { $0.mcc == dataManager.connectedMCC && $0.mnc == dataManager.connectedMNC }) ?? carriers.first
        }
        
        // Sort carriers
        carriers.sort(by: { first, second in
            // Check for connected network
            if first.mcc == current?.mcc {
                // Connected (always first)
                if first.mnc == current?.mnc { return true }
                
                // Same country as connected for first only
                if second.mcc != current?.mcc { return true }
            }
            
            // Check for connected network
            if second.mcc == current?.mcc {
                // Connected (always first)
                if second.mnc == current?.mnc { return false }
                
                // Same country as connected for first only
                if first.mcc != current?.mcc { return false }
            }
            
            // Alphabetic order
            return first.homename ?? "" < second.homename ?? ""
        })
        
        // Calculate points with this carrier
        let points = coverageMap.points?.filter({
            // Define home and iti strings
            let home = "\(current?.mcc ?? "---")-\(current?.mnc ?? "--")"
            let iti = "\(current?.mcc ?? "---")-\(current?.itimnc ?? "--")"
            let homec = "\(current?.mcc ?? "---")-"
            
            // If home and connected are this one
            return ($0.home == home && $0.connected == home)
            
            // Or home is this one and iti its iti one
            || ($0.home == home && $0.connected == iti)
            
            // Or connected to this one from another country
            || (!($0.home?.starts(with: homec) ?? false) && $0.connected == home)
        })
        
        // Update on the map
        map.removeOverlays(map.overlays)
        map.addOverlay(MultiPolygon(polygons: points, size: coverageMap.size ?? 0.001), level: .aboveLabels)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        loadCoverageMap()
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MultiPolygon {
            let polygonRenderer = MultiPolygonPathRenderer(overlay: overlay)
            polygonRenderer.lineWidth = 0.5
            polygonRenderer.alpha = 0.7
            polygonRenderer.miterLimit = 2.0
            return polygonRenderer
        }
        
        return MKOverlayRenderer()
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        RoamingManager.engine(g3engine: true) { result in
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
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.tintColor = CustomColor.darkActive
        navigationController?.navigationBar.barStyle = .blackTranslucent
        total.textColor = .white
    }
    
    @available(iOS, obsoleted: 13.0)
    @objc override func disableDarkMode() {
        super.disableDarkMode()
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.tintColor = CustomColor.lightActive
        navigationController?.navigationBar.barStyle = .default
        total.textColor = .black
    }

}
