//
//  ViewController.swift
//  LocationLog
//
//  Created by Quinn on 30/08/2021.
//

import UIKit
import Foundation
import MapKit
import CoreLocation

class HistoryViewController: UIViewController {
        
    let locationManager = LocationManager.shared
    var logsForDateSelected = [LogItem]()
    var isRegionSetForDateSelected: Bool?
    var timeSliderVC: TimeSliderViewController?
    var isDatePickerVisible = true
    var isCalendarVisible = true
    
    @IBOutlet weak var sizingFrame: UIView!
    @IBOutlet weak var buttonsFrame: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var rightButton: LLButton!
    @IBOutlet weak var datePickerFrameTop: NSLayoutConstraint!
    @IBOutlet weak var datePickerFrameBottom: NSLayoutConstraint!
    @IBOutlet weak var datePickerViewLeading: NSLayoutConstraint!
    @IBOutlet weak var datePickerViewTrailing: NSLayoutConstraint!
    @IBOutlet weak var buttonsFrameHeight: NSLayoutConstraint!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var sizingFrameBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var datePopup: UIView!
    @IBOutlet weak var datePopupLabel: UILabel!
    @IBOutlet weak var datePopupBottom: NSLayoutConstraint!
    
    
    @IBAction func zoomExtents(_ sender: LLButton) {
        zoomExtents()
    }
    
    @IBAction func currentLocation(_ sender: LLButton) {
        turnOnUserTracking()
    }
    
    @IBAction func previousDayButton(_ sender: LLButton) {
        if rightButton.isPressed { timeAdjustButtonTapped() }
        datePicker.advanceDateBy(numberOfDays: -1)
        updatePageForDateSelected(withZoom: true)
        timeSliderVC?.configureAndReset(forLogItems: logsForDateSelected)
        hapticTap()
        updateDatePopUpTextIfCalendarIsHidden()
    }
    
    @IBAction func todayButton(_ sender: LLButton) {
        if rightButton.isPressed { timeAdjustButton(rightButton!) }
        datePicker.setDate(Date(), animated: true)
        updatePageForDateSelected(withZoom: true)
        timeSliderVC?.configureAndReset(forLogItems: logsForDateSelected)
        hapticTap()
        updateDatePopUpTextIfCalendarIsHidden()    }
    
    @IBAction func nextDayButton(_ sender: LLButton) {
        if rightButton.isPressed { timeAdjustButtonTapped() }
        datePicker.advanceDateBy(numberOfDays: 1)
        updatePageForDateSelected(withZoom: true)
        timeSliderVC?.configureAndReset(forLogItems: logsForDateSelected)
        hapticTap()
        updateDatePopUpTextIfCalendarIsHidden()    }
    
    @IBAction func timeAdjustButton(_ sender: Any) {
        timeAdjustButtonTapped()
        updatePageForDateSelected(withZoom: false)
        timeSliderVC?.configureAndReset(forLogItems: logsForDateSelected)
        hapticTap()
    }
    
