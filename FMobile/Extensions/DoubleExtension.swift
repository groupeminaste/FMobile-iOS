//
//  DoubleExtension.swift
//  FMobile
//
//  Created by PlugN on 27/04/2019.
//  Copyright © 2019 Groupe MINASTE. All rights reserved.
//

import Foundation

extension Double {
    
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    func toSpeedtest() -> (String?, String?) {
        if self < 1 {
            return ("\(Int((self * 1000).rounded()))", "Kbps")
        }
        return ("\(self.rounded(toPlaces: 1))", "Mbps")
    }
    
    func simplify(withLetters: Bool = true) -> String {
        if self.isInfinite {
            return "∞"
        }
        
        if withLetters {
            if self >= 1_000_000_000 {
                return "\((self / 1_000_000_000).simplifyToOneDecimal())G"
            }
            
            if self >= 1_000_000 {
                return "\((self / 1_000_000).simplifyToOneDecimal())M"
            }
            
            if self >= 1_000 {
                return "\((self / 1_000).simplifyToOneDecimal())K"
            }
        }
        
        return self.simplifyToOneDecimal()
    }
    
    func oneDecimal() -> Double {
        return (floor(self * 10) / 10)
    }
    
    func simplifyToOneDecimal() -> String {
        let oneDecimal = self.oneDecimal()
        if floor(oneDecimal) == oneDecimal {
            return String.localizedStringWithFormat("%d", Int(oneDecimal))
        }
        return String.localizedStringWithFormat("%.01f", oneDecimal)
    }
    
}
