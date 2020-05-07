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
//  SpeedtestViewController.swift
//  FMobile
//
//  Created by Nathan FALLET on 03/01/2019.
//  Copyright © 2019 Groupe MINASTE. All rights reserved.
//

import UIKit

class SpeedtestViewController: UIViewController {

    var progress = SpeedtestProgressView()
    var desc = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Notifs de changements de couleur
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeEnabled(_:)), name: .darkModeEnabled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeDisabled(_:)), name: .darkModeDisabled, object: nil)
        
        isDarkMode() ? enableDarkMode() : disableDarkMode()
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = false
        }
        navigationItem.title = "speedtest_view_title".localized()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "speedtest_start".localized(), style: .plain, target: self, action: #selector(start(_:)))
        
        // Initialisation des views
        view.addSubview(progress)
        view.addSubview(desc)
        
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 15).isActive = true
        progress.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor).isActive = true
        progress.heightAnchor.constraint(equalToConstant: 250).isActive = true
        progress.loadViews()
        
        desc.translatesAutoresizingMaskIntoConstraints = false
        desc.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor).isActive = true
        desc.topAnchor.constraint(equalTo: progress.bottomAnchor, constant: 20).isActive = true
        desc.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor).isActive = true
        desc.numberOfLines = 0
        desc.textAlignment = .center
        desc.font = UIFont.systemFont(ofSize: 14)
        desc.text = "speedtest_description".localized()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .darkModeEnabled, object: nil)
        NotificationCenter.default.removeObserver(self, name: .darkModeDisabled, object: nil)
    }
    
    @objc override func enableDarkMode() {
        super.enableDarkMode()
        progress.enableDarkMode()
        desc.textColor = CustomColor.darkText2
    }
    
    @objc override func disableDarkMode() {
        super.disableDarkMode()
        progress.disableDarkMode()
        desc.textColor = CustomColor.lightText2
    }
    
    @objc func start(_ sender: Any) {
        progress.start(sender)
    }

}
