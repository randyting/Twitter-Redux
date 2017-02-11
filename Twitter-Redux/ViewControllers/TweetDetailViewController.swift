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
  fileprivate let replyToTweetSegueIdentifier = "ReplyToTweetSegue"
  
  // MARK: - Storyboard Objects
  @IBOutlet fileprivate weak var tweetTextLabel: UILabel!
  @IBOutlet fileprivate weak var userScreennameLabel: UILabel!
  @IBOutlet fileprivate weak var profileImageView: UIImageView!
  @IBOutlet fileprivate weak var userNameLabel: UILabel!
  @IBOutlet fileprivate weak var createdTimeLabel: UILabel!
  
  @IBOutlet fileprivate weak var retweetCountLabel: UILabel!
  @IBOutlet fileprivate weak var favoriteCountLabel: UILabel!
  
  @IBOutlet fileprivate weak var favoriteButton: UIButton!
  @IBOutlet fileprivate weak var replyButton: UIButton!
  @IBOutlet fileprivate weak var retweetButton: UIButton!
  
  // MARK: - Properties
  var tweet: Tweet!
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Tweet"
    updateContent()
    setupAppearance()
  }
  
  // MARK: - Setup
  fileprivate func updateContent() {
    profileImageView.setImageWith(tweet.profileImageURL as URL!)
    profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(TweetDetailViewController.onTapProfileImage(_:))))
    tweetTextLabel.text = tweet.text
    userNameLabel.text = tweet.userName
    userScreennameLabel.text = "@" + tweet.userScreenname
    favoriteCountLabel.text = String(tweet.favoriteCount)
    retweetCountLabel.text = String(tweet.retweetCount)
    createdTimeLabel.text = TwitterDetailDateFormatter.sharedInstance.string(from: TwitterDateFormatter.sharedInstance.date(from: tweet.createdAt)!)
    if tweet.favorited == true {
      favoriteButton.setImage(UIImage(named: "favorite_on"), for: UIControlState())
    } else {
      favoriteButton.setImage(UIImage(named: "favorite"), for: UIControlState())
    }
    if tweet.retweeted == true {
      retweetButton.setImage(UIImage(named: "retweet_on"), for: UIControlState())
    } else {
      retweetButton.setImage(UIImage(named: "retweet"), for: UIControlState())
    }
  }
  
  fileprivate func setupAppearance() {
    profileImageView.layer.cornerRadius = 4.0
    profileImageView.clipsToBounds = true
  }
  
  // MARK: - Behavior
  func onTapProfileImage(_ sender: UITapGestureRecognizer) {
    let profileVC = TwitterUserProfileViewController()
    
    TwitterUser.userWithScreenName(tweet.userScreenname) { (user, error) -> Void in
      if let error = error {
        print("TwitterUser.userWithScreenName Error: \(error.localizedDescription)")
      } else {
        profileVC.user = user
        self.navigationController?.pushViewController(profileVC, animated: true)
      }
    }
  }
  
  @IBAction func onTapFavoriteButton(_ sender: AnyObject) {
    if tweet.favorited == true {
      TwitterUser.unfavorite(tweet) { (_, error) -> Void in
        if let error = error {
          print("Unfavorite Error: \(error.localizedDescription)")
        } else {
          self.updateContent()
        }
      }
    } else {
      TwitterUser.favorite(tweet) { (_, error) -> Void in
        if let error = error {
          print("Favorite Error: \(error.localizedDescription)")
        } else {
          self.updateContent()
        }
      }
    }
  }
  
  @IBAction func onTapRetweet(_ sender: AnyObject) {
    if tweet.retweeted == true {
      TwitterUser.unretweet(tweet) { (_, error) -> Void in
        if let error = error {
          print("Unretweet Error: \(error.localizedDescription)")
        } else {
          self.updateContent()
        }
      }
    } else {
      TwitterUser.retweet(tweet) { (_, error) -> Void in
        if let error = error {
          print("Retweet Error: \(error.localizedDescription)")
        } else {
          self.updateContent()
        }
      }
    }
  }
  
  @IBAction func onTapReplyButton(_ sender: AnyObject) {
    NewTweetViewController.presentNewTweetViewController(inReplyToTweet: tweet, forViewController: self)
  }

}

// MARK: - NewTweetViewControllerDelegate
extension TweetDetailViewController: NewTweetViewControllerDelegate {
  func newTweetViewController(_ newTweetViewController: NewTweetViewController, didCancelNewTweet: Bool) {
    dismiss(animated: true, completion: nil)
  }
  
  func newTweetViewController(_ newTweetViewController: NewTweetViewController, didPostTweetText: String) {
    dismiss(animated: true, completion: nil)
  }
}
