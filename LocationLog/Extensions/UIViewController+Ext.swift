//
//  UIButton+Ext.swift
//  LocationLog
//
//  Created by Quinn on 19/09/2021.
//

import UIKit

extension UIViewController {

    func showSimpleAlert(title: String, message: String, buttonText: String) {
        let alert       = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.message   = message
        let action      = UIAlertAction(title: buttonText, style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    
    func showComplexAlert(title: String, message: String, actionTitle: String, actionStyle: UIAlertAction.Style, cancelTitle:String, cancelStyle: UIAlertAction.Style, actionClosure: @escaping () -> Void) {
        let alert           = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let actionButton    = UIAlertAction(title: actionTitle, style: actionStyle, handler: {
            _ in
            actionClosure()
        })
        let cancelButton    = UIAlertAction(title: cancelTitle, style: cancelStyle, handler: nil)
        alert.addAction(actionButton)
        alert.addAction(cancelButton)
        present(alert, animated: true, completion: nil)
    }

    
    func presentShareSheetForFile(fileURL: URL) {
        let activityView = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        activityView.popoverPresentationController?.barButtonItem = UIBarButtonItem.init()
        self.present(activityView, animated: true, completion: nil)
    }
    
}
