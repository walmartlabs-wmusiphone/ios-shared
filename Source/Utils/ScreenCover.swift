//
//  ScreenCover.swift
//  walmart
//
//  Created by David Sica on 5/9/16.
//  Copyright © 2016 Walmart. All rights reserved.
//

import Foundation

// Declaring conformance to this Protocol will whitelist the UIViewController's
//  view.
//
//  Optionally, implement the shouldWhitelist method to determine whether to
//  wholesale whitelist at runtime.  Or, declare to NOT whitelist but manually 
//  hide sensitive information on the view.
@objc protocol ScreenCoverProtocol {
    optional func shouldWhitelist() -> Bool
}

@objc class ScreenCover: NSObject {
    
    // Tag used for unit testing, set as tag for the screen cover view.
    //  Bonus points if you can identify the tag value significance.
    static let screenCoverViewTag = 620702
}

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.sharedApplication().keyWindow?.rootViewController) -> UIViewController? {
        if let navController = base as? UINavigationController {
            return topViewController(navController.visibleViewController)
        }
        if let tabController = base as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presentedVC = base?.presentedViewController {
            return topViewController(presentedVC)
        }
        return base
    }
    
    static func shouldWhitelistScreenCover() -> Bool {
        if let whitelistProtocol = self.topViewController() as? ScreenCoverProtocol {
            
            if let shouldWhitelist = whitelistProtocol.shouldWhitelist?() {
               return shouldWhitelist
            }
            else {
                return true
            }
        
        } else {
            return false
        }
    }
}
