//
//  CarrierSelectionTableViewCell.swift
//  FMobile
//
//  Created by Nathan FALLET on 19/06/2020.
//  Copyright © 2020 Groupe MINASTE. All rights reserved.
//

import UIKit

class CarrierSelectionTableViewCell: UITableViewCell {

    let label = UILabel()
    
    var expertMode: Bool {
        let datas = UserDefaults(suiteName: "group.fr.plugn.fmobile") ?? Foundation.UserDefaults.standard
        return datas.value(forKey: "modeExpert") as? Bool ?? false
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        separatorInset = .zero
        
        contentView.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontSizeToFitWidth = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @available(iOS 13.0, *)
    func with(carrier: CarrierConfiguration?) -> CarrierSelectionTableViewCell {
        updateText(for: carrier)
        
        return self
    }
    
    #if !targetEnvironment(macCatalyst)
    @available(iOS, obsoleted: 13.0)
    func with(carrier: CarrierConfiguration?, darkMode: Bool) -> CarrierSelectionTableViewCell {
        updateText(for: carrier)
    
        if darkMode {
            backgroundColor = CustomColor.darkBackground
            label.textColor = CustomColor.darkText
        } else {
            backgroundColor = CustomColor.lightBackground
            label.textColor = CustomColor.lightText
        }
        return self
    }
    #endif
    
    func updateText(for carrier: CarrierConfiguration?) {
        label.text = carrier?.toString(expertMode: expertMode)
    }

}

protocol MapCarrierContainer: AnyObject {
    
    var carriers: [CarrierConfiguration] { get set }
    var current: CarrierConfiguration? { get set }
    func loadCoverageMap()
    
}
