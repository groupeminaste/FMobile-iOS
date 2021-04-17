//
//  ButtonTableViewCell.swift
//  FMobile
//
//  Created by Nathan FALLET on 10/1/18.
//  Copyright © 2018 Groupe MINASTE. All rights reserved.
//

import UIKit

class ButtonTableViewCell: UITableViewCell {

    var button: UIButton = UIButton(type: .system)
    var handler: (UIButton) -> Void = { (button) in }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        separatorInset = .zero
        
        contentView.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
        button.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor).isActive = true
        button.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.addTarget(self, action: #selector(onClick(_:)), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @available(iOS 13.0, *)
    func with(title: String, alignment: UIControl.ContentHorizontalAlignment = .center, handler: @escaping (UIButton) -> Void) -> ButtonTableViewCell {
        self.handler = handler
        button.setTitle(title, for: .normal)
        button.contentHorizontalAlignment = alignment
        
        return self
    }
    
    @available(iOS, obsoleted: 13.0)
    func with(title: String, alignment: UIControl.ContentHorizontalAlignment = .center, handler: @escaping (UIButton) -> Void, darkMode: Bool) -> ButtonTableViewCell {
        self.handler = handler
        button.setTitle(title, for: .normal)
        button.contentHorizontalAlignment = alignment
        
        if darkMode {
            backgroundColor = CustomColor.darkBackground
            button.setTitleColor(CustomColor.darkActive, for: .normal)
        } else {
            backgroundColor = CustomColor.lightBackground
            button.setTitleColor(CustomColor.lightActive, for: .normal)
        }
        return self
    }
    
    @objc func onClick(_ sender: UIButton) {
        handler(sender)
    }
    
}
