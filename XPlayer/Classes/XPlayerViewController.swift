//
//  XPlayerViewController.swift
//  XPlayer
//
//  Created by duan on 16/6/21.
//  Copyright © 2016年 monk-studio. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Photos

class XPlayerViewController: WOViewController {
	// UI
    let playerVC = AVPlayerViewController.init(nibName: nil, bundle: nil)
    var url = ""
    var speed = ""
	let playButtton = UIButton()
    let speedButton_05 = UIButton()
    let speedButton_1 = UIButton()
    let speedButton_15 = UIButton()
    let speedButton_2 = UIButton()
	let fullScreenButton = UIButton()
	let closeButton = UIButton()
    let minButton = UIButton()
	let timelineLabel = UILabel()
	let timelineViewContainer = UIView()
	let timelineView = UIView()
	let timelineProgressedView = UIView()
	let timelineDotView = UIView()
	let topGradientLayer = CAGradientLayer()
	let bottomGradientLayer = CAGradientLayer()
	// Gesture
	var sliderPanGesture: UIPanGestureRecognizer!
	var toggleControlTapGesture: UITapGestureRecognizer!
	// State
	var progress: CGFloat = 0 {
		didSet {
			timelineProgressedView.frame = CGRect(x: 0, y: 0, width: self.timelineView.bounds.width * self.progress, height: 2)
			timelineDotView.center = CGPoint(
				x: self.timelineProgressedView.bounds.width,
				y: self.timelineProgressedView.bounds.height / 2
			)
		}
	}
	var showingControls = true

	let themeColor: UIColor
	
	init(url: URL, themeColor: UIColor){
		self.themeColor = themeColor
		super.init()
		let playerItem = AVPlayerItem(url: url)
        self.url = url.absoluteString
		
        
        self.playerVC.player = AVPlayer(playerItem: playerItem)
        self.playerVC.allowsPictureInPicturePlayback = true
        //self.pip = AVPictureInPictureController.init(playerLayer: self.playerVC.player)
        self.playerVC.view.backgroundColor = UIColor.black
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
    
    
    override var canBecomeFirstResponder: Bool {
        return false
    }
    
    override var inputAccessoryView: UIView? {
        return nil
    }
    
	override func viewDidLoad() {
		super.viewDidLoad()
        
        
        if #available(iOS 10.0, *) {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            } catch {
            }
        } else {
            //Fallback on earlier versions
        }
        

