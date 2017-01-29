//
//  StandardColors.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/16/16.
//  Copyright © 2016 Midnite. All rights reserved.
//

import Foundation

#if os(iOS)
    import UIKit
#endif

#if os(watchOS)
    import WatchKit
#endif

class StandardColors {
    /// Standard dark blue background color
    static var backgroundColor = UIColor.black
    
     /// Color of water images found through the app
    static var waterColor = UIColor(red: 78/255, green: 170/255, blue: 186/255, alpha: 1)
    
     /// Standard red color to use throughout the app in destructive instances
    static let standardRedColor = UIColor(red: 230/255, green: 76/255, blue: 12/255, alpha: 1)
    
        /// Standard green color to use throughout the app
    static let standardGreenColor = UIColor(red: 26/255, green: 181/255, blue: 138/255, alpha: 1)
    
     /// Secondary color to use with background color
    static var standardSecondaryColor = UIColor(red: 15/255, green: 15/255, blue: 15/255, alpha: 1)
    
    /// Color for things like buttons and other indicative elements
    static var primaryColor = UIColor.white
    
        /// Reversed primary color
    static var inversedPrimaryColor = UIColor(red: 1/255, green: 23/255, blue: 31/255, alpha: 1)
    
    #if os(iOS)
    
    /// Keyboard color to use depending on theme
    static var standardKeyboardAppearance = UIKeyboardAppearance.dark
    
    #endif
}
