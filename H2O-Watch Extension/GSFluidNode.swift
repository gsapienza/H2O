//
//  GSFluidNode.swift
//  H2O
//
//  Created by Gregory Sapienza on 9/14/16.
//  Copyright © 2016 City Pixels. All rights reserved.
//

import SpriteKit

class GSFluidNode: SKSpriteNode, GSFluidLayoutProtocol {

    typealias Liquid = SKShapeNode
    typealias WaveMovementAnimation = SKAction
    
    var liquidLayer :Liquid! = Liquid()
    var waveMovementAnimation :WaveMovementAnimation!
    var fluidLayout :GSFluidLayout!
    var liquidFillColor = UIColor() {
        didSet {
            liquidLayer.fillColor = liquidFillColor
        }
    }
    var phaseShiftDuration :Double = 1.2 {
        didSet {
            startWaveAnimation()
        }
    }
    
    /// Paths that will contain all of the animatable CGPaths for the liquid to animate through.
    var paths :CFMutableArray = CFArrayCreateMutable(kCFAllocatorDefault, 0, [kCFTypeArrayCallBacks])
    
    func layout() {
        yScale = -1 //Flip the coordinates otherwise the paths will render upside down due to SpriteKit rendering coordinates reverse of UIKit.
        setupLiquid()
        
        let liquidLayerWidth = frame.width * 3 //Set to 3 times the width of the view because the liquid layer will later be horizontally animating. When that animation takes place, the liquid layer x value is sent backwards. Setting the frame to be larger than the view will ensure that it stays on screen

        fluidLayout = GSFluidLayout(frame: frame, fluidWidth: liquidLayerWidth, fillDuration: 3, amplitudeIncrement: 1, maxAmplitude: 15, minAmplitude: 5, numberOfWaves: 2)
        
        startWaveAnimation() //Starts wave movement and horizontally animates the liquid layer
    }
    
    private func setupLiquid() {
        liquidLayer.strokeColor = UIColor.clear
        
        addChild(liquidLayer)
    }
    
    func fillTo(_ fillPercentage: inout Float) {
        if fillPercentage > 1.0 { //Ensures a max of 1 is used as the value
            fillPercentage = 1.0
        }
        
        let fillDifference = fabs(fillPercentage - fluidLayout.fillLevel) //Difference in the new percentage to the current fill level
        
        if fillDifference == 0 { //If fill is the same as before then do nothing
            return
        }
        
        fluidLayout.fillLevel = fillPercentage
        
        let finalRatioYPosition = frame.height - (frame.height * CGFloat((1.02 - fillPercentage))) //Final Y value to fill to based on percentage. 1.02 is chosen instead of 1 to make it so that the waves can be seen even if the fill percentage is 1 and full
        
        let positionDuration = fluidLayout.fillDuration * Double(fillDifference) //Duration calculated from fill duration that can be configured multiplied by the fill difference to give a nice effect.
        let positionAction = SKAction.moveTo(y: -finalRatioYPosition, duration: positionDuration) //Negated finalRatioYPosition because of flipped coordinates.
        liquidLayer.run(positionAction)
    }
    
    func startWaveAnimation() {
        let leftMostXValue = liquidLayer.position.x - frame.width //Initial animation state for horizontal movement, setting the x position back
        let finalXValue = liquidLayer.position.x //Second animation state to send the animation forward to its normal x coordinate
        
        let initialXAction = SKAction.moveTo(x: leftMostXValue, duration: 0)
        let finalXAction = SKAction.moveTo(x: finalXValue, duration: phaseShiftDuration)
        
        let sequenceActions = SKAction.sequence([initialXAction, finalXAction])
        waveMovementAnimation = SKAction.repeatForever(sequenceActions)
        
        liquidLayer.run(waveMovementAnimation)
        
        let waveMovementAnimationDuration = 0.07 //Duration of amplitude changes
        
        //Timer is set to repeat wave animation forever. This is done instead of repeating SKAction because we need a new set of values everytime the animation runs, setting it to repeat would just repeat the same animation with the same exact amplitude values as before
        let waveMovementTimer = Timer(timeInterval: waveMovementAnimationDuration, target: self, selector: #selector(updateWaveAnimation), userInfo: nil, repeats: true)
        RunLoop.current.add(waveMovementTimer, forMode: RunLoopMode.commonModes)
    }
    
    func updateWaveAnimation() {
        let newPaths = fluidLayout.getNewAmplitudeValues() //Get a new array of paths.
        let newPathsCFArray = newPaths as CFArray //Cast new paths to be a CFArray.
        let range = CFRange(location: 0, length: newPaths.count) //Range to add new array to old one.
        CFArrayAppendArray(paths, newPathsCFArray, range) //Add new array of paths to the instance paths array.
        
        let array :[AnyObject] = self.paths as [AnyObject] //Cast the CFArray to a collection array (I don't know why but it crashes on the next line if we use a CFArray.
        self.liquidLayer.path = (array[0] as! CGPath)//CFArrayGetValueAtIndex(self.paths, 0) as! CGPath?
        CFArrayRemoveValueAtIndex(self.paths, 0) //Remove the first value in the array once we've used it.
    }
}
