//
//  EntryButton.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/16/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

class EntryButton: UIButton {
    //MARK: - Public iVars
    
    /// Amount that entry button will add to goal
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
    internal var circleView = UIView()
    
    //MARK: - Setup
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundColor = UIColor.clear
        
        //Circular corner radius
        layer.cornerRadius = bounds.height / 2
        circleView.layer.cornerRadius = layer.cornerRadius
        
        setupColors()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        circleView = generateCircleView()
        configureTitleLabel()
        
        layout()
        clipsToBounds = true
        addTarget(self, action: #selector(EntryButton.onTap), for: .touchUpInside)
    }
    
    ///View layout
    private func layout() {
        //---Circle View---
        addSubview(circleView)
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
        
        view.backgroundColor = UIColor.clear
        view.layer.borderWidth = 0.5
        view.isUserInteractionEnabled = false
        
        return view
    }
}

//MARK: - Target Action
internal extension EntryButton {
    ///Action on tap. Plays audio and animates the button tapped. Calls a delegate method to inform the delegate that the button was tapped
    func onTap() {
        AudioToolbox.standardAudioToolbox.playAudio("Water", fileExtension: "wav", repeatEnabled: false)
        
        UIView.animate(withDuration: 0.1, delay: 0, options: .allowUserInteraction, animations: {
            self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { (Bool) in
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: .allowUserInteraction, animations: {
                self.transform = CGAffineTransform.identity
                }, completion: { (Bool) in
            })
        }
        
        delegate?.entryButtonTapped(amount: amount)
    }
}

// MARK: - NightModeProtocol
extension EntryButton :NightModeProtocol {
    func setupColors() {
        circleView.layer.borderColor = StandardColors.primaryColor.cgColor
        titleLabel?.textColor = StandardColors.primaryColor
    }
}
