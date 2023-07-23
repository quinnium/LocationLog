//
//  ImportViewController.swift
//  LocationLog
//
//  Created by Quinn on 25/11/2021.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers


class ImportViewController: UIViewController {
    
    var loadingViewController: LoadingViewController?
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var infoTextView: UITextView!
    @IBOutlet weak var upperControlsView: UIView!
    @IBOutlet weak var lowerControlsView: UIView!
    
    @IBAction func importFileButton(_ sender: Any) {
        importFromFileButtonTapped()
    }
    
    @IBAction func importURLButton(_ sender: Any) {
        if let url = URL(string: textField.text ?? "") {
            importDataAndShowResult(from: url)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        infoTextView.text = Texts.importInfoText
    }
    
    
    private func configureViews() {
        upperControlsView.layer.cornerRadius    = 10
        upperControlsView.layer.borderWidth     = 2
        upperControlsView.layer.borderColor     = Colors.llPink.cgColor
        lowerControlsView.layer.cornerRadius    = 10
        lowerControlsView.layer.borderWidth     = 2
        lowerControlsView.layer.borderColor     = Colors.llPink.cgColor
        infoTextView.layer.cornerRadius         = 10
        infoTextView.layer.borderWidth          = 1
        infoTextView.layer.borderColor          = UIColor.systemGray2.cgColor
    }
    
    
    private func importFromFileButtonTapped() {
        let docPicker                       = UIDocumentPickerViewController(forOpeningContentTypes: [.json])
        docPicker.delegate                  = self
        docPicker.allowsMultipleSelection   = false
        present(docPicker, animated: true, completion: nil)
    }
    
    
    private func importDataAndShowResult(from url: URL) {
        url.startAccessingSecurityScopedResource()
        // One could stop & start location services so as to avoid conflict if issues in future
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.showLoadingScreen(activityText: "Importing")
            var codableLogItems = [CodableLogItem]()
            
            // Get the CodableLogItems
            ImportManager.getCodableItemsFromURL(url: url) { [weak self] result in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    url.stopAccessingSecurityScopedResource()
                    switch result {
                        
                    case .success(let items):
                        // Success - now save the items
                        codableLogItems         = items
                        CoreDataManager.saveCodableLogItems(codableLogItems: codableLogItems) { [weak self] result in
                            guard let self      = self else { return }
                            self.hideLoadingScreen {
                                DispatchQueue.main.async {
                                    switch result {
                                        
                                    case .success(let numberSaved):
                                        // Successfully saved
                                        if numberSaved  == 0 {
                                            print("QLog: Success - NOOOO new items")
                                            self.showSimpleAlert(
                                                title: "No new items",
                                                message: "Import complete, but no new records were found that weren't already stored by the app)",
                                                buttonText: "OK")
                                        } else {
                                            print("QLog: Success - new items")
                                            self.showSimpleAlert(
                                                title: "Success",
                                                message: "\(numberSaved) new log item(s) successfully imported",
                                                buttonText: "OK")
                                        }
                                        
                                    case .failure(let error):
                                            print("QLog: Success - epic fail")
                                        // Error saving
                                        self.showSimpleAlert(
                                            title: "Error",
                                            message: "Error saving data. Import Not completed",
                                            buttonText: "OK")
                                        print(error.localizedDescription)
                                    }
                                }
                            }
                        }
                        
                    case .failure(let error):
                            self.hideLoadingScreen {
                                DispatchQueue.main.async {
                                    switch error {
                                    case .invalidData:
                                        self.showSimpleAlert(
                                            title: "Error",
                                            message: "Invalid Data. Import Not completed",
                                            buttonText: "OK")
                                    case .requestFailed:
                                        self.showSimpleAlert(
                                            title: "Error",
                                            message: "Request to URL failed. Import Not completed",
                                            buttonText: "OK")
                                    case .errorSaving:
                                        self.showSimpleAlert(
                                            title: "Error",
                                            message: "Error saving data. Import Not completed",
                                            buttonText: "OK")
                                    case .unknown:
                                        self.showSimpleAlert(
                                            title: "Error",
                                            message: "Unknown Error. Import Not completed",
                                            buttonText: "OK")
                                    } // End switch error                                    
                                }
                            }
                    } // End switch result'
                } // End 'DispatchQueue.main.async'
            } // End 'ImportManager.getCodableItemsFromURL' closure
        } // End 'DispatchQueue.main.async'
    } // End importDataAndShowResult function
    
    
    func showLoadingScreen(activityText: String) {
        loadingViewController                           = storyboard?.instantiateViewController(withIdentifier: Identifiers.loadingViewController) as? LoadingViewController
        loadingViewController?.modalPresentationStyle   = .overFullScreen
        loadingViewController?.activityText             = activityText
        present(loadingViewController!, animated: false, completion: nil)
    }
    
    
    func hideLoadingScreen(completion: @escaping () -> Void) {
        loadingViewController?.dismiss(animated: false, completion: completion)
        loadingViewController                           = nil
    }
}



extension ImportViewController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        controller.dismiss(animated: true) {
                self.importDataAndShowResult(from: url)
        }
    }
}
