//
//  ButtonTableViewCell.swift
//  FMobile
//
//  Created by Nathan FALLET on 10/1/18.
//  Copyright © 2018 Groupe MINASTE. All rights reserved.
//

import UIKit

class ButtonTableViewCell: UITableViewCell {

    @IBOutlet weak var button: UIButton?
    var handler: (UIButton) -> Void = { (button) in }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        button?.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        //button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        button?.titleLabel?.adjustsFontSizeToFitWidth = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onClick(_ sender: UIButton) {
        handler(sender)
    }
    
}
