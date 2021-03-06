//
//  CustomEntryButton.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/16/16.
//  Copyright © 2016 Midnite. All rights reserved.
//

import UIKit

class CustomEntryButton: EntryButton {
    //MARK: - Public iVars
    
    /// Makes the amount just a getter. Because setting a preset for a custom button wouldnt make sense
    override var amount: Float {
        set{}
        get {
            return super.amount
        }
    }
}

//MARK: - Target Action
extension CustomEntryButton {
    ///When the user taps the custom button
    override func onTap() {
        AudioToolbox.standardAudioToolbox.playAudio(LightClickSound, repeatEnabled: false)
        
        delegate?.customEntryButtonTapped(customButton: self) //Tell the delegate that custom button was tapped
    }
}
