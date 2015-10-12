//
//  AppearanceHelper.swift
//  Twitter-Redux
//
//  Created by Randy Ting on 10/11/15.
//  Copyright © 2015 Randy Ting. All rights reserved.
//

import UIKit

class AppearanceHelper: NSObject {
  
  class func setColors() {
    
    let primaryBackgroundColor = colorFromHexString("#1C4F6B") //red
    let primaryTintColor = colorFromHexString("#EBE6C0") //White
    let secondaryTintColor = colorFromHexString("#ffffff") // Grey
    
    UINavigationBar.appearance().tintColor = primaryTintColor
    UINavigationBar.appearance().barTintColor = primaryBackgroundColor
    UINavigationBar.appearance().backgroundColor = primaryBackgroundColor
    UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:primaryTintColor]
    
    UITableViewCell.appearance().backgroundColor = secondaryTintColor

  }
  
  class func resetViews() {
    let windows = UIApplication.sharedApplication().windows
    for window in windows {
      let subviews = window.subviews
      for v in subviews {
        v.removeFromSuperview()
        window.addSubview(v)
      }
    }
  }
  
  class func colorFromHexString(hexString: String) -> UIColor {
    var rgbValue: UInt32 = 0
    let scanner = NSScanner(string: hexString)
    scanner.scanLocation = 1
    scanner.scanHexInt(&rgbValue)
    return UIColor(
      red: CGFloat((rgbValue >> 16) & 0xff) / 255,
      green: CGFloat((rgbValue >> 08) & 0xff) / 255,
      blue: CGFloat((rgbValue >> 00) & 0xff) / 255,
      alpha: 1.0)
  }
  
}
