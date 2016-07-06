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
    let entryAmountView = UIView()
    let timeLabel = UILabel()
    let entryAmountLabel = UILabel()
    
    var delegate :InformationEntryInfoCollectionViewCellProtocol?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        entryAmountView.layer.cornerRadius = entryAmountView.bounds.width / 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupEntryAmountView()
        setupTimeLabel()
        setupEntryAmountLabel()
    }
    
    private func setupEntryAmountView() {
        addSubview(entryAmountView)
        
        entryAmountView.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: entryAmountView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: entryAmountView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: entryAmountView, attribute: .width, relatedBy: .equal, toItem: entryAmountView, attribute: .height, multiplier: 1, constant: 0))
        
        entryAmountView.clipsToBounds = true
        entryAmountView.backgroundColor = StandardColors.primaryColor
        
        entryAmountView.layer.borderColor = UIColor.red().withAlphaComponent(0.8).cgColor
        entryAmountView.layer.borderWidth = 0
        
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(self.onLongPressGesture(_:))))
    }
    
    private func setupTimeLabel() {
        addSubview(timeLabel)
        
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let timeLabelFont = StandardFonts.regularFont(12)
        timeLabel.text = ""
        
        let sizeOfTime = timeLabel.text!.size(attributes: [NSFontAttributeName : timeLabelFont])

        addConstraint(NSLayoutConstraint(item: timeLabel, attribute: .top, relatedBy: .equal, toItem: entryAmountView, attribute: .bottom, multiplier: 1, constant: 8))
        addConstraint(NSLayoutConstraint(item: timeLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
         addConstraint(NSLayoutConstraint(item: timeLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0))
         addConstraint(NSLayoutConstraint(item: timeLabel, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: timeLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: sizeOfTime.height))
        
        timeLabel.textColor = StandardColors.primaryColor
        timeLabel.font = timeLabelFont
        timeLabel.textAlignment = .center
    }
    
    private func setupEntryAmountLabel() {
        entryAmountView.addSubview(entryAmountLabel)
        
        entryAmountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let entryLabelFont = StandardFonts.regularFont(14)
        entryAmountLabel.text = ""
        
        let sizeOfEntry = entryAmountLabel.text!.size(attributes: [NSFontAttributeName : entryLabelFont])
        
        entryAmountView.addConstraint(NSLayoutConstraint(item: entryAmountLabel, attribute: .centerY, relatedBy: .equal, toItem: entryAmountView, attribute: .centerY, multiplier: 1, constant: 0))
        entryAmountView.addConstraint(NSLayoutConstraint(item: entryAmountLabel, attribute: .leading, relatedBy: .equal, toItem: entryAmountView, attribute: .leading, multiplier: 1, constant: 0))
        entryAmountView.addConstraint(NSLayoutConstraint(item: entryAmountLabel, attribute: .trailing, relatedBy: .equal, toItem: entryAmountView, attribute: .trailing, multiplier: 1, constant: 0))
        entryAmountView.addConstraint(NSLayoutConstraint(item: entryAmountLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: sizeOfEntry.height))
        
        entryAmountLabel.textColor = StandardColors.inversedPrimaryColor
        entryAmountLabel.font = entryLabelFont
        entryAmountLabel.textAlignment = .center
    }
    
    func onLongPressGesture(_ gestureRecognizer :UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            animateBorder(toValue: 30, isDelegate: true)
        } else if gestureRecognizer.state == .ended {
            animateBorder(toValue: 0, isDelegate: false)
        }
    }
    
    private func animateBorder(toValue :CGFloat, isDelegate :Bool) {
        entryAmountView.layer.borderWidth = toValue
        
        let borderAnimation :CABasicAnimation = CABasicAnimation(keyPath: "borderWidth")
        borderAnimation.fromValue = entryAmountView.layer.presentation()!.value(forKeyPath: "borderWidth")?.floatValue
        borderAnimation.toValue = toValue
        borderAnimation.duration = 0.3
        borderAnimation.isRemovedOnCompletion = false
        
        if isDelegate {
           // borderAnimation.delegate = self
        }
        
        entryAmountView.layer.add(borderAnimation, forKey: "borderWidth")        
    }
    
   /* override func animationDidStop( _ anim: CAAnimation, finished flag: Bool) {
        animateBorder(toValue: 0, isDelegate: false)
        delegate?.promptEntryDeletion(cell: self)
    }*/
}
