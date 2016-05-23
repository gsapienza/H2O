//
//  ViewControllerProtocol.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/21/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

extension UIViewController {
    
    /**
     Set up method swizzling for the dark and light mode switching
    */
    public override static func initialize() {
        struct Static {
            static var token: dispatch_once_t = 0
        }
        
        if self !== UIViewController.self { //Is self not a subclass of a UIViewController
            return
        }
        
        dispatch_once(&Static.token) {
            //View did load swizzle
            let originalViewWillAppearSelector = #selector(UIViewController.viewDidLoad)
            let swizzledViewWillAppearSelector = #selector(UIViewController.newViewDidLoad)
            
            self.swizzleSelector(originalViewWillAppearSelector, swizzledSelector: swizzledViewWillAppearSelector)
            
            //Preferred Status bar style swizzle
            let originalPreferredStatusBarStyleSelector = #selector(UIViewController.preferredStatusBarStyle)
            let swizzledPreferredStatusBarStyleSelector = #selector(UIViewController.newPreferredStatusBarStyle)
            
            self.swizzleSelector(originalPreferredStatusBarStyleSelector, swizzledSelector: swizzledPreferredStatusBarStyleSelector)
        }
    }
    
    /**
     Swizzle two methods by provinding the original selector and a new one that is called in this extension
     
     - parameter originalSelector: Original method to replace
     - parameter swizzledSelector: Replacing method
     */
    public static func swizzleSelector(originalSelector :Selector, swizzledSelector :Selector) {
        let originalMethod = class_getInstanceMethod(self, originalSelector) //Instance method for the original function
        let swizzledMethod = class_getInstanceMethod(self, swizzledSelector) //Instance method for the swizzled function
        
        let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod)) //Adds the method to this class class
        
        if didAddMethod { //If the method was added successfully
            class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod)) //Replaces the original function with the new selector name
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod) //Else just try swapping the method implementations
        }
    }
    
    // MARK: - Method Swizzling
    
    /**
     Replaces viewDidLoad(). Adds a notification for when the theme changes to all view controllers
     */
    func newViewDidLoad() {
        newViewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UIViewController.onThemeChange), name: "DarkModeToggled", object: nil)
    }
    
    /**
     Replaces preferredStatusBarStyle() and asssesses the correct status bar style
     
     - returns: Status bar color depending on the apps current theme
     */
    func newPreferredStatusBarStyle() -> UIStatusBarStyle {
        if AppDelegate.isDarkModeEnabled() {
            return .LightContent
        } else {
            return .Default
        }
    }
    
    /**
     NSNotification method when theme changes. Removes observers for notifications because they will be added back when the view controllers reload and we dont want duplicates. And reloads all of the view controllers to represent the new colors
     */
    func onThemeChange() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        AppDelegate.reloadViewController(self)
    }
}

extension UINavigationController {
    /**
     Gives power to the root view controller to determine if the status bar is hidden
     
     - returns: View controller that can control the status bar hidden status
     */
    public override func childViewControllerForStatusBarHidden() -> UIViewController? {
        return topViewController
    }
    
    /**
     Gives power to the root view controller to determine the status bar color
     
     - returns: View controller that can control the status bar color
     */
    public override func childViewControllerForStatusBarStyle() -> UIViewController? {
        return topViewController
    }
}
