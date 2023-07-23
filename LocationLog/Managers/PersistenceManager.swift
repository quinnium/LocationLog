//
//  PersistenceManager.swift
//  LocationLog
//
//  Created by Quinn on 31/12/2021.
//

import Foundation
import MapKit

enum PersistenceManager {
    
    static let defaults                 = UserDefaults.standard

    enum Keys {
        static let appOpenedCount_Int                       = "appOpenedCount_Int"
        static let trackingActive_Bool                      = "trackingActive_Bool"
        static let mapType_String                           = "mapType_String"
        static let logText_String                           = "logText_String"
        static let minTimeIntervalInSeconds_Int             = "minTimeIntervalInSeconds_Int"
        static let allowPausingOfLocationUpdates_Bool       = "allowPausingOfLocationUpdates_Bool" // no longer used
        static let allowPausingOfLocationUpdatesNew_Bool    = "allowPausingOfLocationUpdates_Bool" // no longer usedlo
    }
    
    
    enum Values {
        static let mapType_standard     = "mapType_standard"
        static let mapType_satellite    = "mapType_satellite"
    }
    
    
    static func save(key: String, value: Any) {
        defaults.setValue(value, forKey: key)
    }
    
    
    static func retrieve(key: String) -> Any? {
        return defaults.value(forKey: key)
    }
    
    
    static func getMapTypePreference() -> MKMapType {
        let key                 = Keys.mapType_String
        let userPreference      = PersistenceManager.retrieve(key: key) as? String
        switch userPreference {
        case PersistenceManager.Values.mapType_standard:
            return MKMapType.standard
        case PersistenceManager.Values.mapType_satellite:
            return MKMapType.satellite
        default:
            PersistenceManager.save(key: key, value: PersistenceManager.Values.mapType_standard)
            return MKMapType.standard
        }
    }
    
    
    static func getTrackingPreference() -> Bool {
        let key                 = Keys.trackingActive_Bool
        if let storedPref       = retrieve(key: key) as? Bool {
            return storedPref
        } else {
            save(key: key, value: true)
            return true
        }
    }
    
    
    static func updateAppOpenedCount() {
        let key                 = Keys.appOpenedCount_Int
        var newCount: Int
        if let existingCount    = retrieve(key: key) as? Int {
            newCount            = existingCount + 1
        } else {
            newCount            = 1
        }
        save(key: key, value: newCount)
    }
    
    
    static func getAppOpenedCount() -> Int {
        if let count            = retrieve(key: Keys.appOpenedCount_Int) as? Int {
            return count
        } else {
            return 0
        }
    }
}
