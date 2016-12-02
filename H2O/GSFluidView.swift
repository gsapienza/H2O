//
//  GSFluidView.swift
//  H2O
//
//  Created by Gregory Sapienza on 9/12/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

class GSFluidView: UIView, GSFluidLayoutProtocol {
    typealias Liquid = CAShapeLayer
    typealias WaveMovementAnimation = CAKeyframeAnimation
    
    var liquidLayer :Liquid! = Liquid()
    var waveMovementAnimation :WaveMovementAnimation!
    var fluidLayout :GSFluidLayout!
    var liquidFillColor = UIColor() {
        didSet {
            liquidLayer.fillColor = liquidFillColor.cgColor
        }
    }
    var phaseShiftDuration :Double = 0.9 {
        didSet {
            startWaveAnimation()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    func layout() {
        setupLiquid()
        
        if fluidLayout == nil {
            fluidLayout = GSFluidLayout(frame: frame, fluidWidth: liquidLayer.bounds.width, fillDuration: 3, amplitudeIncrement: 1, maxAmplitude: 40, minAmplitude: 5, numberOfWaves: 2)
        }
        
        startWaveAnimation() //Starts wave movement and horizontally animates the liquid layer
    }
    
    private func setupLiquid() {
        liquidLayer.masksToBounds = false
        liquidLayer.anchorPoint = CGPoint(x: 0, y: 0)
        
        let liquidLayerWidth = bounds.width * 3 //Set to 3 times the width of the view because the liquid layer will later be horizontally animating. When that animation takes place, the liquid layer x value is sent backwards. Setting the bounds to be larger than the view will ensure that it stays on screen
        
        liquidLayer.frame = CGRect(x: 0, y: frame.height, width: liquidLayerWidth, height: frame.height) //Y value is at the the bottom so it can be animated up later in setFillValue
        
        layer.addSublayer(liquidLayer)
    }
    
    func fillTo(_ fillPercentage :inout Float) {
        if fillPercentage > 1.0 { //Ensures a max of 1 is used as the value
            fillPercentage = 1.0
        }

        let fillDifference = fabs(fillPercentage - fluidLayout.fillLevel) //Difference in the new percentage to the current fill level
        
        if fillDifference == 0 { //If fill is the same as before then do nothing
            return
        }
        
        fluidLayout.fillLevel = fillPercentage
        
        let finalRatioYPosition = CGFloat((1.02 - fillPercentage)) * frame.height //Final Y value to fill to based on percentage. 1.02 is chosen instead of 1 to make it so that the waves can be seen even if the fill percentage is 1 and full
        
        var values :[CGFloat] = []
        
        if let liquidPresentationLayer = liquidLayer.presentation() { //Liquid presentation layer. Presentation layer will give more accurate value to the current state of the liquid layer so we will animate this
            values = [liquidPresentationLayer.position.y, finalRatioYPosition]
        } else {
            values = [frame.height, finalRatioYPosition]
            print("Liquid presentation layer is nil.")
        }
        
        /// Vertical animation setup
        let verticalFillAnimation = CAKeyframeAnimation(keyPath: "position.y")
        verticalFillAnimation.values = values
        verticalFillAnimation.duration = fluidLayout.fillDuration * Double(fillDifference) //Duration calculated from fill duration that can be configured multiplied by the fill difference to give a nice effect
        verticalFillAnimation.isRemovedOnCompletion = false
        verticalFillAnimation.fillMode = kCAFillModeForwards
        liquidLayer.add(verticalFillAnimation, forKey: "position.y")
    }

    func startWaveAnimation() {
        liquidLayer.removeAnimation(forKey: "position.x")
        
        //Phase shift animation to move the wave in a direction horizontally
        let phaseShiftAnimation = CAKeyframeAnimation(keyPath: "position.x")
        
        let leftMostXValue = liquidLayer.position.x - bounds.width //Initial animation state for horizontal movement, setting the x position back
        let finalXValue = liquidLayer.position.x //Second animation state to send the animation forward to its normal x coordinate
        
        phaseShiftAnimation.values = [leftMostXValue, finalXValue]
        phaseShiftAnimation.duration = phaseShiftDuration
        phaseShiftAnimation.repeatCount = HUGE //Repeat forever
        phaseShiftAnimation.isRemovedOnCompletion = false
        phaseShiftAnimation.fillMode = kCAFillModeForwards
        liquidLayer.add(phaseShiftAnimation, forKey: "position.x")
        
        if waveMovementAnimation == nil { //Only create this animation if it hasnt been created before
            //startingAmplitude = maxAmplitude
            
            /// Wave amplitude animation
            let waveMovementAnimationDuration = 0.7 //Duration of amplitude changes
            
            waveMovementAnimation = CAKeyframeAnimation(keyPath: "path")
            waveMovementAnimation!.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)]
            waveMovementAnimation!.values = fluidLayout.getNewAmplitudeValues() //Gets random amplitude values to animate with. Returns an array of CGPaths
            waveMovementAnimation!.duration = waveMovementAnimationDuration
            waveMovementAnimation!.isRemovedOnCompletion = false
            waveMovementAnimation!.fillMode = kCAFillModeBoth
            liquidLayer.add(waveMovementAnimation!, forKey: "path")
            
            //Timer is set to repeat wave animation forever. This is done instead of repeat count because we need a new set of values everytime the animation runs, setting it to repeat would just repeat the same animation with the same exact amplitude values as before
            let waveMovementTimer = Timer(timeInterval: waveMovementAnimationDuration, target: self, selector: #selector(GSFluidView.updateWaveAnimation), userInfo: nil, repeats: true)
            RunLoop.current.add(waveMovementTimer, forMode: RunLoopMode.commonModes)
        }
    }
    
    func updateWaveAnimation() {
        liquidLayer.removeAnimation(forKey: "path") //Remove the last animation
        waveMovementAnimation!.values = fluidLayout.getNewAmplitudeValues() //Set the new values to the wave animation
        liquidLayer.add(waveMovementAnimation!, forKey: "path") //New animation with new values
    }
}
