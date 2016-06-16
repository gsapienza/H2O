//
//  Popsicle.swift
//  Cenify
//
//  Created by Gregory Sapienza on 2/9/16.
//  Copyright © 2016 Gregory Sapienza. All rights reserved.
//

import UIKit

protocol PopsicleProtocol {
    func popsicleDismissed(_ popsicle :Popsicle) //Called when popsicle is dismissed
}

/// Autolayout supported modal view that overlays root view controller
class Popsicle: UIViewController {
    /// PopsicleProtocol Delegate
    var _delegate :PopsicleProtocol!
    
    /// Top constraint of popsicle view
    var _topConstraint = NSLayoutConstraint()
    
    /// Is the popsicle showing on screen
    var _popsiclePushed = false

    /**
     When autolayout constraints are laid out, then show the view controller with an animation. This can be called multiple times by the system so the _popsiclePushed flag prevents multiple pushes
     */
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !_popsiclePushed {
            AppDelegate.delay(0.1, closure: { 
                self.pushPopsicle()
            })
        }
    }
    
    /**
     Sets up popsicle by putting the view controller at the bottom of the screen on top of the root view controller. This does not actually show the view on screen.
     */
    func setupPopsicle() {
        let rootViewController = AppDelegate.getAppDelegate().window?.rootViewController
        
        view.translatesAutoresizingMaskIntoConstraints = false
        rootViewController!.addChildViewController(self)
        addSubview(view, toView: (rootViewController?.view)!)
    }
    
    /**
     Adds subview using standard autolayout constraints where the top constraint is set to the bottom of the screen to be used for future animation when showing the popsicle.
     
     - parameter subView:    View to add to parent view
     - parameter parentView: View to add subview
     */
    func addSubview(_ subView: UIView, toView parentView: UIView) {
        parentView.addSubview(subView)
        
        _topConstraint = NSLayoutConstraint(item: subView, attribute: .top, relatedBy: .equal, toItem: parentView, attribute: .top, multiplier: 1, constant: parentView.bounds.height)
        parentView.addConstraint(_topConstraint)
        parentView.addConstraint(NSLayoutConstraint(item: subView, attribute: .leading, relatedBy: .equal, toItem: parentView, attribute: .leading, multiplier: 1, constant: 0))
        parentView.addConstraint(NSLayoutConstraint(item: subView, attribute: .width, relatedBy: .equal, toItem: parentView, attribute: .width, multiplier: 1, constant: 0))
        parentView.addConstraint(NSLayoutConstraint(item: subView, attribute: .height, relatedBy: .equal, toItem: parentView, attribute: .height, multiplier: 1, constant: 0))
        
    }
    
    /**
     Animates the top constraint to be 0 (on top) and makes _popsiclePushed true to prevent further calls by viewDidLayoutSubviews
     */
    func pushPopsicle() {
        _topConstraint.constant = 0
        _popsiclePushed = true

        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }) { (Bool) -> Void in
        }
    }
    
    /**
     Dismisses view controller by animating top constraint to the bottom and removing it from the root view controller
     */
    func dismissPopsicle() {
        _topConstraint.constant = view.bounds.height
        
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }) { (Bool) -> Void in
                self._popsiclePushed = false
                
                self.removeFromParentViewController()
                self.view.removeFromSuperview()
        }
        
        _delegate?.popsicleDismissed(self)
    }
}
