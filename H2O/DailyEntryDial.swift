//
//  DailyEntryDial.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/16/16.
//  Copyright © 2016 City Pixels. All rights reserved.
//

import UIKit

class DailyEntryDial: UIControl {
    //MARK: - Public iVars
    
    /// Current value in dial.
    var current: Double = 0
    
    /// Total value to fill dial.
    var total: Double = 0
    
    /// Color of unfilled progress circle path.
    var outerCircleColor = UIColor.black {
        didSet {
            outerCircleShapeLayer.strokeColor = outerCircleColor.cgColor
        }
    }
    
    /// Color of filled progress circle path.
    var innerCircleColor = UIColor.white {
        didSet {
            innerCircleShapeLayer.strokeColor = innerCircleColor.cgColor
        }
    }

    // MARK: - Private iVars
    
    /// Line width for the 2 overlapping circles in the gauge
    private var circleLineWidth: CGFloat {
        return frame.width / 8
    }
    
    /// Center label displaying the amount of water that the user drank
    private lazy var currentAmountOfWaterDrankTodayLabel: UILabel = {
        let label = UILabel()
        
        label.font = StandardFonts.boldFont(size: 70)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.textAlignment = .center
        label.baselineAdjustment = .alignCenters
        
        return label
    }()
    
    /// Shape layer that displays in a circle form how much water the user drank
    private lazy var outerCircleShapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        
        shapeLayer.strokeColor = self.outerCircleColor.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        
        return shapeLayer
    }()
    
    /// Shape layer that displays in a circle form how much water the user drank
    private lazy var innerCircleShapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        
        shapeLayer.lineCap = kCALineCapRound
        shapeLayer.strokeColor = self.innerCircleColor.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.transform = CATransform3DMakeRotation(self.degreesToRadians(degrees: 270), 0, 0, 1.0) //Rotation used to get the starting point at the top center and turn clockwise
        
        return shapeLayer
    }()
    
    //MARK: - Setup
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    func customInit() {
        backgroundColor = UIColor.clear
        
        currentAmountOfWaterDrankTodayLabel.textColor = StandardColors.primaryColor
        
        layer.addSublayer(outerCircleShapeLayer)
        layer.addSublayer(innerCircleShapeLayer)
        
        //---Current Amount of Water Drank Today Label---//
        
        addSubview(currentAmountOfWaterDrankTodayLabel)
        
        currentAmountOfWaterDrankTodayLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: currentAmountOfWaterDrankTodayLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: currentAmountOfWaterDrankTodayLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: currentAmountOfWaterDrankTodayLabel, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.5, constant: 0))
        addConstraint(NSLayoutConstraint(item: currentAmountOfWaterDrankTodayLabel, attribute: .height, relatedBy: .equal, toItem: currentAmountOfWaterDrankTodayLabel, attribute: .width, multiplier: 1, constant: 0))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //---Outer Circle Layer---//
        
        outerCircleShapeLayer.frame = bounds
        outerCircleShapeLayer.path = UIBezierPath(ovalIn: bounds.insetBy(dx: circleLineWidth / 2, dy: circleLineWidth / 2)).cgPath //Rect is a CGRect that accounts for the fact that the inner circle line width will display partially outside of the view. This rect brings it in to match with the outer circle
        outerCircleShapeLayer.lineWidth = circleLineWidth
        
        //---Inner Circle Layer---//
        
        innerCircleShapeLayer.frame = bounds
        innerCircleShapeLayer.path = outerCircleShapeLayer.path
        innerCircleShapeLayer.lineWidth = outerCircleShapeLayer.lineWidth
        
        //---Title Label---//
        
        updateAmountOfWaterDrankToday(animated: false)
    }
    
    //MARK: - Public
    
    /// Changes the value for the amount of water drank
    ///
    /// - parameter animated: Should the dial gauge animate on change
    func updateAmountOfWaterDrankToday(animated: Bool) {
        
        currentAmountOfWaterDrankTodayLabel.text = String(Int(current)) + standardUnit.rawValue
        
        let newStrokeEnd = current / total
        
        if animated {
            let animationTime = 0.5
            
            //Animation of the gauge circle
            let previousStrokeEnd = innerCircleShapeLayer.strokeEnd
            innerCircleShapeLayer.strokeEnd = CGFloat(newStrokeEnd)
            
            let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
            strokeAnimation.fromValue = previousStrokeEnd
            strokeAnimation.toValue = newStrokeEnd
            strokeAnimation.duration = animationTime
            strokeAnimation.isRemovedOnCompletion = false
            
            innerCircleShapeLayer.add(strokeAnimation, forKey: "strokeEnd")
        } else {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            innerCircleShapeLayer.strokeEnd = CGFloat(newStrokeEnd)
            CATransaction.commit()
        }
    }
    
    /// Toggle repeating beat animation for dial.
    ///
    /// - parameter toggle: Toggle determining if animation should be active or not.
    func beatAnimation(toggle: Bool) {
        let animationTime = 0.3
        
        if toggle {
            UIView.animate(withDuration: animationTime, delay: 0, options: [.autoreverse, .repeat, .allowUserInteraction], animations: {
                self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                }, completion: { (Bool) in
            })
        } else {
            UIView.animate(withDuration: animationTime, animations: {
                self.transform = CGAffineTransform.identity
            })
        }
    }
    
    //MARK: - Private
    
    /// Helper function to convert degrees to radians
    ///
    /// - parameter degrees: Degrees value to convert
    ///
    /// - returns: Radian value converted from degrees
    private func degreesToRadians(degrees: CGFloat) -> CGFloat {
        return degrees * CGFloat(Float.pi) / 180
    }
    
    // MARK: - Actions

    /// Action that happens when dial button is tapped. Calls the implemented delegate function
    func onDialButton() {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
            self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { (Bool) in
        }
        
        UIView.animate(withDuration: 0.4, delay: 0.1, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.2, options: .curveEaseOut, animations: {
            self.transform = CGAffineTransform.identity
        }, completion: { (Bool) in
        })
    }
}
