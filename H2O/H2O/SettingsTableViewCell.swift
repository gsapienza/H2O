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
    let cellImageView = UIImageView()
    
        /// Text title label
    let cellTextLabel = UILabel()
    
        /// Constraint for the text labels width constraint so it can be modified
    private var textLabelWidthConstraint = NSLayoutConstraint()
    
        /// Side margin amount for contained ui elements on the left and right side of the cell
    private let sideMargin :CGFloat = 15

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
        addSubview(cellImageView)
        
        cellImageView.contentMode = .center
        
        cellImageView.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: cellImageView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 15))
        addConstraint(NSLayoutConstraint(item: cellImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: cellImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 25))
        addConstraint(NSLayoutConstraint(item: cellImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 25))
    }
    
    
    /**
     Sets up properties for the description text label
     */
    private func setupTextLabel() {
        addSubview(cellTextLabel)
        
        cellTextLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: cellTextLabel, attribute: .leading, relatedBy: .equal, toItem: cellImageView, attribute: .trailing, multiplier: 1, constant: sideMargin))
        addConstraint(NSLayoutConstraint(item: cellImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        textLabelWidthConstraint = NSLayoutConstraint(item: cellTextLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: bounds.width / 2)
        addConstraint(textLabelWidthConstraint)
        addConstraint(NSLayoutConstraint(item: cellTextLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: bounds.height))
        
        cellTextLabel.font = StandardFonts.regularFont(18)
        cellTextLabel.minimumScaleFactor = 0.7
        cellTextLabel.adjustsFontSizeToFitWidth = true
    }
    
    /**
     Makes the text label take up the full width of the cell
     */
    func fillCellWithTextLabel() {
        textLabelWidthConstraint.constant = bounds.width - (sideMargin * 2) //Text label starts at the side margin to begin with so we need to double the amount of side margin to make it work for the righ side as well
        layoutIfNeeded()
    }
}

// MARK: - NightModeProtocol
extension SettingsTableViewCell :NightModeProtocol {
    func setupColors() {
        cellTextLabel.textColor = StandardColors.primaryColor
    }
}
