//
//  NavigationTheme.swift
//  H2O
//
//  Created by Gregory Sapienza on 2/5/17.
//  Copyright © 2017 Midnite. All rights reserved.
//

import UIKit

enum NavigationTheme {
    case settings
    case hidden
    
    var barTintColor: UIColor {
        switch self {
        case .settings:
            return UIColor.blue
        case .hidden:
            return UIColor.clear
        }
    }
    
    var titleTextAttributes: [String: NSObject]? {
        switch self {
        case .settings:
            return [NSForegroundColorAttributeName: UIColor.white]
        case .hidden:
            return nil
        }
    }
    
    var defaultBackgroundImage: UIImage? {
        switch self {
        case .settings:
            return nil
        case .hidden:
            return UIImage()
        }
    }
    
    var isTranslucent: Bool {
        switch self {
        case .settings:
            return true
        case .hidden:
            return true
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .settings:
            return UIColor.blue
        case .hidden:
            return UIColor.clear
        }
    }
    
    var shadowImage: UIImage {
        switch self {
        case .settings:
            return UIImage()
        case .hidden:
            return UIImage()
        }
    }
}
