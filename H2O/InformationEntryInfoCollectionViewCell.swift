//
//  InformationEntryInfoCollectionViewCell.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/24/16.
//  Copyright © 2016 City Pixels. All rights reserved.
//

import UIKit

class InformationEntryInfoCollectionViewCell: UICollectionViewCell {
    //MARK: - Public iVars
    
    /// Label displaying the amound of water logged in entry contained in the entryAmountView
    var entryAmountLabel :UILabel!
    
    /// Time that the entry was added
    var timeLabel :UILabel!
    
    //MARK: - Private iVars
    
    /// Circle view displaying the entry and the amount within
    private var entryAmountView :UIView!
    
    
    //MARK: - Setup
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        entryAmountView.layer.cornerRadius = entryAmountView.bounds.width / 2 //Round corners of the entry amount
    }
    
    /// Basic cell view setup
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        entryAmountView = generateEntryAmountView()
        timeLabel = generateTimeLabel()
        entryAmountLabel = generateEntryAmountLabel()
        
        layout()
    }
    
    /// View Layout
    private func layout() {
        //---Entry Amount View---
        addSubview(entryAmountView)
        
        entryAmountView.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: entryAmountView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: entryAmountView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: entryAmountView, attribute: .width, relatedBy: .equal, toItem: entryAmountView, attribute: .height, multiplier: 1, constant: 0))
        
        //---Time Label---
        addSubview(timeLabel)
        
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        timeLabel.text = "" //Empty text to measure the text label with the font set
        
        let sizeOfTime = timeLabel.text!.size(attributes: [NSFontAttributeName : timeLabel.font!]) //Size of label with the font considered
        
        let spaceBetweenEntryAmountAndTimeLabel :CGFloat = 8 //Space between entry amount circle view and the time added label
        
        addConstraint(NSLayoutConstraint(item: timeLabel, attribute: .top, relatedBy: .equal, toItem: entryAmountView, attribute: .bottom, multiplier: 1, constant: spaceBetweenEntryAmountAndTimeLabel))
        addConstraint(NSLayoutConstraint(item: timeLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: timeLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: timeLabel, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: timeLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: sizeOfTime.height)) //Height is the size of the label with the font considered
        
        //---Entry Amount Label---
        entryAmountView.addSubview(entryAmountLabel)
        
        entryAmountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        entryAmountLabel.text = "" //Empty text to measure the text label with the font set
        
        let sizeOfEntry = entryAmountLabel.text!.size(attributes: [NSFontAttributeName : entryAmountLabel.font!]) //Size of label with the font considered
        
        entryAmountView.addConstraint(NSLayoutConstraint(item: entryAmountLabel, attribute: .centerY, relatedBy: .equal, toItem: entryAmountView, attribute: .centerY, multiplier: 1, constant: 0))
        entryAmountView.addConstraint(NSLayoutConstraint(item: entryAmountLabel, attribute: .leading, relatedBy: .equal, toItem: entryAmountView, attribute: .leading, multiplier: 1, constant: 0))
        entryAmountView.addConstraint(NSLayoutConstraint(item: entryAmountLabel, attribute: .trailing, relatedBy: .equal, toItem: entryAmountView, attribute: .trailing, multiplier: 1, constant: 0))
        entryAmountView.addConstraint(NSLayoutConstraint(item: entryAmountLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: sizeOfEntry.height)) //Height is the size of the label with the font considered
    }
    
    //MARK: - Internal
    
    /// Animates the border of the entry amount circle view to be shown or hidden. When complete, it may call the animations delegate.
    ///
    /// - parameter hidden: Should the border be shown or hidden.
    /// - parameter animated: Should the border be animated.
    func animateBorder(hidden :Bool, animated :Bool) {
        let borderWidth :CGFloat = hidden ? 0 : 30
       
        if let presentationLayer = entryAmountView.layer.presentation() {
            if animated {
                let animationKeyValue = "borderWidth"
                
                let borderAnimation :CABasicAnimation = CABasicAnimation(keyPath: animationKeyValue)
                borderAnimation.fromValue = (presentationLayer.value(forKeyPath: animationKeyValue) as AnyObject).floatValue
                borderAnimation.toValue = borderWidth
                borderAnimation.duration = 0.3                
                entryAmountView.layer.add(borderAnimation, forKey: animationKeyValue)
            }
        }
        
        entryAmountView.layer.borderWidth = borderWidth
    }
    
}

//MARK: - Private Generators
private extension InformationEntryInfoCollectionViewCell {
    
    /// Generates a view to display a value
    ///
    /// - returns: Circular view to see value
    func generateEntryAmountView() -> UIView {
        let view = UIView()
        
        view.clipsToBounds = true
        view.backgroundColor = StandardColors.primaryColor
        
        view.layer.borderColor = UIColor.red.withAlphaComponent(0.8).cgColor //Border is present because when holding the entry down. The border will grow to indicate that the user wants to delete the entry
        view.layer.borderWidth = 0
        
        return view
    }
    
    /// Generates a label to display a time
    ///
    /// - returns: Label that displays the time
    func generateTimeLabel() -> UILabel {
        let label = UILabel()
        
        label.textColor = StandardColors.primaryColor
        label.font = StandardFonts.regularFont(size: 12)
        label.textAlignment = .center
        
        return label
    }
    
    /// Generates a label to display an amount
    ///
    /// - returns: Label displaying amount
    func generateEntryAmountLabel() -> UILabel {
        let label = UILabel()
        
        label.textColor = StandardColors.inversedPrimaryColor
        label.font = StandardFonts.regularFont(size: 14)
        label.textAlignment = .center
        
        return label
    }
}
