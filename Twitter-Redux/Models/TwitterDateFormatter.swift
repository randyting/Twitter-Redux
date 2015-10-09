//
//  TwitterDateFormatter.swift
//  Twitter
//
//  Created by Randy Ting on 10/4/15.
//  Copyright © 2015 Randy Ting. All rights reserved.
//

import UIKit

class TwitterDateFormatter: NSDateFormatter {

  static let sharedInstance = TwitterDateFormatter()
  
  required override init() {
    super.init()
    dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
}
