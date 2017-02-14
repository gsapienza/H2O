//
//  SettingLayout.swift
//  H2O
//
//  Created by Gregory Sapienza on 2/12/17.
//  Copyright © 2017 Skyscrapers.IO. All rights reserved.
//

import Foundation

struct SettingLayout<Decoration: Layout, Title: Layout, Control: Layout> : Layout {
   // typealias Content = UIView
    
    /// Decoration representing setting.
    var decoration: Decoration
    
    /// Title of setting.
    var title: Title
    
    /// Control for setting.
    var control: Control
    
    init(decoration: Decoration, title: Title, control: Control) {
        self.decoration = decoration
        self.title = title
        self.control = control
    }
    
    mutating func layout(in rect: CGRect) {
        //---Decoration---//
        
        let decorationSize = rect.height
        let decorationMargin: CGFloat = 15
        let decorationFrame = CGRect(x: decorationMargin, y: decorationMargin, width: decorationSize, height: decorationSize - (decorationMargin * 2))
        
        decoration.layout(in: decorationFrame)
        
        //---Control---//
        
        let controlSize = rect.height
        let controlMargin: CGFloat = 15
        let controlFrame = CGRect(x: rect.height - controlSize - controlMargin, y: controlMargin, width: controlSize, height: controlSize - controlMargin)
        
        control.layout(in: controlFrame)

        //---Title---//
        
        let titleMargin: CGFloat = 15
        let titleXOrigin = decorationFrame.origin.x + decorationFrame.width
        let titleFrame = CGRect(x: titleXOrigin, y: 0, width: rect.width - controlFrame.origin.x - titleXOrigin, height: rect.height)
        
        title.layout(in: titleFrame)
    }
}
