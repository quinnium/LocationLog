//
//  DateHelper.swift
//  LocationLog
//
//  Created by Quinn on 22/10/2021.
//

import Foundation

class DateHelper {
    
    static func getTimeStringFromMinutes(minutes: Int) -> String {
        let hoursString     = String(minutes / 60)
        let minutesString   = String(minutes % 60)
        let stringToReturn  = hoursString + " hrs " + minutesString + " mins"
        return stringToReturn
    }
}
