//
//  MoreViewController.swift
//  LocationLog
//
//  Created by Quinn on 16/11/2021.
//

import UIKit

class MoreTableViewController: UITableViewController {

    @IBOutlet weak var loggingSwitch: UISwitch!
    @IBOutlet weak var mapTypeSwitch: UISegmentedControl!
    @IBOutlet weak var versionLabel: UILabel!
    
    @IBAction func loggingSwitch(_ sender: Any) {
        trackingSwitchChanged()
        LocationManager.shared.safelyStartOrStopTracking()
    }
    
    @IBAction func mapTypeSwitch(_ sender: UISegmentedControl) {
        mapTypeSwitchChanged()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureMapTypeSwitch()
        configureTrackingSwitch()
        setVersionLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.exportDataSegue {
            let destVC      = segue.destination as! ExportDeleteViewController
            destVC.pageType = .exportData
        }
        
        if segue.identifier == Segues.deleteDataSegue {
            let destVC      = segue.destination as! ExportDeleteViewController
            destVC.pageType = .deleteData
        }
        
        if segue.identifier == Segues.privacyInfoSegue {
            let destVC      = segue.destination as! InformationViewController
            destVC.pageType = .privacy
        }
        
        if segue.identifier == Segues.timezoneInfoSegue {
            let destVC      = segue.destination as! InformationViewController
            destVC.pageType = .timezone
        }
        
        if segue.identifier == Segues.thanksInfoSegue {
            let destVC      = segue.destination as! InformationViewController
            destVC.pageType = .thanks
        }
    }
    
    
    private func configureTrackingSwitch() {
        loggingSwitch.isOn  = PersistenceManager.getTrackingPreference()
    }
    
    
    private func trackingSwitchChanged() {
        let setting         = loggingSwitch.isOn
        PersistenceManager.save(key: PersistenceManager.Keys.trackingActive_Bool, value: setting)
    }
    
    
    private func configureMapTypeSwitch() {
        let mapType         = PersistenceManager.getMapTypePreference()
        switch mapType {
        case .standard:
            mapTypeSwitch.selectedSegmentIndex = 0
        case .satellite:
            mapTypeSwitch.selectedSegmentIndex = 1
        default:
            mapTypeSwitch.selectedSegmentIndex = 0
        }
    }
    
    
    private func mapTypeSwitchChanged() {
        var value: String
        switch mapTypeSwitch.selectedSegmentIndex {
        case 0:
            value = PersistenceManager.Values.mapType_standard
        case 1:
            value = PersistenceManager.Values.mapType_satellite
        default:
            showSimpleAlert(title: "Not Found", message: "Map type not found, please contact the developer", buttonText: "OK")
            return
        }
        PersistenceManager.save(key: PersistenceManager.Keys.mapType_String, value: value)
    }
    
    
    private func setVersionLabel() {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        versionLabel.text = "version \(version), build \(build)"
    }
}
