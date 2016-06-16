//
//  InformationEntryInfoCollectionViewCell.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/24/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

protocol InformationEntryInfoCollectionViewCellProtocol {
    func promptEntryDeletion(_ cell :InformationEntryInfoCollectionViewCell)
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
        
        addConstraint(NSLayoutConstraint(item: _entryAmountView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: _entryAmountView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: _entryAmountView, attribute: .width, relatedBy: .equal, toItem: _entryAmountView, attribute: .height, multiplier: 1, constant: 0))
        
        _entryAmountView.clipsToBounds = true
        _entryAmountView.backgroundColor = StandardColors.primaryColor
        
        _entryAmountView.layer.borderColor = UIColor.red().withAlphaComponent(0.8).cgColor
        _entryAmountView.layer.borderWidth = 0
        
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(InformationEntryInfoCollectionViewCell.onLongPressGesture(_:))))
    }
    
    private func setupTimeLabel() {
        addSubview(_timeLabel)
        
        _timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let timeLabelFont = StandardFonts.regularFont(12)
        _timeLabel.text = ""
        
        let sizeOfTime = _timeLabel.text!.size(attributes: [NSFontAttributeName : timeLabelFont])

        addConstraint(NSLayoutConstraint(item: _timeLabel, attribute: .top, relatedBy: .equal, toItem: _entryAmountView, attribute: .bottom, multiplier: 1, constant: 8))
        addConstraint(NSLayoutConstraint(item: _timeLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
         addConstraint(NSLayoutConstraint(item: _timeLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0))
         addConstraint(NSLayoutConstraint(item: _timeLabel, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: _timeLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: sizeOfTime.height))
        
        _timeLabel.textColor = StandardColors.primaryColor
        _timeLabel.font = timeLabelFont
        _timeLabel.textAlignment = .center
    }
    
    private func setupEntryAmountLabel() {
        _entryAmountView.addSubview(_entryAmountLabel)
        
        _entryAmountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let entryLabelFont = StandardFonts.regularFont(14)
        _entryAmountLabel.text = ""
        
        let sizeOfEntry = _entryAmountLabel.text!.size(attributes: [NSFontAttributeName : entryLabelFont])
        
        _entryAmountView.addConstraint(NSLayoutConstraint(item: _entryAmountLabel, attribute: .centerY, relatedBy: .equal, toItem: _entryAmountView, attribute: .centerY, multiplier: 1, constant: 0))
        _entryAmountView.addConstraint(NSLayoutConstraint(item: _entryAmountLabel, attribute: .leading, relatedBy: .equal, toItem: _entryAmountView, attribute: .leading, multiplier: 1, constant: 0))
        _entryAmountView.addConstraint(NSLayoutConstraint(item: _entryAmountLabel, attribute: .trailing, relatedBy: .equal, toItem: _entryAmountView, attribute: .trailing, multiplier: 1, constant: 0))
        _entryAmountView.addConstraint(NSLayoutConstraint(item: _entryAmountLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: sizeOfEntry.height))
        
        _entryAmountLabel.textColor = StandardColors.inversedPrimaryColor
        _entryAmountLabel.font = entryLabelFont
        _entryAmountLabel.textAlignment = .center
    }
    
    func onLongPressGesture(_ gestureRecognizer :UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            animateBorder(30, isDelegate: true)
        } else if gestureRecognizer.state == .ended {
            animateBorder(0, isDelegate: false)
        }
    }
    
    private func animateBorder(_ toValue :CGFloat, isDelegate :Bool) {
        _entryAmountView.layer.borderWidth = toValue
        
        let borderAnimation :CABasicAnimation = CABasicAnimation(keyPath: "borderWidth")
        borderAnimation.fromValue = _entryAmountView.layer.presentation()!.value(forKeyPath: "borderWidth")?.floatValue
        borderAnimation.toValue = toValue
        borderAnimation.duration = 0.3
        borderAnimation.isRemovedOnCompletion = false
        
        if isDelegate {
            borderAnimation.delegate = self
        }
        
        _entryAmountView.layer.add(borderAnimation, forKey: "borderWidth")        
    }
    
    override func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        animateBorder(0, isDelegate: false)
        _delegate?.promptEntryDeletion(self)
    }
}
