//
//  DailyEntryDial.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/16/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

protocol DailyEntryDialProtocol {
    /**
     Determines the amount of water drank today
     
     - returns: Float value of water drank today
     */
    func getAmountOfWaterEnteredToday() -> Float
    
    /**
     Determines the user set goal from NSUserDefaults
     
     - returns: Goal float value set by user
     */
    func getGoal() -> Float
    
    /**
     Called when the user has tapped this view like a button
     */
    func dialButtonTapped()
}

class DailyEntryDial: UIView {
        /// Goal instance var, is loaded through NSUserDefaults and contains daily water goal
    var _goal :Float {
        set{}
        get {
            return _delegate!.getGoal()
        }
    }
    
        /// Current amount of water that the user drank today public property (readonly)
    var currentAmountOfWaterDrankToday :Float {
        set{}
        get {
            return (_delegate?.getAmountOfWaterEnteredToday())!
        }
    }
    
        /// Line width for the 2 overlapping circles in the gauge
    private let _circleLineWidth :CGFloat = 20

        /// Center label displaying the amount of water that the user drank
    private let _currentAmountOfWaterDrankTodayLabel = UILabel()
    
    /// Shape layer that displays in a circle form how much water the user drank
    private let _outerCircleShapeLayer = CAShapeLayer()
    
        /// Shape layer that displays in a circle form how much water the user drank
    private let _innerCircleShapeLayer = CAShapeLayer()
    
    private let _dialButton = UIButton()
    
    var _delegate :DailyEntryDialProtocol?
    
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
                
        setupOuterCirclePath()
        setupInnerCircleShapeLayer()
        setupLabel()
        setupDialButton()
        
        updateAmountOfWaterDrankToday(false)
    }
    
    /**
     Setup for the outer circle that is always displaying to show how much water is needed to drink before reaching goal. Setup using a border
     */
    private func setupOuterCirclePath() {
        let rect = CGRectInset(bounds, _circleLineWidth / 2, _circleLineWidth / 2) //Rect is a CGRect that accounts for the fact that the inner circle line width will display partially outside of the view. This rect brings it in to match with the outer circle
        
        let outerCirclePath = UIBezierPath(ovalInRect: rect) //Circle path
        
        _outerCircleShapeLayer.path = outerCirclePath.CGPath
        
        _outerCircleShapeLayer.frame = bounds
        
        _outerCircleShapeLayer.strokeColor = StandardColors.standardSecondaryColor.colorWithAlphaComponent(0.6).CGColor //Color of border
        _outerCircleShapeLayer.fillColor = UIColor.clearColor().CGColor //Color of fill
        _outerCircleShapeLayer.lineWidth = _circleLineWidth //Size of the border width
        
        layer.addSublayer(_outerCircleShapeLayer)
    }
    
    /**
     Sets up the inner circle path that will represent how much water was drank today. Starts at 0
     */
    private func setupInnerCircleShapeLayer() {
        let rect = CGRectInset(bounds, _circleLineWidth / 2, _circleLineWidth / 2) //Rect is a CGRect that accounts for the fact that the inner circle line width will display partially outside of the view. This rect brings it in to match with the outer circle

        let innerCirclePath = UIBezierPath(ovalInRect: rect) //Circle path

        _innerCircleShapeLayer.path = innerCirclePath.CGPath
        
        _innerCircleShapeLayer.frame = bounds
        
        _innerCircleShapeLayer.strokeColor = StandardColors.primaryColor.CGColor //Color of border
        _innerCircleShapeLayer.fillColor = UIColor.clearColor().CGColor //Color of fill
        _innerCircleShapeLayer.lineWidth = _circleLineWidth //Size of the border width
        //_innerCircleShapeLayer.lineCap = kCALineCapRound //Rounds out the edges
        
        _innerCircleShapeLayer.transform = CATransform3DMakeRotation(degreesToRadians(270), 0, 0, 1.0) //Rotation used to get the starting point at the top center and turn clockwise
        
        layer.addSublayer(_innerCircleShapeLayer)
    }
    
    private func setupDialButton() {
        addSubview(_dialButton)
        
        _dialButton.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: _dialButton, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: _dialButton, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: _dialButton, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: _dialButton, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0))
        
        _dialButton.backgroundColor = UIColor.clearColor()
        _dialButton.titleLabel?.text = ""
        _dialButton.addTarget(self, action: #selector(DailyEntryDial.onDialButton), forControlEvents: .TouchUpInside)
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
        
        _currentAmountOfWaterDrankTodayLabel.font = StandardFonts.thinFont(80)
        _currentAmountOfWaterDrankTodayLabel.textColor = StandardColors.primaryColor
        _currentAmountOfWaterDrankTodayLabel.textAlignment = .Center
    }
    
    //MARK: - Actions
    func onDialButton() {
        UIView.animateWithDuration(0.1, delay: 0, options: .CurveEaseIn, animations: {
            self.transform = CGAffineTransformMakeScale(0.8, 0.8)
        }) { (Bool) in
            self._delegate?.dialButtonTapped()

            UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: .CurveEaseIn, animations: {
                self.transform = CGAffineTransformIdentity
                }, completion: { (Bool) in
            })
        }
    }
    
    //MARK: - Public
    
    /**
     Changes the value for the amount of water drank
     
     - parameter animated: Should the dial gauge animate on change
     */
    func updateAmountOfWaterDrankToday(animated :Bool) {
        _currentAmountOfWaterDrankTodayLabel.text = String(Int(currentAmountOfWaterDrankToday)) + Constants.standardUnit.rawValue
        
        let newStrokeEnd = currentAmountOfWaterDrankToday / _goal
        
        if animated {
            let animationTime = 0.5
            
            //Animation of the gauge circle
            let previousStrokeEnd = _innerCircleShapeLayer.strokeEnd
            _innerCircleShapeLayer.strokeEnd = CGFloat(newStrokeEnd)
            
            let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
            strokeAnimation.fromValue = previousStrokeEnd
            strokeAnimation.toValue = newStrokeEnd
            strokeAnimation.duration = animationTime
            strokeAnimation.removedOnCompletion = false
            
            _innerCircleShapeLayer.addAnimation(strokeAnimation, forKey: "strokeEnd")
        } else {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            _innerCircleShapeLayer.strokeEnd = CGFloat(newStrokeEnd)
            CATransaction.commit()
        }
    }
}
