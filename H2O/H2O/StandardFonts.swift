//
//  StandardFonts.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/17/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

@objc class StandardFonts: NSObject {
    
    @objc class func regularFont(_ size :CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size)
    }
    
    class func lightFont(_ size :CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: UIFontWeightLight)
    }
    
    class func thinFont(_ size :CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: UIFontWeightThin)
    }
    
    class func boldFont(_ size :CGFloat) -> UIFont {
        return UIFont.boldSystemFont(ofSize: size)
    }
}
