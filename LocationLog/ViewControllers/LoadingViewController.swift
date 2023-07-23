//
//  LoadingViewController.swift
//  LocationLog
//
//  Created by Quinn on 01/12/2021.
//

import UIKit

class LoadingViewController: UIViewController {
    
    var activityText: String?
    
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurePage()
    }
    
    
    func configure(activityText: String) {
        self.activityText           = activityText
    }
    
    
    private func configurePage() {
        activityLabel.text          = activityText
        activityIndicator.isHidden  = false
        activityIndicator.startAnimating()
    }
}
