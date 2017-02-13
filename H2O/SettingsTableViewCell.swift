//
//  SettingsTableViewCell.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/17/16.
//  Copyright © 2016 Skyscrapers.IO. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
    
    //MARK: - Public iVars
    
    /// Cell Image view
    var cellImageView :UIImageView!
    
    /// Text title label
    var cellTextLabel :UILabel!
    
    ///MARK: - Private iVars
    
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
        
        cellTextLabel.textColor = StandardColors.primaryColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        cellImageView = generateImageView()
        cellTextLabel = generateTextLabel()
        
        layout()
    }
    
    private func layout() {
        //---Cell Image View---
        addSubview(cellImageView)
        
        cellImageView.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: cellImageView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 15))
        addConstraint(NSLayoutConstraint(item: cellImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: cellImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 25))
        addConstraint(NSLayoutConstraint(item: cellImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 25))
        
        //---Cell Text Label---
        
        addSubview(cellTextLabel)
        
        cellTextLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: cellTextLabel, attribute: .leading, relatedBy: .equal, toItem: cellImageView, attribute: .trailing, multiplier: 1, constant: sideMargin))
        addConstraint(NSLayoutConstraint(item: cellImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        textLabelWidthConstraint = NSLayoutConstraint(item: cellTextLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: bounds.width / 2)
        addConstraint(textLabelWidthConstraint)
        addConstraint(NSLayoutConstraint(item: cellTextLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: bounds.height))
    }
    
    //MARK: - Public
    
    ///Makes the text label take up the full width of the cell
    func fillCellWithTextLabel() {
        textLabelWidthConstraint.constant = bounds.width - (sideMargin * 2) //Text label starts at the side margin to begin with so we need to double the amount of side margin to make it work for the righ side as well
        layoutIfNeeded()
    }
}

// MARK: - Private Generators
private extension SettingsTableViewCell {
    /// Generates text label to use in cell
    ///
    /// - returns: Text label in cell
    func generateTextLabel() -> UILabel {
        let label = UILabel()
        
        label.font = StandardFonts.regularFont(size: 15)
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        
        return label
    }
    
    /// Generates image view to use in cell
    ///
    /// - returns: Image view in cell
    func generateImageView() -> UIImageView {
        let imageView = UIImageView()
        
        imageView.contentMode = .center
        
        return imageView
    }
}
