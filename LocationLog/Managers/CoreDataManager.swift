//
//  CoreDataManager.swift
//  LocationLog
//
//  Created by Quinn on 07/10/2021.
//

import Foundation
import CoreLocation
import UIKit
import CoreData
import MapKit


class CoreDataManager {
    
    static let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    static func saveNewLogItem (locationUpdate: CLLocation) {
        let dateFormatter                   = DateFormatter()
        dateFormatter.dateFormat            = "dd-MMM-yyyy"
        let timeFormatter                   = DateFormatter()
        timeFormatter.dateFormat            = "HH:mm:ss"
        let timeZoneFormatter               = DateFormatter()
        timeZoneFormatter.dateFormat        = "Z"
        let calendar                        = Calendar.autoupdatingCurrent
    
        let newLogItem                      = LogItem(context: context)
        newLogItem.dateAndTimeUTC           = locationUpdate.timestamp
        newLogItem.year                     = Int64(calendar.component(.year, from: locationUpdate.timestamp))
        newLogItem.month                    = Int64(calendar.component(.month, from: locationUpdate.timestamp))
        newLogItem.day                      = Int64(calendar.component(.day, from: locationUpdate.timestamp))
        newLogItem.hour                     = Int64(calendar.component(.hour, from: locationUpdate.timestamp))
        newLogItem.minute                   = Int64(calendar.component(.minute, from: locationUpdate.timestamp))
        newLogItem.second                   = Int64(calendar.component(.second, from: locationUpdate.timestamp))
        newLogItem.timeZone                 = timeZoneFormatter.string(from: locationUpdate.timestamp)
        newLogItem.dateAsString             = dateFormatter.string(from: locationUpdate.timestamp)
        newLogItem.timeAsString             = timeFormatter.string(from: locationUpdate.timestamp)
        // creating the weekday is more involved...
        let numberDayOfWeek                 = calendar.component(.weekday, from: locationUpdate.timestamp)
        switch numberDayOfWeek {
        case 1: newLogItem.weekdayAsString  = "Sunday"
        case 2: newLogItem.weekdayAsString  = "Monday"
        case 3: newLogItem.weekdayAsString  = "Tuesday"
        case 4: newLogItem.weekdayAsString  = "Wednesday"
        case 5: newLogItem.weekdayAsString  = "Thursday"
        case 6: newLogItem.weekdayAsString  = "Friday"
        case 7: newLogItem.weekdayAsString  = "Saturday"
        default: newLogItem.weekdayAsString = ""
        }
        // Create location constants
        newLogItem.latitude                 = locationUpdate.coordinate.latitude
        newLogItem.longitude                = locationUpdate.coordinate.longitude
        
        do {
            try context.save()
        }
        catch {
            print("QLog: Couldn't save the log to CoreData \(error)")
        }
    }
    
    
    static func fetchAllLogItemsMixed() -> [LogItem]? {
        var arrayToReturn: [LogItem]?
        let fullFetch       = LogItem.fetchRequest()
        try? arrayToReturn  = context.fetch(fullFetch)
        return arrayToReturn
    }
    
    
    static func fetchAllLogItemsOrdered(ascending: Bool) -> [LogItem]? {
        var arrayToReturn: [LogItem]?
        let orderedFetch                = LogItem.fetchRequest() as NSFetchRequest
        let sort                        = NSSortDescriptor(key: "dateAndTimeUTC", ascending: ascending)
        orderedFetch.sortDescriptors    = [sort]
        try? arrayToReturn              = context.fetch(orderedFetch)
        return arrayToReturn
    }
    
    
    static func fetchLogItemsForDateOrdered(for date: Date) -> [LogItem]? {
        var arrayToReturn: [LogItem]?
        let calendar                = Calendar.autoupdatingCurrent
        let year                    = calendar.component(.year, from: date)
        let month                   = calendar.component(.month, from: date)
        let day                     = calendar.component(.day, from: date)
        let filteredFetch           = LogItem.fetchRequest() as NSFetchRequest
        let predicateFilter         = NSPredicate(format: "year == %@ && month == %@ && day == %@", String(year), String(month), String(day))
        filteredFetch.predicate     = predicateFilter
        try? arrayToReturn          = context.fetch(filteredFetch)
        arrayToReturn?.sort {
            $0.dateAndTimeUTC! > $1.dateAndTimeUTC!
        }
        return arrayToReturn
    }
    
    
    static func fetchLogItemsBetweenDatesOrdered(from startDate: Date, toInclusive endDate:Date) -> [LogItem] {
        var arrayToReturn       = [LogItem]()
        let allItems            = fetchAllLogItemsOrdered(ascending: true)
        guard let allItems      = allItems else { return arrayToReturn }
        for item in allItems {
            if let itemDate = item.dateAndTimeUTC {
                if  itemDate >= startDate &&
                    itemDate <= endDate {
                    arrayToReturn.append(item)
                }
            }
        }
        arrayToReturn.sort {
            $0.dateAndTimeUTC! < $1.dateAndTimeUTC! }
        return arrayToReturn
    }

    
    static func deleteLogItems(items: [LogItem], completion: @escaping (Bool) -> Void) {
        for item in items {
            context.delete(item)
        }
        do {
            try context.save()
            completion(true)
        } catch {
            completion(false)
        }
    }
    
    
    static func deleteLogItemWithTime(dateAndTimeUTC: Date) {
        var fetchedLogItems     = [LogItem]()
        let filteredFetch       = LogItem.fetchRequest() as NSFetchRequest
        let predicateFilter     = NSPredicate(format: "dateAndTimeUTC == %@", dateAndTimeUTC as NSDate)
        filteredFetch.predicate = predicateFilter
        do {
            try fetchedLogItems = context.fetch(filteredFetch)
        }
        catch {
            print("QLog: failed to fetch data!")
        }
        for item in fetchedLogItems {
            context.delete(item)
        }
        do {
            try context.save()
        } catch {
            print("QLog: Couldn't save the conext!!")
        }
    }
    
    
    static func printTotalCoreDataItems() {
        guard let array = try? context.fetch(LogItem.fetchRequest()) else { return }
        print("QLog: Total Logs in Context: \(array.count)")
    }
    
    
    static func fetchLogItemsWithinRect(within searchRect: MKMapRect) -> [LogItem] {
        var itemsToReturn       = [LogItem]()
        let allItems            = fetchAllLogItemsMixed()
        guard let allItems      = allItems else { return itemsToReturn }
        for item in allItems {
            let location        = CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude)
            let itemMapPoint    = MKMapPoint(location)
            if searchRect.contains(itemMapPoint) {
                itemsToReturn.append(item)
            }
        }
        return itemsToReturn
    }
    
    
    static func saveCodableLogItems(codableLogItems newItems: [CodableLogItem], completion: @escaping (Result<Int, ImportError>) -> Void) {
        let uniqueNewItemsForSaving = filterUnnecessaryItems(codableItems: newItems)

        var count = 0
        for item in uniqueNewItemsForSaving {
            let newItem             = LogItem(context: context)
            newItem.dateAndTimeUTC  = item.dateAndTimeUTC
            newItem.year            = Int64(item.year)
            newItem.month           = Int64(item.month)
            newItem.day             = Int64(item.day)
            newItem.hour            = Int64(item.hour)
            newItem.minute          = Int64(item.minute)
            newItem.second          = Int64(item.second)
            newItem.timeZone        = item.timeZone
            newItem.dateAsString    = item.dateAsString
            newItem.timeAsString    = item.timeAsString
            newItem.weekdayAsString = item.weekdayAsString
            newItem.latitude        = item.latitude
            newItem.longitude       = item.longitude
            
            count += 1
        }
        
        do {
            try context.save()
            completion(.success(count))
        }
        catch {
            print("QLog: \(error)")
            completion(.failure(.errorSaving))
        }
    }
    
    
    private static func filterUnnecessaryItems(codableItems: [CodableLogItem]) -> [CodableLogItem] {
        var itemsToReturn                   = [CodableLogItem]()
        
        // Remove duplicates from codableItems
        var sortedUniqueNewItems            = codableItems
        sortedUniqueNewItems.sort {
            $0.dateAndTimeUTC > $1.dateAndTimeUTC
        }
        for index in 0..<sortedUniqueNewItems.count {
            if index < (sortedUniqueNewItems.count - 1) {
                if sortedUniqueNewItems[index].dateAndTimeUTC == sortedUniqueNewItems[index+1].dateAndTimeUTC {
                    sortedUniqueNewItems.remove(at: index+1)
                }
            }
        }
        itemsToReturn                       = sortedUniqueNewItems
        
        // Filter for those already within CoreData
        let existingItems                   = fetchAllLogItemsOrdered(ascending: false)
        guard existingItems                 != nil else { return itemsToReturn }
        
        var uniqueExistingDates: Set<Date>  = []
        for index in 0..<existingItems!.count {
            if let date                     = existingItems![index].dateAndTimeUTC {
                uniqueExistingDates.insert(date)
            }
        }
        var arrayOfIndexesToDelete          = [Int]()
        for index in 0..<itemsToReturn.count {
            if uniqueExistingDates.contains(itemsToReturn[index].dateAndTimeUTC) {
                arrayOfIndexesToDelete.append(index)
            }
        }
        arrayOfIndexesToDelete.sort() {
            $0 > $1
        }
        for number in arrayOfIndexesToDelete {
            itemsToReturn.remove(at: number)
        }
        
        return itemsToReturn
    }
    
}
