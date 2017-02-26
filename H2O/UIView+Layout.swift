//
//  UILabel+Layout.swift
//  H2O
//
//  Created by Gregory Sapienza on 2/12/17.
//  Copyright © 2017 Skyscrapers.IO. All rights reserved.
//

import UIKit

extension UIView: Layout {
    
    func layout(in rect: CGRect) {
        frame = rect
    }
}

extension UISwitch {
    override func layout(in rect: CGRect) {
        super.layout(in: rect)
        
        var newFrame = frame
        
        switch contentVerticalAlignment {
        case .center:
            let heightDifference = rect.height - frame.height
            newFrame.origin.y = rect.origin.y + heightDifference / 2
        case .bottom:
            newFrame.origin.y = rect.origin.y + rect.height - frame.height
        default:
            break
        }
        
        switch contentHorizontalAlignment {
        case .center:
            newFrame.origin.x = rect.origin.x + frame.width / 2
        case .right:
            newFrame.origin.x = rect.origin.x + rect.width - frame.width
        default:
            break
        }
        
        frame = newFrame
    }
}
