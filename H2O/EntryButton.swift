//
//  EntryButton.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/16/16.
//  Copyright © 2016 City Pixels. All rights reserved.
//

import UIKit

class EntryButton: UIButton {
    //MARK: - Public iVars
    
    /// Amount that entry button will add to goal, sets the titleLabel to this value plus the unit following.
    var amount: Double = 0 {
        didSet {
            setTitle(String(Int(amount)) + standardUnit.rawValue, for: UIControlState())
        }
    }
    
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
    
    //MARK: - Private iVars
    
    /// Circle view outline surrounding the button
    private lazy var circleView: UIView = {
        let view = UIView()
        
        view.backgroundColor = StandardColors.primaryColor.withAlphaComponent(0.1)
        view.isUserInteractionEnabled = false //To block to circle view from intercepting touches.
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.25
        view.layer.shadowRadius = 0.5
        view.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        
        return view
    }()
    
    //MARK: - Public
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //---View---//
        
        backgroundColor = UIColor.clear
        layer.cornerRadius = bounds.height / 2 //Without setting this, highlighting gets messed up.
        
        //---Circle View---//
        
        circleView.layer.cornerRadius = layer.cornerRadius
    }
    
    // MARK: - Private

    private func customInit() {
        
        //---Title Label---//
        
        titleLabel?.font = StandardFonts.regularFont(size: 20)
        setTitleColor(StandardColors.primaryColor, for: .normal)
        
        //---Circle View---//
        
        addSubview(circleView)
        sendSubview(toBack: circleView)
        
        circleView.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: circleView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: circleView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: circleView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: circleView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
    }
}
