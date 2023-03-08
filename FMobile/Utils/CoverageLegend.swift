//
//  CoverageLegend.swift
//  FMobile
//
//  Created by Nathan FALLET on 19/06/2020.
//  Copyright © 2020 Groupe MINASTE. All rights reserved.
//

import UIKit

struct CoverageLegend {
    
    // Properties
    let name: String
    let color: UIColor
    let ids: [String]
    var roaming: Bool
    var selected = true
    
    static let protocol_gprs = ["GPRS"]
    static let protocol_edge = ["EDGE", "Edge"]
    static let protocol_3g = ["WCDMA", "HSDPA", "eHRPD", "EHRPD", "HSUPA", "CDMA", "CDMAEvDoRev0", "CDMAEvDoRevA", "CDMAEvDoRevB"]
    static let protocol_lte = ["LTE"]
    static let protocol_5g = ["NR", "NRNSA"]
    static let protocol_nonetwork = ["NONETWORK"]
    static let protocol_unknown = ["UNKNOWN"]
    
    // Defined data
    static var legend = [
        // Standard
        CoverageLegend(name: "map_info_legend_gprs", color: UIColor(red: 153/255, green: 255/255, blue: 255/255, alpha: 0.4), ids: protocol_gprs, roaming: false),
        CoverageLegend(name: "map_info_legend_edge", color: UIColor(red: 51/255, green: 255/255, blue: 255/255, alpha: 0.5), ids: protocol_edge, roaming: false),
        CoverageLegend(name: "map_info_legend_3g", color: UIColor(red: 178/255, green: 255/255, blue: 102/255, alpha: 0.6), ids: protocol_3g, roaming: false),
        CoverageLegend(name: "map_info_legend_lte", color: UIColor(red: 0/255, green: 204/255, blue: 0/255, alpha: 0.75), ids: protocol_lte, roaming: false),
        CoverageLegend(name: "map_info_legend_5g", color: UIColor(red: 200/255, green: 0/255, blue: 195/255, alpha: 0.8), ids: protocol_5g, roaming: false),
        
        // Roaming
        CoverageLegend(name: "map_info_legend_gprs_r", color: UIColor(red: 255/255, green: 102/255, blue: 102/255, alpha: 0.4), ids: protocol_gprs, roaming: true),
        CoverageLegend(name: "map_info_legend_edge_r", color: UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.5), ids: protocol_edge, roaming: true),
        CoverageLegend(name: "map_info_legend_3g_r", color: UIColor(red: 190/255, green: 153/255, blue: 51/255, alpha: 0.6), ids: protocol_3g, roaming: true),
        CoverageLegend(name: "map_info_legend_lte_r", color: UIColor(red: 255/255, green: 160/255, blue: 110/255, alpha: 0.75), ids: protocol_lte, roaming: true),
        CoverageLegend(name: "map_info_legend_5g_r", color: UIColor(red: 201/255, green: 122/255, blue: 4/255, alpha: 0.8), ids: protocol_5g, roaming: true),
        
        // Unknown
        CoverageLegend(name: "map_info_legend_nonetwork", color: UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.75), ids: protocol_nonetwork, roaming: false),
        CoverageLegend(name: "map_info_legend_unknown", color: UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 0.75), ids: protocol_unknown, roaming: false)
    ]
    
}
