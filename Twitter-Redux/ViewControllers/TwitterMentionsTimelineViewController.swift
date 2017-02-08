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
  
  override func setupInitialValues(){
    title = "Mentions"
    currentUser = UserManager.sharedInstance.currentUser
    refreshTweets()
  }
  
  override func refreshTweets(){
    currentUser.mentionsTimelineWithParams(nil) { (tweets, error) -> () in
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
    let params = TwitterHomeTimelineParameters()
    
    if let tweets = tweets {  // Unwrap tweets because bottom refresh control calls selector when view is loaded
      params.maxId = String((tweets.last!.id! - 1))
      params.count = 20
      
      currentUser.homeTimelineWithParams(params) { (tweets, error) -> () in
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
}
