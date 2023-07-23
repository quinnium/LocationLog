//
//  LogItem+CoreDataProperties.swift
//  LocationLog
//
//  Created by Quinn on 16/10/2021.
//
//

import Foundation
import CoreData


extension LogItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LogItem> {
        return NSFetchRequest<LogItem>(entityName: "LogItem")
    }

    @NSManaged public var dateAndTimeUTC: Date?
    @NSManaged public var dateAsString: String?
    @NSManaged public var day: Int64
    @NSManaged public var hour: Int64
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var minute: Int64
    @NSManaged public var month: Int64
    @NSManaged public var second: Int64
    @NSManaged public var timeAsString: String?
    @NSManaged public var timeZone: String?
    @NSManaged public var weekdayAsString: String?
    @NSManaged public var year: Int64

}

extension LogItem : Identifiable {

}
