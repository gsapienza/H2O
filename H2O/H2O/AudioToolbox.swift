//
//  AudioToolbox.swift
//  BakingKit
//
//  Created by Gregory Sapienza on 5/3/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import UIKit
import AVFoundation

public class AudioToolbox: NSObject {
    
    /// Singleton for the audio toolbox
    public static let standardAudioToolbox = AudioToolbox()
    
    private override init() {
        super.init()
    }
    
    /// Audio player for sounds
    private var audioPlayer: AVAudioPlayer!
    
    /// Play audio in main bundle
    ///
    /// - parameter fileName:      Name of audio file
    /// - parameter fileExtension: Extension of audio file
    /// - parameter repeatEnabled: Option to repeat audio
    public func playAudio(_ fileName :String, fileExtension :String, repeatEnabled :Bool) {
        let backgroundQueue = DispatchQueue.global(qos: DispatchQoS.background.qosClass)
        backgroundQueue.async(execute: {
            let url :URL = Bundle.main.url(forResource: fileName, withExtension: fileExtension)!
            self.audioPlayer = try! AVAudioPlayer(contentsOf: url)
            if repeatEnabled {
                self.audioPlayer.numberOfLoops = -1
            }
            self.audioPlayer.play()
        })
    }
    
    /// Stop repeating audio from playing
    public func stopAudio() {
        audioPlayer.stop()
    }
}
