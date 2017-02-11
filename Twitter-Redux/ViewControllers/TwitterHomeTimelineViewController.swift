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
  fileprivate let tweetsCellReuseIdentifier = "tweetsCellReuseIdentifier"
  
  // MARK: - Properties
  var currentUser: TwitterUser!
  var tweets: [Tweet]?
  let refreshControl = UIRefreshControl()
//  let bottomRefreshControl = UIRefreshControl()
  
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
  
  override func viewWillAppear(_ animated: Bool) {
    tweetsTableView.reloadData()
  }
  
  // MARK: - Initial Setup
  fileprivate func setupTweetsTableView(_ tableView: UITableView) {
    tableView.dataSource = self
    tableView.delegate = self
    tableView.estimatedRowHeight = 300
    tableView.rowHeight = UITableViewAutomaticDimension
    let tweetTableViewCellNib = UINib(nibName: "TweetTableViewCell", bundle: nil)
    tableView.register(tweetTableViewCellNib, forCellReuseIdentifier: tweetsCellReuseIdentifier)
    tableView.separatorInset = UIEdgeInsets.zero
  }
  
  func setupInitialValues() {
    title = "Home"
    currentUser = UserManager.sharedInstance.currentUser
    refreshTweets()
  }
  
  fileprivate func setupRefreshControl(_ refreshControl: UIRefreshControl) {
    refreshControl.addTarget(self, action: #selector(refreshTweets), for: .valueChanged)
    tweetsTableView.insertSubview(refreshControl, at: 0)
    
    tweetsTableView.infiniteScrollIndicatorStyle = .gray
    tweetsTableView.addInfiniteScroll { (_) -> Void in
      self.loadOlderTweets()
    }
  }
  
  fileprivate func setupNavigationBar() {
    navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "compose"), style: .plain, target: self, action: #selector(createNewTweet(_:)))
  }
  
  // MARK: - Behavior
  func createNewTweet(_ sender: UIBarButtonItem) {
    NewTweetViewController.presentNewTweetViewController(inReplyToTweet: nil, forViewController: self)
  }
  
  func refreshTweets() {
    currentUser.homeTimelineWithParams(nil) { (tweets, error) -> Void in
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
  
  func loadOlderTweets() {
    let params = TwitterHomeTimelineParameters()
    
    if let tweets = tweets {  // Unwrap tweets because bottom refresh control calls selector when view is loaded
      params.maxId = String((tweets.last!.id! - 1))
      params.count = 20
      
      currentUser.homeTimelineWithParams(params) { (tweets, error) -> Void in
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

// MARK: - UITableView Delegate and Datasource
extension TwitterHomeTimelineViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tweetsTableView.dequeueReusableCell(withIdentifier: tweetsCellReuseIdentifier, for: indexPath) as! TweetTableViewCell // swiftlint:disable:this force_cast
    
    cell.tweet = tweets?[indexPath.row]
    cell.delegate = self
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let tweets = tweets {
      return tweets.count
    } else {
      return 0
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let tweetDetailVC = TweetDetailViewController()
    tweetDetailVC.edgesForExtendedLayout = UIRectEdge()
    tweetDetailVC.tweet = (tweetsTableView.cellForRow(at: indexPath) as! TweetTableViewCell).tweetToShow // swiftlint:disable:this force_cast
    navigationController?.pushViewController(tweetDetailVC, animated: true)
  }
  
}

// MARK: - TweetTableViewCell Delegate
extension TwitterHomeTimelineViewController: TweetTableViewCellDelegate {
  func tweetTableViewCell(_ tweetTableViewCell: TweetTableViewCell, didTapReplyButton: UIButton) {
    NewTweetViewController.presentNewTweetViewController(inReplyToTweet: tweetTableViewCell.tweetToShow, forViewController: self)
  }
  
  func tweetTableViewCell(_ tweetTableViewCell: TweetTableViewCell, didTapProfileImage: UIImageView) {
    let profileVC = TwitterUserProfileViewController()
    
    TwitterUser.userWithScreenName(tweetTableViewCell.tweetToShow.userScreenname) { (user, error) -> Void in
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
  func newTweetViewController(_ newTweetViewController: NewTweetViewController, didPostTweetText: String) {
    dismiss(animated: true, completion: nil)
    refreshTweets()
  }
  
  func newTweetViewController(_ newTweetViewController: NewTweetViewController, didCancelNewTweet: Bool) {
    dismiss(animated: true, completion: nil)
  }
  
}
