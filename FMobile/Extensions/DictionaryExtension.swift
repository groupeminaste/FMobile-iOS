//
//  DictionaryExtension.swift
//  FMobile
//
//  Created by Nathan FALLET on 31/03/2019.
//  Copyright © 2019 Groupe MINASTE. All rights reserved.
//

import Foundation

extension Dictionary where Value: Equatable {
    
    private func keysForValue(value: Value) -> [Key] {
        return compactMap { (key: Key, val: Value) -> Key? in
            value == val ? key : nil
        }
    }
    
}
