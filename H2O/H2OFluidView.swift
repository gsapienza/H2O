//
//  H2OFluidView.swift
//  H2O
//
//  Created by Gregory Sapienza on 9/5/16.
//  Copyright © 2016 City Pixels. All rights reserved.
//

import UIKit

protocol H2OFluidViewProtocol {
    
    /// Gets fluid view as its animating
    ///
    /// - parameter fluidView: Layer animating
    func fluidViewLayerDidUpdate(fluidView: GSAnimatingProgressLayer)
}

class H2OFluidView: GSFluidView {
    
    //MARK: - Public iVars
    
    override var liquidLayer: Liquid! {
        set {}
        get {
            return liquidProgressLayer
        }
    }
    
    /// Delegate to send messages containing updates to layer
    var h2OFluidViewDelegate: H2OFluidViewProtocol?
    
    //MARK: - Private iVars
    
    /// Layer that will take the place of liquidLayer
    private var liquidProgressLayer = GSAnimatingProgressLayer()
    
    //MARK: - View Setup
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        liquidProgressLayer.keyValuesToMonitor = ["position.y"] //Monitor animations with this key path
        liquidProgressLayer.progressDelegate = self
    }
    
    override func fillTo(_ fillPercentage: inout Float) {
        if fillPercentage > 1.0 { //Ensures a max of 1 is used as the value
            fillPercentage = 1.0
        }
        
        let fillDifference = fabs(fillPercentage - fluidLayout.fillLevel) //Difference in the new percentage to the current fill level
        
        fluidLayout.fillLevel = fillPercentage
        
        let bottomLiquidMargin: CGFloat = 40
        
        let finalRatioYPosition = CGFloat((1.02 - fillPercentage)) * (liquidLayer.frame.height - bottomLiquidMargin) //Final Y value to fill to based on percentage. 1.02 is chosen instead of 1 to make it so that the waves can be seen even if the fill percentage is 1 and full. I subtract from the bottomLiquidMargin to show the liquid even if the value is at zero.
        
        let liquidPresentationLayer = liquidLayer.presentation() //Liquid presentation layer. Presentation layer will give more accurate value to the current state of the liquid layer so we will animate this
        
        /// Vertical animation setup
        let verticalFillAnimation = CAKeyframeAnimation(keyPath: "position.y")
        verticalFillAnimation.values = [(liquidPresentationLayer?.position.y)!, finalRatioYPosition]
        verticalFillAnimation.duration = fluidLayout.fillDuration * Double(fillDifference) //Duration calculated from fill duration that can be configured multiplied by the fill difference to give a nice effect
        verticalFillAnimation.isRemovedOnCompletion = false
        verticalFillAnimation.fillMode = kCAFillModeBoth
        verticalFillAnimation.delegate = liquidProgressLayer
        verticalFillAnimation.setValue("position.y", forKey: gSAnimationID)
        
        liquidLayer.add(verticalFillAnimation, forKey: "position.y")
    }
}

// MARK: - GSAnimatingProgressLayerProtocol
extension H2OFluidView: GSAnimatingProgressLayerProtocol {
    func layerDidUpdate(key: String) {
       // print(liquidLayer.presentation()!.position)
        h2OFluidViewDelegate?.fluidViewLayerDidUpdate(fluidView: liquidLayer as! GSAnimatingProgressLayer)
    }
}
