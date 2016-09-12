//
//  GSAnimatingProgressLayer.swift
//  H2O
//
//  Created by Gregory Sapienza on 9/4/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

/// Animation ID String Constant
let gSAnimationID = "animationId"

protocol GSAnimatingProgressLayerProtocol {
    
    /// When the progress layer has had an animation update for one of the monitored key paths
    ///
    /// - parameter key: Key that was updated
    func layerDidUpdate(key :String)
}

class GSAnimatingProgressLayer :CAShapeLayer {
    
    //MARK: - Public iVars
    
    /// Animation key paths to monitor progress when adding an animation
    var keyValuesToMonitor :[String]?
    
    /// Delegate to call back when modifications happen
    var progressDelegate :GSAnimatingProgressLayerProtocol?
    
    //MARK: - Private iVars
    
    /// Animations in progress on layer
    var animationsInProgress :[CAAnimation] = []
    
    /// Display timer to update with screen refreshes
    var displayLink :CADisplayLink?
    
    //MARK: - Public
    
    override func add(_ anim: CAAnimation, forKey key: String?) {
        super.add(anim, forKey: key)
        
        guard key != nil && keyValuesToMonitor != nil else {
            return
        }

        if keyValuesToMonitor!.contains(key!) { //If the key for this animation should be monitored
            animationsInProgress.append(anim)
            
            displayLink = CADisplayLink(target: self, selector: #selector(displayLinkUpdate))
            displayLink?.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        }
    }
    
    //MARK: - Private
    
    /// Updates with screen to provide updates through the delegate to the layers progress through the animation. Will remove an animation in progress when it has completed
    func displayLinkUpdate() {
        if let animations = animationsContainedForKeys() { //If there are animations for a key to monitor
            for animation in animations {
                if let valueForKey = getValueForKey(anim: animation) {
                    progressDelegate?.layerDidUpdate(key :valueForKey)
                }
            }
        } else { //If there are no animations for keys to monitor
            displayLink?.invalidate()
        }
    }
    
    /// Finds animations in progress for the keys to monitor
    ///
    /// - returns: Array of animations that should be monitored
    func animationsContainedForKeys() -> [CAAnimation]? {
        var animations :[CAAnimation]?
        for animation in animationsInProgress {
            if let valueForKey = getValueForKey(anim: animation) { //Value for animation in array
                if (keyValuesToMonitor?.contains(valueForKey))! { //If the value for the animationID is equal to the animations key value
                    if animations == nil {
                        animations = []
                    }
                    
                    animations!.append(animation)
                }
            }
        }
        
        return animations
    }
    
    /// Get the value for the animationID
    ///
    /// - parameter anim: Animation to get value for
    ///
    /// - returns: Value of animationID from anumation values
    func getValueForKey(anim :CAAnimation) -> String? {
        if let value = anim.value(forKey: gSAnimationID) as? String {
            return value
        } else {
            return nil
        }
    }
}

// MARK: - CAAnimationDelegate
extension GSAnimatingProgressLayer :CAAnimationDelegate {
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let animations = animationsContainedForKeys() { //If there are animations for a key to monitor
            for (i, animation) in animations.enumerated() {
                if let animationValueForKey = getValueForKey(anim: animation), let animValueForKey = getValueForKey(anim: anim) {
                    if animValueForKey == animationValueForKey {
                        if i < animationsInProgress.count { //TODO: Find out why an out of bounds can happen
                            animationsInProgress.remove(at: i)
                        }
                    }
                }
            }
        }
    }
}
