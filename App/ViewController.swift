//
//  ViewController.swift
//  HopeFM
//
//  Created by Oleg Alekseenko on 13.10.15.
//  Modified by Sergey Sadovoi
//  Copyright © 2015 Hope Media Group Ukraine. All rights reserved.
//

import UIKit
import AVFoundation
import SafariServices
import MessageUI
import AFNetworking
import MediaPlayer
import Foundation

class ViewController: UIViewController, MFMailComposeViewControllerDelegate {

	// MARK: - Properties -
    
	@IBOutlet var playButton: UIButton?
	@IBOutlet var playTextLabel: UILabel?
	@IBOutlet var volumeSlider: MPVolumeView?

	// MARK: - View cirle -

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.

        // Setup Volume Slider
        volumeSlider?.setVolumeThumbImage(UIImage(named: "volumeThumb"), forState: .Normal)
        volumeSlider?.setMinimumVolumeSliderImage(UIImage(named: "volumeMinimum")?.resizableImageWithCapInsets(UIEdgeInsetsMake(0, 3, 0, 0)), forState: .Normal)
        volumeSlider?.setMaximumVolumeSliderImage(UIImage(named: "volumeMaximum")?.resizableImageWithCapInsets(UIEdgeInsetsMake(0, 0, 0, 3)), forState: .Normal)
        volumeSlider?.showsRouteButton = false

        // Setup remote controls
        if NSClassFromString("MPNowPlayingInfoCenter") != nil {
            let songInfo: NSDictionary = [
                MPMediaItemPropertyTitle: "Remote.Title".localized,
                MPMediaItemPropertyArtist: "Remote.Subtitle".localized
            ]
            MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = songInfo as! [String : AnyObject]
        }
        
        // Setup background playing
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        } catch {
            print("AVAudioSession setCategory error")
        }

        // Setup network reachability
        AFNetworkReachabilityManager.sharedManager().startMonitoring()
        AFNetworkReachabilityManager.sharedManager().setReachabilityStatusChangeBlock { (status: AFNetworkReachabilityStatus) -> Void in
            switch status {
            case .NotReachable:
                print("Network not reachable")
                if RadioPlayer.sharedInstance.currentlyPlaying() {
                    self.stopPlaying()
                }
            case .ReachableViaWiFi, .ReachableViaWWAN:
                print("Network is ok")
                if RadioPlayer.sharedInstance.currentlyPlaying() {
                    self.startPlaying(true)
                }
            default:
                break
            }
        }

        self.view.layoutIfNeeded()
	}

    // TODO ??
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		self.volumeSlider?.layer.removeAllAnimations()
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		self.becomeFirstResponder()
	}

//	deinit {
//		player?.currentItem?.removeObserver(self, forKeyPath: "status")
//		NSNotificationCenter.defaultCenter().removeObserver(self)
//	}

	// MARK: - Actions -

    @IBAction func showShare(sender: UIButton) {
        let alertVC = UIAlertController(title: "Social.Title".localized, message: nil, preferredStyle: .ActionSheet)
        
        let fbAction = UIAlertAction(title: "Social.Facebook".localized, style: .Default) { (action) -> Void in
            self.openFacebook()
        }
        
        let vkAction = UIAlertAction(title: "Social.Vk".localized, style: .Default) { (action) -> Void in
            self.openVK()
        }
        
        let twAction = UIAlertAction(title: "Social.Twitter".localized, style: .Default) { (action) -> Void in
            self.openTwitter()
        }
        
        // let pdAction = UIAlertAction(title: "Podster", style: .Default) { (action) -> Void in
        //    self.openPodster()
        // };
        
        let emAction = UIAlertAction(title: "Social.Feedback".localized, style: .Default) { (action) -> Void in
            self.sendMail()
        }
        
        let cancelAction = UIAlertAction(title: "Social.Cancel".localized, style: .Cancel) { (action) -> Void in
            
        }
        
        alertVC.addAction(fbAction)
        alertVC.addAction(vkAction)
        alertVC.addAction(twAction)
        // alertVC.addAction(pdAction)
        alertVC.addAction(emAction)
        alertVC.addAction(cancelAction)
        
        self.presentViewController(alertVC, animated: true, completion: nil)
    }
    
    @IBAction func openWebsite(sender: UIButton) {
        openURL(Config.Urls.Website)
    }

	@IBAction func openFacebook() {
		openURL(Config.Urls.Facebook)
	}

	@IBAction func openPodster() {
		openURL(Config.Urls.Podster)
	}

	@IBAction func openTwitter() {
		openURL(Config.Urls.Twitter)
	}

    @IBAction func openVK() {
        let appURL     = Config.Urls.Vk.App!
        let browserURL = Config.Urls.Vk.Browser!

        if UIApplication.sharedApplication().canOpenURL(appURL) {
            UIApplication.sharedApplication().openURL(appURL)
        } else {
            UIApplication.sharedApplication().openURL(browserURL)
        }
	}

	@IBAction func sendMail() {
		if MFMailComposeViewController.canSendMail() {
			let mailVC = MFMailComposeViewController()
			mailVC.setSubject("Hope.FM Radio App")
			mailVC.setToRecipients(["support@hope.ua"])
			mailVC.mailComposeDelegate = self
			self.presentViewController(mailVC, animated: true, completion: nil)
		}
	}

	func openURL(url: NSURL?) -> () {
		if url != nil {
			if UIApplication.sharedApplication().canOpenURL(url!) {
				UIApplication.sharedApplication().openURL(url!)
			}
		}
	}

	@IBAction func playOrPause(sender: UIButton) -> () {
		if RadioPlayer.sharedInstance.currentlyPlaying() {
			stopPlaying()
        } else {
			startPlaying()
		}
	}

	@IBAction func updateVolume(sender: UISlider) {
		RadioPlayer.sharedInstance.setVolume(sender.value)
	}

