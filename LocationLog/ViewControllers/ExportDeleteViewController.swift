//
//  DateSelectionViewController.swift
//  LocationLog
//
//  Created by Quinn on 16/11/2021.
//

import UIKit

class ExportDeleteViewController: UIViewController {
    
    var loadingViewController: LoadingViewController?
    var pageType: DateSelectionScreenType?
    var firstEverDate   = Date()
    var lastEverDate    = Date()
    
    var dateLogicCorrect: Bool {
        return fromDatePicker.date <= toDatePicker.date
    }
    
    @IBOutlet weak var datesSegmentedControl: UISegmentedControl!
    @IBOutlet weak var controlsView: UIView!
    @IBOutlet weak var fromDatePicker: UIDatePicker!
    @IBOutlet weak var toDatePicker: UIDatePicker!
    @IBOutlet weak var formatStackView: UIStackView!
    @IBOutlet weak var formatStackViewHeight: NSLayoutConstraint!
    @IBOutlet weak var formatPicker: UISegmentedControl!
    @IBOutlet weak var actionButton: LLButton!
    @IBOutlet weak var actionButtonTap: NSLayoutConstraint!
    @IBOutlet weak var infoTextView: UITextView!
    
    @IBAction func datesSegmentedControlChanged(_ sender: UISegmentedControl) {
        enableOrDisableDateSelectionAccordingly()
    }
    
    @IBAction func fromDatePickerDateChanged(_ sender: Any) {
        applyMaxAndMins()
        print(fromDatePicker.date)
    }
    
    @IBAction func toDatePickerDateChanged(_ sender: Any) {
        applyMaxAndMins()
        print(toDatePicker.date)
    }
    
