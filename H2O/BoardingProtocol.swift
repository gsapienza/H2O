//
//  BoardingProtocol.swift
//  H2O
//
//  Created by Gregory Sapienza on 12/2/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import Foundation

@objc protocol BoardingProtocol {
    var view :UIView! { set get }
    
    var titleLabel :UILabel! { set get }
    
    func animateOut(completion :@escaping (Bool) -> Void)
    
    func animateIn(completion :@escaping (Bool) -> Void)
    
    func onRightBarButton()
}

extension BoardingProtocol where Self :UIViewController {
    /// Generates a title label.
    ///
    /// - Returns: A magic label to use for title.
    func generateTitleLabel() -> UILabel {
        let label = UILabel()
        
        label.font = StandardFonts.ultraLightFont(size: 48)
        label.textAlignment = .center
        label.textColor = StandardColors.primaryColor
        
        return label
    }
    
    /// Configures a navigation item for this view controller.
    ///
    /// - Parameters:
    ///   - navigationItem: Navigation item to configure.
    ///   - title: Navigation title.
    func configureNavigationItem(navigationItem :inout UINavigationItem, title :String, rightBarButtonItemTitle :String) {
        navigationItem.title = title
        navigationItem.hidesBackButton = true
        let nextBarButtonItem = UIBarButtonItem(title: rightBarButtonItemTitle, style: .plain, target: self, action: #selector(onRightBarButton))
        nextBarButtonItem.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = nextBarButtonItem
    }
}
