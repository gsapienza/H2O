//
//  InformationEntryInfoCollectionViewCell.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/24/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

protocol InformationEntryInfoCollectionViewCellProtocol {
    func promptEntryDeletion(cell :InformationEntryInfoCollectionViewCell)
}

class InformationEntryInfoCollectionViewCell: UICollectionViewCell {
    let _entryAmountView = UIView()
    let _timeLabel = UILabel()
    let _entryAmountLabel = UILabel()
    
    var _delegate :InformationEntryInfoCollectionViewCellProtocol?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        _entryAmountView.layer.cornerRadius = _entryAmountView.bounds.width / 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupEntryAmountView()
        setupTimeLabel()
        setupEntryAmountLabel()
    }
    
    private func setupEntryAmountView() {
        addSubview(_entryAmountView)
        
        _entryAmountView.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: _entryAmountView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: _entryAmountView, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: _entryAmountView, attribute: .Width, relatedBy: .Equal, toItem: _entryAmountView, attribute: .Height, multiplier: 1, constant: 0))
        
        _entryAmountView.clipsToBounds = true
        _entryAmountView.backgroundColor = StandardColors.primaryColor
        
        _entryAmountView.layer.borderColor = UIColor.redColor().colorWithAlphaComponent(0.8).CGColor
        _entryAmountView.layer.borderWidth = 0
        
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(InformationEntryInfoCollectionViewCell.onLongPressGesture(_:))))
    }
    
    private func setupTimeLabel() {
        addSubview(_timeLabel)
        
        _timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let timeLabelFont = StandardFonts.regularFont(12)
        _timeLabel.text = ""
        
        let sizeOfTime = _timeLabel.text!.sizeWithAttributes([NSFontAttributeName : timeLabelFont])

        addConstraint(NSLayoutConstraint(item: _timeLabel, attribute: .Top, relatedBy: .Equal, toItem: _entryAmountView, attribute: .Bottom, multiplier: 1, constant: 8))
        addConstraint(NSLayoutConstraint(item: _timeLabel, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0))
         addConstraint(NSLayoutConstraint(item: _timeLabel, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 0))
         addConstraint(NSLayoutConstraint(item: _timeLabel, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: _timeLabel, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: sizeOfTime.height))
        
        _timeLabel.textColor = StandardColors.primaryColor
        _timeLabel.font = timeLabelFont
        _timeLabel.textAlignment = .Center
    }
    
    private func setupEntryAmountLabel() {
        _entryAmountView.addSubview(_entryAmountLabel)
        
        _entryAmountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let entryLabelFont = StandardFonts.regularFont(14)
        _entryAmountLabel.text = ""
        
        let sizeOfEntry = _entryAmountLabel.text!.sizeWithAttributes([NSFontAttributeName : entryLabelFont])
        
        _entryAmountView.addConstraint(NSLayoutConstraint(item: _entryAmountLabel, attribute: .CenterY, relatedBy: .Equal, toItem: _entryAmountView, attribute: .CenterY, multiplier: 1, constant: 0))
        _entryAmountView.addConstraint(NSLayoutConstraint(item: _entryAmountLabel, attribute: .Leading, relatedBy: .Equal, toItem: _entryAmountView, attribute: .Leading, multiplier: 1, constant: 0))
        _entryAmountView.addConstraint(NSLayoutConstraint(item: _entryAmountLabel, attribute: .Trailing, relatedBy: .Equal, toItem: _entryAmountView, attribute: .Trailing, multiplier: 1, constant: 0))
        _entryAmountView.addConstraint(NSLayoutConstraint(item: _entryAmountLabel, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: sizeOfEntry.height))
        
        _entryAmountLabel.textColor = StandardColors.inversedPrimaryColor
        _entryAmountLabel.font = entryLabelFont
        _entryAmountLabel.textAlignment = .Center
    }
    
    func onLongPressGesture(gestureRecognizer :UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .Began {
            animateBorder(30, isDelegate: true)
        } else if gestureRecognizer.state == .Ended {
           animateBorder(0, isDelegate: false)
        }
    }
    
    private func animateBorder(toValue :CGFloat, isDelegate :Bool) -> CABasicAnimation {
        _entryAmountView.layer.borderWidth = toValue
        
        let borderAnimation :CABasicAnimation = CABasicAnimation(keyPath: "borderWidth")
        borderAnimation.fromValue = _entryAmountView.layer.presentationLayer()!.valueForKeyPath("borderWidth")?.floatValue
        borderAnimation.toValue = toValue
        borderAnimation.duration = 0.3
        borderAnimation.removedOnCompletion = false
        
        if isDelegate {
            borderAnimation.delegate = self
        }
        
        _entryAmountView.layer.addAnimation(borderAnimation, forKey: "borderWidth")
        
        return borderAnimation
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        animateBorder(0, isDelegate: false)
        _delegate?.promptEntryDeletion(self)
    }
}
