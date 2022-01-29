//
//  MultiPolygonsRenderer.swift
//  FMobile
//
//  Created by PlugN on 17/06/2020.
//  Copyright © 2020 Groupe MINASTE. All rights reserved.
//

import Foundation
import MapKit

/// A MKOverlayPathRenderer that can draw a concatenation of multiple polygons as a single polygon
/// This will consume less resources
class MultiPolygonPathRenderer: MKOverlayPathRenderer {
    /**
     Returns a `CGPath` equivalent to this polygon in given renderer.

     - parameter polygon: MKPolygon defining coordinates that will be drawn.

     - returns: Path equivalent to this polygon in given renderer.
     */
    func polyPath(for polygon: MKPolygon?) -> CGPath? {
        guard let polygon = polygon else { return nil }
        let points = polygon.points()

        if polygon.pointCount < 3 { return nil }
        let pointCount = polygon.pointCount

        let path = CGMutablePath()

        if let interiorPolygons = polygon.interiorPolygons {
            for interiorPolygon in interiorPolygons {
                guard let interiorPath = polyPath(for: interiorPolygon) else { continue }
                path.addPath(interiorPath, transform: .identity)
            }
        }

        let startPoint = point(for: points[0])
        path.move(to: CGPoint(x: startPoint.x, y: startPoint.y), transform: .identity)

        for i in 1..<pointCount {
            let nextPoint = point(for: points[i])
            path.addLine(to: CGPoint(x: nextPoint.x, y: nextPoint.y), transform: .identity)
        }

        return path
    }

    /// Draws the overlay’s contents at the specified location on the map.
    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        // Taken from: http://stackoverflow.com/a/17673411

        guard let multiPolygon = self.overlay as? MultiPolygon else { return }
        guard let polygons = multiPolygon.polygons else { return }

        for point in polygons {
            guard let path = self.polyPath(for: point.getPolygon(ofSize: multiPolygon.size)) else { continue }
            self.applyFillProperties(to: context, atZoomScale: zoomScale)
            context.setFillColor(point.protocolToColor().cgColor)
            context.beginPath()
            context.addPath(path)
            context.drawPath(using: CGPathDrawingMode.eoFill)
            self.applyStrokeProperties(to: context, atZoomScale: zoomScale)
            context.beginPath()
            context.addPath(path)
            context.strokePath()
        }
    }
}
