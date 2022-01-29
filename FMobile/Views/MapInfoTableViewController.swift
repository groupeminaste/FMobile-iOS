//
//  MapInfoTableViewController.swift
//  FMobile
//
//  Created by Nathan FALLET on 19/06/2020.
//  Copyright © 2020 Groupe MINASTE. All rights reserved.
//

import UIKit

class MapInfoTableViewController: UITableViewController {
    
    // Delegate
    weak var delegate: MapCarrierContainer?
    
    // Legend data
    let legend = [
        // Standard
        CoverageLegend(name: "map_info_legend_gprs", color: UIColor(red: 153/255, green: 255/255, blue: 255/255, alpha: 0.4)),
        CoverageLegend(name: "map_info_legend_edge", color: UIColor(red: 51/255, green: 255/255, blue: 255/255, alpha: 0.5)),
        CoverageLegend(name: "map_info_legend_3g", color: UIColor(red: 178/255, green: 255/255, blue: 102/255, alpha: 0.6)),
        CoverageLegend(name: "map_info_legend_lte", color: UIColor(red: 0/255, green: 204/255, blue: 0/255, alpha: 0.75)),
        
        // Roaming
        CoverageLegend(name: "map_info_legend_gprs_r", color: UIColor(red: 255/255, green: 102/255, blue: 102/255, alpha: 0.4)),
        CoverageLegend(name: "map_info_legend_edge_r", color: UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.5)),
        CoverageLegend(name: "map_info_legend_3g_r", color: UIColor(red: 255/255, green: 153/255, blue: 51/255, alpha: 0.6)),
        CoverageLegend(name: "map_info_legend_lte_r", color: UIColor(red: 255/255, green: 255/255, blue: 51/255, alpha: 0.75)),
        
        // Unknown
        CoverageLegend(name: "map_info_legend_nonetwork", color: UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.75)),
        CoverageLegend(name: "map_info_legend_unknown", color: UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 0.75))
    ]
    
    // Currently selected carrier
    var current: CarrierConfiguration?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // On enregistre les cellules
        tableView.register(CarrierSelectionTableViewCell.self, forCellReuseIdentifier: "carrierCell")
        tableView.register(LegendTableViewCell.self, forCellReuseIdentifier: "legendCell")
        
        if #available(iOS 13.0, *) {} else {
            // Ecoute les changements de couleurs
            NotificationCenter.default.addObserver(self, selector: #selector(darkModeEnabled(_:)), name: .darkModeEnabled, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(darkModeDisabled(_:)), name: .darkModeDisabled, object: nil)
            
            // On initialise les couleurs
            isDarkMode() ? enableDarkMode() : disableDarkMode()
        }

        // Navigation bar
        title = "map_info_title".localized()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(close(_:)))
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "map_info_carrier".localized() : "map_info_legend".localized()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : legend.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            // Put it into the cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "carrierCell", for: indexPath) as! CarrierSelectionTableViewCell
            if #available(iOS 13.0, *) {
                return cell.with(delegate: delegate)
            } else {
                return cell.with(delegate: delegate, darkMode: isDarkMode())
            }
        } else if indexPath.section == 1 {
            // Get legend data
            let current = legend[indexPath.row]
            
            // Put it into the cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "legendCell", for: indexPath) as! LegendTableViewCell
            if #available(iOS 13.0, *) {
                return cell.with(current: current)
            } else {
                return cell.with(current: current, darkMode: isDarkMode())
            }
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    @objc func close(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
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

}
