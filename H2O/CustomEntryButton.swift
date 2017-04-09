//
//  CustomEntryButton.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/16/16.
//  Copyright © 2016 City Pixels. All rights reserved.
//

import UIKit

class CustomEntryButton: EntryButton {
    //MARK: - Public iVars
    
    /// Makes the amount readonly. Setting a preset for a custom button wouldn't make sense.
    override var amount: Double {
        set{}
        get {
            return super.amount
        }
    }
}
