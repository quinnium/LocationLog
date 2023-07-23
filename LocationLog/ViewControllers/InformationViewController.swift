//
//  InformationViewController.swift
//  LocationLog
//
//  Created by Quinn on 02/01/2022.
//

import UIKit

class InformationViewController: UIViewController {

    var pageType: InformationScreenType?
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurePage(for: pageType)
    }
    
    private func configurePage(for pageType: InformationScreenType?) {
        switch pageType {
        case .privacy:
            title           = Texts.Privacy.title
            textView.text   = Texts.Privacy.text
        case .thanks:
            title           = Texts.Thanks.title
            textView.text   = Texts.Thanks.text
        case .timezone:
            title           = Texts.Timezones.title
            textView.text   = Texts.Timezones.text
        case .none:
            title           = "..."
            textView.text   = "..."
        }
    }
}
