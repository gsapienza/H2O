//
//  SettingsTableViewCell.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/17/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
        /// Cell Image view
    let _imageView = UIImageView()
    
        /// Text title label
    let _textLabel = UILabel()

    //MARK: - View Setup
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = StandardColors.standardSecondaryColor
    }
    
    /**
     Basic setup for cell views
    */
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        setupImageView()
        setupTextLabel()
    }
    
    /**
     Sets up properties for left most image view
     */
    private func setupImageView() {
        addSubview(_imageView)
        
        _imageView.contentMode = .Center
        
        _imageView.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: _imageView, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 15))
        addConstraint(NSLayoutConstraint(item: _imageView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: _imageView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 25))
        addConstraint(NSLayoutConstraint(item: _imageView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 25))
    }
    
    
    /**
     Sets up properties for the description text label
     */
    private func setupTextLabel() {
        addSubview(_textLabel)
        
        _textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: _textLabel, attribute: .Leading, relatedBy: .Equal, toItem: _imageView, attribute: .Trailing, multiplier: 1, constant: 15))
        addConstraint(NSLayoutConstraint(item: _imageView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: _textLabel, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: bounds.width / 2))
        addConstraint(NSLayoutConstraint(item: _textLabel, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: bounds.height))
        
        _textLabel.font = StandardFonts.regularFont(18)
        _textLabel.textColor = UIColor.whiteColor()
    }
}
