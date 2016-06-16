//
//  DailyEntryDateView.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/22/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

class DailyEntryDateView: UIView {
    let _calendarContainerView = UIView()
    let _calendarBackgroundImageView = UIImageView()
    let _dayLabel = UILabel()
    let _monthLabel = UILabel()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundColor = UIColor.clear()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupCalendarContainerView()
        setupCalendarBackgroundImageView()
        setupDateLabels()
    }
    
    private func setupCalendarContainerView() {
        addSubview(_calendarContainerView)
        
        _calendarContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: _calendarContainerView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: _calendarContainerView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 10))
        addConstraint(NSLayoutConstraint(item: _calendarContainerView, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0.7, constant: 0))
        addConstraint(NSLayoutConstraint(item: _calendarContainerView, attribute: .width, relatedBy: .equal, toItem: _calendarContainerView, attribute: .height, multiplier: 1, constant: 0))
        
        _calendarContainerView.backgroundColor = UIColor.clear()
    }

    private func setupCalendarBackgroundImageView() {
        _calendarContainerView.addSubview(_calendarBackgroundImageView)
        
        _calendarBackgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        
        _calendarContainerView.addConstraint(NSLayoutConstraint(item: _calendarBackgroundImageView, attribute: .top, relatedBy: .equal, toItem: _calendarContainerView, attribute: .top, multiplier: 1, constant: 0))
        _calendarContainerView.addConstraint(NSLayoutConstraint(item: _calendarBackgroundImageView, attribute: .leading, relatedBy: .equal, toItem: _calendarContainerView, attribute: .leading, multiplier: 1, constant: 0))
        _calendarContainerView.addConstraint(NSLayoutConstraint(item: _calendarBackgroundImageView, attribute: .trailing, relatedBy: .equal, toItem: _calendarContainerView, attribute: .trailing, multiplier: 1, constant: 0))
        _calendarContainerView.addConstraint(NSLayoutConstraint(item: _calendarBackgroundImageView, attribute: .bottom, relatedBy: .equal, toItem: _calendarContainerView, attribute: .bottom, multiplier: 1, constant: 0))
        
        _calendarBackgroundImageView.image = UIImage(named: "CalendarImage")
    }
    
    private func setupDateLabels() {
        let dateFont = StandardFonts.regularFont(14)
        _dayLabel.text = ""
        
        let sizeOfDay = _dayLabel.text!.size(attributes: [NSFontAttributeName : dateFont])
        
        let calendarLabelSpacingMargin :CGFloat = 5
        
        _calendarContainerView.addSubview(_dayLabel)
        
        _dayLabel.translatesAutoresizingMaskIntoConstraints = false
        
        _calendarContainerView.addConstraint(NSLayoutConstraint(item: _dayLabel, attribute: .centerY, relatedBy: .equal, toItem: _calendarContainerView, attribute: .centerY, multiplier: 1, constant: -sizeOfDay.height / 2 + calendarLabelSpacingMargin))
        _calendarContainerView.addConstraint(NSLayoutConstraint(item: _dayLabel, attribute: .leading, relatedBy: .equal, toItem: _calendarContainerView, attribute: .leading, multiplier: 1, constant: 0))
        _calendarContainerView.addConstraint(NSLayoutConstraint(item: _dayLabel, attribute: .trailing, relatedBy: .equal, toItem: _calendarContainerView, attribute: .trailing, multiplier: 1, constant: 0))
        _calendarContainerView.addConstraint(NSLayoutConstraint(item: _dayLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: sizeOfDay.height))
        
        _dayLabel.font = dateFont
        _dayLabel.textAlignment = .center
                
        
        let sizeOfMonth = _dayLabel.text!.size(attributes: [NSFontAttributeName : dateFont])
        
        _calendarContainerView.addSubview(_monthLabel)
        
        _monthLabel.translatesAutoresizingMaskIntoConstraints = false
        
        _calendarContainerView.addConstraint(NSLayoutConstraint(item: _monthLabel, attribute: .centerY, relatedBy: .equal, toItem: _calendarContainerView, attribute: .centerY, multiplier: 1, constant: sizeOfMonth.height / 2 + calendarLabelSpacingMargin))
        _calendarContainerView.addConstraint(NSLayoutConstraint(item: _monthLabel, attribute: .leading, relatedBy: .equal, toItem: _calendarContainerView, attribute: .leading, multiplier: 1, constant: 0))
        _calendarContainerView.addConstraint(NSLayoutConstraint(item: _monthLabel, attribute: .trailing, relatedBy: .equal, toItem: _calendarContainerView, attribute: .trailing, multiplier: 1, constant: 0))
        _calendarContainerView.addConstraint(NSLayoutConstraint(item: _monthLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: sizeOfMonth.height))
        
        _monthLabel.font = dateFont
        _monthLabel.textAlignment = .center
        _monthLabel.adjustsFontSizeToFitWidth = true
    }
}
