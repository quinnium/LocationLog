//
//  Texts.swift
//  LocationLog
//
//  Created by Quinn on 03/01/2022.
//

import Foundation

enum Texts {
    
    static let loggingFrequencyText = """
    Adjusting this setting will likely affect battery life - the more frequently the app tries to log its location the higher the app's demand is on the device's battery.

    Please note: your device's iOS may choose to terminate ('kill') the app in the background from time to time if/when the iOS requires additional resources. If this happens then the app's logging should re-commence automatically once you have changed location by a significant amount (by approximately 500m).
    """
    
    
    static let exportInfoText = """
        Exporting to 'JSON' format produces a file that can be imported back into this app (so would be useful to backup your data with), but it uses a proprietary schema and therefore will not be usable by any other app/software.
        
        'GPX' format is a commonly recognised format that will be able to be easily imported/read by many other apps/software (but not by this app).
        
        Exported data will include all logs created from the start of the day of the 'from' date, to the end of the day of the 'to' date. Dates selected will be according to your device's current timezone setting.
        """
    
    
    static let importInfoText = """
        Only files that have been exported by this app can be imported (as they need to be of the correct JSON format and schema).
        
        Restrictions require that, when importing from a file via a URL, it must be done using a secure (https) URL, and therefore it will be easier to 'import from file.
        """
    
    
    static let deleteInfoText = """
        Deleted data will include all logs created from the start of the day of the 'from' date, to the end of the day of the 'to' date. Dates selected will be according to your device's current timezone setting.
        """
    
    
    enum Privacy {
        static let title = "Privacy"
        static let text = """
        This app was specifically built by the developer to give users the ability to privately and continuously log their own movements, without having to share / store their data with anyone else (including the developer).
        
        Because this app's location history data is held locally on your device it is recommended that you export your data from time to time (using the app's 'Export Data' feature), otherwise, if you lose your device (or delete this app's data from it), there is no other way to retrieve your location history (other than from device backups).
        
        It should be noted that if you choose to backup your device (for example: using iCloud Backup, or manually backing up your device to your Mac/PC) then this app's data (including the location history data stored by the app) would be included in that backup; this is mentioned because in such an instance your data would then be stored outside of your device and should be usable to restore your location history from if you lost your device (by restoring a new device from that backup). If you upgrade your device, and choose to set it up by restoring your data from your last iCloud Backup, then your new device's Location Log app should then retain all your location history data from your previous device's app.
        """
    }
    
    
    enum Timezones {
        static let title = "Timezones & Location"
        static let text = """
        All times and dates shown on pins and search results are based on the local time zone to the respective location item. Any date / area searches (as well as 'Data Export / Delete' features) are based on the timezone the device is currently set to. If you notice any discrepancy or error that you think might be as a result of a time zone issue, then please feedback this issue in order for this to be fixed in a future update.
        
        Your device determines your location based on a number of factors, and passes this determined location to the app. This app has been uniquely designed to try to achieve the best accuracy reasonably possible but without drawing too much energy from your device's battery, and as a result the accuracy of these location logs can occasionally be less than perfect. The Developer of this app accepts no responsibility or liability for the accuracy or integrity of any data produced, stored, or shown by this app in any way.
        
        Battery drain can vary depending on how you use your device. If you notice battery usage significantly and consistently higher than 10% of total then please get in touch to notify of this issue, so that it can be looked into. It is advised to ensure that your device's WiFi is kept 'On' (even if it isn't connected to any WiFi network) as this is one of the many ways that the iOS system uses to help determine your location (along with cell tower triangulation and, of course, GPS).
        """
    }
    
    
    enum Thanks {
        static let title = "Feedback & Thanks"
        static let text = """
        If you have any issues, queries, or experience any bugs, then feel free to email: LocationLog@quinnium.com. For anyone wishing to simply say 'thanks for the free app', the easiest way to do this is by kindly giving a review on the App Store, which I would greatly appreciate.
        
        Having built this app, and continuously learning Swift since, I am currently (early 2023) looking to become a full-time iOS app developer. If you have any opportunities for a UK-based Swift developer please get in touch on the email address shown above.
        
        For anyone looking to learn for themselves how to create an iPhone app, I highly recommend CodeWithChris.com for teaching the core basics of coding in a well-structured and easy-to-learn way online, and suitable for complete beginners. Huge thanks to SeanAllen.co as well for his teaching, whom I also highly recommend.
        
        With thanks and love to my ever caring and perfect partner Kate, for putting up with having to share me with my laptop so often, and for being the first (unofficial) usability tester.
        """
    }
}

