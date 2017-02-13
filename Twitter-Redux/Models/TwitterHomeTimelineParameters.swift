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
  var sinceID: String?
  var maxID: String?
  
  var dictionary: [String: AnyObject]? {
      var params: [String: AnyObject]? = [:]
      let parameterDictionary = namesAndValues()
      for (name, value) in parameterDictionary {
        if let value = value {
          params?[name] = value
        }
      }
      if params?.count == 0 {
        return nil
      } else {
        return params
      }
  }
  
  override init() {
    super.init()
  }
  
  convenience init(withCount count: Int? = nil,
                   withSinceID sinceID: String? = nil,
                   withMaxID maxID: String? = nil) {
    self.init()
    
    self.count = count
    self.sinceID = sinceID
    self.maxID = maxID
  }
  
  fileprivate func namesAndValues() -> [String:AnyObject?] {
    let dictionary: [String: AnyObject?] =
    [
      "count": self.count as AnyObject?,
      "since_id": self.sinceID as AnyObject?,
      "max_id": self.maxID as AnyObject?
    ]
    
    return dictionary
  }
  
}
