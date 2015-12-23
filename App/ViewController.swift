//
//  ViewController.swift
//  HopeFM
//
//  Created by Oleg Alekseenko on 13.10.15.
//  Modified by Sergey Sadovoi
//  Copyright © 2016 Hope Media Group Ukraine. All rights reserved.
//

import UIKit
import MessageUI
import MediaPlayer

class ViewController: UIViewController, MFMailComposeViewControllerDelegate {

	// MARK: - Properties -

	@IBOutlet var playButton: UIButton?
	@IBOutlet var playTextLabel: UILabel?
	@IBOutlet var volumeSlider: MPVolumeView?

	// MARK: - View cirle -

	override func viewDidLoad() {
		super.viewDidLoad()

        volumeSlider?.setVolumeThumbImage(UIImage(named: "volumeThumb"), forState: .Normal)
        volumeSlider?.setMinimumVolumeSliderImage(UIImage(named: "volumeMinimum")?.resizableImageWithCapInsets(UIEdgeInsetsMake(0, 3, 0, 0)), forState: .Normal)
        volumeSlider?.setMaximumVolumeSliderImage(UIImage(named: "volumeMaximum")?.resizableImageWithCapInsets(UIEdgeInsetsMake(0, 0, 0, 3)), forState: .Normal)
        volumeSlider?.showsRouteButton = false
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)

		let notificationCenter = NSNotificationCenter.defaultCenter()

		notificationCenter.addObserverForName(RadioPlayerNotification.DidBecomeReady, object: nil, queue: nil, usingBlock: { [weak self] (notification: NSNotification) -> Void  in
			self?.updateUI()
			self?.showError(nil)
			})

		notificationCenter.addObserverForName(RadioPlayerNotification.DidStart, object: nil, queue: nil, usingBlock: { [weak self] (notification: NSNotification) -> Void  in
			self?.updateUI()
		})

		notificationCenter.addObserverForName(RadioPlayerNotification.DidPause, object: nil, queue: nil, usingBlock: { [weak self] (notification: NSNotification) -> Void  in
			self?.updateUI()
			})

		notificationCenter.addObserverForName(RadioPlayerNotification.DidFail, object: nil, queue: nil, usingBlock: { [weak self] (notification: NSNotification) -> Void  in
			self?.updateUI()
			self?.showError(notification.userInfo?["Error"] as? String)
			})

		notificationCenter.addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil, queue: nil, usingBlock: { [weak self] (notification: NSNotification) -> Void  in
			self?.updateUI()
			})
	}

	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)

		NSNotificationCenter.defaultCenter().removeObserver(self)
	}

	private func updateUI() {
		playButton?.selected = RadioPlayer.sharedPlayer.isPlaying()
	}
    
	// MARK: - Actions -

	@IBAction func onPlay(sender: UIButton) -> () {
		RadioPlayer.sharedPlayer.toggle()
	}

	private func showError(message: String?) {
		if let message = message {
			self.playTextLabel?.attributedText = NSAttributedString(string: message.localized, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(20.0, weight: UIFontWeightSemibold), NSForegroundColorAttributeName: UIColor(hex: 0xff0000)])
		} else {
			self.playTextLabel?.attributedText = nil
		}
	}

