//
//  GSAnimatingProgressLayer.swift
//  H2O
//
//  Created by Gregory Sapienza on 9/4/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

private struct AnimationInProgress {
    /// Key set when adding animation
    var key :String
    
    /// The actual CAAnimation
    var animation :CAAnimation
    
    /// Not the animation begin time, but the time set internally when the animation is added
    var beginTime :CFTimeInterval
}

protocol GSAnimatingProgressLayerProtocol {
    
    /// When the progress layer has had an animation update for one of the monitored key paths
    ///
    /// - parameter key: Key that was updated
    func layerDidUpdate(key :String)
}

class GSAnimatingProgressLayer :CAShapeLayer {
    
    //MARK: - Public iVars
    
    /// Animation key paths to monitor progress when adding an animation
    var keyPathsToMonitor :[String]?
    
    /// Delegate to call back when modifications happen
    var progressDelegate :GSAnimatingProgressLayerProtocol?
    
    //MARK: - Private iVars
    
    /// Animations in progress on layer
    private var animationsInProgress :[AnimationInProgress] = []
    
    /// Display timer to update with screen refreshes
    private var displayLink :CADisplayLink?
    
    //MARK: - Public
    
    override func add(_ anim: CAAnimation, forKey key: String?) {
        super.add(anim, forKey: key)
        
        guard key != nil && keyPathsToMonitor != nil else {
            return
        }
        
        if !keyAlreadyAnimating(key: key!) { //If the key is not currently being animated
            var beginTime :CFTimeInterval = 0
            if anim.beginTime != 0 {
                beginTime = anim.beginTime
            } else {
                beginTime = CACurrentMediaTime()
            }
            
            let animationInProgress = AnimationInProgress(key: key!, animation: anim, beginTime: beginTime) //Create AnimationInProgress for the animation being added
            animationsInProgress.append(animationInProgress)
            
            if keyPathsToMonitor!.contains(key!) { //If the key for this animation should be monitored
                displayLink = CADisplayLink(target: self, selector: #selector(displayLinkUpdate))
                displayLink?.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
            }
        }
    }
    
    //MARK: - Private
    
    /// Check if there is an animation in progress for a key to monitor
    ///
    /// - parameter key: Key to monitor
    ///
    /// - returns: True if there is an animation in progress for the key
    private func keyAlreadyAnimating(key :String) -> Bool {
        for animation in animationsInProgress {
            if animation.key == key {
                return true
            }
        }
        return false
    }
    
    /// Updates with screen to provide updates through the delegate to the layers progress through the animation. Will remove an animation in progress when it has completed
    @objc private func displayLinkUpdate() {
        if let animations = animationsContainedForKeys() { //If there are animations for a key to monitor
            for (i, animation) in animations.enumerated() {
                let currentTime = CACurrentMediaTime() //Time since animation was added.
                let finalTime = animation.beginTime + animation.animation.duration //Duration of the animation. Accounts for begin time of CAAnimation
                progressDelegate?.layerDidUpdate(key :animation.key)
                if currentTime >= finalTime { //If the time elapsed has passed the duration of the animtation, remove the animation from those in progress
                    animationsInProgress.remove(at: i)
                }
            }
        } else { //If there are no animations for keys to monitor
            displayLink?.invalidate()
        }
    }
    
    /// Finds animations in progress for the keys to monitor
    ///
    /// - returns: Array of animations that should be monitored
    private func animationsContainedForKeys() -> [AnimationInProgress]? {
        var animations :[AnimationInProgress]?
        for animation in animationsInProgress {
            if (keyPathsToMonitor?.contains(animation.key))! {
                if animations == nil {
                    animations = []
                }
                
                animations!.append(animation)
            }
        }
        return animations
    }
}
