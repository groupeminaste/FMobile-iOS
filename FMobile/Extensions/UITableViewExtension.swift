//
//  UITableViewExtension.swift
//  FMobile
//
//  Created by PlugN on 07/05/2019.
//  Copyright © 2019 Groupe MINASTE. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {
    
    /// Check if cell at the specific section and row is visible
    /// - Parameters:
    /// - section: an Int reprenseting a UITableView section
    /// - row: and Int representing a UITableView row
    /// - Returns: True if cell at section and row is visible, False otherwise
    func isCellVisible(section:Int, row: Int) -> Bool {
        guard let indexes = self.indexPathsForVisibleRows else {
            return false
        }
        return indexes.contains {$0.section == section && $0.row == row }
    }
    
}