    @IBAction func datePicker(_ sender: UIDatePicker) {
        hapticTap()
        updatePageForDateSelected(withZoom: true)
        timeSliderVC?.updateForDateWithoutMovingSliders(logItems: logsForDateSelected)
    }
    
    
    @IBAction func swipeDownOnDatePickerFrame(_ sender: UISwipeGestureRecognizer) {
//        guard rightButton.isPressed == false else { return }
//        timeAdjustButton(self)
    }
    
    
    @IBAction func swipeUpOnDatePickerFrame(_ sender: UISwipeGestureRecognizer) {
//        guard rightButton.isPressed == true else { return }
//        timeAdjustButton(self)
    }
    
    
    @IBAction func slideUpDownButton(_ sender: Any) {
        if isDatePickerVisible {
            slideSizingFrameDown()
            rightButton.turnOff()
        }
        else {
            slideSizingFrameUp()
            rightButton.turnOn()
        }
        isDatePickerVisible.toggle()
        hapticTap()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSizingFrame()
        configureMapView()
        adjustConstraintsForSmallDevices()
        locationManager.delegate    = self
        setSelfAsSecondTabDelegate()
        configureDatePickerMaxAndMin()
        updatePageForDateSelected(withZoom: true)
        configureDatePopUp()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapView.mapType             = PersistenceManager.getMapTypePreference()
        configureDatePickerMaxAndMin() // In case an import/delete function has happened prior
        updateDatePopUpTextIfCalendarIsHidden()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier                 == Segues.timeSliderSegue {
            timeSliderVC                    = segue.destination as? TimeSliderViewController
            timeSliderVC?.delegate          = self
        }
    }
    
    
    private func setSelfAsSecondTabDelegate() {
        if let secondTab                    = tabBarController?.viewControllers![1] as? SearchViewController {
            secondTab.delegate              = self
        }
    }
    
    
    private func configureDatePickerMaxAndMin() {
        let allData = CoreDataManager.fetchAllLogItemsOrdered(ascending: false)
        datePicker.minimumDate = allData?.last?.dateAndTimeUTC
        datePicker.maximumDate = allData?.first?.dateAndTimeUTC
    }
    
    
    func configureSizingFrame() {
        sizingFrame.layer.cornerRadius      = 20
        sizingFrame.clipsToBounds           = true
        sizingFrame.layer.borderWidth       = 2
        sizingFrame.layer.borderColor       = Colors.llPink.cgColor
    }
    
    
    func adjustConstraintsForSmallDevices() {
        if DeviceTypes.isiPhoneSEGen2       == true {
//            datePickerViewLeading.constant  = 75
//            datePickerViewTrailing.constant = 75
            buttonsFrameHeight.constant     = 45
        }
    }
    
    
    func configureMapView() {
        // Moves the logo and legal link is a result of 20-pixel rounded corners of sizing frame
        mapView.layoutMargins               = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        // Shift centre of map to comepnsate for slight offset due to 20-pixel rounded corners of sizing frame
        let currentOffsetforSizingFrame     = CGFloat(20)
        let currentMapHeight                = mapView.frame.height
        let percentageOffset                = currentOffsetforSizingFrame / currentMapHeight
        let latitudeSpan                    = mapView.region.span.latitudeDelta.magnitude
        let offsetLatitude                  = latitudeSpan * Double(percentageOffset)
        let currentOriginLatitude           = mapView.region.center.latitude.magnitude
        let newOriginalLatitude             = currentOriginLatitude - (offsetLatitude/2)
        let amendedOriginLatitude           = CLLocationDegrees(Float(newOriginalLatitude))
        mapView.region.center.latitude      = amendedOriginLatitude
        mapView.showsUserLocation           = true
        mapView.delegate                    = self
    }
    
    
    func configureDatePopUp() {
        datePopup.layer.cornerRadius      = 10
        datePopup.layer.borderWidth       = 1
        datePopup.layer.borderColor       = Colors.llPink.cgColor
    }
    
    
    func slideSizingFrameDown() {
        isCalendarVisible = false
        updateDatePopUpTextIfCalendarIsHidden()
        let sFrame = view.convert(buttonsFrame.frame, from: sizingFrame)
        print(sFrame.maxY)
        let slideAmount = view.frame.height - sFrame.maxY

        UIView.animate(withDuration: 0.2) {
            self.sizingFrameBottomConstraint.constant = -20
            self.sizingFrameBottomConstraint.constant = -(slideAmount + 20)
            self.view.layoutIfNeeded()
        }
        UIView.animate(withDuration: 0.3, delay: 0.2) {
            self.datePopupBottom.constant = -50
            self.datePopupBottom.constant = -10
            self.view.layoutIfNeeded()
        }
    }
    

