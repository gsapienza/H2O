//
//  Global.swift
//  H2O
//
//  Created by Gregory Sapienza on 9/4/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit


/// Standard unit of measurement
let standardUnit :Unit = .Oz

/// Delays block of code from running by a specified amount of time
///- parameters:
///   - delay: Time to delay code from being ran
func delay(delay: Double, closure: @escaping ()->()) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
        closure()
    })
}

///- returns: Current AppDelegate
func getAppDelegate() -> AppDelegate {
    return (UIApplication.shared.delegate as? AppDelegate)!
}
