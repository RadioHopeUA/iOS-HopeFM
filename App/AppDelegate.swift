//
//  AppDelegate.swift
//  Hope.FM
//
//  Created by Sergey Sadovoi on 14.12.15.
//  Copyright © 2016 Hope Media Group Ukraine. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

		try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
		try! AVAudioSession.sharedInstance().setActive(true)
		MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [
			MPMediaItemPropertyTitle: "Remote.Title".localized,
			MPMediaItemPropertyArtist: "Remote.Subtitle".localized
		]

		return true
	}

	func applicationDidBecomeActive(application: UIApplication) {
		UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
	}

	func applicationWillTerminate(application: UIApplication) {
		UIApplication.sharedApplication().endReceivingRemoteControlEvents()
	}

	override func remoteControlReceivedWithEvent(event: UIEvent?) {
		if let event = event {
			switch (event.type, event.subtype) {
			case (.RemoteControl, .RemoteControlPlay), (.RemoteControl, .RemoteControlPause):
				RadioPlayer.sharedPlayer.toggle()
			default: break
			}
		}
	}
}
