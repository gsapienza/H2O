//
//  Setting.swift
//  H2O
//
//  Created by Gregory Sapienza on 2/12/17.
//  Copyright © 2017 Skyscrapers.IO. All rights reserved.
//

import Foundation

enum SettingType {
    case button
    case toggleSwitch(onAction: () -> Void, offAction: () -> Void)
    case presetValue
}

struct Setting {
    
    /// Image name for image representing setting.
    var imageName: String
    
    /// Title of setting.
    var title: String
    
    /// Type of setting.
    var type: SettingType
}
