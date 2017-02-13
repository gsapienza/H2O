//
//  UIViewControllerExtension.swift
//  H2O
//
//  Created by Gregory Sapienza on 2/5/17.
//  Copyright © 2017 Midnite. All rights reserved.
//

import UIKit

protocol NavigationThemeProtocol {
    var navigationThemeDidChangeHandler: ((NavigationTheme) -> Void)? { get set }
}

extension NavigationThemeProtocol where Self : UIViewController {
    func updateNavigationBar(navigationTheme: NavigationTheme) {
        navigationThemeDidChangeHandler?(navigationTheme)
    }
}
