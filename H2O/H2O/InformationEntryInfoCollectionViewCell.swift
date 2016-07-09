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
    
    /// Circle view displaying the entry and the amount within
    let entryAmountView = UIView()
    
    /// Label displaying the amound of water logged in entry contained in the entryAmountView
    let entryAmountLabel = UILabel()
    
    /// Time that the entry was added
    let timeLabel = UILabel()
    
    /// Delegate to inform of events within an entry cell
    var delegate :InformationEntryInfoCollectionViewCellProtocol?
    
    //MARK: - Setup
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        entryAmountView.layer.cornerRadius = entryAmountView.bounds.width / 2 //Round corners of the entry amount
    }
    
    /// Basic cell view setup
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupEntryAmountView()
        setupTimeLabel()
        setupEntryAmountLabel()
    }
    
    /// Layout for the entry amount circle view. Rounding of the circle happens in layout subviews because it is earlier in the view life cyle
    private func setupEntryAmountView() {
        addSubview(entryAmountView)
        
        entryAmountView.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: entryAmountView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: entryAmountView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: entryAmountView, attribute: .width, relatedBy: .equal, toItem: entryAmountView, attribute: .height, multiplier: 1, constant: 0))
        
        entryAmountView.clipsToBounds = true
        entryAmountView.backgroundColor = StandardColors.primaryColor
        
        entryAmountView.layer.borderColor = UIColor.red().withAlphaComponent(0.8).cgColor //Border is present because when holding the entry down. The border will grow to indicate that the user wants to delete the entry
        entryAmountView.layer.borderWidth = 0
        
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(self.onLongPressGesture(_:)))) //Long press gesture will invoke a promptDelete from the delegate
    }
    
    /// Layout for the time label representing the time of the entry. Displayed below the entry circle view
    private func setupTimeLabel() {
        addSubview(timeLabel)
        
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let timeLabelFont = StandardFonts.regularFont(12)
        timeLabel.text = "" //Empty text to measure the text label with the font set
        
        let sizeOfTime = timeLabel.text!.size(attributes: [NSFontAttributeName : timeLabelFont]) //Size of label with the font considered

        let spaceBetweenEntryAmountAndTimeLabel :CGFloat = 8 //Space between entry amount circle view and the time added label
        
        addConstraint(NSLayoutConstraint(item: timeLabel, attribute: .top, relatedBy: .equal, toItem: entryAmountView, attribute: .bottom, multiplier: 1, constant: spaceBetweenEntryAmountAndTimeLabel))
        addConstraint(NSLayoutConstraint(item: timeLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
         addConstraint(NSLayoutConstraint(item: timeLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0))
         addConstraint(NSLayoutConstraint(item: timeLabel, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: timeLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: sizeOfTime.height)) //Height is the size of the label with the font considered
        
        timeLabel.textColor = StandardColors.primaryColor
        timeLabel.font = timeLabelFont
        timeLabel.textAlignment = .center
    }
    
    /// Layout for the entry amount label within the entry amount circle view
    private func setupEntryAmountLabel() {
        entryAmountView.addSubview(entryAmountLabel)
        
        entryAmountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let entryLabelFont = StandardFonts.regularFont(14)
        entryAmountLabel.text = "" //Empty text to measure the text label with the font set
        
        let sizeOfEntry = entryAmountLabel.text!.size(attributes: [NSFontAttributeName : entryLabelFont]) //Size of label with the font considered
        
        entryAmountView.addConstraint(NSLayoutConstraint(item: entryAmountLabel, attribute: .centerY, relatedBy: .equal, toItem: entryAmountView, attribute: .centerY, multiplier: 1, constant: 0))
        entryAmountView.addConstraint(NSLayoutConstraint(item: entryAmountLabel, attribute: .leading, relatedBy: .equal, toItem: entryAmountView, attribute: .leading, multiplier: 1, constant: 0))
        entryAmountView.addConstraint(NSLayoutConstraint(item: entryAmountLabel, attribute: .trailing, relatedBy: .equal, toItem: entryAmountView, attribute: .trailing, multiplier: 1, constant: 0))
        entryAmountView.addConstraint(NSLayoutConstraint(item: entryAmountLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: sizeOfEntry.height)) //Height is the size of the label with the font considered
        
        entryAmountLabel.textColor = StandardColors.inversedPrimaryColor
        entryAmountLabel.font = entryLabelFont
        entryAmountLabel.textAlignment = .center
    }
    
    //MARK: - Actions
    
    /// When the cell is long pressed invoke the red border animation. PromptDelete happens when animation is complete
    ///
    /// - parameter gestureRecognizer: The long press gesture
    internal func onLongPressGesture(_ gestureRecognizer :UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            animateBorder(toValue: 30, isDelegate: true)
        } else if gestureRecognizer.state == .ended {
            animateBorder(toValue: 0, isDelegate: false)
        }
    }
    
    /// Animates the border of the entry amount circle view to a value. When complete, it may call the animations delegate.
    ///
    /// - parameter toValue:    Value of the border thickness to animate to
    /// - parameter isDelegate: Should the ending of the animation call the delegate to indicate that it is complete.
    private func animateBorder(toValue :CGFloat, isDelegate :Bool) {
        entryAmountView.layer.borderWidth = toValue
        
        let animationKeyValue = "borderWidth"
        
        let borderAnimation :CABasicAnimation = CABasicAnimation(keyPath: animationKeyValue)
        borderAnimation.fromValue = entryAmountView.layer.presentation()!.value(forKeyPath: animationKeyValue)?.floatValue
        borderAnimation.toValue = toValue
        borderAnimation.duration = 0.3
        borderAnimation.isRemovedOnCompletion = false
        
        if isDelegate {
           // borderAnimation.delegate = self
        }
        
        entryAmountView.layer.add(borderAnimation, forKey: animationKeyValue)
    }
    
   /* override func animationDidStop( _ anim: CAAnimation, finished flag: Bool) {
        animateBorder(toValue: 0, isDelegate: false)
        delegate?.promptEntryDeletion(cell: self)
    }*/
}
