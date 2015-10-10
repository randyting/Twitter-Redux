//
//  TweetTableViewCell.swift
//  Twitter-Redux
//
//  Created by Randy Ting on 10/9/15.
//  Copyright © 2015 Randy Ting. All rights reserved.
//

import UIKit

@objc protocol TweetTableViewCellDelegate {
  optional func tweetTableViewCell(tweetTableViewCell: TweetTableViewCell, didLoadMediaImage: Bool) -> ()
}

class TweetTableViewCell: UITableViewCell {

  // MARK: - Storyboard Objects
  @IBOutlet private weak var profileImageView: UIImageView!
  @IBOutlet private weak var tweetTextLabel: UILabel!
  @IBOutlet private weak var timeSinceCreatedDXTimestampLabel: DXTimestampLabel!
  @IBOutlet private weak var userNameLabel: UILabel!
  @IBOutlet private weak var userScreenNameLabel: UILabel!
  
  @IBOutlet private weak var replyButton: UIButton!
  
  @IBOutlet private weak var retweetButton: UIButton!
  @IBOutlet private weak var retweetCountLabel: UILabel!
  
  @IBOutlet private weak var favoriteButton: UIButton!
  @IBOutlet private weak var favoriteCountLabel: UILabel!
  
  
  // MARK: - Properties
  weak var delegate: AnyObject?
  
  var tweet: Tweet! {
    didSet{
      updateContent()
    }
  }
  
  // MARK: - Setup
  private func updateContent() {
    profileImageView.setImageWithURL(tweet.profileImageURL)
    tweetTextLabel.text = tweet.text
    userNameLabel.text = tweet.userName
    userScreenNameLabel.text = "@" + tweet.userScreenname
    favoriteCountLabel.text = String(tweet.favoriteCount)
    retweetCountLabel.text = String(tweet.retweetCount)
    timeSinceCreatedDXTimestampLabel.timestamp = TwitterDateFormatter.sharedInstance.dateFromString(tweet.createdAt)
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
  @IBAction func onTapRetweetButton(sender: AnyObject) {
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
  
  @IBAction func onTapFavoriteButton(sender: UIButton) {
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
    
}
