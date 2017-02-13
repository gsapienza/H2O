//
//  GSAnimations.swift
//  H2O
//
//  Created by Gregory Sapienza on 12/2/16.
//  Copyright © 2016 Skyscrapers.IO. All rights reserved.
//

import UIKit

class GSAnimations {
    /// Helper function to convert degrees to radians
    ///
    /// - parameter degrees: Degrees value to convert
    ///
    /// - returns: Radian value converted from degrees
    class func degreesToRadians( degrees :CGFloat) -> CGFloat {
        return degrees * CGFloat(Float.pi) / 180
    }
    
    /// Shakes a specified layer to indicate it contains invalid data.
    ///
    /// - Parameters:
    ///   - layer: Layer to perform animation on.
    ///   - completion: Animation completion.
    class func invalid(layer :CALayer, completion :@escaping (Bool) -> Void) {
        let animationDuration :TimeInterval = 0.8
        let moveValue :CGFloat = 20 //initial X translation to shake
        let shakeDuration = 0.2
        
        ///Shake keyframe animation
        UIView.animateKeyframes(withDuration: animationDuration, delay: 0, options: .allowUserInteraction, animations: { () -> Void in
            ///Shake forward
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: shakeDuration, animations: { () -> Void in
                layer.position = CGPoint(x: layer.position.x + moveValue, y: layer.position.y)
            })
            
            ///Shake back
            UIView.addKeyframe(withRelativeStartTime: shakeDuration, relativeDuration: shakeDuration, animations: { () -> Void in
                layer.position = CGPoint(x: layer.position.x - moveValue * 2, y: layer.position.y)
            })
            
            ///Shake forward
            UIView.addKeyframe(withRelativeStartTime: shakeDuration * 2, relativeDuration: shakeDuration, animations: { () -> Void in
                layer.position = CGPoint(x: layer.position.x + moveValue * 2, y: layer.position.y)
            })
            
            ///Shake back
            UIView.addKeyframe(withRelativeStartTime: shakeDuration * 3, relativeDuration: shakeDuration, animations: { () -> Void in
                layer.position = CGPoint(x: layer.position.x - moveValue, y: layer.position.y)
            })
        }) { (Bool) -> Void in
            completion(true)
        }
    }
    
    /// Rotates a specified layer back and forth.
    ///
    /// - Parameters:
    ///   - layer: Layer to perform animation on.
    ///   - completion: Animation completion.
    class func rotationShake(layer :CALayer, completion :@escaping (Bool) -> Void) {
        let animationDuration :TimeInterval = 1
        let rotateValue :CGFloat = 10 //initial X translation to shake
        let shakeDuration = 0.2
        
        ///Shake keyframe animation
        UIView.animateKeyframes(withDuration: animationDuration, delay: 0, options: .allowUserInteraction, animations: { () -> Void in
            ///Shake forward
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: shakeDuration, animations: { () -> Void in
                layer.transform = CATransform3DMakeRotation(degreesToRadians(degrees: -rotateValue), 0, 0, 1)
            })
            
            ///Shake back
            UIView.addKeyframe(withRelativeStartTime: shakeDuration, relativeDuration: shakeDuration, animations: { () -> Void in
                layer.transform = CATransform3DMakeRotation(degreesToRadians(degrees: rotateValue), 0, 0, 1)
            })
            
            ///Shake forward
            UIView.addKeyframe(withRelativeStartTime: shakeDuration * 2, relativeDuration: shakeDuration, animations: { () -> Void in
                layer.transform = CATransform3DMakeRotation(degreesToRadians(degrees: -rotateValue), 0, 0, 1)
            })
            
            ///Shake back
            UIView.addKeyframe(withRelativeStartTime: shakeDuration * 3, relativeDuration: shakeDuration, animations: { () -> Void in
                layer.transform = CATransform3DMakeRotation(degreesToRadians(degrees: rotateValue), 0, 0, 1)
            })
            
            ///Normal
            UIView.addKeyframe(withRelativeStartTime: shakeDuration * 4, relativeDuration: shakeDuration, animations: { () -> Void in
                layer.transform = CATransform3DMakeRotation(degreesToRadians(degrees: 0), 0, 0, 1)
            })
            
        }) { (Bool) -> Void in
            completion(true)
        }
    }
}
