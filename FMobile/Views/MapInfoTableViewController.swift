//
//  MapInfoTableViewController.swift
//  FMobile
//
//  Created by Nathan FALLET on 19/06/2020.
//  Copyright © 2020 Groupe MINASTE. All rights reserved.
//

import UIKit
#if FMOBILECOVERAGE
import GroupeMINASTE
#endif

class MapInfoTableViewController: UITableViewController, MapInfoContainer {
    
    // Delegate
    weak var delegate: MapCarrierContainer?
    
    // Currently selected carrier
    var current: CarrierConfiguration?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // On enregistre les cellules
        tableView.register(CarrierSelectionTableViewCell.self, forCellReuseIdentifier: "carrierCell")
        tableView.register(LegendTableViewCell.self, forCellReuseIdentifier: "legendCell")
        tableView.register(ButtonTableViewCell.self, forCellReuseIdentifier: "buttonCell")
        tableView.register(AppTableViewCell.self, forCellReuseIdentifier: "appCell")
        
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
        title = "map_info_title".localized()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(close(_:)))
    }
    
    func reloadInformation() {
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        #if FMOBILECOVERAGE
        return 4
        #else
        return 2
        #endif
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        #if FMOBILECOVERAGE
        if section == 0 {
            return "install_fmobile".localized()
        }
        #endif
        return ""
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        #if FMOBILECOVERAGE
        if section == 2 {
            return "install_apps".localized()
        } else if section == 3 {
            return ""
        }
        #endif
        return section == 0 ? "map_info_carrier".localized() : "map_info_legend".localized()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        #if FMOBILECOVERAGE
        if section == 2 {
            return 2
        } else if section == 3 {
            return 1
        }
        #endif
        return section == 0 ? 1 : CoverageLegend.legend.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            // Put it into the cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "carrierCell", for: indexPath) as! CarrierSelectionTableViewCell
            #if targetEnvironment(macCatalyst)
            return cell.with(carrier: delegate?.current)
            #else
            if #available(iOS 13.0, *) {
                return cell.with(carrier: delegate?.current)
            } else {
                return cell.with(carrier: delegate?.current, darkMode: isDarkMode())
            }
            #endif
        } else if indexPath.section == 1 {
            // Get legend data
            let current = CoverageLegend.legend[indexPath.row]
            
            // Put it into the cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "legendCell", for: indexPath) as! LegendTableViewCell
            #if targetEnvironment(macCatalyst)
            return cell.with(current: current)
            #else
            if #available(iOS 13.0, *) {
                return cell.with(current: current)
            } else {
                return cell.with(current: current, darkMode: isDarkMode())
            }
            #endif
        }
        #if FMOBILECOVERAGE
        if indexPath.section == 2 {
            // Check element
            if indexPath.row == 0 {
                // Install FMobile
                let handler: ((UIButton) -> Void) = { _ in
                    
                }
                
                #if targetEnvironment(macCatalyst)
                return (tableView.dequeueReusableCell(withIdentifier: "appCell", for: indexPath) as! AppTableViewCell).with(name: "fmobile".localized(), desc: "install_fmobile_desc".localized(), icon: UIImage(named: "IMG_4533"), handler: handler)
                #else
                if #available(iOS 13.0, *) {
                    return (tableView.dequeueReusableCell(withIdentifier: "appCell", for: indexPath) as! AppTableViewCell).with(name: "fmobile".localized(), desc: "install_fmobile_desc".localized(), icon: UIImage(named: "IMG_4533"), handler: handler)
                } else {
                    return (tableView.dequeueReusableCell(withIdentifier: "appCell", for: indexPath) as! AppTableViewCell).with(name: "fmobile".localized(), desc: "install_fmobile_desc".localized(), icon: UIImage(named: "IMG_4533"), handler: handler, darkMode: isDarkMode())
                }
                #endif
            } else if indexPath.row == 1 {
                // Install FWi-Fi
                let handler: ((UIButton) -> Void) = { _ in
                    
                }
                
                #if targetEnvironment(macCatalyst)
                return (tableView.dequeueReusableCell(withIdentifier: "appCell", for: indexPath) as! AppTableViewCell).with(name: "fwifi".localized(), desc: "install_fwifi_desc".localized(), icon: UIImage(named: "fwifi"), handler: handler)
                #else
                if #available(iOS 13.0, *) {
                    return (tableView.dequeueReusableCell(withIdentifier: "appCell", for: indexPath) as! AppTableViewCell).with(name: "fwifi".localized(), desc: "install_fwifi_desc".localized(), icon: UIImage(named: "fwifi"), handler: handler)
                } else {
                    return (tableView.dequeueReusableCell(withIdentifier: "appCell", for: indexPath) as! AppTableViewCell).with(name: "fwifi".localized(), desc: "install_fwifi_desc".localized(), icon: UIImage(named: "fwifi"), handler: handler, darkMode: isDarkMode())
                }
                #endif
            }
        } else {
            // Button handler
            let handler: ((UIButton) -> Void) = { _ in
                let mainController = GroupeMINASTEController()
                mainController.navigationItem.title = "minaste_center".localized()
                    
                let close = UIBarButtonItem(title: "close".localized(), style: .done, target: self, action: #selector(self.closeAction))
                mainController.navigationItem.setLeftBarButton(close, animated: true)
                
                let controller = UINavigationController(rootViewController: mainController)
                    
                self.present(controller, animated: true, completion: nil)
            }
            
            #if targetEnvironment(macCatalyst)
            return (tableView.dequeueReusableCell(withIdentifier: "buttonCell", for: indexPath) as! ButtonTableViewCell).with(title: "minaste_center".localized(), alignment: .left, handler: handler)
            #else
            if #available(iOS 13.0, *) {
                return (tableView.dequeueReusableCell(withIdentifier: "buttonCell", for: indexPath) as! ButtonTableViewCell).with(title: "minaste_center".localized(), alignment: .left, handler: handler)
            } else {
                // Fallback on earlier versions
                    return (tableView.dequeueReusableCell(withIdentifier: "buttonCell", for: indexPath) as! ButtonTableViewCell).with(title: "minaste_center".localized(), alignment: .left, handler: handler, darkMode: isDarkMode())
            }
            #endif
        }
        #endif
        
        return UITableViewCell()
    }
    
    #if FMOBILECOVERAGE
    @objc func closeAction() {
        self.dismiss(animated: true, completion: nil)
    }
    #endif
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        #if FMOBILECOVERAGE
        if indexPath.section == 2 {
            return 68
        }
        #endif
        return 48
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            // Handle click on carrier cell
            let mapCarrierVC = MapCarrierTableViewController(style: .grouped)
            mapCarrierVC.delegate = delegate
            mapCarrierVC.delegate2 = self
            present(UINavigationController(rootViewController: mapCarrierVC), animated: true, completion: nil)
        } else if indexPath.section == 1 {
            // Handle protocol selection
            CoverageLegend.legend[indexPath.row].selected.toggle()
            self.tableView.reloadData()
            delegate?.loadCoverageMap()
        }
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

protocol MapInfoContainer: class {
    
    func reloadInformation()
    
}
