//
//  TweetDetailViewController.swift
//  Twitter-Redux
//
//  Created by Randy Ting on 10/10/15.
//  Copyright © 2015 Randy Ting. All rights reserved.
//

import UIKit

class TweetDetailViewController: UIViewController {

  // MARK: - Constants
  private let replyToTweetSegueIdentifier = "ReplyToTweetSegue"
  
  // MARK: - Storyboard Objects
  @IBOutlet private weak var tweetTextLabel: UILabel!
  @IBOutlet private weak var userScreennameLabel: UILabel!
  @IBOutlet private weak var profileImageView: UIImageView!
  @IBOutlet private weak var userNameLabel: UILabel!
  @IBOutlet private weak var createdTimeLabel: UILabel!
  
  @IBOutlet private weak var retweetCountLabel: UILabel!
  @IBOutlet private weak var favoriteCountLabel: UILabel!
  
  @IBOutlet private weak var favoriteButton: UIButton!
  @IBOutlet private weak var replyButton: UIButton!
  @IBOutlet private weak var retweetButton: UIButton!
  
  // MARK: - Properties
  var tweet: Tweet!
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Tweet"
    updateContent()
  }
  
  // MARK: - Setup
  private func updateContent() {
    profileImageView.setImageWithURL(tweet.profileImageURL)
    profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onTapProfileImage:"))
    tweetTextLabel.text = tweet.text
    userNameLabel.text = tweet.userName
    userScreennameLabel.text = "@" + tweet.userScreenname
    favoriteCountLabel.text = String(tweet.favoriteCount)
    retweetCountLabel.text = String(tweet.retweetCount)
    createdTimeLabel.text = TwitterDetailDateFormatter.sharedInstance.stringFromDate(TwitterDateFormatter.sharedInstance.dateFromString(tweet.createdAt)!)
    if tweet.favorited == true {
      favoriteButton.setImage(UIImage(named: "favorite_on"), forState: UIControlState.Normal)
    } else {
      favoriteButton.setImage(UIImage(named: "favorite"), forState: UIControlState.Normal)
    }
    if tweet.retweeted == true {
      retweetButton.setImage(UIImage(named: "retweet_on"), forState: UIControlState.Normal)
    } else {
      retweetButton.setImage(UIImage(named: "retweet"), forState: UIControlState.Normal)
    }
  }
  
  // MARK: - Behavior
  func onTapProfileImage(sender: UITapGestureRecognizer) {
    let profileVC = TwitterUserProfileViewController()
    
    TwitterUser.userWithScreenName(tweet.userScreenname) { (user, error) -> () in
      if let error = error {
        print("TwitterUser.userWithScreenName Error: \(error.localizedDescription)")
      } else {
        profileVC.user = user
        self.navigationController?.pushViewController(profileVC, animated: true)
      }
    }
  }
  
  @IBAction func onTapFavoriteButton(sender: AnyObject) {
    if tweet.favorited == true{
      TwitterUser.unfavorite(tweet) { (response, error) -> () in
        if let error = error {
          print("Unfavorite Error: \(error.localizedDescription)")
        } else {
          self.updateContent()
        }
      }
    } else {
      TwitterUser.favorite(tweet) { (response, error) -> () in
        if let error = error {
          print("Favorite Error: \(error.localizedDescription)")
        } else {
          self.updateContent()
        }
      }
    }
  }
  
  @IBAction func onTapRetweet(sender: AnyObject) {
    if tweet.retweeted == true{
      TwitterUser.unretweet(tweet) { (response, error) -> () in
        if let error = error {
          print("Unretweet Error: \(error.localizedDescription)")
        } else {
          self.updateContent()
        }
      }
    } else {
      TwitterUser.retweet(tweet) { (response, error) -> () in
        if let error = error {
          print("Retweet Error: \(error.localizedDescription)")
        } else {
          self.updateContent()
        }
      }
    }
  }
  
  @IBAction func onTapReplyButton(sender: AnyObject) {
    NewTweetViewController.presentNewTweetVCInReplyToTweet(tweet, forViewController: self)
  }

}

// MARK: - NewTweetViewControllerDelegate
extension TweetDetailViewController: NewTweetViewControllerDelegate {
  func newTweetViewController(newTweetViewController: NewTweetViewController, didCancelNewTweet: Bool) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  func newTweetViewController(newTweetViewController: NewTweetViewController, didPostTweetText: String) {
    dismissViewControllerAnimated(true, completion: nil)
  }
}
