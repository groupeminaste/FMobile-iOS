//
//  TableViewCell.swift
//  FMobile
//
//  Created by Nathan FALLET on 10/1/18.
//  Copyright © 2018 Groupe MINASTE. All rights reserved.
//

import UIKit

class LegendTableViewCell: UITableViewCell {

    var color = UIView()
    var label = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        separatorInset = .zero
        
        contentView.addSubview(color)
        contentView.addSubview(label)
        
        color.translatesAutoresizingMaskIntoConstraints = false
        color.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
        color.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        color.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor).isActive = true
        color.widthAnchor.constraint(equalToConstant: 48).isActive = true
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: color.trailingAnchor, constant: 12).isActive = true
        label.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontSizeToFitWidth = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @available(iOS 13.0, *)
    func with(current: CoverageLegend) -> LegendTableViewCell {
        label.text = current.name.localized()
        color.backgroundColor = current.color
        
        return self
    }
    
    @available(iOS, obsoleted: 13.0)
    func with(current: CoverageLegend, darkMode: Bool) -> LegendTableViewCell {
        label.text = current.name.localized()
        color.backgroundColor = current.color
    
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
