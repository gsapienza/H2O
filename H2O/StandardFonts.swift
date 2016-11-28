//
//  StandardFonts.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/17/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

@objc class StandardFonts: NSObject {
    
    class func regularFont(size :CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size)
    }
    
    class func lightFont(size :CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: UIFontWeightLight)
    }
    
    class func thinFont(size :CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: UIFontWeightThin)
    }
    
    class func ultraLightFont(size :CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: UIFontWeightUltraLight)
    }
    
    class func boldFont(size :CGFloat) -> UIFont {
        return UIFont.boldSystemFont(ofSize: size)
    }
}
