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
        
        if #available(iOS 13.0, *) {} else {
            // Notifs de changements de couleur
            NotificationCenter.default.addObserver(self, selector: #selector(darkModeEnabled(_:)), name: .darkModeEnabled, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(darkModeDisabled(_:)), name: .darkModeDisabled, object: nil)
            
            isDarkMode() ? enableDarkMode() : disableDarkMode()
        }
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = false
        }
        navigationItem.title = "speedtest_view_title".localized()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "speedtest_start".localized(), style: .plain, target: self, action: #selector(start(_:)))
        
        // Initialisation des views
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        }
        view.addSubview(progress)
        view.addSubview(desc)
        
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 15).isActive = true
        progress.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor).isActive = true
        progress.heightAnchor.constraint(equalToConstant: 250).isActive = true
        progress.statusChanged = { speedtest in
            if speedtest != nil {
                self.navigationItem.rightBarButtonItem?.title = "speedtest_stop".localized()
            } else {
                self.navigationItem.rightBarButtonItem?.title = "speedtest_start".localized()
            }
        }
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
    
    @available(iOS, obsoleted: 13.0)
    deinit {
        NotificationCenter.default.removeObserver(self, name: .darkModeEnabled, object: nil)
        NotificationCenter.default.removeObserver(self, name: .darkModeDisabled, object: nil)
    }
    
    @available(iOS, obsoleted: 13.0)
    @objc override func enableDarkMode() {
        super.enableDarkMode()
        progress.enableDarkMode()
        desc.textColor = CustomColor.darkText2
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.tintColor = CustomColor.darkActive
        navigationController?.navigationBar.barStyle = .black
    }
    
    @available(iOS, obsoleted: 13.0)
    @objc override func disableDarkMode() {
        super.disableDarkMode()
        progress.disableDarkMode()
        desc.textColor = CustomColor.lightText2
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.tintColor = CustomColor.lightActive
        navigationController?.navigationBar.barStyle = .default
    }
    
    @objc func start(_ sender: Any) {
        progress.start(sender)
    }

}
