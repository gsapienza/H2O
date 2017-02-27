//
//  SettingLayout.swift
//  H2O
//
//  Created by Gregory Sapienza on 2/12/17.
//  Copyright © 2017 Skyscrapers.IO. All rights reserved.
//

import Foundation

struct BasicSettingLayout<Decoration: Layout, Title: Layout, Control: Layout> : Layout {    
    /// Decoration representing setting.
    var decoration: Decoration?
    
    /// Title of setting.
    var title: Title?
    
    /// Control for setting.
    var control: Control?
    
    
    init(decoration: Decoration?, title: Title?, control: Control?) {
        self.decoration = decoration
        self.title = title
        self.control = control
    }
    
    mutating func layout(in rect: CGRect) {
        //---Decoration---//
        
        let decorationSize = rect.height / 2
        let decorationMargin: CGFloat = 10
        let decorationFrame = CGRect(x: rect.origin.y + decorationMargin, y: rect.origin.y + rect.size.height / 2 - decorationSize / 2, width: decorationSize, height: decorationSize)
        
        if var decoration = decoration {
            decoration.layout(in: decorationFrame)
        }
        
        //---Control---//
        
        let controlMargin: CGFloat = 10
        let controlWidth = rect.width / 5
        let controlFrame = CGRect(x: rect.width - controlWidth - controlMargin, y: rect.origin.y, width: controlWidth, height: rect.height)
        
        if var control = control {
            control.layout(in: controlFrame)
        }
        

        //---Title---//
        
        let titleMargin: CGFloat = 15
        let titleXOrigin = decorationFrame.origin.x + decorationFrame.width
        let titleFrame = CGRect(x: titleXOrigin + titleMargin, y: rect.origin.y, width: controlFrame.origin.x - titleXOrigin, height: rect.height)
        
        if var title = title {
            title.layout(in: titleFrame)
        }
        
    }
}
