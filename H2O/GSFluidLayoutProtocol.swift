//
//  GSFluidLayoutProtocol.swift
//  H2O
//
//  Created by Gregory Sapienza on 9/12/16.
//  Copyright © 2016 City Pixels. All rights reserved.
//

import UIKit

protocol GSFluidLayoutProtocol {
    
    /// Liquid view type.
    associatedtype Liquid
    
    /// Wave animation.
    associatedtype WaveMovementAnimation
    
    /// Frame of container.
    var frame :CGRect { get }
    
    /// Layer of liquid type inside container.
    var liquidLayer :Liquid! { get set }
    
    /// Animation for the waves movement.
    var waveMovementAnimation :WaveMovementAnimation! { get set }
    
    /// Color of liquid layer.
    var liquidFillColor :UIColor { get set }
    
    /// Duration of phase shift animation as its moving the fluid back and forth horizontally.
    var phaseShiftDuration :Double { get set }
    
    /// Layout of all view types.
    func layout()
    
    /// Fill liquid to an amount from 0 to 1.
    ///
    /// - parameter fillPercentage: Percentage to fill liquid layer. Value between 0 and 1
    func fillTo(_ fillPercentage :inout Float)
    
    /// Uses 2 animations to control the waves. The first one is the phase shift which essentially moves the liquid x position horizontally to look like the waves are moving in a single direction. The other animation is the one that actually controls the wave shapes using path animations.
    func startWaveAnimation()
    
    /// Called by timer to regenerate the wave animation using new amplitude values.
    func updateWaveAnimation()
}
