//
//  DailyEntryDateView.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/22/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

class DailyEntryDateView: UIView {
    let calendarContainerView = UIView()
    let calendarBackgroundImageView = UIImageView()
    let dayLabel = UILabel()
    let monthLabel = UILabel()
    
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
        addSubview(calendarContainerView)
        
        calendarContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: calendarContainerView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: calendarContainerView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 10))
        addConstraint(NSLayoutConstraint(item: calendarContainerView, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0.7, constant: 0))
        addConstraint(NSLayoutConstraint(item: calendarContainerView, attribute: .width, relatedBy: .equal, toItem: calendarContainerView, attribute: .height, multiplier: 1, constant: 0))
        
        calendarContainerView.backgroundColor = UIColor.clear()
    }

    private func setupCalendarBackgroundImageView() {
        calendarContainerView.addSubview(calendarBackgroundImageView)
        
        calendarBackgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        
        calendarContainerView.addConstraint(NSLayoutConstraint(item: calendarBackgroundImageView, attribute: .top, relatedBy: .equal, toItem: calendarContainerView, attribute: .top, multiplier: 1, constant: 0))
        calendarContainerView.addConstraint(NSLayoutConstraint(item: calendarBackgroundImageView, attribute: .leading, relatedBy: .equal, toItem: calendarContainerView, attribute: .leading, multiplier: 1, constant: 0))
        calendarContainerView.addConstraint(NSLayoutConstraint(item: calendarBackgroundImageView, attribute: .trailing, relatedBy: .equal, toItem: calendarContainerView, attribute: .trailing, multiplier: 1, constant: 0))
        calendarContainerView.addConstraint(NSLayoutConstraint(item: calendarBackgroundImageView, attribute: .bottom, relatedBy: .equal, toItem: calendarContainerView, attribute: .bottom, multiplier: 1, constant: 0))
        
        calendarBackgroundImageView.image = UIImage(named: "CalendarImage")
    }
    
    private func setupDateLabels() {
        let dateFont = StandardFonts.regularFont(14)
        dayLabel.text = ""
        
        let sizeOfDay = dayLabel.text!.size(attributes: [NSFontAttributeName : dateFont])
        
        let calendarLabelSpacingMargin :CGFloat = 5
        
        calendarContainerView.addSubview(dayLabel)
        
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        
        calendarContainerView.addConstraint(NSLayoutConstraint(item: dayLabel, attribute: .centerY, relatedBy: .equal, toItem: calendarContainerView, attribute: .centerY, multiplier: 1, constant: -sizeOfDay.height / 2 + calendarLabelSpacingMargin))
        calendarContainerView.addConstraint(NSLayoutConstraint(item: dayLabel, attribute: .leading, relatedBy: .equal, toItem: calendarContainerView, attribute: .leading, multiplier: 1, constant: 0))
        calendarContainerView.addConstraint(NSLayoutConstraint(item: dayLabel, attribute: .trailing, relatedBy: .equal, toItem: calendarContainerView, attribute: .trailing, multiplier: 1, constant: 0))
        calendarContainerView.addConstraint(NSLayoutConstraint(item: dayLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: sizeOfDay.height))
        
        dayLabel.font = dateFont
        dayLabel.textAlignment = .center
                
        
        let sizeOfMonth = dayLabel.text!.size(attributes: [NSFontAttributeName : dateFont])
        
        calendarContainerView.addSubview(monthLabel)
        
        monthLabel.translatesAutoresizingMaskIntoConstraints = false
        
        calendarContainerView.addConstraint(NSLayoutConstraint(item: monthLabel, attribute: .centerY, relatedBy: .equal, toItem: calendarContainerView, attribute: .centerY, multiplier: 1, constant: sizeOfMonth.height / 2 + calendarLabelSpacingMargin))
        calendarContainerView.addConstraint(NSLayoutConstraint(item: monthLabel, attribute: .leading, relatedBy: .equal, toItem: calendarContainerView, attribute: .leading, multiplier: 1, constant: 0))
        calendarContainerView.addConstraint(NSLayoutConstraint(item: monthLabel, attribute: .trailing, relatedBy: .equal, toItem: calendarContainerView, attribute: .trailing, multiplier: 1, constant: 0))
        calendarContainerView.addConstraint(NSLayoutConstraint(item: monthLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: sizeOfMonth.height))
        
        monthLabel.font = dateFont
        monthLabel.textAlignment = .center
        monthLabel.adjustsFontSizeToFitWidth = true
    }
}
