//
//  LLAnnotation.swift
//  LocationLog
//
//  Created by Quinn on 11/10/2021.
//

import Foundation
import MapKit

class LLAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var timeAsString: String
    var dateAsString: String
    var dateAndTimeUTC: Date
    var title: String?
    var hourAsInt: Int
    var minuteAsInt: Int
    
    
    init(date: String, time: String, hourAsInt: Int, minuteAsInt: Int, coordinate: CLLocationCoordinate2D, dateUTC: Date, type: AnnotationType) {
        self.timeAsString   = time
        self.dateAsString   = date
        self.coordinate     = coordinate
        self.dateAndTimeUTC = dateUTC
        self.hourAsInt      = hourAsInt
        self.minuteAsInt    = minuteAsInt
        switch type {
        case .history:
            self.title      = timeAsString
        case .search:
            self.title      = dateAsString
        }
    }
}
