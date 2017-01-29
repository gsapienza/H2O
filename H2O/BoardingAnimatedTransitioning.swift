//
//  BoardingAnimatedTransitioning.swift
//  H2O
//
//  Created by Gregory Sapienza on 12/2/16.
//  Copyright © 2016 Midnite. All rights reserved.
//

import Foundation

class BoardingAnimatingTransitioning :NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView //Container view containing from and to view controllers.
        
        guard
            let fromViewController = transitionContext.viewController(forKey: .from) as? BoardingProtocol, //View controller coming from.
            let toViewController = transitionContext.viewController(forKey: .to) as? BoardingProtocol //View controller moving to.
            else {
                print("Container view controllers do not confrom to BoardingProtocol.")
                return
        }
        
        toViewController.view.frame = CGRect(x: 0, y: 0, width: fromViewController.view.bounds.width, height: fromViewController.view.bounds.height)
        containerView.insertSubview(toViewController.view, belowSubview: fromViewController.view)
        toViewController.titleLabel?.isHidden = true
        
        if let toViewControllerTitleLabelText = toViewController.titleLabel?.text {
            fromViewController.titleLabel?.animate(to: toViewControllerTitleLabelText, completion: { _ in
            })
        } else {
            print("To View Controller title text is nil.")
        }
        
        fromViewController.animateOut { (complete :Bool) in
            toViewController.titleLabel?.isHidden = false
            fromViewController.view.removeFromSuperview()
        }
        
        toViewController.animateIn { (complete :Bool) in
            transitionContext.completeTransition(true)
        }
    }
}
