//
//  XPlayerViewController+UI.swift
//  XPlayer
//
//  Created by duan on 16/9/18.
//  Copyright © 2016年 monk-studio. All rights reserved.
//

import UIKit
import TinyConstraints


extension XPlayerViewController {
	func setupUI() {
        addChild(playerVC)
		playerVC.view.isUserInteractionEnabled = false
        	view.layer.zPosition = 9999
		view.insertSubview(playerVC.view, belowSubview: pipCloseButton)
        playerVC.didMove(toParent: self)

		[topGradientLayer, bottomGradientLayer].forEach { (layer) in
			layer.opacity = 0
            self.view.layer.addSublayer(layer)
		}
		[playButtton, speedButton_05, speedButton_1, speedButton_15, speedButton_2, closeButton, fullScreenButton, timelineLabel].forEach { button in
			button.layer.zPosition = 10
			self.view.addSubview(button)
		}
		timelineViewContainer.translatesAutoresizingMaskIntoConstraints = false
		timelineView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(timelineViewContainer)
		timelineViewContainer.addSubview(timelineView)
		timelineView.addSubview(timelineProgressedView)
		timelineView.addSubview(timelineDotView)


        let bottomMargin:CGFloat = 40
        let leftMargin:CGFloat = 16
        playerVC.view.edgesToSuperview()

        playButtton.size(CGSize.square(24))
        playButtton.leadingToSuperview(offset: leftMargin)
        playButtton.bottomToSuperview(offset: -bottomMargin)

        fullScreenButton.size(CGSize.square(24))
        fullScreenButton.trailingToSuperview(offset: leftMargin)
        fullScreenButton.bottomToSuperview(offset: -bottomMargin)

        closeButton.size(CGSize.square(32))
        closeButton.trailingToSuperview(offset: leftMargin)
        closeButton.topToSuperview(offset: 40)
        
        speedButton_05.size(CGSize.square(32))
        speedButton_05.trailingToSuperview(offset: leftMargin + 40)
        speedButton_05.centerY(to: closeButton)
        
        speedButton_1.size(CGSize.square(32))
        speedButton_1.trailingToSuperview(offset: leftMargin + 40 + 40)
        speedButton_1.centerY(to: closeButton)
        
        speedButton_15.size(CGSize.square(32))
        speedButton_15.trailingToSuperview(offset: leftMargin + 40 + 40 + 40)
        speedButton_15.centerY(to: closeButton)
        
        speedButton_2.size(CGSize.square(32))
        speedButton_2.trailingToSuperview(offset: leftMargin + 40 + 40 + 40 + 40)
        speedButton_2.centerY(to: closeButton)

        timelineLabel.centerY(to: fullScreenButton)
        timelineLabel.trailingToLeading(of: fullScreenButton, offset: -leftMargin)

        timelineViewContainer.height(30)
        timelineViewContainer.leadingToTrailing(of: playButtton, offset: leftMargin)
        timelineViewContainer.trailingToLeading(of: timelineLabel, offset: -leftMargin)
        timelineView.centerY(to: playButtton)

        timelineViewContainer.leading(to: timelineView)
        timelineViewContainer.trailing(to: timelineView)
        timelineViewContainer.centerY(to: timelineView)
        timelineView.height(2)

		timelineProgressedView.frame = CGRect(x: 0, y: 0, width: 0, height: 2)
		timelineDotView.frame = CGRect(x: -11 / 2, y: 2 / 2 - 11 / 2, width: 11, height: 11)

		view.backgroundColor = UIColor.black
        view.tintColor = UIColor.white
		playerVC.showsPlaybackControls = false
		playButtton.setImage(UIImage.bundleImage("play_24")?.withRenderingMode(.alwaysTemplate), for: [])
		playButtton.imageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
		playButtton.imageView?.contentMode = .scaleAspectFit
        
        speedButton_05.setTitle("0.5", for: .normal)
        speedButton_05.titleLabel?.textColor = .white
        
        speedButton_1.setTitle("1.0", for: .normal)
        speedButton_1.titleLabel?.textColor = .white
        
        speedButton_15.setTitle("1.5", for: .normal)
        speedButton_15.titleLabel?.textColor = .white

        speedButton_2.setTitle("2.0", for: .normal)
        speedButton_2.titleLabel?.textColor = .white
        
        updateSpeedButton()

		fullScreenButton.setImage(UIImage.bundleImage("maximize_24")?.withRenderingMode(.alwaysTemplate), for: [])
		fullScreenButton.imageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
		fullScreenButton.imageView?.contentMode = .scaleAspectFit
		closeButton.setImage(UIImage.bundleImage("x_24")?.withRenderingMode(.alwaysTemplate), for: [])
		closeButton.imageView?.contentMode = .scaleAspectFit
		timelineView.backgroundColor = UIColor(white: 1, alpha: 0.4)
		timelineProgressedView.backgroundColor = themeColor
		timelineDotView.backgroundColor = UIColor.white
		timelineView.layer.cornerRadius = 2
		timelineProgressedView.layer.cornerRadius = 2
		timelineDotView.layer.cornerRadius = 5.5
		timelineLabel.font = UIFont(name: "Avenir", size: 10)
		timelineLabel.textAlignment = .center
		timelineLabel.textColor = UIColor.white
		timelineLabel.text = "00:00 / 00:00"
		topGradientLayer.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
		topGradientLayer.opacity = 0
		bottomGradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
		bottomGradientLayer.opacity = 0
		timelineViewContainer.isUserInteractionEnabled = false
	}
    
    func updateSpeedButton(){
        
        speedButton_05.layer.borderWidth = 0
        speedButton_1.layer.borderWidth = 0
        speedButton_15.layer.borderWidth = 0
        speedButton_2.layer.borderWidth = 0
        
        switch (self.speed){
            case "":
                speedButton_1.layer.borderColor = UIColor.white.cgColor
                speedButton_1.layer.borderWidth = 1.0
            case "0.5":
                speedButton_05.layer.borderColor = UIColor.white.cgColor
                speedButton_05.layer.borderWidth = 1.0
            case "1.0":
                speedButton_1.layer.borderColor = UIColor.white.cgColor
                speedButton_1.layer.borderWidth = 1.0
            case "1.5":
                speedButton_15.layer.borderColor = UIColor.white.cgColor
                speedButton_15.layer.borderWidth = 1.0
            case "2.0":
                speedButton_2.layer.borderColor = UIColor.white.cgColor
                speedButton_2.layer.borderWidth = 1.0
            default:
                speedButton_1.layer.borderColor = UIColor.white.cgColor
                speedButton_1.layer.borderWidth = 1.0
        }
        
    }
}
