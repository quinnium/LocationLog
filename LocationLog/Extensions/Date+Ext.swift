//
//  Date+Ext.swift
//  LocationLog
//
//  Created by Quinn on 17/11/2021.
//

import Foundation

extension Date {
    
    func LLStartOfDay() -> Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    
    func LLEndOfDay() -> Date? {
        let startOfDay  = self.LLStartOfDay()
        let endOfDay    = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)
        return endOfDay
    }
}
