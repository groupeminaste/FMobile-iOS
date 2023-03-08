//
//  SwitchTableViewCell.swift
//  FMobile
//
//  Created by Nathan FALLET on 10/1/18.
//  Copyright © 2018 Groupe MINASTE. All rights reserved.
//

import UIKit

class SwitchTableViewCell: UITableViewCell {

    var label = UILabel()
    var switchElement = UISwitch()
    var id = String()
    var controller: GeneralTableViewController?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        separatorInset = .zero
        
        contentView.addSubview(label)
        contentView.addSubview(switchElement)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor).isActive = true
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontSizeToFitWidth = true
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        switchElement.translatesAutoresizingMaskIntoConstraints = false
        switchElement.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor).isActive = true
        switchElement.leadingAnchor.constraint(greaterThanOrEqualTo: label.trailingAnchor, constant: 10).isActive = true
        switchElement.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
        switchElement.addTarget(self, action: #selector(onChange(_:)), for: .valueChanged)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @available(iOS 13.0, *)
    func with(id: String = "", controller: GeneralTableViewController?, text: String, enabled: Bool) -> SwitchTableViewCell {
        self.id = id
        self.controller = controller
        label.text = text
        switchElement.isOn = enabled
        
        return self
    }
    
    @available(iOS, obsoleted: 13.0)
    func with(id: String = "", controller: GeneralTableViewController?, text: String, enabled: Bool, darkMode: Bool) -> SwitchTableViewCell {
        self.id = id
        self.controller = controller
        label.text = text
        switchElement.isOn = enabled
        
        if darkMode {
            backgroundColor = CustomColor.darkBackground
            label.textColor = CustomColor.darkText
        } else {
            backgroundColor = CustomColor.lightBackground
            label.textColor = CustomColor.lightText
        }
        return self
    }
    
    
    @objc func onChange(_ sender: Any) {
        // Save switch
        let datas = UserDefaults(suiteName: "group.fr.plugn.fmobile") ?? Foundation.UserDefaults.standard
        datas.set(switchElement.isOn, forKey: id)
        datas.set(true, forKey: "didChangeSettings")
        datas.synchronize()
        
        // Unwrap controller
        if let table = controller {
            // If coverage map, show alert
            if id == "coveragemap" && switchElement.isOn && !datas.bool(forKey: "coveragemap_noalert") {
                datas.set(false, forKey: "coveragemap")
                datas.synchronize()
                
                let alert = UIAlertController(title: "coveragemap_alert_title".localized(), message: "coveragemap_alert_description".localized(), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "coveragemap_alert_accept".localized(), style: .default) { _ in
                    datas.set(true, forKey: "coveragemap")
                    datas.synchronize()
                    table.loadUI(wifi: WifiNetwork.currentWifiNetwork)
                    table.refreshSections()
                })
                alert.addAction(UIAlertAction(title: "coveragemap_alert_accept2".localized(), style: .default) { _ in
                    // Save "Do not show again"
                    datas.set(true, forKey: "coveragemap")
                    datas.set(true, forKey: "coveragemap_noalert")
                    datas.synchronize()
                    table.loadUI(wifi: WifiNetwork.currentWifiNetwork)
                    table.refreshSections()
                })
                alert.addAction(UIAlertAction(title: "coveragemap_alert_deny".localized(), style: .cancel) { _ in
                    // Cancel switch
                    datas.set(false, forKey: "coveragemap")
                    datas.synchronize()
                })
                table.present(alert, animated: true, completion: nil)
            }
            
            if #available(iOS 13.0, *) {} else {
                if id == "isDarkMode" {
                    NotificationCenter.default.post(name: switchElement.isOn ? .darkModeEnabled : .darkModeDisabled, object: nil)
                }
            }
            
            if id == "allow014G" && !datas.bool(forKey: "allow014G_noalert") {
                let dataManager = DataManager()
                if !dataManager.current.card.roamLTE && !switchElement.isOn {
                    datas.set(true, forKey: "allow014G")
                    datas.synchronize()
                    let alert = UIAlertController(title: "LTE_roaming_not_certified".localized(), message: "LTE_roaming_not_certified_description".localized(), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "confirm_activation".localized(), style: .default) { _ in
                        datas.set(false, forKey: "allow014G")
                        datas.synchronize()
                        table.loadUI(wifi: WifiNetwork.currentWifiNetwork)
                    })
                    alert.addAction(UIAlertAction(title: "always_confirm_activation".localized(), style: .default) { _ in
                        // Save "Do not show again"
                        datas.set(false, forKey: "allow014G")
                        datas.set(true, forKey: "allow014G_noalert")
                        datas.synchronize()
                        table.loadUI(wifi: WifiNetwork.currentWifiNetwork)
                    })
                    alert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel) { _ in
                        // Cancel switch
                        datas.set(true, forKey: "allow014G")
                        datas.synchronize()
                    })
                    table.present(alert, animated: true, completion: nil)
                }
            }
            
            if id == "allow015G" && !datas.bool(forKey: "allow015G_noalert") {
                let dataManager = DataManager()
                if !dataManager.current.card.roam5G && !switchElement.isOn {
                    datas.set(true, forKey: "allow015G")
                    datas.synchronize()
                    let alert = UIAlertController(title: "5G_roaming_not_certified".localized(), message: "5G_roaming_not_certified_description".localized(), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "confirm_activation".localized(), style: .default) { _ in
                        datas.set(false, forKey: "allow015G")
                        datas.synchronize()
                        table.loadUI(wifi: WifiNetwork.currentWifiNetwork)
                    })
                    alert.addAction(UIAlertAction(title: "always_confirm_activation".localized(), style: .default) { _ in
                        // Save "Do not show again"
                        datas.set(false, forKey: "allow015G")
                        datas.set(true, forKey: "allow015G_noalert")
                        datas.synchronize()
                        table.loadUI(wifi: WifiNetwork.currentWifiNetwork)
                    })
                    alert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel) { _ in
                        // Cancel switch
                        datas.set(true, forKey: "allow015G")
                        datas.synchronize()
                    })
                    table.present(alert, animated: true, completion: nil)
                }
            }
            
            // Reload UI
            table.loadUI(wifi: WifiNetwork.currentWifiNetwork)
        }
    }
    
}
