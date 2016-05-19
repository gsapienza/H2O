//
//  CustomEntryButton.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/16/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit

class CustomEntryButton: EntryButton {
        /// Makes the amount just a getter. Because setting a preset for a custom button wouldnt make sense
    override var _amount: Float {
        set{}
        get {
            return super._amount
        }
    }
    
    /**
     When the user taps the custom button
     */
    override func onTap() {
        CENAudioToolbox.standardAudioToolbox.playAudio("b4", fileExtension: "wav", repeatEnabled: false)

        _delegate?.customEntryButtonTapped(self) //Tell the delegate that custom button was tapped
    }
}
