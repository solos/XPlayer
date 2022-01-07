//
//  XPlayerViewController + Action.swift
//  XPlayer
//
//  Created by duan on 16/9/19.
//  Copyright © 2016年 monk-studio. All rights reserved.
//

import UIKit
import AVFoundation

// MARK: Action
extension XPlayerViewController {
	@objc func handleSliderPan(gesture: UIPanGestureRecognizer) {
		let locationInTimelineView = gesture.location(in: timelineView)
        
       
		switch gesture.state {
		case .began:
			//trigger control
			handleTouchInTimelineView(location: locationInTimelineView)
			playerVC.player!.pause()
		case .changed:
			handleTouchInTimelineView(location: locationInTimelineView)
		case .ended, .cancelled:
			let targetTime = CMTimeGetSeconds(self.playerVC.player!.currentItem!.duration) * Double(self.progress)
            playerVC.player!.seek(to: CMTimeMakeWithSeconds(targetTime, preferredTimescale: 1), completionHandler: { _ in
				self.playerVC.player!.play()
			})
		default: break
		}
	}
	
	private func handleTouchInTimelineView(location: CGPoint) {
        let properLocationX = Swift.min(max(location.x, 0), self.timelineView.bounds.width)
		self.progress = properLocationX / self.timelineView.bounds.width
		// update timeline text
		let totalTime = Float64(CMTimeGetSeconds(self.playerVC.player!.currentItem!.duration))
		guard let totalTimeString = self.playerVC.player!.currentItem!.duration.timecode() else { return }
		let currentTime = totalTime * Float64(self.progress)
        guard let currentTimeString = CMTimeMakeWithSeconds(currentTime, preferredTimescale: 1).timecode() else { return }
		self.timelineLabel.text = currentTimeString + " / " + totalTimeString
	}
    
    @objc func handleRight(gesture: UISwipeGestureRecognizer){
        
    }
    
    
    @objc func tapClose(gesture: UIPanGestureRecognizer){

        //let location = gesture.location(in: self.view)

        if gesture.state != .ended {
            return
        }
        let v = gesture.velocity(in: self.playerVC.view)
        
        /*
        if (v.y < 0) {
            //up
            self.didPressClose()
            return
        }
         */
    }

    @objc func tapPause(gesture: UITapGestureRecognizer){
        self.togglePlay()

    }
    
	@objc func toggleShowControls(gesture: UITapGestureRecognizer) {
		if gesture.state != .ended { return }
		let location = gesture.location(in: self.view)
		if location.y > playButtton.frame.minY || location.y < closeButton.frame.maxY { return }
		if showingControls {
			showingControls = false
			UIView.animate(withDuration: 0.3){ [weak self] in
				guard let _self = self else { return }
				[
					_self.playButtton,
                    _self.speedButton,
                    _self.fullScreenButton,
					_self.timelineLabel, _self.timelineViewContainer
				].forEach({ (view) in
					view.layer.transform = CATransform3DMakeTranslation(0, 30, 0)
					view.alpha = 0
				})
				self?.topGradientLayer.transform = CATransform3DMakeTranslation(0, -UIScreen.main.bounds.height, 0)
				self?.bottomGradientLayer.transform = CATransform3DMakeTranslation(0, UIScreen.main.bounds.height, 0)
				self?.closeButton.layer.transform = CATransform3DMakeTranslation(0, -50, 0)
				self?.closeButton.alpha = 0
                
			}
		} else {
			showingControls = true
			UIView.animate(withDuration: 0.3){ [weak self] in
				guard let _self = self else { return }
				[
					_self.playButtton,
                    _self.fullScreenButton,
					_self.timelineLabel, _self.timelineViewContainer,
					_self.speedButton, _self.closeButton
				].forEach { (view) in
					view.layer.transform = CATransform3DIdentity
					view.alpha = 1
				}
				[
					_self.bottomGradientLayer,
					_self.topGradientLayer
				].forEach({ (layer) in
					layer.transform = CATransform3DIdentity
				})
			}
		}
	}
	
    
    @objc func toggleSpeed() {
        //form speed todo
        
        let alert = UIAlertController()
        alert.title = "播放倍速设置"
        //alert.view.backgroundColor = ThemeManager.sharedInstance.theme.viewBackground
        //alert.view.tintColor = ThemeManager.sharedInstance.theme.text
        
        let speedMap: [String: Float] = ["0.5倍": 0.5, "0.75倍": 0.75, "正常": 1, "1.25倍": 1.25, "1.5倍": 1.5, "1.75倍": 1.75, "2倍": 2]
        
        var sorted:[String] = ["0.5倍", "0.75倍", "正常", "1.25倍", "1.5倍", "1.75倍", "2倍"]
        sorted.reverse()

        for k in sorted {
            guard let  v = speedMap[k] else { continue }
            var item: UIAlertAction
            item = UIAlertAction(title: k, style: .default, handler: {
                [weak self] ACTION in
                guard let self = self else { return }
                
                self.updateSpeed(speed: v, title: k)
                //set speed
                alert.hide()
            })
            
            if (v == self.speed){
                item.setValue(UIColor.red, forKey: "titleTextColor")
            }
            alert.addAction(item)
        }
        
        let cancle = UIAlertAction(title: "取消", style: .cancel, handler: {
            [weak self] ACTION in
            guard let _ = self else { return }
            
            alert.hide()
        })
        
        alert.addAction(cancle)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            if let popoverController = alert.popoverPresentationController {
                popoverController.sourceView = self.speedButton
                popoverController.sourceRect = self.speedButton.frame
            }
        }
        

