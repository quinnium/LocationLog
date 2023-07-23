//
//  Constants.swift
//  LocationLog
//
//  Created by Quinn on 17/09/2021.
//

import Foundation
import UIKit


enum Colors {
    static let llPink                   = UIColor(named: "LLPink")!
    static let llButtonBackgroundTop    = UIColor(named: "LLButtonBackgroundTop")!
    static let searchBarWhite           = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
}


enum Gradients {
    static func buttonGradientNormal() -> CAGradientLayer {
        let gradientLayer           = CAGradientLayer()
        let topColor: CGColor       = UIColor.white.cgColor//UIColor.white.cgColor
        let bottomColor: CGColor    = UIColor.lightGray.cgColor//UIColor.init(red: 190/255.0, green: 190/255.0, blue: 190/255.0, alpha: 1).cgColor
        gradientLayer.colors        = [bottomColor, topColor]
        gradientLayer.startPoint    = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint      = CGPoint(x: 0, y: 0)
        return gradientLayer
    }
    static func buttonGradientInverse() -> CAGradientLayer {
        let gradientLayer           = CAGradientLayer()
        let topColor: CGColor       = UIColor.init(red: 219/255.0, green: 0/255.0, blue: 113/255.0, alpha: 1).cgColor
        let bottomColor: CGColor    = UIColor.init(red: 141/255.0, green: 0/255.0, blue: 46/255.0, alpha: 1).cgColor
        gradientLayer.colors        = [bottomColor, topColor]
        gradientLayer.startPoint    = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint      = CGPoint(x: 0, y: 0)
        return gradientLayer
    }
}


enum Variables {
    static let timeControlsShift: CGFloat = 175
}


enum AnnotationType {
    case history
    case search
}


enum DateSelectionScreenType {
    case exportData
    case deleteData
}


enum InformationScreenType {
    case privacy
    case timezone
    case thanks
}


enum ExportType {
    case json
    case gpx
}


enum Images {
    static let pin = UIImage(named: "Pin")
}


enum Identifiers {
    static let searchResultsCell        = "searchResultsCell"
    static let geoSearchResultsCell     = "geoSearchResultsCell"
    static let historyAnnotationView    = "historyAnnotationViewIdentifier"
    static let searchAnnotationView     = "searchAnnotationViewIdentifier"
    static let geoSearchViewController  = "GeoSearchViewController"
    static let loadingViewController    = "loadingViewController"
}


enum ScreenSize {
    static let width        = UIScreen.main.bounds.size.width
    static let height       = UIScreen.main.bounds.size.height
    static let maxLength    = max(ScreenSize.width, ScreenSize.height)
    static let minLength    = min(ScreenSize.width, ScreenSize.height)
}


enum DeviceTypes {
    static let idiom                    = UIDevice.current.userInterfaceIdiom
    static let nativeScale              = UIScreen.main.nativeScale
    static let scale                    = UIScreen.main.scale
    static let isiPhoneSEGen1           = idiom == .phone && ScreenSize.maxLength == 568.0
    static let isiPhoneSEGen2           = idiom == .phone && ScreenSize.maxLength == 667.0
    static let isiPhone8Standard        = idiom == .phone && ScreenSize.maxLength == 667.0 && nativeScale == scale
    static let isiPhone8Zoomed          = idiom == .phone && ScreenSize.maxLength == 667.0 && nativeScale > scale
    static let isiPhone8PlusStandard    = idiom == .phone && ScreenSize.maxLength == 736.0
    static let isiPhone8PlusZoomed      = idiom == .phone && ScreenSize.maxLength == 736.0 && nativeScale < scale
    static let isiPhoneX                = idiom == .phone && ScreenSize.maxLength == 812.0
    static let isiPhoneXsMaxAndXr       = idiom == .phone && ScreenSize.maxLength == 896.0
    static let isiPad                   = idiom == .pad && ScreenSize.maxLength >= 1024.0
    
    static func isiPhoneXAspectRatio() -> Bool {
        return isiPhoneX || isiPhoneXsMaxAndXr
    }
}


enum Segues {
    static let timeSliderSegue          = "timeSliderSegue"
    static let geoSearchSegue           = "geoSearchSegue"
    static let exportDataSegue          = "exportDataSegue"
    static let importDataSegue          = "importDataSegue"
    static let deleteDataSegue          = "deleteDataSegue"
    static let privacyInfoSegue         = "privacyInfoSegue"
    static let timezoneInfoSegue        = "timezoneInfoSegue"
    static let thanksInfoSegue          = "thanksInfoSegue"
    
}


enum ImportError: Error {
    case invalidData, requestFailed, errorSaving, unknown
}


func llPrint(for item: String) {
    print("QLog: \(item) \(Date())")
}
