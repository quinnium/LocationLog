//
//  LogManager.swift
//  LocationLog
//
//  Created by Quinn on 22/02/2022.
//

import Foundation

enum LogManager {
    
    static func saveLog(save text: String) {
  
        var existingText = PersistenceManager.retrieve(key: PersistenceManager.Keys.logText_String) as? String
        if existingText == nil {
            existingText = ""
        }

        let myDateFormatter             = DateFormatter()
        myDateFormatter.dateFormat      = "yyyy-MM-dd' @ 'HH:mm:ss"
        let logDateString = myDateFormatter.string(from: Date())

        let textToAdd = "\(logDateString): \(text)"
        let textToSave = existingText! + textToAdd + "\n"
        PersistenceManager.save(key: PersistenceManager.Keys.logText_String, value: textToSave)
         
    }
    
    
    static func fetchLog() -> String {
        let fetchedText = PersistenceManager.retrieve(key: PersistenceManager.Keys.logText_String) as? String
        guard fetchedText != nil else { return "nil" }
        return fetchedText!
    }
    
    
    static func clearLog() {
        PersistenceManager.save(key: PersistenceManager.Keys.logText_String, value: "")
    }
}
