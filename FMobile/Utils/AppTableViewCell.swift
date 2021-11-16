//
//  AppTableViewCell.swift
//  Delta
//
//  Created by Nathan FALLET on 21/02/2020.
//  Copyright © 2020 Nathan FALLET. All rights reserved.
//

import UIKit

class AppTableViewCell: UITableViewCell {

    var icon = UIImageView()
    var name = UILabel()
    var desc = UILabel()
    var handler: (UIButton) -> Void = { (button) in }
    var button: UIButton = UIButton(type: .system)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        accessoryType = .disclosureIndicator

        contentView.addSubview(button)
        button.addSubview(icon)
        button.addSubview(name)
        button.addSubview(desc)
        

        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
        icon.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        icon.bottomAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.bottomAnchor).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 45).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 45).isActive = true
        icon.layer.masksToBounds = true
        icon.layer.cornerRadius = 8

        name.translatesAutoresizingMaskIntoConstraints = false
        name.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
        name.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 10).isActive = true
        name.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true

        desc.translatesAutoresizingMaskIntoConstraints = false
        desc.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 4).isActive = true
        desc.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 10).isActive = true
        desc.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
        desc.bottomAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.bottomAnchor).isActive = true
        desc.font = .systemFont(ofSize: 15)
        desc.textColor = .gray
        desc.lineBreakMode = .byTruncatingTail
        desc.numberOfLines = 0
        button.addTarget(self, action: #selector(onClick(_:)), for: .touchUpInside)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func with(name: String, desc: String, icon: UIImage?, handler: @escaping (UIButton) -> Void) -> AppTableViewCell {
        self.handler = handler
        self.name.text = name
        self.desc.text = desc
        self.icon.image = icon

        return self
    }
    
    @objc func onClick(_ sender: UIButton) {
        handler(sender)
    }

}
