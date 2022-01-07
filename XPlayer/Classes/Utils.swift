//
//  Utils.swift
//  XPlayer
//
//  Created by duan on 16/9/20.
//  Copyright © 2016年 monk-studio. All rights reserved.
//

import UIKit


let win = UIWindow(frame: UIScreen.main.bounds)
let vc = UIViewController()

extension UIImage {
    static func bundleImage(_ name: String) -> UIImage? {
        let frameworkBundle = Bundle.init(for: XPlayer.self)
        guard
            let url = frameworkBundle.resourceURL?.appendingPathComponent("XPlayer.bundle"),
            let bundle = Bundle.init(url: url)
            else { return nil }
        return UIImage(named: name, in: bundle, compatibleWith: nil)
    }
}

extension CGSize {
    static func square(_ border: CGFloat) -> CGSize {
        return CGSize(width: border, height: border)
    }
}

public extension UIAlertController {
    
    func show() {
        vc.view.backgroundColor = .clear
        win.rootViewController = vc
        win.windowLevel = UIWindow.Level.alert + 1  // Swift 3-4: UIWindowLevelAlert + 1
        win.makeKeyAndVisible()
        vc.present(self, animated: true, completion: nil)
    }
    
    func hide(){
        win.windowLevel = UIWindow.Level.normal - 1
        vc.dismiss(animated: true, completion: nil)
    }
}
