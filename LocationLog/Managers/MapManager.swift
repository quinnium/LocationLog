//
//  MapManager.swift
//  LocationLog
//
//  Created by Quinn on 11/10/2021.
//

import Foundation
import MapKit

class MapManager {
    
    
    static let minLatDelta: Double = (1 / 111 / 1000 * 200) // 1 = 111 km
    static func annotationsFromLogItems(from array: [LogItem], for type: AnnotationType) -> [LLAnnotation] {
        var arrayToReturn = [LLAnnotation]()
        for item in array {
            if item.dateAsString != nil && item.timeAsString != nil && item.dateAndTimeUTC != nil {
                let newAnnotation = LLAnnotation(
                    date: item.dateAsString!,
                    time: item.timeAsString!,
                    hourAsInt: Int(item.hour),
                    minuteAsInt: Int(item.minute),
                    coordinate: CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude),
                    dateUTC: item.dateAndTimeUTC!,
                    type: type)
                arrayToReturn.append(newAnnotation)
            }
        }
        return arrayToReturn
    }
    
    
    static func configureAnnotationView(for annotation: MKAnnotation, in mapView:MKMapView, for annotationType: AnnotationType) -> MKAnnotationView? {
        var annotationView              = mapView.dequeueReusableAnnotationView(withIdentifier: Identifiers.historyAnnotationView)
        if annotationView               == nil {
            annotationView              = MKAnnotationView(annotation: annotation, reuseIdentifier: Identifiers.historyAnnotationView)
        } else {
            annotationView?.annotation  = annotation
        }
        annotationView?.image           = Images.pin
        annotationView?.centerOffset    = CGPoint(x: 4, y: -16)
        annotationView?.canShowCallout  = true
        
        if annotationType == .history {
            let rightButton                             = UIButton(type: .detailDisclosure)
            rightButton.setImage(UIImage(systemName: "trash"), for: .normal)
            rightButton.tintColor                       = Colors.llPink
            annotationView?.rightCalloutAccessoryView   = rightButton
        }
        
        if annotationType == .search {
            let rightButton                             = UIButton(type: .detailDisclosure)
            rightButton.setImage(UIImage(systemName: "arrowshape.turn.up.right"), for: .normal)
            rightButton.tintColor                       = Colors.llPink
            annotationView?.rightCalloutAccessoryView   = rightButton
        }
        return annotationView
    }
    
    
    static func getPolylinefromLogItems(from logItems: [LogItem]) -> MKPolyline {
        var coordArray      = [CLLocationCoordinate2D]()
        for item in logItems {
            let newCoord    = CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude)
            coordArray.append(newCoord)
        }
        let myPolyLine      = MKPolyline(coordinates: coordArray, count: coordArray.count)
        return myPolyLine
    }
    
    
    static func getRegionFromLogItems(array: [LogItem], expanseMultiplier: Double) -> MKCoordinateRegion {
        var regionToReturn: MKCoordinateRegion
        var latitudeArray       = [CLLocationDegrees]()
        var longitudeArray      = [CLLocationDegrees]()
        for item in array {
            latitudeArray.append(item.latitude)
            longitudeArray.append(item.longitude)
        }
        let minLatitude         = latitudeArray.min()
        let maxLatitude         = latitudeArray.max()
        let minLongitude        = longitudeArray.min()
        let maxLongitude        = longitudeArray.max()
        
        if minLatitude != nil && maxLatitude != nil && minLongitude != nil && maxLongitude != nil {
            let zoomSpan        = MKCoordinateSpan(
                latitudeDelta: Double.maximum(minLatDelta, (maxLatitude! - minLatitude!) * expanseMultiplier),
                longitudeDelta: (maxLongitude! - minLongitude!) * expanseMultiplier)
            let centreCoord     = CLLocationCoordinate2D(
                latitude: ((maxLatitude! + minLatitude!)/2),
                longitude: ((maxLongitude! + minLongitude!)/2))
            regionToReturn      = MKCoordinateRegion(center: centreCoord, span: zoomSpan)
        } else {
            // noCoords in original array, so return default zoom
            let zoomSpan        = MKCoordinateSpan(
                latitudeDelta: (180),
                longitudeDelta: (360))
            let zoomCentre      = CLLocationCoordinate2D(latitude: 0.00, longitude: 0.00)
            regionToReturn      = MKCoordinateRegion(center: zoomCentre, span: zoomSpan)
        }
        return regionToReturn
    }
    
    
    static func getTotalMetersBetweenLogItems(logItemsArray: [LogItem]) -> Double? {
        var totalDistance: Double           = 0
        let totalCount                      = logItemsArray.count
        guard totalCount > 1 else { return nil }
        for index in 0..<totalCount-1 {
            let item1                       = logItemsArray[index]
            let coord1                      = CLLocation(latitude: item1.latitude, longitude: item1.longitude)
            let item2                       = logItemsArray[index + 1]
            let coord2                      = CLLocation(latitude: item2.latitude, longitude: item2.longitude)
            let distanceInMetresBetweenTwo  = coord1.distance(from: coord2)
            totalDistance += distanceInMetresBetweenTwo
        }
        return totalDistance
    }
    
    
    static func calculateSearchMapRect (searchSquare: CGRect, mapView: MKMapView) -> MKMapRect {
        // reset the laypout margins (so as not to skew the calculations) for restoring later
        mapView.insetsLayoutMarginsFromSafeArea = false
        let storedMargine                       = mapView.layoutMargins
        mapView.layoutMargins                   = .zero
        // Calculate search rect frame edges as proportional to mapView frame size
        let leftEdgeAsProportion                = searchSquare.minX / mapView.frame.width
        let topEdgeAsProportion                 = searchSquare.minY / mapView.frame.height
        let widthAsProportion                   = searchSquare.width / mapView.frame.width
        let heightAsProportion                  = searchSquare.height / mapView.frame.height
        let fullMapRect                         = mapView.visibleMapRect
        
        let searchMapRect                       = MKMapRect(
                                                    x: fullMapRect.minX + (leftEdgeAsProportion * fullMapRect.width),
                                                    y: fullMapRect.minY + (topEdgeAsProportion * fullMapRect.height),
                                                    width: fullMapRect.width * widthAsProportion,
                                                    height: fullMapRect.height * heightAsProportion)
        // Restore margins
        mapView.layoutMargins                   = storedMargine
        
        return searchMapRect
    }
    
    
    static func getPolygonFromRect (rect: MKMapRect) -> MKPolygon {        
        let minX                            = rect.minX
        let maxX                            = rect.maxX
        let minY                            = rect.minY
        let maxY                            = rect.maxY
        
        let topLeft                         = MKMapPoint(x: minX, y: maxY)
        let topRight                        = MKMapPoint(x: maxX, y: maxY)
        let bottomRight                     = MKMapPoint(x: maxX, y: minY)
        let bottomLeft                      = MKMapPoint(x: minX, y: minY)
        
        let polyCoordinates: [MKMapPoint]   = [topLeft, topRight, bottomRight, bottomLeft, topLeft]
        let polygonToReturn                 = MKPolygon(points: polyCoordinates, count: polyCoordinates.count)
        
        return polygonToReturn
    }
 
}
