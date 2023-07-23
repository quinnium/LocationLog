//
//  LLAlerts.swift
//  LocationLog
//
//  Created by Quinn on 06/10/2021.
//

import Foundation
import UIKit


enum Alerts {
    
    static func locationAccessRestricted() -> UIAlertController {
        
        let alertToReturn   = UIAlertController(
            title: "Review Location Settings",
            message: "In order for this app to be able to continupously log your location it needs your permisison to 'always' access your location - Your Location Services settings do not currently allow this.\n\nTo change this, tap 'Settings' below, select 'Location', and tap 'Always' from the list",
            preferredStyle: .alert)
        
        let settingsAction  = UIAlertAction(title: "Settings", style: .default, handler: {
            action in
            if let url      = NSURL(string:UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
            }
        })
        
        let okAction        = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        
        alertToReturn.addAction(settingsAction)
        alertToReturn.addAction(okAction)
        
        return alertToReturn
    }
}
