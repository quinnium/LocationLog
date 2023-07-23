//
//  ShortcutsManager.swift
//  LocationLog
//
//  Created by AQ on 01/07/2022.
//

import Foundation
import UIKit

enum ShortcutsManager {
    
    enum ActionType: String {
        case generateTrackingOffOption = "generateTrackingOffOption"
        case generateTrackingOnOption = "generateTrackingOnOption"
    }
    
    
    static func generateShortcutOption(type: ActionType) {
        let application = UIApplication.shared
        
        var myShortcut = UIApplicationShortcutItem(type: "", localizedTitle: "")
        
        switch type {
        case .generateTrackingOffOption:
            myShortcut = UIApplicationShortcutItem(type: ActionType.generateTrackingOffOption.rawValue,
                                                        localizedTitle: "Turn Logging Off",
                                                        localizedSubtitle: nil,
                                                        icon: UIApplicationShortcutIcon(systemImageName: "location.slash"),
                                                        userInfo: nil)
        case .generateTrackingOnOption:
            myShortcut = UIApplicationShortcutItem(type: ActionType.generateTrackingOnOption.rawValue,
                                                        localizedTitle: "Turn Logging On",
                                                        localizedSubtitle: nil,
                                                        icon: UIApplicationShortcutIcon(systemImageName: "location.fill"),
                                                        userInfo: nil)
        }
                
        application.shortcutItems = [myShortcut]
    }
    
    
    static func handler(for actionType: ActionType, tabBar: UITabBarController) {
        
        switch actionType {
        case .generateTrackingOffOption:
            print("tracking Off launched")
            LocationManager.shared.trackingOn = false
            PersistenceManager.save(key: PersistenceManager.Keys.trackingActive_Bool, value: false)
            
        case .generateTrackingOnOption:
            print("tracking On launched")
            LocationManager.shared.trackingOn = true
            PersistenceManager.save(key: PersistenceManager.Keys.trackingActive_Bool, value: true)
        }
        
        LocationManager.shared.safelyStartOrStopTracking()
        
        tabBar.selectedIndex = 2
    }
}
