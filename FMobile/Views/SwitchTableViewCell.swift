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
    
    func with(id: String = "", controller: GeneralTableViewController?, text: String, enabled: Bool) -> SwitchTableViewCell {
        self.id = id
        self.controller = controller
        label.text = text
        switchElement.isOn = enabled
        
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
                let alert = UIAlertController(title: "coveragemap_alert_title".localized(), message: "coveragemap_alert_description".localized(), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "coveragemap_alert_accept".localized(), style: .default) { _ in })
                alert.addAction(UIAlertAction(title: "coveragemap_alert_accept2".localized(), style: .default) { _ in
                    // Save "Do not show again"
                    datas.set(true, forKey: "coveragemap_noalert")
                    datas.synchronize()
                })
                alert.addAction(UIAlertAction(title: "coveragemap_alert_deny".localized(), style: .cancel) { _ in
                    // Cancel switch
                    datas.set(false, forKey: "coveragemap")
                    datas.synchronize()
                    table.loadUI()
                    table.refreshSections()
                })
                table.present(alert, animated: true, completion: nil)
            }
            
            // Reload UI
            table.loadUI()
            table.refreshSections()
        }
    }
    
}
