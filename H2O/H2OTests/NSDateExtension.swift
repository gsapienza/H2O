//
//  NSDateExtension.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/20/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

extension NSDate {
    func dateForCurrentTimeZone() -> NSDate {
        let timeZone = NSTimeZone.localTimeZone()
        
        let seconds = Double(timeZone.secondsFromGMTForDate(self))
        
        return NSDate(timeInterval: seconds, sinceDate: self)
    }
}