//	func playerDidEnded(not: NSNotification) {
//		stopPlaying()
//        print("Player ended")
//	}

//	func playerDidFailed(not: NSNotification) {
//		stopPlaying()
//        print("Player failed")
//		showError("Error.Player".localized)
//	}

    func startPlaying(reset: Bool = false) {
        print("Play start")
		if AFNetworkReachabilityManager.sharedManager().reachable {
            if reset {
                RadioPlayer.sharedInstance.reset()
            }
            RadioPlayer.sharedInstance.play()
			beginRecurciveUpdateTitleUpdate()
            playButton?.selected = true
		} else {
			showError("Error.Network".localized)
		}
	}

	func stopPlaying() {
        print("Play stop")
        RadioPlayer.sharedInstance.pause()
        playButton?.selected = false
    }

	func beginRecurciveUpdateTitleUpdate() {
		let manager = AFURLSessionManager()
		let responseSerializer = AFHTTPResponseSerializer()
		var types = responseSerializer.acceptableContentTypes
		types?.insert("text/plain")
		responseSerializer.acceptableContentTypes = types
		manager.responseSerializer = responseSerializer
		let request = NSURLRequest(URL: Config.Stream.Info!)
		let task = manager.dataTaskWithRequest(request) { (response, data, error) -> Void in
			if (data as? NSData) != nil {
				let text = NSString(data: data as! NSData, encoding: NSUTF8StringEncoding)!
				let components = text.componentsSeparatedByString("-")
				if components.count > 1 {
					self.updateTextLabel(components[0], detail: components[1])
				}
			}

			let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(3 * Double(NSEC_PER_SEC)))
			dispatch_after(delayTime, dispatch_get_main_queue()) {
				if RadioPlayer.sharedInstance.currentlyPlaying() {
					self.beginRecurciveUpdateTitleUpdate()
				}
			}
		}
		task.resume()
	}

	func updateTextLabel(title: String?, var detail: String?) {
		let string = NSMutableAttributedString()
		if title != nil {
			let atributes = [
				NSFontAttributeName : UIFont.systemFontOfSize(20.0, weight: UIFontWeightSemibold)
			]

			let titleString = NSAttributedString(string: title!, attributes: atributes )
			string.appendAttributedString(titleString)
		}

		if detail != nil {
			if title != nil {
				detail = "\n\(detail!)"
			}
			let atributes = [
				NSFontAttributeName : UIFont.systemFontOfSize(16.0, weight: UIFontWeightUltraLight)
			]

			let detailString = NSAttributedString(string: detail!, attributes: atributes)
			string.appendAttributedString(detailString)
		}

		self.playTextLabel?.attributedText = string
	}

    func showError(msg: String?) {
        let attributes = [
            NSFontAttributeName : UIFont.systemFontOfSize(20.0, weight: UIFontWeightSemibold),
            NSForegroundColorAttributeName: UIColor(red: 255.0 / 255.0, green: 0, blue: 0, alpha: 0.7)
        ]
        let message = NSAttributedString(string: msg!, attributes: attributes)
        
        self.playTextLabel?.attributedText = message
    }

	override func remoteControlReceivedWithEvent(event: UIEvent?) {
		if event!.type == UIEventType.RemoteControl {
			switch event!.subtype {
			case UIEventSubtype.RemoteControlPlay:
				startPlaying()
                print("Remote Play")
			case UIEventSubtype.RemoteControlPause:
				stopPlaying()
                print("Remote Pause")
			default: break
			}
		}
	}

	// MARK: - MFMailComposeDelegate -

	func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
		controller.dismissViewControllerAnimated(true, completion: nil)
	}
}
