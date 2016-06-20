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
            setTitle(String(Int(_amount)) + Constants.standardUnit.rawValue, for: UIControlState())
        }
    }
        /// EntryButtonDelegate Protocol delegate
    var _delegate :EntryButtonProtocol?
    
        /// What to do when the button is highlighted. Simply changes the button background color. The text is changed on highlight in the setupAmountLabelFunction
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                layer.backgroundColor = StandardColors.primaryColor.withAlphaComponent(0.5).cgColor
            } else {
                layer.backgroundColor = UIColor.clear().cgColor
            }
        }
    }
    
        /// Circle view outline surrounding the button
    private let _circleView = UIView()
    
    //MARK: - View Setup
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundColor = UIColor.clear()
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
        
        addTarget(self, action: #selector(EntryButton.onTap), for: .touchUpInside)
    }
    
    /**
     Sets up circle view outline as a seperate view in case future animating is desired
     */
    private func setupCircleView() {
        addSubview(_circleView)
        _circleView.isUserInteractionEnabled = false
        _circleView.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: _circleView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: _circleView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: _circleView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: _circleView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))

        
        _circleView.backgroundColor = UIColor.clear()
        
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
        CENAudioToolbox.standardAudioToolbox.playAudio("Water", fileExtension: "wav", repeatEnabled: false)
        
        UIView.animate(withDuration: 0.1, delay: 0, options: .allowUserInteraction, animations: { 
            self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }) { (Bool) in
                UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: .allowUserInteraction, animations: {
                    self.transform = CGAffineTransform.identity
                    }, completion: { (Bool) in
                })
        }
        
        _delegate?.entryButtonTapped(_amount)
    }
}

// MARK: - NightModeProtocol
extension EntryButton :NightModeProtocol {
    func setupColors() {
        _circleView.layer.borderColor = StandardColors.primaryColor.cgColor
        titleLabel?.textColor = StandardColors.primaryColor
    }
}
