//
//  EntryButton.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/16/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

class EntryButton: UIButton {
        /// Amount that entry button will add to goal
    var _amount :Float = 0 {
        didSet {
            setTitle(String(Int(_amount)) + Constants.standardUnit.rawValue, forState: .Normal)
        }
    }
        /// EntryButtonDelegate Protocol delegate
    var _delegate :EntryButtonProtocol?
    
        /// What to do when the button is highlighted. Simply changes the button background color. The text is changed on highlight in the setupAmountLabelFunction
    override var highlighted: Bool {
        didSet {
            if highlighted {
                layer.backgroundColor = StandardColors.primaryColor.colorWithAlphaComponent(0.5).CGColor
            } else {
                layer.backgroundColor = UIColor.clearColor().CGColor
            }
        }
    }
    
        /// Circle view outline surrounding the button
    private let _circleView = UIView()
    
    //MARK: - View Setup
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundColor = UIColor.clearColor()
        layer.cornerRadius = bounds.height / 2
        _circleView.layer.cornerRadius = layer.cornerRadius
        
        setupColors()
    }
    
    /**
     Autolayout setup and adds action for self
     */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupCircleView()
        setupAmountLabel()
        
        clipsToBounds = true
        
        addTarget(self, action: #selector(EntryButton.onTap), forControlEvents: .TouchUpInside)
    }
    
    /**
     Sets up circle view outline as a seperate view in case future animating is desired
     */
    private func setupCircleView() {
        addSubview(_circleView)
        _circleView.userInteractionEnabled = false
        _circleView.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: _circleView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: _circleView, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: _circleView, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: _circleView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0))

        
        _circleView.backgroundColor = UIColor.clearColor()
        
        _circleView.layer.borderWidth = 0.5
    }
    
    /**
     Sets up the button label with visual properties
     */
    private func setupAmountLabel() {
        titleLabel?.font = StandardFonts.regularFont(20)//CENTextUtilities.systemFont(20)
    }
    
    //MARK: - Actions
    
    /**
     Action on tap. Plays audio and animates the button tapped. Calls a delegate method to inform the delegate that the button was tapped
     */
    internal func onTap() {
        CENAudioToolbox.standardAudioToolbox.playAudio("Pop_A", fileExtension: "wav", repeatEnabled: false)
        
        UIView.animateWithDuration(0.1, delay: 0, options: .AllowUserInteraction, animations: { 
            self.transform = CGAffineTransformMakeScale(0.8, 0.8)
            }) { (Bool) in
                UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: .AllowUserInteraction, animations: {
                    self.transform = CGAffineTransformIdentity
                    }, completion: { (Bool) in
                })
        }
        
        _delegate?.entryButtonTapped(_amount)
    }
}

// MARK: - NightModeProtocol
extension EntryButton :NightModeProtocol {
    func setupColors() {
        _circleView.layer.borderColor = StandardColors.primaryColor.CGColor
        titleLabel?.textColor = StandardColors.primaryColor
    }
}
