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
    "Menu",
    "Navigation With Menu"
  ]
  
  // MARK: - Instance Variables
  var currentViewController: UIViewController?
  
  // MARK: - Initializer
  override init() {
    vcArray = [
      MenuViewController(),
      UINavigationController(rootViewController: MenuViewController())
    ]
  }
}
