//
//  SearchHelper.swift
//  LocationLog
//
//  Created by Quinn on 03/10/2021.
//

import Foundation
import MapKit

class SearchHelper {
    
    static func getStringFromCompletion(completion: MKLocalSearchCompletion) -> String {
        var stringToReturn      = ""
        stringToReturn          += completion.title
        if completion.subtitle  != "" {
            stringToReturn      += ", " + completion.subtitle
        }
        return stringToReturn
    }
    
    
    static func getRegionFromCompletion(mkCompletion: MKLocalSearchCompletion, completed: @escaping (MKCoordinateRegion?) -> Void) {
        //Fetch actual location item from 'completion' item
        let searchRequest               = MKLocalSearch.Request(completion: mkCompletion)
        let search                      = MKLocalSearch(request: searchRequest)
        // Run the fetch/search (+ closure)
        search.start { response, error in
            var regionToReturn: MKCoordinateRegion?
            // Check no errors
            guard response?.mapItems[0] != nil && error == nil else {
                regionToReturn = nil
                completed(regionToReturn)
                return
            }
            let returnedItem            = response!.mapItems[0]
            // If response contains a location & region ('ClCircularRegion')...
            if let circularRegion       = returnedItem.placemark.region as? CLCircularRegion {
                // Create an adjuster to zoom out further than default region
                let adjuster: Double    = 2.0
                regionToReturn          = MKCoordinateRegion(
                    center: circularRegion.center,
                    latitudinalMeters: circularRegion.radius * adjuster,
                    longitudinalMeters: circularRegion.radius * adjuster)
            } else {
                // Otherwise response just contains a location...
                let span                = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                regionToReturn          = MKCoordinateRegion(center: returnedItem.placemark.coordinate, span: span)
            }
            completed(regionToReturn)
        }
    }
}

