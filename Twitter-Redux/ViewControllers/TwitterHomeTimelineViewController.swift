//
//  TwitterHomeTimelineViewController.swift
//  Twitter-Redux
//
//  Created by Randy Ting on 10/9/15.
//  Copyright © 2015 Randy Ting. All rights reserved.
//

import UIKit

class TwitterHomeTimelineViewController: UIViewController {
  
  // MARK: - Constants
  private let tweetsCellReuseIdentifier = "tweetsCellReuseIdentifier"
  
  // MARK: - Properties
  var currentUser: TwitterUser!
  var tweets: [Tweet]?
  let refreshControl = UIRefreshControl()
  let bottomRefreshControl = UIRefreshControl()
  
  // MARK: - Storyboard
  @IBOutlet weak var tweetsTableView: UITableView!
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupTweetsTableView(tweetsTableView)
    setupRefreshControl(refreshControl)
    setupInitialValues()
    setupNavigationBar()
  }
  
  override func viewWillAppear(animated: Bool) {
    tweetsTableView.reloadData()
  }
  
  
  // MARK: - Initial Setup
  private func setupTweetsTableView(tableView: UITableView){
    tableView.dataSource = self
    tableView.delegate = self
    tableView.estimatedRowHeight = 300
    tableView.rowHeight = UITableViewAutomaticDimension
    let tweetTableViewCellNib = UINib(nibName: "TweetTableViewCell", bundle: nil)
    tableView.registerNib(tweetTableViewCellNib, forCellReuseIdentifier: tweetsCellReuseIdentifier)
    tableView.separatorInset = UIEdgeInsetsZero
  }
  
  func setupInitialValues(){
    title = "Home"
    currentUser = UserManager.sharedInstance.currentUser
    refreshTweets()
  }
  
  private func setupRefreshControl(refreshControl: UIRefreshControl) {
    refreshControl.addTarget(self, action: "refreshTweets", forControlEvents: .ValueChanged)
    tweetsTableView.insertSubview(refreshControl, atIndex: 0)
    
    bottomRefreshControl.triggerVerticalOffset = 100
    bottomRefreshControl.addTarget(self, action: "loadOlderTweets", forControlEvents: .ValueChanged)
    tweetsTableView.bottomRefreshControl = bottomRefreshControl
  }
  
  private func setupNavigationBar(){
//    let newTweetButton = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: "createNewTweet:")
    navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "compose"), style: .Plain, target: self, action: "createNewTweet:")
  }
  
  // MARK: - Behavior
  func createNewTweet(sender: UIBarButtonItem) {
    NewTweetViewController.presentNewTweetVCInReplyToTweet(nil, forViewController: self)
  }
  
  func refreshTweets(){
    currentUser.homeTimelineWithParams(nil) { (tweets, error) -> () in
      if let error = error {
        print(error.localizedDescription)
      } else {
        self.tweets = tweets
        self.tweetsTableView.reloadData()
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          self.refreshControl.endRefreshing()
        })
      }
    }
  }
  
  func loadOlderTweets() {
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
          dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.bottomRefreshControl.endRefreshing()
          })
        }
      }
    }
  }
}

// MARK: - UITableView Delegate and Datasource
extension TwitterHomeTimelineViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tweetsTableView.dequeueReusableCellWithIdentifier(tweetsCellReuseIdentifier, forIndexPath: indexPath) as! TweetTableViewCell
    
    cell.tweet = tweets?[indexPath.row]
    cell.delegate = self
    
    return cell
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let tweets = tweets {
      return tweets.count
    } else {
      return 0
    }
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    let tweetDetailVC = TweetDetailViewController()
    tweetDetailVC.edgesForExtendedLayout = .None
    tweetDetailVC.tweet = (tweetsTableView.cellForRowAtIndexPath(indexPath) as! TweetTableViewCell).tweetToShow
    navigationController?.pushViewController(tweetDetailVC, animated: true)
  }
  
}

// MARK: - TweetTableViewCell Delegate
extension TwitterHomeTimelineViewController: TweetTableViewCellDelegate {
  func tweetTableViewCell(tweetTableViewCell: TweetTableViewCell, didTapReplyButton: UIButton) {
    NewTweetViewController.presentNewTweetVCInReplyToTweet(tweetTableViewCell.tweetToShow, forViewController: self)
  }
  
  func tweetTableViewCell(tweetTableViewCell: TweetTableViewCell, didTapProfileImage: UIImageView) {
    let profileVC = TwitterUserProfileViewController()
    
    TwitterUser.userWithScreenName(tweetTableViewCell.tweetToShow.userScreenname) { (user, error) -> () in
      if let error = error {
        print("TwitterUser.userWithScreenName Error: \(error.localizedDescription)")
      } else {
        profileVC.user = user
        self.navigationController?.pushViewController(profileVC, animated: true)
      }
    }
  }
  
}

// MARK: - NewTweetViewController Delegate
extension TwitterHomeTimelineViewController: NewTweetViewControllerDelegate {
  func newTweetViewController(newTweetViewController: NewTweetViewController, didPostTweetText: String) {
    dismissViewControllerAnimated(true, completion: nil)
    refreshTweets()
  }
  
  func newTweetViewController(newTweetViewController: NewTweetViewController, didCancelNewTweet: Bool) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
}



