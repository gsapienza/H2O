//
//  DailyEntryDial.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/16/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

protocol DailyEntryDialProtocol {
    
    /// Determines the amount of water drank today
    ///
    /// - returns: Float value of water drank today
    func getAmountOfWaterEnteredToday() -> Float
    
    /// Determines the user set goal from NSUserDefaults

    ///
    /// - returns: Goal float value set by user
    func getGoal() -> Float
    
    ///Called when the user has tapped this view like a button
    func dialButtonTapped()
}

class DailyEntryDial: UIView {
    //MARK: - Public iVars
    
    /// Goal instance var, is loaded through NSUserDefaults and contains daily water goal (readonly)
    var goal :Float {
        set{}
        get {
            return delegate!.getGoal()
        }
    }
    
    /// Current amount of water that the user drank today public property (readonly)
    var currentAmountOfWaterDrankToday :Float {
        set{}
        get {
            return (delegate?.getAmountOfWaterEnteredToday())!
        }
    }
    
    ///DailyEntryDialProtocol Delegate
    var delegate :DailyEntryDialProtocol?
    
    //MARK: - Internal iVars
    
    /// Line width for the 2 overlapping circles in the gauge
    internal let circleLineWidth :CGFloat = 20

    /// Center label displaying the amount of water that the user drank
    internal var currentAmountOfWaterDrankTodayLabel :UILabel!
    
    /// Shape layer that displays in a circle form how much water the user drank
    internal var outerCircleShapeLayer :CAShapeLayer!
    
    /// Shape layer that displays in a circle form how much water the user drank
    internal var innerCircleShapeLayer :CAShapeLayer!
    
    /// Button in middle that displays how much water was drank
    internal var dialButton :UIButton!
    
    //MARK: - Setup
    
    ///Makes the background always transparent and sets up circle layer. Initial amount is also calculated here
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundColor = UIColor.clear
        
        outerCircleShapeLayer = generateOuterCircleShapeLayer()
        innerCircleShapeLayer = generateInnerCircleShapeLayer()
        currentAmountOfWaterDrankTodayLabel = generateAmountLabel()
        dialButton = generateDialButton()
        
        updateAmountOfWaterDrankToday(animated: false)
        setupColors()
        
        layout()
    }
    
    /// Layout for all subviews within view
    private func layout() {
        //---Outer Circle Layer---
        outerCircleShapeLayer.frame = bounds
        layer.addSublayer(outerCircleShapeLayer)
        
        //---Inner Circle Layer---
        
        innerCircleShapeLayer.frame = bounds
        layer.addSublayer(innerCircleShapeLayer)
        
        //---Current Amount of Water Drank Today Label---
        
        addSubview(currentAmountOfWaterDrankTodayLabel)
        
        currentAmountOfWaterDrankTodayLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: currentAmountOfWaterDrankTodayLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: currentAmountOfWaterDrankTodayLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: currentAmountOfWaterDrankTodayLabel, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: currentAmountOfWaterDrankTodayLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
        
        //---Dial Button---
        
        addSubview(dialButton)
        
        dialButton.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: dialButton, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: dialButton, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: dialButton, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: dialButton, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
    }
    
    //MARK: - Internal
    
    /// Helper function to convert degrees to radians
    ///
    /// - parameter degrees: Degrees value to convert
    ///
    /// - returns: Radian value converted from degrees
    internal func degreesToRadians( degrees :CGFloat) -> CGFloat {
        return degrees * CGFloat(Float.pi) / 180
    }
    
    //MARK: - Public
    
    /// Changes the value for the amount of water drank
    ///
    /// - parameter animated: Should the dial gauge animate on change
    func updateAmountOfWaterDrankToday( animated :Bool) {
        currentAmountOfWaterDrankTodayLabel.text = String(Int(currentAmountOfWaterDrankToday)) + standardUnit.rawValue
        
        let newStrokeEnd = currentAmountOfWaterDrankToday / goal
        
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
}

// MARK: - Private Generators
private extension DailyEntryDial {
    
    /// Generates an outer circle to use to display full unfilled progress
    
    ///
    /// - returns: Layer containing the circle
    func generateOuterCircleShapeLayer() -> CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        
        let rect = bounds.insetBy(dx: circleLineWidth / 2, dy: circleLineWidth / 2) //Rect is a CGRect that accounts for the fact that the inner circle line width will display partially outside of the view. This rect brings it in to match with the outer circle
        
        let circlePath = UIBezierPath(ovalIn: rect) //Circle path
        shapeLayer.path = circlePath.cgPath
        shapeLayer.lineWidth = circleLineWidth //Size of the border width
        
        return shapeLayer
    }
    
    /// Generates an inner circle path that will represent how much water was drank today. Starts at 0

    ///
    /// - returns: Layer containing the circle
    func generateInnerCircleShapeLayer() -> CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        
        let rect = bounds.insetBy(dx: circleLineWidth / 2, dy: circleLineWidth / 2) //Rect is a CGRect that accounts for the fact that the inner circle line width will display partially outside of the view. This rect brings it in to match with the outer circle
        
        let innerCirclePath = UIBezierPath(ovalIn: rect) //Circle path
        
        shapeLayer.path = innerCirclePath.cgPath
        
        shapeLayer.lineWidth = circleLineWidth //Size of the border width
        shapeLayer.lineCap = kCALineCapRound //Rounds out the edges
        
        shapeLayer.transform = CATransform3DMakeRotation(degreesToRadians(degrees: 270), 0, 0, 1.0) //Rotation used to get the starting point at the top center and turn clockwise
        
        return shapeLayer
    }
    
    /// Generates amount label in center of dial
    ///
    /// - returns: Label to display water amount
    func generateAmountLabel() -> UILabel {
        let label = UILabel()
        
        label.font = StandardFonts.thinFont(size: 80)
        label.textAlignment = .center
        
        return label
    }
    
    /// Generates button which will contain all contenrs of the dial and calls a delegate function when tapped
    ///
    /// - returns: Button that will represent the dial
    func generateDialButton() -> UIButton {
        let dialButton = UIButton()
        
        dialButton.backgroundColor = UIColor.clear
        dialButton.titleLabel?.text = ""
        dialButton.addTarget(self, action: #selector(DailyEntryDial.onDialButton), for: .touchUpInside)
        
        return dialButton
    }
}

// MARK: - Target Actions
internal extension DailyEntryDial {
    
    /// Action that happens when dial button is tapped. Calls the implemented delegate function
    func onDialButton() {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
            self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { (Bool) in
            self.delegate?.dialButtonTapped()
            
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: .curveEaseIn, animations: {
                self.transform = CGAffineTransform.identity
                }, completion: { (Bool) in
            })
        }
    }
}

// MARK: - NightModeProtocol
extension DailyEntryDial :NightModeProtocol {
    func setupColors() {
        currentAmountOfWaterDrankTodayLabel.textColor = StandardColors.primaryColor
        outerCircleShapeLayer.strokeColor = StandardColors.primaryColor.withAlphaComponent(0.2).cgColor //Color of border
        outerCircleShapeLayer.fillColor = UIColor.clear.cgColor //Color of fill
        
        innerCircleShapeLayer.strokeColor = StandardColors.primaryColor.cgColor //Color of border
        innerCircleShapeLayer.fillColor = UIColor.clear.cgColor //Color of fill
    }
}
