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
    
    public func playAudio(fileName :String, fileExtension :String, repeatEnabled :Bool) {
        let backgroundQueue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
        dispatch_async(backgroundQueue, {
            let url : NSURL = NSBundle.mainBundle().URLForResource(fileName, withExtension: fileExtension)!
            self._audioPlayer = try! AVAudioPlayer(contentsOfURL: url)
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