        alert.show()
        //let window = UIApplication.shared.keyWindow
        //guard let window = UIApplication.shared.windows.first else { return }
        
        //window.addSubview(alert.view)
        /*

        window.rootViewController?.present(alert, animated: true, completion: {
            alert.view.superview?.subviews.first?.isUserInteractionEnabled = true
            alert.view.superview?.subviews.first?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        })
         */
        //alert.show()
        
        /*
        if #available(iOS 13.0, *) {
            if var topController = UIApplication.shared.keyWindow?.rootViewController  {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                topController.present(alert, animated: true, completion: nil)
            }
        }
         */

    }
    
    @objc func alertControllerBackgroundTapped()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
	@objc func togglePlay() {

        let state = playerVC.player!.timeControlStatus
        if self.progress == 1 && state != .playing {
            self.progress = 0
            
           
            playerVC.player!.seek(to: CMTime.zero)
            playerVC.player!.play()
            self.resetSpeed()
            return
        }

        if  state == .playing || state == .waitingToPlayAtSpecifiedRate {
            playerVC.player!.pause()
		} else {
            playerVC.player!.play()
            self.resetSpeed()
		}
	}
    
    func resetSpeed(){
        let title = self.speedButton.currentTitle
        if title == "倍速" {
            self.updateSpeed(speed: 1, title: "")
        } else {
            let speedTitle = title!.replacingOccurrences(of: "倍", with: "")
            let speed = Float(speedTitle)
            if speed != nil {
                self.updateSpeed(speed: speed!, title: "")
            }
        }
    }
	
	@objc func toggleOrientationSwitch() {
		guard let currentOrientationState = UIDevice.current.value(forKey: "orientation") as? Int else { return }
		if currentOrientationState == UIInterfaceOrientation.landscapeLeft.rawValue {
			UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
		}
		if currentOrientationState == UIInterfaceOrientation.portrait.rawValue {
			UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
		}
	}
	
	@objc func handleOrientationChange(notification: NSNotification) {
		let currentOrientationState = UIDevice.current.orientation
		if currentOrientationState.isPortrait {
			fullScreenButton.setImage(UIImage.bundleImage("maximize_24")?.withRenderingMode(.alwaysTemplate), for: [])
			transitionPanGesture.isEnabled = true
			topGradientLayer.opacity = 0
			bottomGradientLayer.opacity = 0
		} else {
			fullScreenButton.setImage(UIImage.bundleImage("minimize_24")?.withRenderingMode(.alwaysTemplate), for: [])
			transitionPanGesture.isEnabled = false
			topGradientLayer.opacity = 0.2
			bottomGradientLayer.opacity = 0.2
		}
		UIView.animate(withDuration: 0.2) { [weak self] in
			// Force Update
			self?.progress += CGFloat(UInt.min)
		}
	}
	
	@objc func didPressClose() {
		let currentOrientation = UIApplication.shared.statusBarOrientation
		if currentOrientation == UIInterfaceOrientation.landscapeLeft {
			UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
			delay(seconds: 0.3) {
				WOMaintainer.dismiss(completion: nil)
			}
			return
		}
		WOMaintainer.dismiss(completion: nil)
	}
    
    @objc func min() {
        let currentOrientation = UIApplication.shared.statusBarOrientation
        if currentOrientation == UIInterfaceOrientation.landscapeLeft {
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            delay(seconds: 0.3) {
                WOMaintainer.dismiss(completion: nil)
            }
            return
        }
        WOMaintainer.dismiss(completion: nil)
    }
    
    func updateSpeed(speed: Float, title: String){
        
        if speed != 0 {
            
            self.playerVC.player!.rate = speed
            self.speed = speed
            
        }
        
        if title != "" {
            
            var setTitle = title
            if speed == 1 {
                setTitle = "倍速"
            }
            
            speedButton.setTitle(setTitle, for: .normal)
        }
        
    }
}
