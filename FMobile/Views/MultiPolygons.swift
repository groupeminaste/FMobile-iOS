//
//  MultiPolygons.swift
//  FMobile
//
//  Created by PlugN on 17/06/2020.
//  Copyright © 2020 Groupe MINASTE. All rights reserved.
//

import Foundation
import MapKit

/// A concatenation of multiple polygons to allow a single overlay to be drawn in the map,
/// which will consume less resources
class MultiPolygon: NSObject, MKOverlay {
    
    var size: Double
    var polygons: [CoveragePoint]?
    var boundingMapRect: MKMapRect

    init(polygons: [CoveragePoint]?, size: Double) {
        self.size = size
        self.polygons = polygons
        self.boundingMapRect = MKMapRect.null

        super.init()

        guard let pols = polygons?.map({ $0.getPolygon(ofSize: size) }) else { return }
        for (index, polygon) in pols.enumerated() {
            if index == 0 { self.boundingMapRect = polygon.boundingMapRect; continue }
            boundingMapRect = boundingMapRect.union(polygon.boundingMapRect)
        }
    }

    var coordinate: CLLocationCoordinate2D {
        return MKMapPoint(x: boundingMapRect.midX, y: boundingMapRect.maxY).coordinate
    }
}
