//
//  UINavigationBarExtension.swift
//  H2O
//
//  Created by Gregory Sapienza on 2/5/17.
//  Copyright © 2017 Skyscrapers.IO. All rights reserved.
//

import UIKit

extension UINavigationBar {
    func applyTheme(navigationTheme: NavigationTheme) {
        barTintColor = navigationTheme.barTintColor
        setBackgroundImage(navigationTheme.defaultBackgroundImage, for: .default)
        titleTextAttributes = navigationTheme.titleTextAttributes
        isTranslucent = navigationTheme.isTranslucent
        backgroundColor = navigationTheme.backgroundColor
        shadowImage = navigationTheme.shadowImage
    }
}