		self.setupUI()
		// Action
        speedButton_05.addTarget(self, action: #selector(togglePlaySpeed05), for: .touchUpInside)
        speedButton_1.addTarget(self, action: #selector(togglePlaySpeed1), for: .touchUpInside)
        speedButton_15.addTarget(self, action: #selector(togglePlaySpeed15), for: .touchUpInside)
        speedButton_2.addTarget(self, action: #selector(togglePlaySpeed2), for: .touchUpInside)
		playButtton.addTarget(self, action: #selector(togglePlay), for: .touchUpInside)
		fullScreenButton.addTarget(self, action: #selector(toggleOrientationSwitch), for: .touchUpInside)
		closeButton.addTarget(self, action: #selector(didPressClose), for: .touchUpInside)
		// Gesture
		sliderPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleSliderPan))
		timelineViewContainer.addGestureRecognizer(sliderPanGesture)
        
        
		toggleControlTapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleShowControls))
		view.addGestureRecognizer(toggleControlTapGesture)
		// State
		transitionPanGesture.isEnabled = false
        
        let closeTap = UITapGestureRecognizer.init(target: self, action: #selector(tapClose))
        closeTap.numberOfTapsRequired = 2
        closeTap.numberOfTouchesRequired = 1

        //let pauseTap = UITapGestureRecognizer.init(target: self, action: #selector(tapPause))
        //pauseTap.numberOfTapsRequired = 1
        //pauseTap.numberOfTouchesRequired = 1
        
        view.addGestureRecognizer(closeTap)
        //view.addGestureRecognizer(pauseTap)
        
        
        
        /*
        UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleDoubleTap:)];
        doubleTapGesture.numberOfTapsRequired =2;
        doubleTapGesture.numberOfTouchesRequired =1;
        [bgView addGestureRecognizer:doubleTapGesture];
         */


        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longpress(_:)))
        longPressRecognizer.minimumPressDuration = 1
        longPressRecognizer.delaysTouchesBegan = true
        view.addGestureRecognizer(longPressRecognizer)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		playerVC.player!.addObserver(self,
		                             forKeyPath: "rate",
		                             options: [.new],
		                             context: nil)
		playerVC.player!.currentItem!.addObserver(self, forKeyPath: "status", options: [.new], context: nil)
        playerVC.player!.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 1), queue: nil) { [weak self] (time) in
			guard let timecode = self?.playerVC.player?.currentItem?.duration.timecode() else { return }
			guard let currentTimecode = self?.playerVC.player?.currentItem?.currentTime().timecode() else { return }
			self?.timelineLabel.text = currentTimecode + " / " + timecode
		}
        playerVC.player!.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 100), queue: nil) { [weak self] (time) in
			guard let timecode = self?.playerVC.player?.currentItem?.duration else { return }
			guard let currentTimecode = self?.playerVC.player?.currentItem?.currentTime() else { return }
			let percentage = CMTimeGetSeconds(currentTimecode) / CMTimeGetSeconds(timecode)
			if !percentage.isNaN {
				self?.progress = CGFloat(percentage)
			}
		}
        NotificationCenter.default.addObserver(self, selector: #selector(handleOrientationChange), name: UIDevice.orientationDidChangeNotification, object: nil)
		playerVC.player?.play()
	}
	
	override func viewDidLayoutSubviews() {
		topGradientLayer.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
		bottomGradientLayer.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
	}
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		// play & stop
		if keyPath == "rate" {
			guard let rate = change?[NSKeyValueChangeKey.newKey] as? Float else { return }
			if rate == 0 {
				// stopped & lag
				playButtton.setImage(UIImage.bundleImage("play_24")?.withRenderingMode(.alwaysTemplate), for: .normal)
			}
			if rate == 1.0 {
				// start play
				playButtton.setImage(UIImage.bundleImage("pause_24")?.withRenderingMode(.alwaysTemplate), for: .normal)
			}
		}
		// finish loading
		if keyPath == "status" {
            if playerVC.player!.currentItem!.status == AVPlayerItem.Status.readyToPlay {
				self.timelineViewContainer.isUserInteractionEnabled = true
				if let presentationSize = self.playerVC.player?.currentItem?.presentationSize , presentationSize != CGSize.zero {
					let pipHeight = WOMaintainerInfo.pipDefaultSize.width * presentationSize.height / presentationSize.width
					let pipSize = CGSize(width: WOMaintainerInfo.pipDefaultSize.width, height: pipHeight)
					self.PIPRect = WOMaintainerInfo.pipRect(size: pipSize)
				}
				self.transitionPanGesture.isEnabled = true
			}
            if playerVC.player!.currentItem!.status == AVPlayerItem.Status.failed {
			}
		}
	}
	
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return [.landscape, .portrait]
	}
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
    
    
    @objc  func longpress(_ sender: UIGestureRecognizer){
        
        self.didPressClose()
        
        /*
         if sender.state == .began {
         
         let alert = UIAlertController()
         
         let videoLink = self.url
         let saveVideo = UIAlertAction(title: "下载视频", style: .default, handler: {
         [weak self] ACTION in
         guard let self = self else { return }
         
         DispatchQueue.global(qos: .background).async {
         if let url = URL(string: videoLink),
         let urlData = NSData(contentsOf: url) {
         let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
         let ts = Date().timeIntervalSince1970
         let filePath = "\(documentsPath)/\(ts).mp4"
         DispatchQueue.main.async {
         urlData.write(toFile: filePath, atomically: true)
         PHPhotoLibrary.shared().performChanges({
         PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: filePath))
         }) { [weak self] completed, error in
         guard let self = self else { return }
         
         if error != nil {
         } else {
         if completed {
         }
         }
         }
         }
         }
         }
         })
         
         let cancle = UIAlertAction(title: "取消", style: .cancel, handler: {
         [weak self] ACTION in
         guard let self = self else { return }
         })
         
         alert.addAction(saveVideo)
         alert.addAction(cancle)
         
         if UIDevice.current.userInterfaceIdiom == .pad {
         
         alert.popoverPresentationController?.sourceView = self.view
         alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
         
         }
         
         /*
         let alertWindow = UIWindow(frame: UIScreen.main.bounds)
         alertWindow.rootViewController = UIViewController()
         alertWindow.windowLevel = UIWindowLevelAlert - 1
         alertWindow.makeKeyAndVisible()
         alertWindow.rootViewController?.present(alert, animated: true, completion: nil)
         */
         
         var rootViewController = UIApplication.shared.keyWindow?.rootViewController
         if let tab = rootViewController as? UITabBarController {
             rootViewController = tab.selectedViewController
             let nav = rootViewController as? UINavigationController
                 if nav != nil {
                    
                     let vc = nav!.topViewController
                    if vc != nil {
                        if vc!.presentedViewController != nil {
                            let v = vc!.presentedViewController
                            v!.present(alert, animated: true, completion: nil)
                        } else {
                            vc!.present(alert, animated: true, completion: nil)
                        }
                        
                    }
                 }
             }

         }
         
         */
    }
   
}

// MARK: Utils
extension CMTime {
	func timecode() -> String? {
		let totalSeconds = CMTimeGetSeconds(self)
		if totalSeconds.isNaN { return nil }
		let minutes = Int(floor(CGFloat(totalSeconds) / 60))
		let seconds = Int(totalSeconds) % 60
		if minutes < 0 || seconds < 0 { return nil }
		let minuteString = minutes >= 10 ? "\(minutes)" : "0\(minutes)"
		let secondString = seconds >= 10 ? "\(seconds)" : "0\(seconds)"
		return minuteString + ":" + secondString
	}
}
