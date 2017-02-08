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
  fileprivate func attemptToLogin() {
    TwitterUser.loginWithCompletion { (user: TwitterUser?, error: NSError?) -> () in
      if let error = error {
        print(error.localizedDescription)
        let alert = UIAlertController.init(title: nil, message: error.localizedDescription, preferredStyle: .alert)
        let tryAgainAction = UIAlertAction(title: "Try Again", style: UIAlertActionStyle.cancel, handler: { (action: UIAlertAction) -> Void in
          self.attemptToLogin()
        })
        alert.addAction(tryAgainAction)
        self.present(alert, animated: true, completion: nil)
      } else {
        UserManager.sharedInstance.currentUser = user
        TwitterUser.currentUser = user
        UserManager.sharedInstance.loggedInUsers.append(user!)
        NotificationCenter.default.post(name: Notification.Name(rawValue: userDidLoginNotification), object: self)
      }
    }
  }

  @IBAction func onTapLoginButton(_ sender: UIButton) {
    attemptToLogin()
  }
  
}
