//
//  StandardFonts.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/17/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

@objc class StandardFonts: NSObject {
    
    @objc class func regularFont(size :CGFloat) -> UIFont {
        return UIFont(name: "Bariol-Regular", size: size)!
    }
    
    class func lightFont(size :CGFloat) -> UIFont {
        return UIFont(name: "Bariol-Light", size: size)!
    }
    
    class func thinFont(size :CGFloat) -> UIFont {
        return UIFont(name: "Bariol-Thin", size: size)!
    }
    
    class func boldFont(size :CGFloat) -> UIFont {
        return UIFont(name: "Bariol-Bold", size: size)!
    }
}
