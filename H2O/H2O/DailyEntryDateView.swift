//
//  DailyEntryDateView.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/22/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

class DailyEntryDateView: UIView {
    //MARK: - Public iVars
    
    /// Container view containing the calendar image, day and month
    var calendarContainerView :UIView!
    
    /// Calendar image
    var calendarBackgroundImageView :UIImageView!
    
    /// Day label on calendar
    var dayLabel :UILabel!
    
    /// Month label on calendar
    var monthLabel :UILabel!
    
    //MARK: - View Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        calendarContainerView = generateCalendarContainerView()
        calendarBackgroundImageView = generateCalendarBackgroundImageView()
        dayLabel = generateCalendarLabel()
        monthLabel = generateCalendarLabel()
        
        layout()
    }
    
    private func layout() {
        //---Calendar Container View---
        
        addSubview(calendarContainerView)
        
        calendarContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        let calendarContainerLeadingContraint :CGFloat = 10 //Leading constraint
        let calendarContainerSizePercentageToSuperview :CGFloat = 0.7 //Size of view compared to this view
        
        addConstraint(NSLayoutConstraint(item: calendarContainerView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: calendarContainerView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: calendarContainerLeadingContraint))
        addConstraint(NSLayoutConstraint(item: calendarContainerView, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: calendarContainerSizePercentageToSuperview, constant: 0))
        addConstraint(NSLayoutConstraint(item: calendarContainerView, attribute: .width, relatedBy: .equal, toItem: calendarContainerView, attribute: .height, multiplier: 1, constant: 0)) //Height is the same as width
        
        //---Calendar Background Image View
        
        calendarContainerView.addSubview(calendarBackgroundImageView)
        
        calendarBackgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        
        calendarContainerView.addConstraint(NSLayoutConstraint(item: calendarBackgroundImageView, attribute: .top, relatedBy: .equal, toItem: calendarContainerView, attribute: .top, multiplier: 1, constant: 0))
        calendarContainerView.addConstraint(NSLayoutConstraint(item: calendarBackgroundImageView, attribute: .leading, relatedBy: .equal, toItem: calendarContainerView, attribute: .leading, multiplier: 1, constant: 0))
        calendarContainerView.addConstraint(NSLayoutConstraint(item: calendarBackgroundImageView, attribute: .trailing, relatedBy: .equal, toItem: calendarContainerView, attribute: .trailing, multiplier: 1, constant: 0))
        calendarContainerView.addConstraint(NSLayoutConstraint(item: calendarBackgroundImageView, attribute: .bottom, relatedBy: .equal, toItem: calendarContainerView, attribute: .bottom, multiplier: 1, constant: 0))
        
        //---Day Label---
        
        dayLabel.text = "" //Empty text to get the size of the label. Mainly the height
        
        let sizeOfDay = dayLabel.text!.size(attributes: [NSFontAttributeName : dayLabel.font]) //Size of the label with font
        
        let calendarLabelCenterSpacingMargin :CGFloat = 5 //Amount of margin from the center point of the calendar container view
        
        calendarContainerView.addSubview(dayLabel)
        
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        
        calendarContainerView.addConstraint(NSLayoutConstraint(item: dayLabel, attribute: .centerY, relatedBy: .equal, toItem: calendarContainerView, attribute: .centerY, multiplier: 1, constant: -sizeOfDay.height / 2 + calendarLabelCenterSpacingMargin)) //Y position of day label is above center point by half the label height and the center margin
        calendarContainerView.addConstraint(NSLayoutConstraint(item: dayLabel, attribute: .leading, relatedBy: .equal, toItem: calendarContainerView, attribute: .leading, multiplier: 1, constant: 0))
        calendarContainerView.addConstraint(NSLayoutConstraint(item: dayLabel, attribute: .trailing, relatedBy: .equal, toItem: calendarContainerView, attribute: .trailing, multiplier: 1, constant: 0))
        calendarContainerView.addConstraint(NSLayoutConstraint(item: dayLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: sizeOfDay.height)) //Height is associated with label size with font
        
        //---Month Label---
        
        let sizeOfMonth = dayLabel.text!.size(attributes: [NSFontAttributeName : monthLabel.font]) //Month label is the same font and size as the day label so just get the size of month label from the day label properties
        
        calendarContainerView.addSubview(monthLabel)
        
        monthLabel.translatesAutoresizingMaskIntoConstraints = false
        
        calendarContainerView.addConstraint(NSLayoutConstraint(item: monthLabel, attribute: .centerY, relatedBy: .equal, toItem: calendarContainerView, attribute: .centerY, multiplier: 1, constant: sizeOfMonth.height / 2 + calendarLabelCenterSpacingMargin)) //Y position of day label is below center point by half the label height and the center margin
        calendarContainerView.addConstraint(NSLayoutConstraint(item: monthLabel, attribute: .leading, relatedBy: .equal, toItem: calendarContainerView, attribute: .leading, multiplier: 1, constant: 0))
        calendarContainerView.addConstraint(NSLayoutConstraint(item: monthLabel, attribute: .trailing, relatedBy: .equal, toItem: calendarContainerView, attribute: .trailing, multiplier: 1, constant: 0))
        calendarContainerView.addConstraint(NSLayoutConstraint(item: monthLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: sizeOfMonth.height)) //Height is associated with label size with font
    }
}

// MARK: - Private Generators
private extension DailyEntryDateView {
    
    /// Generates a view to contain elements in the calendar view
    ///
    /// - returns: View containing Calendar elements
    func generateCalendarContainerView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }
    
    /// Generates an image view displaying a calendar background
    ///
    /// - returns: Image that looks like a calendar
    func generateCalendarBackgroundImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "CalendarImage")
        return imageView
    }
    
    /// Generates a label to use in the calendar
    ///
    /// - returns: Label to use in calendar
    func generateCalendarLabel() -> UILabel {
        let label = UILabel()
        
        label.font = StandardFonts.regularFont(size: 14)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        
        return label
    }
}
