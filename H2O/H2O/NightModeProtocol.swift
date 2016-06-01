//
//  NightModeProtocol.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/30/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

/**
 *  Protocol for any views that have any changes to make when night mode is enabled
 */
protocol NightModeProtocol {
    /**
     Set up color values that will be changed in view when theme is toggled
     */
    func setupColors()
}
