//
//  GSFluidView.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/29/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

class GSFluidView: UIView {
    
    //MARK: - Liquid Layer Properties
    
    /// Main layer of liquid that has the waves and pretty much all movements
    private var liquidLayer = CAShapeLayer()
    
    /// Lavel of vertical fill from 0 to 1
    private var fillLevel :Float = 0.0
    
    /// Fill Color of Fluid
    var fillColor = UIColor() {
        didSet {
            liquidLayer.fillColor = fillColor.CGColor
        }
    }
    
    /// Duration of fill of fluid
    var fillDuration = 7.0
    
    //MARK: - Wave Properties
    
    /// Random interval between max and min
    var amplitudeIncrement = 5
    
    /// Maximum wave height
    var maxAmplitude = 40

    /// Minimum wave height
    var minAmplitude = 5

    /// Array of possible amplitude values
    private var amplitudeArray :[Int] = []
    
    /// The initial amplitude set. When the amplitude values change for the liquid view during animation the startingAmplitude becomes the last value set so that the next time it animates it can once again be the initial amplitude
    private var startingAmplitude = 0
    
    /// Keyframe animation that control the wave amplitude animation on the liquid layer. NOT THE HORIZONTAL MOVEMENT
    private var waveMovementAnimation :CAKeyframeAnimation?
    
    var rootView :UIView {
        set {}
        get {
            return (window?.subviews.first!)!
        }
    }
    
    //MARK: - Setup
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //Initial amplitude values created by using the min amplitude and moving to the max amplitude by the time of the increment of the wave
        for i in minAmplitude.stride(to: maxAmplitude, by: amplitudeIncrement) {
            amplitudeArray.append(i)
        }
        
