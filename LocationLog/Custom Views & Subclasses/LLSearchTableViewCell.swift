//
//  LLSearchTableViewCell.swift
//  LocationLog
//
//  Created by Quinn on 14/11/2021.
//

import UIKit

protocol SearchTableViewProtocol {
    func didTapButton(date: Date)
}



class LLSearchTableViewCell: UITableViewCell {

    static let identifier = Identifiers.searchResultsCell
    var dateItem: DateItem?
    var delegate: SearchTableViewProtocol?
    
    @IBOutlet weak var dayOfWeekLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var jumpToButton: UIButton!
    
    @IBAction func jumpToButtonTapped(_ sender: UIButton) {
        guard dateItem != nil else { return }
        delegate?.didTapButton(date: dateItem!.dateAndTimeUTC)
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        configure()
    }
    
    
    func configure() {
        dateLabel.text              = dateItem?.dateAsString
        dayOfWeekLabel.text         = dateItem?.weekdayAsString
        if isSelected {
            jumpToButton.isHidden   = false
            jumpToButton.isUserInteractionEnabled = true
        } else {
            jumpToButton.isHidden   = true
            jumpToButton.isUserInteractionEnabled = false
        }
    }
}
