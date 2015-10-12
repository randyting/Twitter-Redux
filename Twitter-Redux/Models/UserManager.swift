//
//  UserManager.swift
//  Twitter-Redux
//
//  Created by Randy Ting on 10/9/15.
//  Copyright © 2015 Randy Ting. All rights reserved.
//

import UIKit

class UserManager: NSObject {
  
  // MARK: - Shared Instance
  static let sharedInstance = UserManager()
  
  // MARK: - Instance Variables
  var loggedInUsers: [TwitterUser] = []
  var currentUser: TwitterUser?
}