        setupLiquid()
    }
    
    private func setupLiquid() {
        liquidLayer.anchorPoint = CGPointMake(0, 0)
        
        let liquidLayerWidth = bounds.width * 3 //Set to 3 times the width of the view because the liquid layer will later be horizontally animating. When that animation takes place, the liquid layer x value is sent backwards. Setting the bounds to be larger than the view will ensure that it stays on screen
        
        liquidLayer.frame = CGRectMake(0, frame.height, liquidLayerWidth, frame.height) //Y value is at the the bottom so it can be animated up later in setFillValue
        
        layer.addSublayer(liquidLayer)
        startWaveAnimation() //Starts wave movement and horizontally animates the liquid layer
    }
    
    //MARK: - Public
    
    /**
     Vertically fills liquid to percentage from 0 to 1.
     
     - parameter fillPercentage: 0 to 1 value
     */
    func fillTo(inout fillPercentage :Float) {
        if fillPercentage > 1.0 { //Ensures a max of 1 is used as the value
            fillPercentage = 1.0
        }
        
        let fillDifference = fabs(fillPercentage - fillLevel) //Difference in the new percentage to the current fill level
        
        if fillDifference == 0 { //If fill is the same as before then do nothing
            return
        }
        
        fillLevel = fillPercentage //Set ivar to the latest fill percentage
        
        let finalRatioYPosition = CGFloat((1.02 - fillPercentage)) * liquidLayer.frame.height //Final Y value to fill to based on percentage. 1.02 is chosen instead of 1 to make it so that the waves can be seen even if the fill percentage is 1 and full
        
        let liquidPresentationLayer = liquidLayer.presentationLayer() //Liquid presentation layer. Presentation layer will give more accurate value to the current state of the liquid layer so we will animate this
        
        /// Vertical animation setup
        let verticalFillAnimation = CAKeyframeAnimation(keyPath: "position.y")
        verticalFillAnimation.values = [(liquidPresentationLayer?.position.y)!, finalRatioYPosition]
        verticalFillAnimation.duration = fillDuration * Double(fillDifference) //Duration calculated from fill duration that can be configured multiplied by the fill difference to give a nice effect
        verticalFillAnimation.removedOnCompletion = false
        verticalFillAnimation.fillMode = kCAFillModeForwards
        liquidLayer.addAnimation(verticalFillAnimation, forKey: "position.y")
    }
    
    //MARK: - Liquid Waves
    
    /**
     Uses 2 animations to control the waves. The first one is the phase shift which essentially moves the liquid x position horizontally to look like the waves are moving in a single direction. The other animation is the one that actually controls the wave shapes using path animations
     */
    private func startWaveAnimation() {
        if waveMovementAnimation == nil { //Only create this animation if it hasnt been created before
            //startingAmplitude = maxAmplitude
            
            //Phase shift animation to move the wave in a direction horizontally
            let phaseShiftAnimation = CAKeyframeAnimation(keyPath: "position.x")
            
            let leftMostXValue = liquidLayer.position.x - bounds.width //Initial animation state for horizontal movement, setting the x position back
            let finalXValue = liquidLayer.position.x //Second animation state to send the animation forward to its normal x coordinate
            
            phaseShiftAnimation.values = [leftMostXValue, finalXValue]
            phaseShiftAnimation.duration = 0.75
            phaseShiftAnimation.repeatCount = HUGE //Repeat forever
            phaseShiftAnimation.removedOnCompletion = false
            phaseShiftAnimation.fillMode = kCAFillModeForwards
            liquidLayer.addAnimation(phaseShiftAnimation, forKey: "position.x")
            
            /// Wave amplitude animation
            let waveMovementAnimationDuration = 0.5 //Duration of amplitude changes
            
            waveMovementAnimation = CAKeyframeAnimation(keyPath: "path")
            waveMovementAnimation!.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)]
            waveMovementAnimation!.values = getNewAmplitudeValues() //Gets random amplitude values to animate with. Returns an array of CGPaths
            waveMovementAnimation!.duration = waveMovementAnimationDuration
            waveMovementAnimation!.removedOnCompletion = false
            waveMovementAnimation!.fillMode = kCAFillModeForwards
            
            //Timer is set to repeat wave animation forever. This is done instead of repeat count because we need a new set of values everytime the animation runs, setting it to repeat would just repeat the same animation with the same exact amplitude values as before
            let waveMovementTimer = NSTimer(timeInterval: waveMovementAnimationDuration, target: self, selector: #selector(GSFluidView.updateWaveAnimation), userInfo: nil, repeats: true)
            NSRunLoop.currentRunLoop().addTimer(waveMovementTimer, forMode: NSRunLoopCommonModes)
        }
    }
    
    /**
     Called by timer to regenerate the wave animation using new amplitude values
     */
    internal func updateWaveAnimation() {
        liquidLayer.removeAnimationForKey("path") //Remove the last animation
        waveMovementAnimation!.values = getNewAmplitudeValues() //Set the new values to the wave animation
        liquidLayer.addAnimation(waveMovementAnimation!, forKey: "path") //New animation with new values
    }
    
    /**
     Generates amplitude values randomly from amplitude array values
     
     - returns: Array of paths to generate wave amplitude animation
     */
    private func getNewAmplitudeValues() -> [CGPath] {
        
        /**
         Calculates wave path. These paths essentially makes up the entire liquid layer from top to bottom
         
         - parameter randomAmplitudeValue: Random value generated from the amplitudeArray
         - parameter amplitudeIncrement:   Increment to move amplitude value (used as a way to determine a negative or positive direction)
         
         - returns: Array of paths that meet the starting amplitude to the random amplitude value
         */
        func getPaths(randomAmplitudeValue :Int, amplitudeIncrement :Int) -> [CGPath] {
            let startPoint = CGPointMake(0, 0) //Start point for the liquid path. Top left
            
            var paths :[CGPath] = [] //Paths to return
            
            /**
             Computes the correct for loop depending if the amplitudeIncrement is positive or negative
             
             - parameter pathComputation: Computation of path to go in for loop
             */
            func strideToRandomAmplitudeValue(pathComputation : (j :Int) -> Void) {
                //For loops create incremental paths based on how far the last amplitudeValue was from the new one. For example, a previous amplitude of 5 and a random value of 20 will give us 4 new paths
                if amplitudeIncrement < 0 { //If increment is negative
                    for j in startingAmplitude.stride(through: randomAmplitudeValue, by: amplitudeIncrement) { //Move backwards
                        pathComputation(j: j) //Get a single path
                    }
                } else { //If increment is positive
                    for j in startingAmplitude.stride(to: randomAmplitudeValue, by: amplitudeIncrement) { //Move forwards
                        pathComputation(j: j) //Get a single path
                    }
                }
            }
            
            //Computation of single path happens here. J is just the amplitude essentially how high or low to go on the wave
            strideToRandomAmplitudeValue { (j) in
                let line = UIBezierPath() //Liquid path
                
                line.moveToPoint(startPoint) //Top left
                
                var temporaryAmplitude = CGFloat(j) //Amplitude value in between startingAmplitude and randomAmplitude value
                
                let dividingWave = self.bounds.width / 2 //This controls how many waves will be in the view. The liquidView width divided by the dividingWave equals how many waves exist. In this case it will be 6 because we made the width of the liquid view to be the width of this view multiplied by 3. Dividing that value by 2 would equal 6.
                
                for i in Int(dividingWave).stride(to: Int(self.liquidLayer.bounds.width), by: Int(dividingWave)) { //Number of waves in view
                    
                    let quadEndPoint = CGPointMake(startPoint.x + CGFloat(i), startPoint.y) //Move to x value on top of liquid
                    
                    let controlPoint = CGPointMake(startPoint.x + CGFloat(i) - (dividingWave / 2), startPoint.y + temporaryAmplitude) //Dip in the middle of the iteration of the number of wave. This control point is where the wave will essentially go
                    
                    line.addQuadCurveToPoint(quadEndPoint, controlPoint: controlPoint) //Add rounded curve on top of liquid (basically a point to make up a wave)
                    
                    temporaryAmplitude = -temporaryAmplitude //Inverses amplitude to simply go up or down depending on the last animations (essentially making a complete wave)
                }
                
                line.addLineToPoint(CGPointMake(self.liquidLayer.bounds.width, self.frame.height + CGFloat(self.maxAmplitude))) //Bottom right corner
                
                line.addLineToPoint(CGPointMake(0, self.frame.height + CGFloat(self.maxAmplitude))) //Bottom left corner
                
                line.closePath() //Close path right back up to the top left and now we have a liquid path!
                
                paths.append(line.CGPath) //Add this path to the paths to return
            }
            
            return paths
        }
        
        //Start here
       
        let unsignedAmplitudeCount = uint_fast32_t(amplitudeArray.count) //Unsigned count int of the amplitudeOfArray so it can be used to get a random index
        let randomIndex = arc4random_uniform(unsignedAmplitudeCount) //Random index from amplitude array
        let randomAmplitudeValue = amplitudeArray[Int(randomIndex)] //Random amplitude value from index
        
        var newAmplitudeValues :[CGPath] = [] //Array of amplitude values to return
        
        var paths :[CGPath] = [] //Empty array of paths to return
        if startingAmplitude >= randomAmplitudeValue { //If the new value is smaller or equal to the last one
            paths = getPaths(randomAmplitudeValue, amplitudeIncrement: -amplitudeIncrement) //Get paths with random amplitude being less than the last amplitude (startingAmplitude) therefore having to go backwards to meet it
        } else {
            paths = getPaths(randomAmplitudeValue, amplitudeIncrement: amplitudeIncrement) //Get paths with random amplitude being greater than the last amplitude (startingAmplitude) therefore having to go forwards to meet it
        }
        
        newAmplitudeValues.appendContentsOf(paths) //Add paths to array
        
        startingAmplitude = randomAmplitudeValue //Starting amplitude has now become the last amplitude selected so that it can increment again once this method is called again
        
        return newAmplitudeValues
    }
}
