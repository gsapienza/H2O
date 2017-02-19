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
    
    var controlSize: CGSize
    
    init(decoration: Decoration, title: Title, control: Control, controlSize: CGSize) {
        self.decoration = decoration
        self.title = title
        self.control = control
        self.controlSize = controlSize
    }
    
    mutating func layout(in rect: CGRect) {
        //---Decoration---//
        
        let decorationSize = rect.height / 2
        let decorationMargin: CGFloat = 10
        let decorationFrame = CGRect(x: rect.origin.y + decorationMargin, y: rect.origin.y, width: decorationSize, height: decorationSize)
        
        decoration.layout(in: decorationFrame)
        
        //---Control---//
        
        let controlMargin: CGFloat = 15
        let controlWidth = rect.width / 5
        let controlFrame = CGRect(x: rect.width - controlWidth - controlMargin, y: rect.origin.y, width: controlWidth, height: rect.height)
        
        control.layout(in: controlFrame)

        //---Title---//
        
        let titleMargin: CGFloat = 15
        let titleXOrigin = decorationFrame.origin.x + decorationFrame.width
        let titleFrame = CGRect(x: titleXOrigin + titleMargin, y: rect.origin.y, width: controlFrame.origin.x - titleXOrigin, height: rect.height)
        
        title.layout(in: titleFrame)
    }
}
