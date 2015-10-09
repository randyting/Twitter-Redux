//
//  TwitterDetailDateFormatter.swift
//  Twitter
//
//  Created by Randy Ting on 10/4/15.
//  Copyright © 2015 Randy Ting. All rights reserved.
//

import UIKit

class TwitterDetailDateFormatter: NSDateFormatter {

  static let sharedInstance = TwitterDetailDateFormatter()
  
  required override init() {
    super.init()
    dateFormat = "M/d/yyyy, HH:mm a"
    AMSymbol = "am"
    PMSymbol = "pm"
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
