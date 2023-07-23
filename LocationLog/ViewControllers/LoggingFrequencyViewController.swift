//
//  LoggingFrequencyViewController.swift
//  LocationLog
//
//  Created by AQ on 16/09/2022.
//

import UIKit

class LoggingFrequencyViewController: UIViewController {
    
    @IBOutlet weak var controlsView: UIView!
    
    @IBOutlet weak var infoTextView: UITextView!
    
    @IBOutlet weak var minTimeSlider: UISlider!
    
    @IBOutlet weak var minTimeLabel: UILabel!
       
    @IBAction func minTimeSlider(_ sender: UISlider) {
        minTimeSliderValueChanged()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        propagateTimeSliderValue()
        updateMinTimeLabel()
        infoTextView.text = Texts.loggingFrequencyText
    }
    
    
    func configureViews() {
        controlsView.layer.cornerRadius = 10
        controlsView.layer.borderWidth  = 2
        controlsView.layer.borderColor  = Colors.llPink.cgColor
        infoTextView.layer.cornerRadius = 10
        infoTextView.layer.borderWidth  = 1
        infoTextView.layer.borderColor  = UIColor.systemGray2.cgColor
    }
    
    
    func propagateTimeSliderValue() {
        // If UserDefault value exista, set them to that, else set to default value in LocationManager
        let storedMinTimeValueInSeconds = PersistenceManager.retrieve(key: PersistenceManager.Keys.minTimeIntervalInSeconds_Int) as? Int
        let minTimeValueInMinutes = (storedMinTimeValueInSeconds ?? Int(LocationManager.shared.minTimeInterval)) / 60
        minTimeSlider.setValue(Float(minTimeValueInMinutes), animated: false)
    }
    
    
    func minTimeSliderValueChanged() {
        minTimeSlider.value = minTimeSlider.value.rounded()
        let minValueInSeconds = Int(minTimeSlider.value * 60)
        updateMinTimeLabel()
        LocationManager.shared.minTimeInterval = Double(minValueInSeconds)
        PersistenceManager.save(key: PersistenceManager.Keys.minTimeIntervalInSeconds_Int, value: minValueInSeconds)
    }
    

    func updateMinTimeLabel() {
        let intValue = Int(minTimeSlider.value.rounded())
        if intValue == 1 {
            minTimeLabel.text = "1 minute"
        } else {
            minTimeLabel.text = "\(intValue) minutes"
        }
    }
}
