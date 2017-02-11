//
//  AppDelegate.swift
//  Twitter-Redux
//
//  Created by Randy Ting on 10/8/15.
//  Copyright © 2015 Randy Ting. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  var menuNavigationController: UINavigationController?
  var mainVC: MainViewController?
  var loginVC: TwitterLoginViewController?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
    window = UIWindow(frame: UIScreen.main.bounds)
    mainVC = MainViewController()
    loginVC = TwitterLoginViewController()
  
    let menuViewController = MenuViewController()
    menuViewController.delegate = mainVC
    menuNavigationController = UINavigationController(rootViewController: menuViewController)
    
    if let mainVC = mainVC {
      if let menuNavigationController = menuNavigationController {
        mainVC.addChildViewController(menuNavigationController)
        menuNavigationController.view.frame = CGRect(x: 0, y: 0, width: MenuViewController.Constants.menuWidth, height: mainVC.view.bounds.height)
        menuNavigationController.view.autoresizingMask = [.flexibleHeight, .flexibleTopMargin, .flexibleBottomMargin]
        mainVC.view.addSubview(menuNavigationController.view)
        mainVC.view.bringSubview(toFront: mainVC.containerView)
        menuNavigationController.didMove(toParentViewController: mainVC)
      }
      
    }
    
    if let currentUser = TwitterUser.currentUser {
      UserManager.sharedInstance.currentUser = currentUser
      UserManager.sharedInstance.loggedInUsers.append(currentUser)
      mainVC?.selectViewController(MenuVCManager.sharedInstance.vcArray[0])
    } else {
      mainVC?.selectViewController(loginVC!)
    }
    
    window?.rootViewController = mainVC
    
    AppearanceHelper.setColors()
    window?.makeKeyAndVisible()
    
    return true
  }
  
  func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
    TwitterClient.sharedInstance.openURL(url)
    
    return true
  }
  
}
