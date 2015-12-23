//
//  RadioPlayer.swift
//  HopeFM
//
//  Created by Sergey Sadovoi on 15.12.15.
//  Copyright © 2016 Hope Media Group Ukraine. All rights reserved.
//

import Foundation
import AVFoundation
import AFNetworking

struct RadioPlayerNotification {
	static let DidBecomeReady = "RadioPlayerDidBecomeReady"
	static let DidStart = "RadioPlayerDidStart"
	static let DidPause = "RadioPlayerDidPause"
	static let DidFail = "RadioPlayerDidFail"
}

class RadioPlayer: NSObject {
    static let sharedPlayer = RadioPlayer()
    private var _player = AVPlayer(URL: Config.Stream.Url!)
	private var _playerContext = 0

	override init() {
		super.init()
		
		_player.addObserver(self, forKeyPath: "status", options: .New, context: &_playerContext)

		AFNetworkReachabilityManager.sharedManager().startMonitoring()
		AFNetworkReachabilityManager.sharedManager().setReachabilityStatusChangeBlock { [weak self] (status: AFNetworkReachabilityStatus) -> Void in
			switch status {
			case .ReachableViaWiFi, .ReachableViaWWAN:
				NSNotificationCenter.defaultCenter().postNotificationName(RadioPlayerNotification.DidBecomeReady, object: nil)
			case .NotReachable:
				self?.fail("Error.Network")
			default:
				break
			}
		}
	}

    func toggle() {
        if isPlaying() {
            pause()
        } else if .ReadyToPlay == _player.status {
			play()
		} else {
			_player.replaceCurrentItemWithPlayerItem(AVPlayerItem.init(URL: Config.Stream.Url!))
		}
    }

    func isPlaying() -> Bool {
        return _player.rate > 0.0
    }

	private func play() {
		_player.play()
		NSNotificationCenter.defaultCenter().postNotificationName(RadioPlayerNotification.DidStart, object: nil)
	}

	private func pause() {
		_player.pause()
		NSNotificationCenter.defaultCenter().postNotificationName(RadioPlayerNotification.DidPause, object: nil)
	}

	private func fail(message: String?) {
		_player.pause()
		if let message = message {
			NSNotificationCenter.defaultCenter().postNotificationName(RadioPlayerNotification.DidFail, object: nil, userInfo: ["Error" : message])
		} else {
			NSNotificationCenter.defaultCenter().postNotificationName(RadioPlayerNotification.DidFail, object: nil)
		}
	}

	override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
		if &_playerContext == context {
			if let status = change?[NSKeyValueChangeNewKey] as? AVPlayerStatus {
				switch status {
					case .ReadyToPlay:
						NSNotificationCenter.defaultCenter().postNotificationName(RadioPlayerNotification.DidBecomeReady, object: nil)
					case .Failed:
						fail(_player.currentItem?.error?.localizedDescription)
					default: break
					}
			}
		} else {
			super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
		}
	}
}
