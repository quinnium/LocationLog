//
//  TimeSliderViewController.swift
//  LocationLog
//
//  Created by Quinn on 21/09/2021.
//

import UIKit

protocol HistoryVCTimeSliderProtocol {
    func timeSliderFilteredLogItems(for logItems:[LogItem])
}



class TimeSliderViewController: UIViewController {

    var delegate: HistoryVCTimeSliderProtocol?
    var logsForDateSelected = [LogItem]()

    @IBOutlet weak var timeFromSlider: UISlider!
    @IBOutlet weak var timeFromLabel: UILabel!
    @IBOutlet weak var timeToSlider: UISlider!
    @IBOutlet weak var timeToLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBAction func timeFromSlider(_ sender: UISlider) {
        sliderValueLogicCheck(slider: sender)
        updateSliderLabel(slider: sender)
        updatePageForSliderValues()
    }
    
    @IBAction func timeToSlider(_ sender: UISlider) {
        sliderValueLogicCheck(slider: sender)
        updateSliderLabel(slider: sender)
        updatePageForSliderValues()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAndReset(forLogItems: logsForDateSelected)
    }
    
    
    func configureAndReset(forLogItems: [LogItem]) {
        logsForDateSelected         = forLogItems
        timeFromSlider.minimumValue = 0
        timeFromSlider.maximumValue = 1440
        timeFromSlider.value        = timeFromSlider.minimumValue
        timeFromLabel.text            = "00:00"
        timeToSlider.minimumValue   = 0
        timeToSlider.maximumValue   = 1440
        timeToSlider.value          = timeToSlider.maximumValue
        timeToLabel.text            = "00:00"
        infoLabel.text              = ""
    }

    
    func sliderValueLogicCheck(slider: UISlider) {
        if slider                   == timeFromSlider {
            guard slider.value      < timeToSlider.value else {
                slider.value        = timeToSlider.value - 1
                return
            }
        }
        else if slider              == timeToSlider {
            guard slider.value      > timeFromSlider.value else {
                slider.value        = timeFromSlider.value + 1
                return
            }
        }
    }
    
    
    func updateSliderLabel(slider: UISlider) {
        // Convert value to text for time
        let value               = slider.value
        let hours               = Int(value / 60)
        let minutes             = Int(value) % 60
        let hoursString         = String(format: "%02d", hours)
        let minutesString       = String(format: "%02d", minutes)
        var textString: String
        if value                == 1440 {
            textString          = "00:00"
        } else {
            textString          = "\(hoursString):\(minutesString)"
        }
        // Update respective label
        if slider               == timeFromSlider {
            timeFromLabel.text  = textString
        }
        else if slider          == timeToSlider {
            timeToLabel.text    = textString
        }
   }
    
    
    func updatePageForSliderValues() {
        let timeFrom            = Int(timeFromSlider.value)
        let timeTo              = Int(timeToSlider.value)
        var filteredArray       = [LogItem]()
        for item in logsForDateSelected {
            let itemMinuteOfDay = (item.hour * 60) + (item.minute)
            if itemMinuteOfDay  >= timeFrom && itemMinuteOfDay <= timeTo {
                filteredArray.append(item)
            }
        }
        let totalMinutes        = timeTo - timeFrom
        updateLabelForFilteredItems(items: filteredArray, totalMinutes: totalMinutes)
        delegate?.timeSliderFilteredLogItems(for: filteredArray)
    }
    
    
    func updateLabelForFilteredItems(items: [LogItem], totalMinutes: Int) {
        let timeString          = DateHelper.getTimeStringFromMinutes(minutes: totalMinutes)
        let distanceInMetres    = MapManager.getTotalMetersBetweenLogItems(logItemsArray: items)
        if distanceInMetres     == nil {
            infoLabel.text      = timeString
            return
        }
        var distanceString      = ""
        if distanceInMetres!    < 100 {
            distanceString      = "Less than 100m"
        } else
        if distanceInMetres!    < 1000 {
            let roundedDistance = Int(distanceInMetres!.rounded())
            distanceString      = "\(roundedDistance)m"
        } else
        if distanceInMetres!    >= 1000 {
            let distanceInKM    = (distanceInMetres!/100).rounded() / 10
            let distanceInMiles = ((distanceInKM * (0.6213711922))*10).rounded() / 10
            distanceString      = "\(distanceInKM) km (\(distanceInMiles) miles)"
        }
        infoLabel.text          = timeString + ", " + distanceString + " travelled"
    }
    
    
    func updateForDateWithoutMovingSliders(logItems: [LogItem]) {
        logsForDateSelected     = logItems
        updatePageForSliderValues()
    }
    
    
    func isTimeWithinSliderValues(hour: Int, minute: Int) -> Bool {
        let minuteOfDay = (hour * 60) + minute
        let fromMinute  = Int(timeFromSlider.value)
        let toMinute    = Int(timeToSlider.value)
        if minuteOfDay >= fromMinute && minuteOfDay <= toMinute {
            return true
        } else {
            return false
        }
    }
}
