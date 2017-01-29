//
//  Global.swift
//  H2O
//
//  Created by Gregory Sapienza on 9/4/16.
//  Copyright © 2016 Midnite. All rights reserved.
//

import UIKit
import WatchKit

/// Delays block of code from running by a specified amount of time
///- parameters:
///   - delay: Time to delay code from being ran
func delay(delay: Double, closure: @escaping ()->()) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
        closure()
    })
}

#if os(iOS)

/// Gets the current App Delegate.
///
///- returns: Current App Delegate.
func getAppDelegate() -> AppDelegate {
    return (UIApplication.shared.delegate as? AppDelegate)!
}
    
#endif

#if os(watchOS)

/// Gets the current Watch Extension Delegate.
///
/// - returns: Current Watch Extension Delegate.
func getWKExtensionDelegate() -> ExtensionDelegate {
    return WKExtension.shared().delegate as! ExtensionDelegate
}

#endif
