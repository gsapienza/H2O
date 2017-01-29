//
//  UIViewCollectionViewCellExtension.swift
//  Midnite
//
//  Created by Gregory Sapienza on 4/5/16.
//  Copyright © 2016 Gregory Sapienza. All rights reserved.
//

import UIKit

public enum WobbleSide {
    case left
    case right
}

/// Class methods to enable wobbling of views like the iOS home screen. Great for table and collection view cells!
public class WobbleAnimation {
    /**
     Called when starting editing cells in the corresponding collection view. Starts shaking and makes the delete button appear
     */
    public class func start(view: UIView, onSide side: WobbleSide) {
        var startingWobbleVar = 1.5
        if side == .right {
            startingWobbleVar = -startingWobbleVar
        }
        
        view.transform = CGAffineTransform.identity.rotated(by: (CGFloat(-startingWobbleVar * M_PI) / 180.0))
        
        UIView.animate(withDuration: 0.1, delay: 0, options: [.autoreverse, .repeat, .allowUserInteraction, .curveLinear], animations: { () -> Void in
            view.transform = CGAffineTransform.identity.rotated(by: (CGFloat(startingWobbleVar * M_PI) / 180.0))
        }) { (Bool) -> Void in
        }
    }
    
    /**
     Called when finished editing cells in the corresponding collection view. Stops shaking and makes the delete button disappear
     */
    public class func stop(view: UIView) {
        UIView.animate(withDuration: 0.1, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction, .curveLinear], animations: { () -> Void in
            view.transform = CGAffineTransform.identity
        }) { (Bool) -> Void in
        }
    }
}
