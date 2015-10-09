//
//  TwitterHomeTimelineParameters.swift
//  Twitter
//
//  Created by Randy Ting on 10/2/15.
//  Copyright © 2015 Randy Ting. All rights reserved.
//

import UIKit

class TwitterHomeTimelineParameters: NSObject {
  
  var count: Int?
  var sinceId: String?
  var maxId: String?
  
  var dictionary: [String:AnyObject]?{
    get {
      var params: [String: AnyObject]? = [:]
      let parameterDictionary = namesAndValues()
      for (name, value) in parameterDictionary {
        if let value = value {
          params![name] = value
        }
      }
      if params?.count == 0 {
        return nil
      } else {
        return params
      }
    }
  }
  
  override init() {
    super.init()
  }
  
  private func namesAndValues() -> [String:AnyObject?] {
    let dictionary: [String: AnyObject?] =
    [
      "count"   : self.count,
      "since_id": self.sinceId,
      "max_id"  : self.maxId
    ]
    
    return dictionary
  }
  
}
