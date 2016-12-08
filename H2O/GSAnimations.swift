//
//  GSAnimations.swift
//  H2O
//
//  Created by Gregory Sapienza on 12/2/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

class GSAnimations {
    
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
}