//    func startPlaying(reset: Bool = false) {
//		if AFNetworkReachabilityManager.sharedManager().reachable {
//            if reset {
//                RadioPlayer.sharedInstance.reset()
//            }
//            RadioPlayer.sharedPlayer.play()
//			beginRecurciveUpdateTitleUpdate()
//            playButton?.selected = true
//		} else {
//			showError("Error.Network".localized)
//		}
//	}
//
//	func stopPlaying() {
//        RadioPlayer.sharedInstance.pause()
//        playButton?.selected = false
//    }
//
//	func beginRecurciveUpdateTitleUpdate() {
//		let manager = AFURLSessionManager()
//		let responseSerializer = AFHTTPResponseSerializer()
//		var types = responseSerializer.acceptableContentTypes
//		types?.insert("text/plain")
//		responseSerializer.acceptableContentTypes = types
//		manager.responseSerializer = responseSerializer
//		let request = NSURLRequest(URL: Config.Stream.Info!)
//		let task = manager.dataTaskWithRequest(request) { (response, data, error) -> Void in
//			if (data as? NSData) != nil {
//				let text = NSString(data: data as! NSData, encoding: NSUTF8StringEncoding)!
//				let components = text.componentsSeparatedByString("-")
//				if components.count > 1 {
//					self.updateTextLabel(components[0], detail: components[1])
//				}
//			}
//
//			let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(3 * Double(NSEC_PER_SEC)))
//			dispatch_after(delayTime, dispatch_get_main_queue()) {
//				if RadioPlayer.sharedInstance.currentlyPlaying() {
//					self.beginRecurciveUpdateTitleUpdate()
//				}
//			}
//		}
//		task.resume()
//	}
//
//	func updateTextLabel(title: String?, var detail: String?) {
//		let string = NSMutableAttributedString()
//		if title != nil {
//			let atributes = [
//				NSFontAttributeName : UIFont.systemFontOfSize(20.0, weight: UIFontWeightSemibold)
//			]
//
//			let titleString = NSAttributedString(string: title!, attributes: atributes )
//			string.appendAttributedString(titleString)
//		}
//
//		if detail != nil {
//			if title != nil {
//				detail = "\n\(detail!)"
//			}
//			let atributes = [
//				NSFontAttributeName : UIFont.systemFontOfSize(16.0, weight: UIFontWeightUltraLight)
//			]
//
//			let detailString = NSAttributedString(string: detail!, attributes: atributes)
//			string.appendAttributedString(detailString)
//		}
//
//		self.playTextLabel?.attributedText = string
//	}

	// MARK: - Sharing -

	@IBAction func onShare(sender: UIButton) {
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

		let emAction = UIAlertAction(title: "Social.Feedback".localized, style: .Default) { (action) -> Void in
			self.sendMail()
		}

		let cancelAction = UIAlertAction(title: "Social.Cancel".localized, style: .Cancel) { (action) -> Void in

		}

		alertVC.addAction(fbAction)
		alertVC.addAction(vkAction)
		alertVC.addAction(twAction)
		alertVC.addAction(emAction)
		alertVC.addAction(cancelAction)

		self.presentViewController(alertVC, animated: true, completion: nil)
	}

	@IBAction func onOpenWebsite(sender: UIButton) {
		openURL(Config.Urls.Website)
	}

	private func openFacebook() {
		openURL(Config.Urls.Facebook)
	}

	private func openPodster() {
		openURL(Config.Urls.Podster)
	}

	private func openTwitter() {
		openURL(Config.Urls.Twitter)
	}

	private func openVK() {
		let appURL     = Config.Urls.Vk.App!
		let browserURL = Config.Urls.Vk.Browser!

		if UIApplication.sharedApplication().canOpenURL(appURL) {
			UIApplication.sharedApplication().openURL(appURL)
		} else {
			UIApplication.sharedApplication().openURL(browserURL)
		}
	}

	private func sendMail() {
		if MFMailComposeViewController.canSendMail() {
			let mailVC = MFMailComposeViewController()
			mailVC.setSubject("Hope.FM Radio App")
			mailVC.setToRecipients(["support@hope.ua"])
			mailVC.mailComposeDelegate = self
			self.presentViewController(mailVC, animated: true, completion: nil)
		}
	}

	private func openURL(url: NSURL?) -> () {
		if let url = url {
			if UIApplication.sharedApplication().canOpenURL(url) {
				UIApplication.sharedApplication().openURL(url)
			}
		}
	}

	// MARK: - MFMailComposeDelegate -

	func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
		controller.dismissViewControllerAnimated(true, completion: nil)
	}
}
