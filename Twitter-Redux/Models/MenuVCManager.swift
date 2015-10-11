//
//  MenuVCManager.swift
//  Twitter-Redux
//
//  Created by Randy Ting on 10/8/15.
//  Copyright © 2015 Randy Ting. All rights reserved.
//

import UIKit

class MenuVCManager: NSObject {
  
  // MARK: - Shared Instance
  static let sharedInstance = MenuVCManager()
  
  // MARK: - Constants
  let vcArray: [UIViewController]!
  
  let vcTitleArray = [
    "Home",
    "Mentions",
    "Me"
  ]
  
  // MARK: - Instance Variables
  var currentViewController: UIViewController? {
    didSet {
      if let currentViewController = currentViewController {
        if let topVC = (currentViewController as? UINavigationController)?.topViewController {
          if topVC.isKindOfClass(TwitterUserProfileViewController){
            (topVC as! TwitterUserProfileViewController).user = UserManager.sharedInstance.currentUser
          }
        }
      }
    }
  }
  
  // MARK: - Initializer
  override init() {
    vcArray = [
      UINavigationController(rootViewController: TwitterHomeTimelineViewController()),
      UINavigationController(rootViewController: TwitterMentionsTimelineViewController()),
      UINavigationController(rootViewController: TwitterUserProfileViewController()),
    ]
  }
}
