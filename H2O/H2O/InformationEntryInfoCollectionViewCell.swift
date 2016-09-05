//
//  InformationEntryInfoCollectionViewCell.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/24/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

protocol InformationEntryInfoCollectionViewCellProtocol {
    /// Send message that user has prompted deletion of an entry
    ///
    /// - parameter cell: Cell representing entry to delete
    func promptEntryDeletion(cell :InformationEntryInfoCollectionViewCell)
}

class InformationEntryInfoCollectionViewCell: UICollectionViewCell {
    //MARK: - Public iVars
    
    /// Label displaying the amound of water logged in entry contained in the entryAmountView
    var entryAmountLabel :UILabel!
    
    /// Time that the entry was added
    var timeLabel :UILabel!
    
    /// Delegate to inform of events within an entry cell
    var delegate :InformationEntryInfoCollectionViewCellProtocol?
    
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
        
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(self.onLongPressGesture(_:)))) //Long press gesture will invoke a promptDelete from the delegate
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
    
    /// Animates the border of the entry amount circle view to a value. When complete, it may call the animations delegate.
    ///
    /// - parameter toValue:    Value of the border thickness to animate to
    /// - parameter isDelegate: Should the ending of the animation call the delegate to indicate that it is complete.
    internal func animateBorder(toValue :CGFloat, isDelegate :Bool) {
        entryAmountView.layer.borderWidth = toValue
        
        let animationKeyValue = "borderWidth"
        
        let borderAnimation :CABasicAnimation = CABasicAnimation(keyPath: animationKeyValue)
        borderAnimation.fromValue = (entryAmountView.layer.presentation()!.value(forKeyPath: animationKeyValue) as AnyObject).floatValue
        borderAnimation.toValue = toValue
        borderAnimation.duration = 0.3
        borderAnimation.isRemovedOnCompletion = false
        
        if isDelegate {
            borderAnimation.delegate = self
        }
        
        entryAmountView.layer.add(borderAnimation, forKey: animationKeyValue)        
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

// MARK: - Target Action
internal extension InformationEntryInfoCollectionViewCell {
    /// When the cell is long pressed invoke the red border animation. PromptDelete happens when animation is complete
    ///
    /// - parameter gestureRecognizer: The long press gesture
    func onLongPressGesture(_ gestureRecognizer :UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            animateBorder(toValue: 30, isDelegate: true)
        } else if gestureRecognizer.state == .ended {
            animateBorder(toValue: 0, isDelegate: false)
        }
    }
}

// MARK: - CAAnimationDelegate
extension InformationEntryInfoCollectionViewCell :CAAnimationDelegate {
     func animationDidStop( _ anim: CAAnimation, finished flag: Bool) {
        animateBorder(toValue: 0, isDelegate: false)
        delegate?.promptEntryDeletion(cell: self)
    }
}
