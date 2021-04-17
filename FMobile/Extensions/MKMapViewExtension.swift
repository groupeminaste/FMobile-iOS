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

    func topCenterCoordinate() -> CLLocationCoordinate2D {
        return self.convert(CGPoint(x: self.frame.size.width / 2.0, y: 0), toCoordinateFrom: self)
    }

    func currentRadius() -> Double {
        let topCenterCoordinate = self.topCenterCoordinate()
        return sqrt(pow(centerCoordinate.latitude - topCenterCoordinate.latitude, 2) + pow(centerCoordinate.longitude - topCenterCoordinate.longitude, 2))
    }

}
