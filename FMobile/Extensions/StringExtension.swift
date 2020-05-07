//
//  StringExtension.swift
//  FMobile
//
//  Created by Nathan FALLET on 15/05/2019.
//  Copyright © 2019 Groupe MINASTE. All rights reserved.
//

import Foundation

extension String {
    
    func localized(bundle: Bundle = .main, tableName: String = "Localizable") -> String {
        return NSLocalizedString(self, tableName: tableName, value: "**\(self)**", comment: "")
    }
    
    func format(_ args : CVarArg...) -> String {
        return String(format: self, locale: .current, arguments: args)
    }
    
    func format(_ args : [String]) -> String {
        return String(format: self, locale: .current, arguments: args)
    }
    
}
