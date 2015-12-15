//
//  RadioPlayer.swift
//  HopeFM
//
//  Created by Sergey Sadovoi on 15.12.15.
//  Copyright © 2016 Hope Media Group Ukraine. All rights reserved.
//

import Foundation
import AVFoundation

class RadioPlayer {
    static let sharedInstance = RadioPlayer()
    private var player = AVPlayer(URL: Config.Stream.Url!)
    private var isPlaying = false
    
    func play() {
        player.play()
        isPlaying = true
    }
    
    func pause() {
        player.pause()
        isPlaying = false
    }
    
    func toggle() {
        if isPlaying == true {
            pause()
        } else {
            play()
        }
    }
    
    func currentlyPlaying() -> Bool {
        return isPlaying
    }
}
