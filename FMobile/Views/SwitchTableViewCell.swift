/*
Copyright (C) 2020 Groupe MINASTE

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*/
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
    var controller: TableViewController?
    
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
    
    func with(id: String = "", controller: TableViewController?, text: String, enabled: Bool, darkMode: Bool) -> SwitchTableViewCell {
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
        let datas = Foundation.UserDefaults.standard
        datas.set(switchElement.isOn, forKey: id)
        datas.set(true, forKey: "didChangeSettings")
        datas.synchronize()
        
        if id == "isDarkMode" {
            NotificationCenter.default.post(name: switchElement.isOn ? .darkModeEnabled : .darkModeDisabled, object: nil)
        }
        
        if let table = controller {
            table.loadUI()
            table.refreshSections()
        }
    }
    
}
