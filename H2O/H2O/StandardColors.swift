//
//  StandardColors.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/16/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

class StandardColors: NSObject {
     /// Standard dark blue background color
    static var backgroundColor :UIColor {
        set{}
        get {
            if AppDelegate.isDarkModeEnabled() {
                return UIColor(red: 30/255, green: 35/255, blue: 44/255, alpha: 1)
            } else {
                return UIColor.whiteColor()
            }
        }
    }
    
     /// Color of water images found through the app
    static let waterColor = UIColor(red: 35/255, green: 210/255, blue: 231/255, alpha: 1)
    
     /// Standard red color to use throughout the app in destrictive or not instances
    static let standardRedColor = UIColor(red: 230/255, green: 76/255, blue: 12/255, alpha: 1)
    
        /// Standard green color to use throughout the app in destrictive or not instances
    static let standardGreenColor = UIColor.greenColor()
    
     /// Secondary color to use with background color
    static var standardSecondaryColor :UIColor {
        set{}
        get {
            if AppDelegate.isDarkModeEnabled() {
                return UIColor(red: 45/255, green: 53/255, blue: 68/255, alpha: 1)
            } else {
                return UIColor(white: 0.95, alpha: 0.5)
            }
        }
    }
    
        /// Color for things like test and other indicative elements
    static var primaryColor :UIColor {
        set{}
        get {            
            if AppDelegate.isDarkModeEnabled() {
                return UIColor.whiteColor()
            } else {
                return UIColor(red: 30/255, green: 35/255, blue: 44/255, alpha: 1)
            }
        }
    }
    
        /// Reversed primary color
    static var inversedPrimaryColor :UIColor {
        set{}
        get {
            if AppDelegate.isDarkModeEnabled() {
                return UIColor(red: 30/255, green: 35/255, blue: 44/255, alpha: 1)
            } else {
                return UIColor.whiteColor()
            }
        }
    }
    
        /// Keyboard color to use depending on theme
    static var standardKeyboardAppearance :UIKeyboardAppearance {
        set{}
        get {
            if AppDelegate.isDarkModeEnabled() {
                return .Dark
            } else {
                return .Light
            }
        }
    }
}
