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
        
        backgroundColor = UIColor.clearColor()
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        setupCalendarContainerView()
        setupCalendarBackgroundImageView()
        setupDateLabels()
    }
    
    private func setupCalendarContainerView() {
        addSubview(_calendarContainerView)
        
        _calendarContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: _calendarContainerView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: _calendarContainerView, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 10))
        addConstraint(NSLayoutConstraint(item: _calendarContainerView, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 0.7, constant: 0))
        addConstraint(NSLayoutConstraint(item: _calendarContainerView, attribute: .Width, relatedBy: .Equal, toItem: _calendarContainerView, attribute: .Height, multiplier: 1, constant: 0))
        
        _calendarContainerView.backgroundColor = UIColor.clearColor()
    }

    private func setupCalendarBackgroundImageView() {
        _calendarContainerView.addSubview(_calendarBackgroundImageView)
        
        _calendarBackgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        
        _calendarContainerView.addConstraint(NSLayoutConstraint(item: _calendarBackgroundImageView, attribute: .Top, relatedBy: .Equal, toItem: _calendarContainerView, attribute: .Top, multiplier: 1, constant: 0))
        _calendarContainerView.addConstraint(NSLayoutConstraint(item: _calendarBackgroundImageView, attribute: .Leading, relatedBy: .Equal, toItem: _calendarContainerView, attribute: .Leading, multiplier: 1, constant: 0))
        _calendarContainerView.addConstraint(NSLayoutConstraint(item: _calendarBackgroundImageView, attribute: .Trailing, relatedBy: .Equal, toItem: _calendarContainerView, attribute: .Trailing, multiplier: 1, constant: 0))
        _calendarContainerView.addConstraint(NSLayoutConstraint(item: _calendarBackgroundImageView, attribute: .Bottom, relatedBy: .Equal, toItem: _calendarContainerView, attribute: .Bottom, multiplier: 1, constant: 0))
        
        _calendarBackgroundImageView.image = UIImage(named: "CalendarImage")
    }
    
    private func setupDateLabels() {
        let dateFont = StandardFonts.regularFont(14)
        
        let sizeOfDay = _dayLabel.text!.sizeWithAttributes([NSFontAttributeName : dateFont])
        
        let calendarLabelSpacingMargin :CGFloat = 5
        
        _calendarContainerView.addSubview(_dayLabel)
        
        _dayLabel.translatesAutoresizingMaskIntoConstraints = false
        
        _calendarContainerView.addConstraint(NSLayoutConstraint(item: _dayLabel, attribute: .CenterY, relatedBy: .Equal, toItem: _calendarContainerView, attribute: .CenterY, multiplier: 1, constant: -sizeOfDay.height / 2 + calendarLabelSpacingMargin))
        _calendarContainerView.addConstraint(NSLayoutConstraint(item: _dayLabel, attribute: .Leading, relatedBy: .Equal, toItem: _calendarContainerView, attribute: .Leading, multiplier: 1, constant: 0))
        _calendarContainerView.addConstraint(NSLayoutConstraint(item: _dayLabel, attribute: .Trailing, relatedBy: .Equal, toItem: _calendarContainerView, attribute: .Trailing, multiplier: 1, constant: 0))
        _calendarContainerView.addConstraint(NSLayoutConstraint(item: _dayLabel, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: sizeOfDay.height))
        
        _dayLabel.font = dateFont
        _dayLabel.textAlignment = .Center
                
        
        let sizeOfMonth = _dayLabel.text!.sizeWithAttributes([NSFontAttributeName : dateFont])
        
        _calendarContainerView.addSubview(_monthLabel)
        
        _monthLabel.translatesAutoresizingMaskIntoConstraints = false
        
        _calendarContainerView.addConstraint(NSLayoutConstraint(item: _monthLabel, attribute: .CenterY, relatedBy: .Equal, toItem: _calendarContainerView, attribute: .CenterY, multiplier: 1, constant: sizeOfMonth.height / 2 + calendarLabelSpacingMargin))
        _calendarContainerView.addConstraint(NSLayoutConstraint(item: _monthLabel, attribute: .Leading, relatedBy: .Equal, toItem: _calendarContainerView, attribute: .Leading, multiplier: 1, constant: 0))
        _calendarContainerView.addConstraint(NSLayoutConstraint(item: _monthLabel, attribute: .Trailing, relatedBy: .Equal, toItem: _calendarContainerView, attribute: .Trailing, multiplier: 1, constant: 0))
        _calendarContainerView.addConstraint(NSLayoutConstraint(item: _monthLabel, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: sizeOfMonth.height))
        
        _monthLabel.font = dateFont
        _monthLabel.textAlignment = .Center
        _monthLabel.adjustsFontSizeToFitWidth = true
    }
}
