//
//  StatusViewController.swift
//  FMobile
//
//  Created by PlugN on 01/07/2020.
//  Copyright © 2020 Groupe MINASTE. All rights reserved.
//

import Foundation
import UIKit

class StatusViewController: UIViewController {
    
    var image = UIImageView(image: UIImage(named: "IMG_4533_2.png"))
    var connected_protocol = UILabel()
    var connected_name = UILabel()
    let test = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        view.backgroundColor = .groupTableViewBackground
        
        connected_protocol.text = "4G+++++++++++++++"
        connected_protocol.numberOfLines = 1
        connected_protocol.textAlignment = .left
        connected_protocol.font = UIFont(name: "SF Bold", size: 45)
        
        connected_protocol.text = "Free"
        connected_protocol.numberOfLines = 1
        connected_protocol.textAlignment = .right
        connected_protocol.font = UIFont(name: "SF", size: 25)
        
        view.addSubview(test)
        view.addSubview(image)
        
        image.translatesAutoresizingMaskIntoConstraints = false
        image.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor).isActive = true
        image.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.centerYAnchor, constant: -130).isActive = true
        image.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        image.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        image.contentMode = .scaleAspectFit
        
        test.translatesAutoresizingMaskIntoConstraints = false
        test.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor).isActive = true
        test.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: -10).isActive = true
        test.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -10).isActive = true
        test.topAnchor.constraint(equalTo: image.bottomAnchor).isActive = true
        
        test.addArrangedSubview(connected_name)
        test.addArrangedSubview(connected_protocol)
        
        connected_name.translatesAutoresizingMaskIntoConstraints = false
        //connected_name.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor).isActive = true
        connected_name.topAnchor.constraint(equalTo: test.topAnchor, constant: -5).isActive = true
        connected_name.leadingAnchor.constraint(equalTo: test.leadingAnchor, constant: -5).isActive = true
        connected_name.bottomAnchor.constraint(equalTo: test.bottomAnchor, constant: -5).isActive = true
        connected_name.widthAnchor.constraint(equalToConstant: -80).isActive = true
        connected_name.numberOfLines = 0
        //connected_name.rightAnchor.constraint(equalTo: connected_protocol.leftAnchor).isActive = true
        
        connected_protocol.translatesAutoresizingMaskIntoConstraints = false
        //connected_protocol.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor).isActive = true
        connected_protocol.topAnchor.constraint(equalTo: connected_name.topAnchor).isActive = true
        connected_protocol.leadingAnchor.constraint(equalTo: connected_name.leadingAnchor, constant: -10).isActive = true
        connected_protocol.trailingAnchor.constraint(equalTo: test.trailingAnchor, constant: -5).isActive = true
        connected_protocol.numberOfLines = 0
        //connected_protocol.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        
        navigationItem.title = "fmobile".localized()
        
    }
    
    func refreshView() {
        let dataManager = DataManager()
        connected_protocol.text = dataManager.sim.network.connected
        connected_name.text = dataManager.sim.network.name
    }
}
