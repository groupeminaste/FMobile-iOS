//
//  TableViewCell.swift
//  FMobile
//
//  Created by Nathan FALLET on 10/1/18.
//  Copyright © 2018 Groupe MINASTE. All rights reserved.
//

import UIKit

class LabelTableViewCell: UITableViewCell {

    var label: UILabel = UILabel()
    
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
    func with(text: String, accessory: UITableViewCell.AccessoryType = .none) -> LabelTableViewCell {
        label.text = text
        accessoryType = accessory
        
        return self
    }
    
    @available(iOS, obsoleted: 13.0)
    func with(text: String, accessory: UITableViewCell.AccessoryType = .none, darkMode: Bool) -> LabelTableViewCell {
           label.text = text
           accessoryType = accessory
        
           if darkMode {
               backgroundColor = CustomColor.darkBackground
               label.textColor = CustomColor.darkText
           } else {
               backgroundColor = CustomColor.lightBackground
               label.textColor = CustomColor.lightText
           }
           return self
       }

}
