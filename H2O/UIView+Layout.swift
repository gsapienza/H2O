//
//  UILabel+Layout.swift
//  H2O
//
//  Created by Gregory Sapienza on 2/12/17.
//  Copyright © 2017 Midnite. All rights reserved.
//

import UIKit

extension UIView: Layout {
    
    func layout(in rect: CGRect) {
        frame = rect
    }
}
