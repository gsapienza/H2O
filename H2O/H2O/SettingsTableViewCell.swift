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
    
        /// Constraint for the text labels width constraint so it can be modified
    private var _textLabelWidthConstraint = NSLayoutConstraint()
    
        /// Side margin amount for contained ui elements on the left and right side of the cell
    private let _sideMargin :CGFloat = 15

    //MARK: - View Setup
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = StandardColors.standardSecondaryColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupColors()
    }
    
    /**
     Basic setup for cell views
    */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupImageView()
        setupTextLabel()
    }
    
    /**
     Sets up properties for left most image view
     */
    private func setupImageView() {
        addSubview(_imageView)
        
        _imageView.contentMode = .center
        
        _imageView.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: _imageView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 15))
        addConstraint(NSLayoutConstraint(item: _imageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: _imageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 25))
        addConstraint(NSLayoutConstraint(item: _imageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 25))
    }
    
    
    /**
     Sets up properties for the description text label
     */
    private func setupTextLabel() {
        addSubview(_textLabel)
        
        _textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: _textLabel, attribute: .leading, relatedBy: .equal, toItem: _imageView, attribute: .trailing, multiplier: 1, constant: _sideMargin))
        addConstraint(NSLayoutConstraint(item: _imageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        _textLabelWidthConstraint = NSLayoutConstraint(item: _textLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: bounds.width / 2)
        addConstraint(_textLabelWidthConstraint)
        addConstraint(NSLayoutConstraint(item: _textLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: bounds.height))
        
        _textLabel.font = StandardFonts.regularFont(18)
        _textLabel.minimumScaleFactor = 0.7
        _textLabel.adjustsFontSizeToFitWidth = true
    }
    
    /**
     Makes the text label take up the full width of the cell
     */
    func fillCellWithTextLabel() {
        _textLabelWidthConstraint.constant = bounds.width - (_sideMargin * 2) //Text label starts at the side margin to begin with so we need to double the amount of side margin to make it work for the righ side as well
        layoutIfNeeded()
    }
}

// MARK: - NightModeProtocol
extension SettingsTableViewCell :NightModeProtocol {
    func setupColors() {
        _textLabel.textColor = StandardColors.primaryColor
    }
}
