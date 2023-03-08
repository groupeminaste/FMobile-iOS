//
//  LocationSearchTableViewController.swift
//  FMobile
//
//  Created by Nathan FALLET on 20/06/2020.
//  Copyright © 2020 Groupe MINASTE. All rights reserved.
//

import UIKit
import MapKit

class LocationSearchTableViewController: UITableViewController, UISearchResultsUpdating {
    
    var matchingItems = [MKMapItem]()
    var mapView: MKMapView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Transparence
        tableView.alpha = 0.8
        
        // On enregistre les cellules
        tableView.register(LabelTableViewCell.self, forCellReuseIdentifier: "labelCell")
        
        #if !targetEnvironment(macCatalyst)
        if #available(iOS 13.0, *) {} else {
            // Ecoute les changements de couleurs
            NotificationCenter.default.addObserver(self, selector: #selector(darkModeEnabled(_:)), name: .darkModeEnabled, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(darkModeDisabled(_:)), name: .darkModeDisabled, object: nil)
            
            // On initialise les couleurs
            isDarkMode() ? enableDarkMode() : disableDarkMode()
        }
        #endif
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = (tableView.dequeueReusableCell(withIdentifier: "labelCell", for: indexPath) as! LabelTableViewCell)
        let item = matchingItems[indexPath.row]
        #if targetEnvironment(macCatalyst)
        return cell.with(text: item.name ?? "")
        #else
        if #available(iOS 13, *) {
            return cell.with(text: item.name ?? "")
        } else {
            return cell.with(text: item.name ?? "", darkMode: isDarkMode())
        }
        #endif
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = matchingItems[indexPath.row]
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: item.placemark.coordinate, span: span)
        mapView?.setRegion(region, animated: true)
        
        dismiss(animated: true, completion: nil)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        // Get view and search query
        guard let mapView = mapView, let searchText = searchController.searchBar.text else { return }
        
        // Create a request to get map items
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = mapView.region
        
        // Start the search
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else { return }
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
    }
    
    #if !targetEnvironment(macCatalyst)
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
    #endif

}
