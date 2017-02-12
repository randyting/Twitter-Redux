//
//  TwitterMentionsTimelineViewController.swift
//  Twitter-Redux
//
//  Created by Randy Ting on 10/11/15.
//  Copyright © 2015 Randy Ting. All rights reserved.
//

import UIKit

class TwitterMentionsTimelineViewController: TwitterHomeTimelineViewController {
  
  init() {
    super.init(nibName: "TwitterHomeTimelineViewController", bundle: nil)
    //Do whatever you want here
  }
  
  required init(coder aDecoder: NSCoder) {
    super.init(nibName: "TwitterHomeTimelineViewController", bundle: nil)
  }
  
  override func setupInitialValues() {
    title = "Mentions"
    currentUser = UserManager.sharedInstance.currentUser
    refreshTweets()
  }
  
  override func refreshTweets() {
    currentUser.mentionsTimelineWithParams(nil) { (tweets, error) -> Void in
      if let error = error {
        print(error.localizedDescription)
      } else {
        self.tweets = tweets
        self.tweetsTableView.reloadData()
        DispatchQueue.main.async(execute: { () -> Void in
          self.refreshControl.endRefreshing()
        })
      }
    }
  }
  
  override func loadOlderTweets() {
    
    guard let tweets = tweets else { return }
    let params = TwitterHomeTimelineParameters(withCount: 20,
                                               withSinceID: nil,
                                               withMaxID: String(tweets.last!.id - 1))
    
    currentUser.mentionsTimelineWithParams(params) { (tweets, error) -> Void in
      if let error = error {
        print(error.localizedDescription)
      } else {
        self.tweets? += tweets!
        self.tweetsTableView.reloadData()
        DispatchQueue.main.async(execute: { () -> Void in
          self.tweetsTableView.finishInfiniteScroll()
        })
      }
    }
    
  }
}
