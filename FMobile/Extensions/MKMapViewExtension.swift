//
//  MKMapViewExtension.swift
//  FMobile
//
//  Created by Nathan FALLET on 17/09/2019.
//  Copyright © 2019 Groupe MINASTE. All rights reserved.
//

import Foundation
import MapKit

extension MKMapView {

    func topLeftCoordinate() -> CLLocationCoordinate2D {
        return self.convert(CGPoint(x: 0, y: 0), toCoordinateFrom: self)
    }

    func currentRadius() -> Double {
        let topLeftCoordinate = self.topLeftCoordinate()
        return sqrt(pow(centerCoordinate.latitude - topLeftCoordinate.latitude, 2) + pow(centerCoordinate.longitude - topLeftCoordinate.longitude, 2))
    }

}
