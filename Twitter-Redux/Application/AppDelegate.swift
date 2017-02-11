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
  
  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }
  
  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }
  
  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  
  func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
    TwitterClient.sharedInstance.openURL(url)
    
    return true
  }
  
  
}

