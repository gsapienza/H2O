//
//  CENAudioToolbox.swift
//  CenifyKit
//
//  Created by Gregory Sapienza on 5/3/16.
//  Copyright © 2016 Cenify. All rights reserved.
//

import UIKit
import AVFoundation

public class CENAudioToolbox: NSObject {
    
    public static let standardAudioToolbox = CENAudioToolbox()
    
    /// Audio player for sounds
    private var _audioPlayer: AVAudioPlayer!
    
    public func playAudio(_ fileName :String, fileExtension :String, repeatEnabled :Bool) {
        let backgroundQueue = DispatchQueue.global(attributes: DispatchQueue.GlobalAttributes(rawValue: UInt64(Int(UInt64(DispatchQueueAttributes.qosBackground.rawValue)))))
        backgroundQueue.async(execute: {
            let url : URL = Bundle.main().urlForResource(fileName, withExtension: fileExtension)!
            self._audioPlayer = try! AVAudioPlayer(contentsOf: url)
            if repeatEnabled {
                self._audioPlayer.numberOfLoops = -1
            }
            self._audioPlayer.play()
        })
    }
    
    public func stopAudio() {
        _audioPlayer.stop()
    }
}
