//
//  Constants.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/18/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

enum Unit :String {
    case Oz = "oz"
    case Ml = "ml"
}

class Constants: NSObject {
    
     /// Standard unit of measurement
    static let standardUnit :Unit = .Oz
}
