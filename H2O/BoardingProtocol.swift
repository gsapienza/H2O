//
//  BoardingProtocol.swift
//  H2O
//
//  Created by Gregory Sapienza on 12/2/16.
//  Copyright © 2016 City Pixels. All rights reserved.
//

import Foundation

@objc protocol BoardingProtocol {
    ///View where boarding subviews are contained.
    var view: UIView! { set get }
    
    func animateIn(completion: @escaping (Bool) -> Void)

    func animateOut(completion: @escaping (Bool) -> Void)
    
    ///Boarding screen title label.
    @objc optional var titleLabel: GSMagicTextLabel { get }

    ///Action when right bar button is tapped.
    @objc optional func onRightBarButton()
}

extension BoardingProtocol where Self: UIViewController {
    /// Generates a title label.
    ///
    /// - Returns: A magic label to use for title.
    func generateTitleLabel(text: String) -> GSMagicTextLabel {
        let label = GSMagicTextLabel()
        
        label.text = text
        let fontSize = UIScreen.main.bounds.width / 9
        label.font = StandardFonts.ultraLightFont(size: fontSize) //48
        label.textAlignment = .center
        label.textColor = StandardColors.primaryColor
        
        return label
    }
    
    /// Configures a navigation item for this view controller.
    ///
    /// - Parameters:
    ///   - navigationItem: Navigation item to configure.
    ///   - title: Navigation title.
    func configureNavigationItem(navigationItem: inout UINavigationItem, title: String, rightBarButtonItemTitle: String) {
        navigationItem.title = title
        navigationItem.hidesBackButton = true
        let nextBarButtonItem = UIBarButtonItem(title: rightBarButtonItemTitle, style: .plain, target: self, action: #selector(onRightBarButton))
        nextBarButtonItem.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = nextBarButtonItem
    }
}
