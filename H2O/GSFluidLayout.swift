//
//  GSFluidView.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/29/16.
//  Copyright © 2016 City Pixels. All rights reserved.
//

import SpriteKit

struct GSFluidLayout {
    
    //MARK: - Public iVars
    
    /// Frame where fluid resides in
    let frame :CGRect!
    
    /// Width of the fluid
    let fluidWidth :CGFloat!
    
    /// Duration of fill of fluid
    let fillDuration :Double!
        
    /// Random interval between max and min
    let amplitudeIncrement :Int!
    
    /// Maximum wave height
    let maxAmplitude :Int!

    /// Minimum wave height
    let minAmplitude :Int!
    
    /// Number of amplitude wave paths that can be creates when getting new amplitude values
    let numberOfWaves :Int!
    
    /// The initial amplitude set. When the amplitude values change for the liquid view during animation the startingAmplitude becomes the last value set so that the next time it animates it can once again be the initial amplitude
    private var startingAmplitude :Int = 0
    
    /// Lavel of vertical fill from 0 to 1
    var fillLevel :Float = 0
    
    //MARK: - Private iVars
    
    /// Array of possible amplitude values
    private var amplitudeArray :[Int] = []
    
    //MARK: - Setup
    
    init(frame :CGRect, fluidWidth :CGFloat, fillDuration :Double, amplitudeIncrement :Int, maxAmplitude :Int, minAmplitude :Int, numberOfWaves :Int) {
        self.frame = frame
        self.fluidWidth = fluidWidth
        self.fillDuration = fillDuration
        self.amplitudeIncrement = amplitudeIncrement
        self.maxAmplitude = maxAmplitude
        self.minAmplitude = minAmplitude
        self.numberOfWaves = numberOfWaves
        
        updateAmplitudeArray()
    }
    
    //MARK: - Private
    
    /// Set the amplitude array with values ranging from min amplitude to max amplitude
    private mutating func updateAmplitudeArray() {
        //Initial amplitude values created by using the min amplitude and moving to the max amplitude by the time of the increment of the wave
        amplitudeArray = []
        for i in stride(from: minAmplitude, to: maxAmplitude, by: amplitudeIncrement) {
            amplitudeArray.append(i)
        }
    }
    
    //MARK: - Public
    
    /**
     Generates amplitude values randomly from amplitude array values
     
     - returns: Array of paths to generate wave amplitude animation
     */
    mutating func getNewAmplitudeValues() -> [CGPath] {
        
        /**
         Calculates wave path. These paths essentially makes up the entire liquid layer from top to bottom
         
         - parameter randomAmplitudeValue: Random value generated from the amplitudeArray
         - parameter amplitudeIncrement:   Increment to move amplitude value (used as a way to determine a negative or positive direction)
         
         - returns: Array of paths that meet the starting amplitude to the random amplitude value
         */
        func getPaths(_ randomAmplitudeValue :Int, amplitudeIncrement :Int) -> [CGPath] {
            let startPoint = CGPoint(x: 0, y: 0) //Start point for the liquid path. Top left
            
            var paths :[CGPath] = [] //Paths to return
            
            /**
             Computes the correct for loop depending if the amplitudeIncrement is positive or negative
             
             - parameter pathComputation: Computation of path to go in for loop
             */
            func strideToRandomAmplitudeValue(_ pathComputation : (_ j :Int) -> Void) {
                //For loops create incremental paths based on how far the last amplitudeValue was from the new one. For example, a previous amplitude of 5 and a random value of 20 will give us 4 new paths
                if amplitudeIncrement < 0 { //If increment is negative
                    for j in stride(from: startingAmplitude, through: randomAmplitudeValue, by: amplitudeIncrement) { //Move backwards
                        pathComputation(j) //Get a single path
                    }
                } else { //If increment is positive
                    for j in stride(from :startingAmplitude, to: randomAmplitudeValue, by: amplitudeIncrement) { //Move forwards
                        pathComputation(j) //Get a single path
                    }
                }
            }
            
            //Computation of single path happens here. J is just the amplitude essentially how high or low to go on the wave
            strideToRandomAmplitudeValue { (j) in
                let line = UIBezierPath() //Liquid path
                
                line.move(to: startPoint) //Top left
                
                var temporaryAmplitude = CGFloat(j) //Amplitude value in between startingAmplitude and randomAmplitude value
                
                let dividingWave = frame.width / CGFloat(numberOfWaves) //This controls how many waves will be in the view. The liquidView width divided by the dividingWave equals how many waves exist. In this case it will be 6 because we made the width of the liquid view to be the width of this view multiplied by 3. Dividing that value by 2 would equal 6.
                
                for i in stride(from: Int(dividingWave), to: Int(fluidWidth), by: Int(dividingWave)) { //Number of waves in view
                    
                    let quadEndPoint = CGPoint(x: startPoint.x + CGFloat(i), y: startPoint.y) //Move to x value on top of liquid
                    
                    let controlPoint = CGPoint(x: startPoint.x + CGFloat(i) - (dividingWave / 2), y: startPoint.y + temporaryAmplitude) //Dip in the middle of the iteration of the number of wave. This control point is where the wave will essentially go
                    
                    line.addQuadCurve(to: quadEndPoint, controlPoint: controlPoint) //Add rounded curve on top of liquid (basically a point to make up a wave)
                    
                    temporaryAmplitude = -temporaryAmplitude //Inverses amplitude to simply go up or down depending on the last animations (essentially making a complete wave)
                }
                
                line.addLine(to: CGPoint(x: fluidWidth, y: frame.height + CGFloat(self.maxAmplitude))) //Bottom right corner
                
                line.addLine(to: CGPoint(x: 0, y: frame.height + CGFloat(self.maxAmplitude))) //Bottom left corner
                
                line.close() //Close path right back up to the top left and now we have a liquid path!
                
                paths.append(line.cgPath) //Add this path to the paths to return
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
        
        newAmplitudeValues.append(contentsOf: paths) //Add paths to array
        
        startingAmplitude = randomAmplitudeValue //Starting amplitude has now become the last amplitude selected so that it can increment again once this method is called again
        
        return newAmplitudeValues
    }
}
