//
//  CarrierSelectionTableViewCell.swift
//  FMobile
//
//  Created by Nathan FALLET on 19/06/2020.
//  Copyright © 2020 Groupe MINASTE. All rights reserved.
//

import UIKit

class CarrierSelectionTableViewCell: UITableViewCell, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    weak var delegate: MapCarrierContainer?
    let textField = UITextField()
    let pickerView = UIPickerView()
    let pickerAccessory = UIToolbar()
    
    var expertMode: Bool {
        let datas = UserDefaults(suiteName: "group.fr.plugn.fmobile") ?? Foundation.UserDefaults.standard
        return datas.value(forKey: "modeExpert") as? Bool ?? false
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        separatorInset = .zero
        
        contentView.addSubview(textField)
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
        textField.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        textField.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor).isActive = true
        textField.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        textField.adjustsFontSizeToFitWidth = true
        textField.inputView = pickerView
        textField.inputAccessoryView = pickerAccessory
        textField.delegate = self
        
        pickerView.dataSource = self
        pickerView.delegate = self
        
        pickerAccessory.autoresizingMask = .flexibleHeight
        pickerAccessory.items = [
            UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(pickerViewCancel(_:))),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(pickerViewDone(_:)))
        ]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @available(iOS 13.0, *)
    func with(delegate: MapCarrierContainer?) -> CarrierSelectionTableViewCell {
        self.delegate = delegate
        updateText()
        
        return self
    }
    
    @available(iOS, obsoleted: 13.0)
    func with(delegate: MapCarrierContainer?, darkMode: Bool) -> CarrierSelectionTableViewCell {
        self.delegate = delegate
        updateText()
    
        if darkMode {
            backgroundColor = CustomColor.darkBackground
            textField.textColor = CustomColor.darkText
        } else {
            backgroundColor = CustomColor.lightBackground
            textField.textColor = CustomColor.lightText
        }
        return self
    }
    
    func updateText() {
        textField.text = delegate?.current?.toString(expertMode: expertMode)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return delegate?.carriers.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return (delegate?.carriers.count ?? 0 > row ? delegate?.carriers[row] : nil)?.toString(expertMode: expertMode) ?? ""
    }
    
    @objc func pickerViewCancel(_ sender: UIBarButtonItem) {
        textField.resignFirstResponder()
    }
    
    @objc func pickerViewDone(_ sender: UIBarButtonItem) {
        let index = pickerView.selectedRow(inComponent: 0)
        
        textField.resignFirstResponder()
        delegate?.current = delegate?.carriers.count ?? 0 > index ? delegate?.carriers[index] : nil
        updateText()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }

}

protocol MapCarrierContainer: class {
    
    var carriers: [CarrierConfiguration] { get set }
    var current: CarrierConfiguration? { get set }
    
}
