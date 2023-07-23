//
//  LogViewController.swift
//  LocationLog
//
//  Created by Quinn on 01/01/2022.
//

import UIKit

class LogViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    @IBAction func refreshButton(_ sender: UIButton) {
        refresh()
    }
    
    @IBAction func deleteButton(_ sender: UIButton) {
        LogManager.clearLog()
        refresh()
    }
    
    @IBAction func copyButton(_ sender: Any) {
        let pasteboard = UIPasteboard.general
        pasteboard.string = textView.text
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor    = .lightGray
        view.layer.borderWidth  = 2
        view.layer.borderColor  = UIColor.blue.cgColor
        refresh()
    }
    
    func refresh() {
        textView.text = LogManager.fetchLog()
    }
}
