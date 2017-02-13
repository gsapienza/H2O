//
//  EntryButton.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/16/16.
//  Copyright © 2016 Skyscrapers.IO. All rights reserved.
//

import UIKit

class EntryButton: UIButton {
    //MARK: - Public iVars
    
    /// Amount that entry button will add to goal, sets the titleLabel to this value plus the unit following.
    var amount :Float = 0 {
        didSet {
            setTitle(String(Int(amount)) + standardUnit.rawValue, for: UIControlState())
        }
    }
    /// EntryButtonDelegate Protocol delegate
    var delegate :EntryButtonProtocol?
    
    /// What to do when the button is highlighted. Simply changes the button background color.
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                layer.backgroundColor = StandardColors.primaryColor.withAlphaComponent(0.5).cgColor
            } else {
                layer.backgroundColor = UIColor.clear.cgColor
            }
        }
    }
    
    //MARK: - Internal iVars
    
    /// Circle view outline surrounding the button
    var circleView = UIView()
    
    //MARK: - Setup
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundColor = UIColor.clear
        
        //Circular corner radius
        layer.cornerRadius = bounds.height / 2 //Without setting this, highlighting gets messed up.
        circleView.layer.cornerRadius = layer.cornerRadius
        
        setTitleColor(StandardColors.primaryColor, for: .normal)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        customInit()
    }
    
    func customInit() {
        circleView = generateCircleView()
        configureTitleLabel()
        
        layout()
        addTarget(self, action: #selector(EntryButton.onTap), for: .touchUpInside)
    }
    
    ///View layout
    private func layout() {
        //---Circle View---
        addSubview(circleView)
        sendSubview(toBack: circleView)
        circleView.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: circleView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: circleView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: circleView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: circleView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
    }
}

//MARK: - Private View Configurations
private extension EntryButton {
    /// Configures the button title label
    func configureTitleLabel() {
        titleLabel!.font = StandardFonts.regularFont(size: 20)
    }
}

//MARK: - Private Generators
private extension EntryButton {
    
    /// Generates a view for a circle border
    ///
    /// - returns: View for circle border
    func generateCircleView() -> UIView {
        let view = UIView()
        
        view.backgroundColor = StandardColors.primaryColor.withAlphaComponent(0.1)
        view.isUserInteractionEnabled = false //To block to circle view from intercepting touches.
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.25
        view.layer.shadowRadius = 0.5
        view.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        
        return view
    }
}

//MARK: - Target Action
extension EntryButton {
    ///Action on tap. Plays audio and animates the button tapped. Calls a delegate method to inform the delegate that the button was tapped
    func onTap() {
        AudioToolbox.standardAudioToolbox.playAudio(WaterDrop1Sound, repeatEnabled: false)
        let feedbackGenerator = UINotificationFeedbackGenerator()
        feedbackGenerator.prepare()
        feedbackGenerator.notificationOccurred(.success)
        
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
            self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { (Bool) in
        }
        
        UIView.animate(withDuration: 0.4, delay: 0.1, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.2, options: .curveEaseOut, animations: {
            self.transform = CGAffineTransform.identity
        }, completion: { (Bool) in
        })
        
        delegate?.entryButtonTapped(amount: amount)
    }
}
