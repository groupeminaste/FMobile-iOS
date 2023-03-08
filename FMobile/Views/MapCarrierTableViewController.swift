//
//  MapCarrierTableViewController.swift
//  FMobile
//
//  Created by Nathan FALLET on 22/12/2020.
//  Copyright © 2020 Groupe MINASTE. All rights reserved.
//

import UIKit

class MapCarrierTableViewController: UITableViewController {

    // Delegate
    weak var delegate: MapCarrierContainer?
    weak var delegate2: MapInfoContainer?
    
    // Currently selected carrier
    var current: CarrierConfiguration?
    
    // Sorted carriers
    var sortedCarriers = [[CarrierConfiguration]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // On enregistre les cellules
        tableView.register(CarrierSelectionTableViewCell.self, forCellReuseIdentifier: "carrierCell")
        
        #if !targetEnvironment(macCatalyst)
        if #available(iOS 13.0, *) {} else {
            // Ecoute les changements de couleurs
            NotificationCenter.default.addObserver(self, selector: #selector(darkModeEnabled(_:)), name: .darkModeEnabled, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(darkModeDisabled(_:)), name: .darkModeDisabled, object: nil)
            
            // On initialise les couleurs
            isDarkMode() ? enableDarkMode() : disableDarkMode()
        }
        #endif
        
        // Navigation bar
        title = "map_carrier_title".localized()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(close(_:)))
        
        // Update carriers in list
        for carrier in delegate?.carriers ?? [] {
            // Check the last array
            if let last = sortedCarriers.last, let first = last.first {
                // Check if current is in the same category
                if carrier.land == first.land {
                    // Add carrier to last section
                    sortedCarriers[sortedCarriers.count - 1].append(carrier)
                } else {
                    // Add a new section (for a new land)
                    sortedCarriers.append([carrier])
                }
            } else {
                // No array found, at the first one
                sortedCarriers.append([carrier])
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sortedCarriers.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sortedCarriers[section].first?.land ?? ""
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedCarriers[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "carrierCell", for: indexPath) as! CarrierSelectionTableViewCell
        let carrier = sortedCarriers[indexPath.section][indexPath.row]
        
        #if targetEnvironment(macCatalyst)
        return cell.with(carrier: carrier)
        #else
        if #available(iOS 13.0, *) {
            return cell.with(carrier: carrier)
        } else {
            return cell.with(carrier: carrier, darkMode: isDarkMode())
        }
        #endif
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.current = sortedCarriers[indexPath.section][indexPath.row]
        delegate2?.reloadInformation()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func close(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
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
