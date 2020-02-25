//
//  XPlayerViewController+Action.swift
//  XPlayer
//
//  Created by duan on 16/9/19.
//  Copyright © 2016年 monk-studio. All rights reserved.
//

import UIKit


extension XPlayerViewController {
	override func didEnterPIP() {
		super.didEnterPIP()
		self.toggleControlTapGesture.isEnabled = false
	}
	
	override func didEnterOut() {
		super.didEnterOut()
        if self.playerVC.player != nil {
    		self.playerVC.player!.removeObserver(self, forKeyPath: "rate")
    		self.playerVC.player!.currentItem!.removeObserver(self, forKeyPath: "status")
        }
		NotificationCenter.default.removeObserver(self)
        if self.playerVC.player != nil {
    		self.playerVC.player!.pause()
    		self.playerVC.player = nil
        }
	}
	
	override func didEnterFullScreen() {
		super.didEnterFullScreen()
		self.toggleControlTapGesture.isEnabled = true
		UIView.animate(withDuration: 0.3) { [weak self] in
			guard let _self = self else { return }
			[
                _self.playButtton, _self.speedButton_05, _self.speedButton_1, _self.speedButton_15, _self.speedButton_2, _self.closeButton,
				_self.fullScreenButton, _self.timelineLabel,
				_self.closeButton, _self.timelineViewContainer
			].forEach { (element) in
				element.layer.transform = CATransform3DIdentity
				_self.showingControls = true
				element.alpha = 1
			}
			self?.progress += CGFloat(UInt.min)
		}
	}
	
	override func didStartTransition() {
		super.didStartTransition()
		UIView.animate(withDuration: 0.3) { [weak self] in
			guard let _self = self else { return }
			[
				_self.playButtton, _self.speedButton_05, _self.speedButton_1, _self.speedButton_15, _self.speedButton_2,_self.closeButton,
				_self.fullScreenButton, _self.timelineLabel,
				_self.closeButton, _self.timelineViewContainer
			].forEach { (element) in
					element.alpha = 0
			}
		}
	}
}
