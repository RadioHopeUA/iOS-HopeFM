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
    
    func reset() {
        print("Inner Play reset")
        player.replaceCurrentItemWithPlayerItem(AVPlayerItem(URL: Config.Stream.Url!))
    }
    
    func play() {
        print("Inner Play start")
        player.play()
        isPlaying = true
    }
    
    func pause() {
        print("Inner Play pause")
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
    
    func setVolume(volume: Float) {
        player.volume = volume
    }
    
    func getPlayer() -> AVPlayer {
        return player
    }
}
