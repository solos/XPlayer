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
			playerVC.player!.seek(to: CMTimeMakeWithSeconds(targetTime, 1), completionHandler: { _ in
				self.playerVC.player!.play()
			})
		default: break
		}
	}
	
	private func handleTouchInTimelineView(location: CGPoint) {
		let properLocationX = min(max(location.x, 0), self.timelineView.bounds.width)
		self.progress = properLocationX / self.timelineView.bounds.width
		// update timeline text
		let totalTime = Float64(CMTimeGetSeconds(self.playerVC.player!.currentItem!.duration))
		guard let totalTimeString = self.playerVC.player!.currentItem!.duration.timecode() else { return }
		let currentTime = totalTime * Float64(self.progress)
		guard let currentTimeString = CMTimeMakeWithSeconds(currentTime, 1).timecode() else { return }
		self.timelineLabel.text = currentTimeString + " / " + totalTimeString
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
					_self.playButtton, _self.fullScreenButton,
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
					_self.playButtton, _self.fullScreenButton,
					_self.timelineLabel, _self.timelineViewContainer,
					_self.closeButton
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
	
	@objc func togglePlay() {

        let state = playerVC.player!.timeControlStatus
        if self.progress == 1 && state != .playing {
            self.progress = 0
            playerVC.player!.seek(to: kCMTimeZero)
            playerVC.player!.play()
            return
        }

        if  state == .playing || state == .waitingToPlayAtSpecifiedRate {
            playerVC.player!.play()
		} else {
			playerVC.player!.pause()
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
}