    @IBAction func actionTapped(_ sender: UIButton) {
        
        guard dateLogicCorrect else {
            showSimpleAlert(title: "Date Error", message: "Please check dates. The 'From' date cannot be after the 'To' date", buttonText: "OK")
            return
        }
        
        switch pageType {
        case .exportData:
            exportDataForDatesShown()
        case .deleteData:
            deleteLogsForDatesShown()
        case .none:
            print("QLog: No page type")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurePage(for: pageType)
        configureViews()
        setFirstAndLastDates()
        applyMaxAndMins()
        datesSegmentedControl.selectedSegmentIndex = 0
        datesSegmentedControlChanged(datesSegmentedControl)
    }
    
    
    func configureViews() {
        controlsView.layer.cornerRadius = 10
        controlsView.layer.borderWidth  = 2
        controlsView.layer.borderColor  = Colors.llPink.cgColor
        infoTextView.layer.cornerRadius = 10
        infoTextView.layer.borderWidth  = 1
        infoTextView.layer.borderColor  = UIColor.systemGray2.cgColor
        fromDatePicker.tintColor        = Colors.llPink
    }
    
    
    func configurePage(for type: DateSelectionScreenType?) {
        
        switch type {
            
        case .exportData:
            actionButton.setTitle("Export", for: .normal)
            title               = "Export Data"
            infoTextView.text   = Texts.exportInfoText
            
        case .deleteData:
            hideFormatStackView()
            actionButton.setTitle("Delete", for: .normal)
            title               = "Delete Data"
            infoTextView.text   = Texts.deleteInfoText
            
        case .none:
            // Page not configured
            print("QLog: Page not configured")
        }
    }
    
    
    private func setFirstAndLastDates() {
        let allLogs                 = CoreDataManager.fetchAllLogItemsOrdered(ascending: false)
        if allLogs                  != nil {
            lastEverDate            = allLogs?.first?.dateAndTimeUTC ?? Date()
            firstEverDate           = allLogs?.last?.dateAndTimeUTC?.LLStartOfDay() ?? Date()
        }
    }
    
    
    private func hideFormatStackView() {
        formatStackViewHeight.constant              = 0
        actionButtonTap.constant                    = 0
        formatStackView.isHidden                    = true
        formatStackView.isUserInteractionEnabled    = false
    }
    
    
    private func enableOrDisableDateSelectionAccordingly() {
        if datesSegmentedControl.selectedSegmentIndex   == 0 {
            fromDatePicker.isUserInteractionEnabled     = false
            toDatePicker.isUserInteractionEnabled       = false
            fromDatePicker.alpha                        = 0.3
            toDatePicker.alpha                          = 0.3
            fromDatePicker.date                         = firstEverDate
            toDatePicker.date                           = lastEverDate
        }
        else {
            fromDatePicker.isUserInteractionEnabled     = true
            toDatePicker.isUserInteractionEnabled       = true
            fromDatePicker.alpha                        = 1
            toDatePicker.alpha                          = 1
        }
    }
    
    
    private func applyMaxAndMins() {
        fromDatePicker.minimumDate  = firstEverDate
        fromDatePicker.maximumDate  = lastEverDate
        
        toDatePicker.minimumDate    = firstEverDate
        toDatePicker.maximumDate    = lastEverDate
    }
    
    
    private func deleteLogsForDatesShown() {
        let allLogs                                 = CoreDataManager.fetchAllLogItemsOrdered(ascending: false)
        guard let allLogs                           = allLogs else { return }
        var itemsToDelete                           = [LogItem]()
        showComplexAlert(
            title: "Delete?",
            message: "Are you sure you want to permanantly delete logs for selected dates?",
            actionTitle: "Delete",
            actionStyle: .destructive,
            cancelTitle: "Cancel",
            cancelStyle: .cancel) { [weak self] in
                guard let self                      = self else { return }

                self.showLoadingScreen(activityText: "Deleting") {
                    let startOfDeleteFromDate       = self.fromDatePicker.date.LLStartOfDay()
                    let endOfDeleteToDate           = self.toDatePicker.date.LLEndOfDay()
                    for item in allLogs {
                        if item.dateAndTimeUTC      != nil && endOfDeleteToDate != nil {
                            if item.dateAndTimeUTC! >= startOfDeleteFromDate && item.dateAndTimeUTC! < endOfDeleteToDate! {
                                itemsToDelete.append(item)
                            }
                        }
                    }
                    
                    let count = itemsToDelete.count
                    CoreDataManager.deleteLogItems(items: itemsToDelete) { [weak self] _ in
                        guard let self = self else { return }
                        
                        DispatchQueue.main.async {
                            self.hideLoadingScreen()
                            self.viewDidLoad()
                            self.showSimpleAlert(
                                title: "Complete",
                                message: "\(count) log items succesfully deleted",
                                buttonText: "OK")
                        }
                    }
                }
            }
    }
    
    
    private func exportDataForDatesShown() {
        
        let fromDateStart           = fromDatePicker.date.LLStartOfDay()
        let toDateEnd               = toDatePicker.date.LLEndOfDay()
        guard let toDateEnd         = toDateEnd else {
            showSimpleAlert(
                title: "Error",
                message: "Error processing 'to' date",
                buttonText: "OK")
            return
        }
        let logsToExport            = CoreDataManager.fetchLogItemsBetweenDatesOrdered(from: fromDateStart, toInclusive: toDateEnd)
        guard logsToExport.count    > 0 else {
            showSimpleAlert(
                title: "No Logs",
                message: "No Logs to export for dates selected",
                buttonText: "OK")
            return
        }
        var url: URL?
        switch formatPicker.selectedSegmentIndex {
        case 0: //JSON
            url                     = ExportManager.createTempFileFromLogItems(itemsToExport: logsToExport, fileType: .json)
        case 1: //GPX
            url                     = ExportManager.createTempFileFromLogItems(itemsToExport: logsToExport, fileType: .gpx)
        default:
            showSimpleAlert(
                title: "Format!",
                message: "No export format selected",
                buttonText: "OK")
            return
        }
        guard url != nil else {
            showSimpleAlert(
                title: "Error",
                message: "Could not export file",
                buttonText: "OK")
            return
        }
        presentShareSheetForFile(fileURL: url!)
    }
    
    
    func showLoadingScreen(activityText: String, actionClosure: @escaping () -> Void) {
        loadingViewController = storyboard?.instantiateViewController(withIdentifier: Identifiers.loadingViewController) as? LoadingViewController
        loadingViewController?.modalPresentationStyle   = .overFullScreen
        loadingViewController?.activityText             = activityText
        present(loadingViewController!, animated: false, completion: actionClosure)
    }
    
    
    func hideLoadingScreen() {
        loadingViewController?.dismiss(animated: false, completion: nil)
        loadingViewController = nil
    }
    
    
}
