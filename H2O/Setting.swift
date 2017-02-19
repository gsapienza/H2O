//
//  Setting.swift
//  H2O
//
//  Created by Gregory Sapienza on 2/12/17.
//  Copyright © 2017 Skyscrapers.IO. All rights reserved.
//

import Foundation

enum SettingType {
    case toggleSwitch(onAction: () -> (), offAction: () -> ())
    case presetValueChanger(labelValue: String, doneAction: (_ value :Float) -> ())
    case button
}

class Setting {
    
    /// Image name for image representing setting.
    var imageName: String
    
    /// Title of setting.
    var title: String
    
    /// Control of setting.
    var controlType: SettingType
    
    init(imageName: String, title: String, controlType: SettingType) {
        self.imageName = imageName
        self.title = title
        self.controlType = controlType
    }
}
