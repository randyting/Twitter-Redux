//
//  TweetTableViewCell.swift
//  Twitter-Redux
//
//  Created by Randy Ting on 10/9/15.
//  Copyright © 2015 Randy Ting. All rights reserved.
//

import UIKit

@objc protocol TweetTableViewCellDelegate {
  optional func tweetTableViewCell(tweetTableViewCell: TweetTableViewCell, didTapReplyButton: UIButton)
  optional func tweetTableViewCell(tweetTableViewCell: TweetTableViewCell, didTapProfileImage: UIImageView)
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
  
  @IBOutlet weak var retweetOrReplyContainerView: UIView!
  @IBOutlet weak var retweetOrReplyContainerViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var retweetOrReplyIcon: UIImageView!
  @IBOutlet weak var retweetOrReplyLabel: UILabel!
  
  @IBOutlet weak var profileImageTopToContainerHeightConstraint: NSLayoutConstraint!
  
  // MARK: - Properties
  var tweetToShow: Tweet!
  weak var delegate: AnyObject?
  
  var tweet: Tweet! {
    didSet{
      tweetToShow = tweet.originalTweet ?? tweet
      updateContent()
      setupAppearance()
    }
  }
  
  // MARK: - Setup
  private func updateContent() {
    
    profileImageView.setImageWithURL(tweetToShow.profileImageURL)
    profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onTapProfileImage:"))
    
    tweetTextLabel.text = tweetToShow.text
    userNameLabel.text = tweetToShow.userName
    userScreenNameLabel.text = "@" + tweetToShow.userScreenname
    favoriteCountLabel.text = String(tweetToShow.favoriteCount)
    retweetCountLabel.text = String(tweetToShow.retweetCount)
    timeSinceCreatedDXTimestampLabel.timestamp = TwitterDateFormatter.sharedInstance.dateFromString(tweet.createdAt)
    if tweetToShow.favorited == true {
      favoriteButton.setImage(UIImage(named: "favorite_on"), forState: UIControlState.Normal)
    } else {
      favoriteButton.setImage(UIImage(named: "favorite"), forState: UIControlState.Normal)
    }
    if tweetToShow.retweeted == true {
      retweetButton.setImage(UIImage(named: "retweet_on"), forState: UIControlState.Normal)
    } else {
      retweetButton.setImage(UIImage(named: "retweet"), forState: UIControlState.Normal)
    }
    
    if tweet.isRetweet || tweet.isReply {
      retweetOrReplyContainerView.hidden = false
      retweetOrReplyContainerViewHeightConstraint.constant = 25
      profileImageTopToContainerHeightConstraint.constant = 0
      if tweet.isRetweet {
        retweetOrReplyIcon.image = UIImage(named: "retweet")
        retweetOrReplyLabel.text = "\(tweet.userName!) Retweeted"
      } else {
        retweetOrReplyIcon.image = UIImage(named: "reply")
        retweetOrReplyLabel.text = "in reply to @\(tweet.inReplyToScreenName!)"
      }
    } else {
      retweetOrReplyContainerView.hidden = true
      retweetOrReplyContainerViewHeightConstraint.constant = 0
      profileImageTopToContainerHeightConstraint.constant = 15
    }
    
  }
  
  private func setupAppearance() {
    profileImageView.layer.cornerRadius = 4.0
    profileImageView.clipsToBounds = true
  }
  
  // MARK: - Behavior
  @IBAction func onTapRetweetButton(sender: AnyObject) {
    if tweetToShow.retweeted == true{
      TwitterUser.unretweet(tweetToShow) { (response, error) -> () in
        if let error = error {
          print("Unretweet Error: \(error.localizedDescription)")
        } else {
          self.updateContent()
        }
      }
    } else {
      TwitterUser.retweet(tweetToShow) { (response, error) -> () in
        if let error = error {
          print("Retweet Error: \(error.localizedDescription)")
        } else {
          self.updateContent()
        }
      }
    }
  }
  
  @IBAction func onTapFavoriteButton(sender: UIButton) {
    if tweetToShow.favorited == true{
      TwitterUser.unfavorite(tweetToShow) { (response, error) -> () in
        if let error = error {
          print("Unfavorite Error: \(error.localizedDescription)")
        } else {
          self.updateContent()
        }
      }
    } else {
      TwitterUser.favorite(tweetToShow) { (response, error) -> () in
        if let error = error {
          print("Favorite Error: \(error.localizedDescription)")
        } else {
          self.updateContent()
        }
      }
    }
  }
  
  @IBAction func onTapReplyButton(sender: UIButton) {
    delegate?.tweetTableViewCell!(self, didTapReplyButton: sender)
  }
  
  func onTapProfileImage(sender: UITapGestureRecognizer) {
    delegate?.tweetTableViewCell!(self, didTapProfileImage: profileImageView)
  }
  
  //  MARK: - Lifecycel
  override func awakeFromNib() {
    super.awakeFromNib()
    
    self.layoutMargins = UIEdgeInsetsZero
    self.preservesSuperviewLayoutMargins = false
  }

}
