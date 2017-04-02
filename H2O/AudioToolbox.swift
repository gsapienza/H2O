//
//  AudioToolbox.swift
//  BakingKit
//
//  Created by Gregory Sapienza on 5/3/16.
//  Copyright © 2016 City Pixels. All rights reserved.
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
    /// - parameter fileName:      Name of audio file with extension
    /// - parameter repeatEnabled: Option to repeat audio
    public func playAudio(_ fileName: String, repeatEnabled: Bool) {
        let backgroundQueue = DispatchQueue.global(qos: DispatchQoS.background.qosClass)
        backgroundQueue.async(execute: {
            let fileNameSeperated = fileName.components(separatedBy: ".")
            let url: URL = Bundle.main.url(forResource: fileNameSeperated.first, withExtension: fileNameSeperated.last)!
            do {
                self.audioPlayer = try AVAudioPlayer(contentsOf: url)
                self.audioPlayer.volume = 0.4
                
                if repeatEnabled {
                    self.audioPlayer.numberOfLoops = -1
                }
                self.audioPlayer.prepareToPlay()
                self.audioPlayer.play()
            } catch {
                NSLog("Audio player could not be initialized.")
            }
        })
    }
    
    /// Stop repeating audio from playing
    public func stopAudio() {
        audioPlayer.stop()
    }
}
