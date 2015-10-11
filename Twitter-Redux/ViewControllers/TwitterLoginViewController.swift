//
//  TwitterLoginViewController.swift
//  Twitter-Redux
//
//  Created by Randy Ting on 10/9/15.
//  Copyright © 2015 Randy Ting. All rights reserved.
//

import UIKit

class TwitterLoginViewController: UIViewController {
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  // MARK: - Convenience
  private func attemptToLogin() {
    TwitterUser.loginWithCompletion { (user: TwitterUser?, error: NSError?) -> () in
      if let error = error {
        print(error.localizedDescription)
        let alert = UIAlertController.init(title: nil, message: error.localizedDescription, preferredStyle: .Alert)
        let tryAgainAction = UIAlertAction(title: "Try Again", style: UIAlertActionStyle.Cancel, handler: { (action: UIAlertAction) -> Void in
          self.attemptToLogin()
        })
        alert.addAction(tryAgainAction)
        self.presentViewController(alert, animated: true, completion: nil)
      } else {
        UserManager.sharedInstance.currentUser = user
        TwitterUser.currentUser = user
        UserManager.sharedInstance.loggedInUsers.append(user!)
        NSNotificationCenter.defaultCenter().postNotificationName(userDidLoginNotification, object: self)
      }
    }
  }

  @IBAction func onTapLoginButton(sender: UIButton) {
    attemptToLogin()
  }
  
}
