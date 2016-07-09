//
//  DailyEntryDateView.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/22/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

class DailyEntryDateView: UIView {
    
    /// Container view containing the calendar image, day and month
    let calendarContainerView = UIView()
    
    /// Calendar image
    let calendarBackgroundImageView = UIImageView()
    
    /// Day label on calendar
    let dayLabel = UILabel()
    
    /// Month label on calendar
    let monthLabel = UILabel()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundColor = UIColor.clear()
    }
    
    ///Basic view setup
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupCalendarContainerView()
        setupCalendarBackgroundImageView()
        setupDateLabels()
    }
    
    /// Layout for the calendar container view
    private func setupCalendarContainerView() {
        addSubview(calendarContainerView)
        
        calendarContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        let calendarContainerLeadingContraint :CGFloat = 10 //Leading constraint
        let calendarContainerSizePercentageToSuperview :CGFloat = 0.7 //Size of view compared to this view
        
        addConstraint(NSLayoutConstraint(item: calendarContainerView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: calendarContainerView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: calendarContainerLeadingContraint))
        addConstraint(NSLayoutConstraint(item: calendarContainerView, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: calendarContainerSizePercentageToSuperview, constant: 0))
        addConstraint(NSLayoutConstraint(item: calendarContainerView, attribute: .width, relatedBy: .equal, toItem: calendarContainerView, attribute: .height, multiplier: 1, constant: 0)) //Height is the same as width
        
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
    
    /// Layout for day and month labels
    private func setupDateLabels() {
        
        /*---Day Setup---*/
        
        let dateFont = StandardFonts.regularFont(14)
        dayLabel.text = "" //Empty text to get the size of the label. Mainly the height
        
        let sizeOfDay = dayLabel.text!.size(attributes: [NSFontAttributeName : dateFont]) //Size of the label with font
        
        let calendarLabelCenterSpacingMargin :CGFloat = 5 //Amount of margin from the center point of the calendar container view
        
        calendarContainerView.addSubview(dayLabel)
        
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        
        calendarContainerView.addConstraint(NSLayoutConstraint(item: dayLabel, attribute: .centerY, relatedBy: .equal, toItem: calendarContainerView, attribute: .centerY, multiplier: 1, constant: -sizeOfDay.height / 2 + calendarLabelCenterSpacingMargin)) //Y position of day label is above center point by half the label height and the center margin
        calendarContainerView.addConstraint(NSLayoutConstraint(item: dayLabel, attribute: .leading, relatedBy: .equal, toItem: calendarContainerView, attribute: .leading, multiplier: 1, constant: 0))
        calendarContainerView.addConstraint(NSLayoutConstraint(item: dayLabel, attribute: .trailing, relatedBy: .equal, toItem: calendarContainerView, attribute: .trailing, multiplier: 1, constant: 0))
        calendarContainerView.addConstraint(NSLayoutConstraint(item: dayLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: sizeOfDay.height)) //Height is associated with label size with font
        
        dayLabel.font = dateFont
        dayLabel.textAlignment = .center
        
        /*---Month Setup---*/
        
        let sizeOfMonth = dayLabel.text!.size(attributes: [NSFontAttributeName : dateFont]) //Month label is the same font and size as the day label so just get the size of month label from the day label properties
        
        calendarContainerView.addSubview(monthLabel)
        
        monthLabel.translatesAutoresizingMaskIntoConstraints = false
        
        calendarContainerView.addConstraint(NSLayoutConstraint(item: monthLabel, attribute: .centerY, relatedBy: .equal, toItem: calendarContainerView, attribute: .centerY, multiplier: 1, constant: sizeOfMonth.height / 2 + calendarLabelCenterSpacingMargin)) //Y position of day label is below center point by half the label height and the center margin
        calendarContainerView.addConstraint(NSLayoutConstraint(item: monthLabel, attribute: .leading, relatedBy: .equal, toItem: calendarContainerView, attribute: .leading, multiplier: 1, constant: 0))
        calendarContainerView.addConstraint(NSLayoutConstraint(item: monthLabel, attribute: .trailing, relatedBy: .equal, toItem: calendarContainerView, attribute: .trailing, multiplier: 1, constant: 0))
        calendarContainerView.addConstraint(NSLayoutConstraint(item: monthLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: sizeOfMonth.height)) //Height is associated with label size with font
        
        monthLabel.font = dateFont
        monthLabel.textAlignment = .center
        monthLabel.adjustsFontSizeToFitWidth = true
    }
}
