//
//  UIDatePicker+Ext.swift
//  LocationLog
//
//  Created by Quinn on 18/10/2021.
//

import Foundation
import UIKit

extension UIDatePicker {
    
    func advanceDateBy(numberOfDays days: Int) {
        let selectedDate    = date
        let newDate         = calendar.date(byAdding: .day, value: days, to: selectedDate)
        guard newDate       != nil else { return }
        setDate(newDate!, animated: true)
    }
}
