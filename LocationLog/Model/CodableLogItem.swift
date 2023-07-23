//
//  CodableLogItem.swift
//  LocationLog
//
//  Created by Quinn on 17/11/2021.
//

import Foundation

class CodableLogItem: Codable {
    //UTC date and time
    var dateAndTimeUTC  = Date()
    
    //All the folliwing are local time componants
    var year            = 0
    var month           = 0
    var day             = 0
    var hour            = 0
    var minute          = 0
    var second          = 0
    var timeZone        = ""
    var dateAsString    = ""
    var timeAsString    = ""
    var weekdayAsString = ""

    // Location Coords (Lat/Long)
    var latitude        = 0.00
    var longitude       = 0.00
}
