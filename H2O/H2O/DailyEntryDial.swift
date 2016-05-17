//
//  DailyEntryDial.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/16/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

class DailyEntryDial: UIView {
        /// Goal instance var, is loaded through NSUserDefaults and contains daily water goal
    private var _goal :Float = 0
    
        /// Goal public property (readonly)
    var goal :Float {
        set{}
        get {
            return _goal
        }
    }
    
        /// Instance var for the current amount of water that the user has entered today
    private var _currentAmountOfWaterDrankToday :Float = 0

        /// Current amount of water that the user drank today public property (readonly)
    var currentAmountOfWaterDrankToday :Float {
        set{}
        get {
            return _currentAmountOfWaterDrankToday
        }
    }
    
        /// Line width for the 2 overlapping circles in the gauge
    private let _circleLineWidth :CGFloat = 20

        /// Center label displaying the amount of water that the user drank
    private let _currentAmountOfWaterDrankTodayLabel = UILabel()
    
        /// Shape layer that displays in a circle form how much water the user drank
    private let _innerCircleShapeLayer = CAShapeLayer()
    
    //MARK: - View Layout
    
    /**
     Makes the background always transparent
     */
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundColor = UIColor.clearColor()
    }
    
    /**
     Sets the goal from NSUserDefaults and sets up properties for subviews
     */
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        _goal = NSUserDefaults.standardUserDefaults().floatForKey("GoalValue")
        
        setupOuterCircle()
        setupInnerCircleShapeLayer()
        setupLabel()
    }
    
    /**
     Setup for the outer circle that is always displaying to show how much water is needed to drink before reaching goal. Setup using a border
     */
    private func setupOuterCircle() {
        layer.cornerRadius = bounds.width / 2
        layer.borderWidth = _circleLineWidth
        layer.borderColor = UIColor(white: 1, alpha: 0.2).CGColor
    }
    
    /**
     Sets up the inner circle path that will represent how much water was drank today. Starts at 0
     */
    private func setupInnerCircleShapeLayer() {
        let rect = CGRectInset(bounds, _circleLineWidth / 2, _circleLineWidth / 2) //Rect is a CGRect that accounts for the fact that the inner circle line width will display partially outside of the view. This rect brings it in to match with the outer circle

        let innerCirclePath = UIBezierPath(ovalInRect: rect) //Circle path

        _innerCircleShapeLayer.path = innerCirclePath.CGPath
        
        _innerCircleShapeLayer.frame = bounds
        
        _innerCircleShapeLayer.strokeStart = 0 //Starting point
        _innerCircleShapeLayer.strokeEnd = 0 //Default ending point. Can be changed with changeCurrentAmountOfWaterDrankToday
        _innerCircleShapeLayer.strokeColor = UIColor.whiteColor().CGColor //Color of border
        _innerCircleShapeLayer.fillColor = UIColor.clearColor().CGColor //Color of fill
        _innerCircleShapeLayer.lineWidth = _circleLineWidth //Size of the border width
        _innerCircleShapeLayer.lineCap = kCALineCapRound //Rounds out the edges
        
        _innerCircleShapeLayer.transform = CATransform3DMakeRotation(degreesToRadians(270), 0, 0, 1.0) //Rotation used to get the starting point at the top center and turn clockwise
        
        layer.addSublayer(_innerCircleShapeLayer)
    }
    
    /**
     Helper function to convert degrees to radians
     
     - parameter degrees: Degrees value to convert
     
     - returns: Radian value converted from degrees
     */
    private func degreesToRadians(degrees :CGFloat) -> CGFloat {
        return degrees * CGFloat(M_PI)/180
    }
    
    
    /**
     Sets up the properties for the center label
     */
    private func setupLabel() {
        addSubview(_currentAmountOfWaterDrankTodayLabel)
        
        _currentAmountOfWaterDrankTodayLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: _currentAmountOfWaterDrankTodayLabel, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: _currentAmountOfWaterDrankTodayLabel, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: _currentAmountOfWaterDrankTodayLabel, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: _currentAmountOfWaterDrankTodayLabel, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0))
        
        _currentAmountOfWaterDrankTodayLabel.font = StandardFonts.regularFont(80)
        _currentAmountOfWaterDrankTodayLabel.textColor = UIColor.whiteColor()
        _currentAmountOfWaterDrankTodayLabel.text = String(0) + "ml"
        _currentAmountOfWaterDrankTodayLabel.textAlignment = .Center
    }
    
    //MARK: - Public
    
    /**
     Changes the value for the amount of water drank
     
     - parameter newValue: New value to represent towards goal
     - parameter animated: Should the dial gauge animate on change
     */
    func changeCurrentAmountOfWaterDrankToday(newValue :Float, animated :Bool) {
        _currentAmountOfWaterDrankTodayLabel.text = String(Int(newValue)) + "ml"
        _currentAmountOfWaterDrankToday = newValue
        
        var animationTime = 0.0
        
        if animated {
            animationTime = 0.5
        }
        
        //Animation of the gauge circle
        let previousStrokeEnd = _innerCircleShapeLayer.strokeEnd
        let newStrokeEnd = _currentAmountOfWaterDrankToday / _goal
        _innerCircleShapeLayer.strokeEnd = CGFloat(newStrokeEnd)

        let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeAnimation.fromValue = previousStrokeEnd
        strokeAnimation.toValue = newStrokeEnd
        strokeAnimation.duration = animationTime
        strokeAnimation.removedOnCompletion = false
        
        self._innerCircleShapeLayer.addAnimation(strokeAnimation, forKey: "strokeEnd")
    }
}
