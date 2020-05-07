//
//  SwitchTableViewCell.swift
//  FMobile
//
//  Created by Nathan FALLET on 10/1/18.
//  Copyright © 2018 Groupe MINASTE. All rights reserved.
//

import UIKit

class SwitchTableViewCell: UITableViewCell {

    @IBOutlet weak var label: UILabel?
    @IBOutlet weak var switchElement: UISwitch?
    var id = String()
    var controller: TableViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        label?.font = UIFont.preferredFont(forTextStyle: .body)
        //label.font = UIFont.systemFont(ofSize: 15)
        label?.adjustsFontSizeToFitWidth = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onChange(_ sender: Any) {
        let datas = Foundation.UserDefaults.standard
        datas.set(switchElement?.isOn, forKey: id)
        datas.set(true, forKey: "didChangeSettings")
        datas.synchronize()
        
        if let table = controller {
            table.loadUI()
            table.refreshSections()
        }
    }
    
}
