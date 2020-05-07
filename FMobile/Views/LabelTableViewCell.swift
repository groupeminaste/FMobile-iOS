//
//  TableViewCell.swift
//  FMobile
//
//  Created by Nathan FALLET on 10/1/18.
//  Copyright © 2018 Groupe MINASTE. All rights reserved.
//

import UIKit

class LabelTableViewCell: UITableViewCell {

    @IBOutlet weak var label: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        label?.font = UIFont.preferredFont(forTextStyle: .body)
        //label.font = UIFont.systemFont(ofSize: 15)
        label?.adjustsFontSizeToFitWidth = true
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
