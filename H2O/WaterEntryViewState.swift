//
//  WaterEntryViewState.swift
//  H2O
//
//  Created by Gregory Sapienza on 4/8/17.
//  Copyright © 2017 City Pixels. All rights reserved.
//

import Foundation

struct WaterEntryViewAttributesState: OptionSet {
    let rawValue: Int
    
    static var neverOpenedInformationViewController = WaterEntryViewAttributesState(rawValue: 1)
    static var undoButtonPresenting = WaterEntryViewAttributesState(rawValue: 2)
}

enum WaterEntryPresentingViewState: Int {
    case mainViewControllerPresenting = 1
    case customEntryViewPresenting = 2
    case settingsViewControllerPresenting = 3
    case informationViewControllerPresenting = 4
}

struct WaterEntryViewState {
    var presentingState: WaterEntryPresentingViewState = .mainViewControllerPresenting
    var attributesState: WaterEntryViewAttributesState = []
}
