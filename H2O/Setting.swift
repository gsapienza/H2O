//
//  Setting.swift
//  H2O
//
//  Created by Gregory Sapienza on 2/12/17.
//  Copyright © 2017 Skyscrapers.IO. All rights reserved.
//

import Foundation

class Setting {
    
    /// Image name for image representing setting.
    var imageName: String
    
    /// Title of setting.
    var title: String
    
    /// Control of setting.
    var action: () -> ()
    
    var control: AnyObject
    
    init(imageName: String, title: String, control: AnyObject, action: @escaping () -> ()) {
        self.imageName = imageName
        self.title = title
        self.control = control
        self.action = action
        
        setControlAction()
    }
}
