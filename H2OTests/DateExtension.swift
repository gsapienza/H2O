//
//  NSDateExtension.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/20/16.
//  Copyright © 2016 City Pixels. All rights reserved.
//

import UIKit

extension Date {
    func dateForCurrentTimeZone() -> Date {
        let timeZone = TimeZone.current
        
        let seconds = Double(timeZone.secondsFromGMT(for: self))
        
        return Date(timeInterval: seconds, since: self)
    }
}
