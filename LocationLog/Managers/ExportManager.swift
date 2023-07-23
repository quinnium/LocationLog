//
//  ExportManager.swift
//  LocationLog
//
//  Created by Quinn on 17/11/2021.
//

import Foundation
import UIKit



protocol ExportDelegateProtocol {
    func progressUpdate(step: Int, totalSteps: Int)
}



class ExportManager {
    
    static var delegate: ExportDelegateProtocol?
    
    static func createTempFileFromLogItems(itemsToExport: [LogItem], fileType: ExportType) -> URL? {
        // Convert to String
        var dataString: String?
        switch fileType {
        case .json:
            let codableLogItems     = getCodableItemsFromLogItems(logItems: itemsToExport)
            let encodedData         = convertCodableItemsToJSONData(codableLogItems: codableLogItems)
            guard encodedData       != nil else { return nil }
            dataString              = String(data: encodedData!, encoding: String.Encoding.utf8)
        case .gpx:
            dataString              = convertLogItemsToGPXString(from: itemsToExport)
        }
        guard dataString            != nil else { return nil }
        // Write String to file
        let firstDateString         = itemsToExport.last?.dateAsString ?? ""
        let lastDateString          = itemsToExport.first?.dateAsString ?? ""
        let filenameWithPath        = writeStringToTempFile(dataString: dataString!, fromString: firstDateString, toString: lastDateString, fileSuffix: fileType)
        guard filenameWithPath      != nil else { return nil }
        // Return url to file
        return filenameWithPath
    }
    
    
    private static func getCodableItemsFromLogItems(logItems: [LogItem]) -> [CodableLogItem] {
        var codableLogItems             = [CodableLogItem]()
        for item in logItems {
            if item.dateAndTimeUTC      != nil {
                let newItem             = CodableLogItem()
                newItem.dateAndTimeUTC  = item.dateAndTimeUTC!
                newItem.year            = Int(item.year)
                newItem.month           = Int(item.month)
                newItem.day             = Int(item.day)
                newItem.hour            = Int(item.hour)
                newItem.minute          = Int(item.minute)
                newItem.second          = Int(item.second)
                newItem.timeZone        = String(item.timeZone ?? "")
                newItem.dateAsString    = String(item.dateAsString ?? "")
                newItem.timeAsString    = String(item.timeAsString ?? "")
                newItem.weekdayAsString = String(item.weekdayAsString ?? "")
                newItem.latitude        = item.latitude
                newItem.longitude       = item.longitude
                codableLogItems.append(newItem)
            }
        }
        return codableLogItems
    }
    
    
    private static func convertCodableItemsToJSONData(codableLogItems: [CodableLogItem]) -> Data? {
        var encodedDataToReturn: Data?
        let encoder                     = JSONEncoder()
        let myDateFormatter             = DateFormatter()
        myDateFormatter.dateFormat      = "yyyy-MM-dd'T'HH:mm:ssZ"
        encoder.dateEncodingStrategy    = .formatted(myDateFormatter)
        encoder.outputFormatting        = .prettyPrinted
        encodedDataToReturn             = try? encoder.encode(codableLogItems)
        return encodedDataToReturn
    }
    
    
    private static func convertLogItemsToGPXString(from logItems: [LogItem]) -> String? {
        guard logItems.count > 0 else { return nil }
        var gpxString               = ""
        gpxString                   += """
            <?xml version="1.0" encoding="utf-8" standalone="no"?>
            <gpx version="1.1" creator="Location Log" xmlns="http://www.topografix.com/GPX/1/1">
                <trk>
                    <name>Location Log</name>
                    <trkseg>
            
            """
        let dateFormatter           = ISO8601DateFormatter()
        dateFormatter.timeZone      = TimeZone.current
        

        for item in logItems {
            gpxString               += "          <trkpt lat=\"\(item.latitude)\" lon=\"\(item.longitude)\">"
            gpxString               += "\n"
            if item.dateAndTimeUTC  != nil {
                let utcString       = dateFormatter.string(from: item.dateAndTimeUTC!)
                gpxString           += "          <time>\(utcString)</time>"
                gpxString           += "\n"
            }
            gpxString               += "          </trkpt>"
            gpxString               += "\n"
        }
        
        gpxString                   += """
                    </trkseg>
                </trk>
            </gpx>

            """
        return gpxString
    }
    
    
    private static func writeStringToTempFile(dataString: String, fromString: String, toString: String, fileSuffix: ExportType) -> URL? {
        // Create a custom directory
        let tempDirectory           = FileManager.default.temporaryDirectory
        let customDirectory         = tempDirectory.appendingPathComponent("Exports", isDirectory: true)
        print(customDirectory)
        // Delete any prevous existence of this custom directory, for general housekeeping
        try? FileManager.default.removeItem(at: customDirectory)
        do {
            try FileManager.default.createDirectory(at: customDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        catch {
            print(error)
            return nil
        }
        // Write to a new file in this directory
        var suffix: String
        switch fileSuffix {
        case .json:
            suffix                  = "json"
        case .gpx:
            suffix                  = "gpx"
        }
        let filename                = "LocationLog \(fromString) to \(toString).\(suffix)"
        let filenameWithPath        = customDirectory.appendingPathComponent(filename)
        do {
            try dataString.write(to: filenameWithPath, atomically: true, encoding: .utf8)
        } catch {
            return nil
        }
        // Successfully written, now return the URL to this file
        return filenameWithPath
    }

}
