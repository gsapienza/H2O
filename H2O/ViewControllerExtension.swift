//
//  ViewControllerProtocol.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/21/16.
//  Copyright © 2016 Midnite. All rights reserved.
//

import UIKit

extension UIViewController {
    
    /**
     Set up method swizzling for the dark and light mode switching
    */
    open override static func initialize() {
        
        if self !== UIViewController.self { //Is self not a subclass of a UIViewController
            return
        }
        
        //View did load swizzle
        let originalViewWillAppearSelector = #selector(UIViewController.viewDidLoad)
        let swizzledViewWillAppearSelector = #selector(UIViewController.newViewDidLoad)
        
        swizzleSelector(originalViewWillAppearSelector, swizzledSelector: swizzledViewWillAppearSelector)
        
        //Preferred Status bar style swizzle
        let originalPreferredStatusBarStyleSelector = #selector(getter: UIViewController.preferredStatusBarStyle)
        let swizzledPreferredStatusBarStyleSelector = #selector(UIViewController.newPreferredStatusBarStyle)
        
        swizzleSelector(originalPreferredStatusBarStyleSelector, swizzledSelector: swizzledPreferredStatusBarStyleSelector)
    }
    
    /**
     Swizzle two methods by provinding the original selector and a new one that is called in this extension
     
     - parameter originalSelector: Original method to replace
     - parameter swizzledSelector: Replacing method
     */
    public static func swizzleSelector(_ originalSelector :Selector, swizzledSelector :Selector) {
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
        NotificationCenter.default.addObserver(self, selector: #selector(UIViewController.onThemeChange), name: DarkModeToggledNotification, object: nil)
    }
    
    /**
     Replaces preferredStatusBarStyle() and asssesses the correct status bar style
     
     - returns: Status bar color depending on the apps current theme
     */
    func newPreferredStatusBarStyle() -> UIStatusBarStyle {
        if AppUserDefaults.getDarkModeEnabled() {
            return .lightContent
        } else {
            return .default
        }
    }
    
    /**
     NSNotification method when theme changes. Removes observers for notifications because they will be added back when the view controllers reload and we dont want duplicates. And reloads all of the view controllers to represent the new colors
     */
    func onThemeChange() {
        NotificationCenter.default.removeObserver(self)
        AppDelegate.reloadViewController(self)
    }
}

extension UINavigationController {
    /**
     Gives power to the root view controller to determine if the status bar is hidden
     
     - returns: View controller that can control the status bar hidden status
     */
    override open var childViewControllerForStatusBarHidden: UIViewController? {
        get {
            return topViewController
        }
    }
    
    /**
     Gives power to the root view controller to determine the status bar color
     
     - returns: View controller that can control the status bar color
     */
    override open var childViewControllerForStatusBarStyle: UIViewController? {
        get {
            return topViewController
        }
    }
}
