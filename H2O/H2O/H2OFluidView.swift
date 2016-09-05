//
//  H2OFluidView.swift
//  H2O
//
//  Created by Gregory Sapienza on 9/5/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

protocol H2OFluidViewProtocol {
    
    /// Gets fluid view as its animating
    ///
    /// - parameter fluidView: Layer animating
    func fluidViewLayerDidUpdate(fluidView :GSAnimatingProgressLayer)
}

class H2OFluidView: GSFluidView {

    //MARK: - Public iVars
    
    override var liquidLayer: CAShapeLayer {
        set {}
        get {
            return liquidProgressLayer
        }
    }
    
    /// Delegate to send messages containing updates to layer
    var h2OFluidViewDelegate :H2OFluidViewProtocol?
    
    //MARK: - Private iVars
    
    /// Layer that will take the place of liquidLayer
    private var liquidProgressLayer = GSAnimatingProgressLayer()
    
    //MARK: - View Setup
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        liquidProgressLayer.keyPathsToMonitor = ["position.y"] //Monitor animations with this key path
        liquidProgressLayer.progressDelegate = self
    }
}

// MARK: - GSAnimatingProgressLayerProtocol
extension H2OFluidView :GSAnimatingProgressLayerProtocol {
    func layerDidUpdate(key: String) {
       // print(liquidLayer.presentation()!.position)
       // h2OFluidViewDelegate?.fluidViewLayerDidUpdate(fluidView: liquidLayer as! GSAnimatingProgressLayer)
    }
}
