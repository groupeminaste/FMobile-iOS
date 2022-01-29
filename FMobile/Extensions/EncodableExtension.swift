//
//  EncodableExtension.swift
//  FMobile
//
//  Created by Nathan FALLET on 20/06/2020.
//  Copyright © 2020 Groupe MINASTE. All rights reserved.
//

import Foundation

extension Encodable {
    
    func toJSON() -> String? {
        if let json = try? JSONEncoder().encode(self), let string = String(bytes: json, encoding: .utf8) {
            return string
        }
        return nil
    }
    
}
