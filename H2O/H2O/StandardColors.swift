//
//  StandardColors.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/16/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import Foundation

#if os(iOS)
    import UIKit
#endif

#if os(watchOS)
    import WatchKit
#endif

class StandardColors: NSObject {
     /// Standard dark blue background color
    static var backgroundColor :UIColor {
        set{}
        get {
            if AppUserDefaults.getDarkModeEnabled() {
                return UIColor(red: 1/255, green: 23/255, blue: 31/255, alpha: 1)
            } else {
                return UIColor.white
            }
        }
    }
    
     /// Color of water images found through the app
    static var waterColor :UIColor {
        set{}
        get {
            if AppUserDefaults.getDarkModeEnabled() {
                return UIColor(red: 55/255, green: 187/255, blue: 216/255, alpha: 1)
            } else {
                return UIColor(red: 55/255, green: 187/255, blue: 216/255, alpha: 1)
            }
        }
    }
    
     /// Standard red color to use throughout the app in destructive instances
    static let standardRedColor = UIColor(red: 230/255, green: 76/255, blue: 12/255, alpha: 1)
    
        /// Standard green color to use throughout the app
    static let standardGreenColor = UIColor(red: 26/255, green: 181/255, blue: 138/255, alpha: 1)
    
     /// Secondary color to use with background color
    static var standardSecondaryColor :UIColor {
        set{}
        get {
            if AppUserDefaults.getDarkModeEnabled() {
                return UIColor(red: 2/255, green: 30/255, blue: 42/255, alpha: 1)
            } else {
                return UIColor(white: 0.95, alpha: 0.5)
            }
        }
    }
    
        /// Color for things like test and other indicative elements
    static var primaryColor :UIColor {
        set{}
        get {            
            if AppUserDefaults.getDarkModeEnabled() {
                return UIColor.white
            } else {
                return UIColor(red: 1/255, green: 23/255, blue: 31/255, alpha: 1)
            }
        }
    }
    
        /// Reversed primary color
    static var inversedPrimaryColor :UIColor {
        set{}
        get {
            if AppUserDefaults.getDarkModeEnabled() {
                return UIColor(red: 1/255, green: 23/255, blue: 31/255, alpha: 1)
            } else {
                return UIColor.white
            }
        }
    }
    
    #if os(iOS)
    
        /// Keyboard color to use depending on theme
    static var standardKeyboardAppearance :UIKeyboardAppearance {
        set{}
        get {
            if AppUserDefaults.getDarkModeEnabled() {
                return .dark
            } else {
                return .light
            }
        }
    }
    
    #endif
}