    func slideSizingFrameUp() {
        isCalendarVisible = true
        let sFrame = view.convert(buttonsFrame.frame, from: sizingFrame)
        print(sFrame.maxY)
        let slideAmount = view.frame.height - sFrame.maxY

        UIView.animate(withDuration: 0.2) {
            self.sizingFrameBottomConstraint.constant = -(slideAmount + 20)
            self.sizingFrameBottomConstraint.constant = -20
            self.view.layoutIfNeeded()
        }
        UIView.animate(withDuration: 0.3, delay: 0.2) {
            self.datePopupBottom.constant = -10
            self.datePopupBottom.constant = -50
            self.view.layoutIfNeeded()
        }
    }
   
    
    func updateDatePopUpTextIfCalendarIsHidden() {
        if isCalendarVisible == false {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .full
            datePopupLabel.text = dateFormatter.string(from: datePicker.date)
        }
    }
    
    
    func timeAdjustButtonTapped() {
        if rightButton.isPressed            == false {
            showTimeControls()
        } else {
            hideTimeControls()
        }
        rightButton.togglePressed()
    }
    
    
    func showTimeControls() {
        datePicker.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.2) {
            self.datePickerFrameTop.constant    = Variables.timeControlsShift
            self.view.layoutIfNeeded()
        }
    }
    
    
    func hideTimeControls() {
        datePicker.isUserInteractionEnabled = true
        UIView.animate(withDuration: 0.2) {
            self.datePickerFrameTop.constant    = 0
            self.view.layoutIfNeeded()
        }
    }
    
    
    func updatePageForDateSelected(withZoom: Bool) {
        logsForDateSelected                     = fetchLogItemsForDateShown()
        updateMapPins(for: logsForDateSelected)
        updateMapPolyLine(for: logsForDateSelected)
        if withZoom { zoomExtents() }
    }

    
    
    func isDatePickerSetToToday() -> Bool {
        if Calendar.current.isDateInToday(datePicker.date) {
            return true
        } else {
            return false
        }
    }
    
    
    func fetchLogItemsForDateShown() -> [LogItem] {
        let date        = datePicker.date
        let logItems    = CoreDataManager.fetchLogItemsForDateOrdered(for: date)
        if logItems     == nil {
            showSimpleAlert(title: "Error", message: "Error fetching Location Logs from memory", buttonText: "OK")
            // return empty array
            return [LogItem]()
        }
            return logItems!
    }
    
    
    func updateMapPins(for logItems: [LogItem]) {
        var annotations             = MapManager.annotationsFromLogItems(from: logItems, for: .history)
        if isDatePickerSetToToday() {
            annotations = filterOutAnnotationsByTimeSlider(annotations: annotations)
        }
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(annotations)
    }
    
    
    func filterOutAnnotationsByTimeSlider(annotations: [LLAnnotation]) -> [LLAnnotation] {
        guard let timeSliderVC = timeSliderVC else { return annotations }
        var annotationsToReturn = [LLAnnotation]()
        for item in annotations {
            if timeSliderVC.isTimeWithinSliderValues(hour: item.hourAsInt, minute: item.minuteAsInt) {
                annotationsToReturn.append(item)
            }
        }
        return annotationsToReturn
    }
    
    
    func updateMapPolyLine(for logItems: [LogItem]) {
        let polyLine                = MapManager.getPolylinefromLogItems(from: logItems)
        mapView.removeOverlays(mapView.overlays)
        mapView.addOverlay(polyLine)
    }
    
    
    func zoomExtents() {
        let region                  = MapManager.getRegionFromLogItems(array: logsForDateSelected, expanseMultiplier: 1.25)
        mapView.setRegion(region, animated: true)
        isRegionSetForDateSelected  = true
    }
    
    
    func turnOnUserTracking() {
        mapView.userTrackingMode    = .follow
    }
    
    
    private func hapticTap() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}



extension HistoryViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is LLAnnotation else { return nil }
        let annotationView      = MapManager.configureAnnotationView(for: annotation, in: mapView, for: .history)
        return annotationView
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer            = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor    = Colors.llPink
        renderer.lineWidth      = 2
        return renderer
    }
    

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let selectedPin   = mapView.selectedAnnotations.last as? LLAnnotation else { return }
        showComplexAlert(
            title: "Delete?",
            message: "Are you sure you want to delete this pin? This action cannot be undone",
            actionTitle: "Delete",
            actionStyle: .destructive,
            cancelTitle: "Cancel",
            cancelStyle: .default) { [weak self] in
                guard let self = self else { return }
                CoreDataManager.deleteLogItemWithTime(dateAndTimeUTC: selectedPin.dateAndTimeUTC)
                self.updatePageForDateSelected(withZoom: false)
            }
    }
}



extension HistoryViewController: HistoryVCLocationProtocol {
    
    func locationRecordsUpdated() {
        // In case it's just gone midnight, update datePicker's min/max dates
        let maxPickerDate                       = datePicker.maximumDate ?? Date()
        if Date() > maxPickerDate {
            configureDatePickerMaxAndMin()
        }
        // And also handle situation when user is looking at current date
        if  isDatePickerSetToToday()            == true {
            logsForDateSelected                 = fetchLogItemsForDateShown()
            guard timeSliderVC                  != nil else { return }
            timeSliderVC!.logsForDateSelected   = logsForDateSelected
            updatePageForDateSelected(withZoom: false)
        }
    }
    
    
    func locationSettingsAlert() {
        let alert = Alerts.locationAccessRestricted()
        present(alert, animated: true, completion: nil)
    }
}



extension HistoryViewController: HistoryVCTimeSliderProtocol {
    
    func timeSliderFilteredLogItems(for logItems: [LogItem]) {
        updateMapPins(for: logItems)
    }
}



extension HistoryViewController: HistoryVCShowDateProtocol {
   
    func goToDate(dateUTC: Date) {
        datePicker.date = dateUTC
        updatePageForDateSelected(withZoom: true)
    }
}




