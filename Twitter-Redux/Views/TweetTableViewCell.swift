//
//  TweetTableViewCell.swift
//  Twitter-Redux
//
//  Created by Randy Ting on 10/9/15.
//  Copyright © 2015 Randy Ting. All rights reserved.
//

import UIKit

@objc protocol TweetTableViewCellDelegate {
  @objc optional func tweetTableViewCell(_ tweetTableViewCell: TweetTableViewCell, didTapReplyButton: UIButton)
  @objc optional func tweetTableViewCell(_ tweetTableViewCell: TweetTableViewCell, didTapProfileImage: UIImageView)
}

class TweetTableViewCell: UITableViewCell {
  
  // MARK: - Storyboard Objects
  @IBOutlet fileprivate weak var profileImageView: UIImageView!
  @IBOutlet fileprivate weak var tweetTextLabel: UILabel!
  @IBOutlet fileprivate weak var timeSinceCreatedDXTimestampLabel: DXTimestampLabel!
  @IBOutlet fileprivate weak var userNameLabel: UILabel!
  @IBOutlet fileprivate weak var userScreenNameLabel: UILabel!
  
  @IBOutlet fileprivate weak var replyButton: UIButton!
  
  @IBOutlet fileprivate weak var retweetButton: UIButton!
  @IBOutlet fileprivate weak var retweetCountLabel: UILabel!
  
  @IBOutlet fileprivate weak var favoriteButton: UIButton!
  @IBOutlet fileprivate weak var favoriteCountLabel: UILabel!
  
  @IBOutlet fileprivate weak var retweetOrReplyContainerView: UIView!
  @IBOutlet fileprivate weak var retweetContainerViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet fileprivate weak var retweetOrReplyIcon: UIImageView!
  @IBOutlet fileprivate weak var retweetOrReplyLabel: UILabel!
  
  @IBOutlet fileprivate weak var profileTopToContainerHeightConstraint: NSLayoutConstraint!
  
  // MARK: - Properties
  var tweetToShow: Tweet!
  weak var delegate: AnyObject?
  
  var tweet: Tweet! {
    didSet {
      tweetToShow = tweet.originalTweet ?? tweet
      updateContent()
      setupAppearance()
    }
  }
  
  // MARK: - Setup
  fileprivate func updateContent() {
    
    profileImageView.setImageWith(tweetToShow.profileImageURL as URL!)
    profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapProfileImage(_:))))
    
    tweetTextLabel.text = tweetToShow.text
    userNameLabel.text = tweetToShow.userName
    userScreenNameLabel.text = "@" + tweetToShow.userScreenname
    favoriteCountLabel.text = String(tweetToShow.favoriteCount)
    retweetCountLabel.text = String(tweetToShow.retweetCount)
    timeSinceCreatedDXTimestampLabel.timestamp = TwitterDateFormatter.sharedInstance.date(from: tweet.createdAt)
    if tweetToShow.favorited == true {
      favoriteButton.setImage(UIImage(named: "favorite_on"), for: UIControlState())
    } else {
      favoriteButton.setImage(UIImage(named: "favorite"), for: UIControlState())
    }
    if tweetToShow.retweeted == true {
      retweetButton.setImage(UIImage(named: "retweet_on"), for: UIControlState())
    } else {
      retweetButton.setImage(UIImage(named: "retweet"), for: UIControlState())
    }
    
    if tweet.isRetweet || tweet.isReply {
      retweetOrReplyContainerView.isHidden = false
      retweetContainerViewHeightConstraint.constant = 25
      profileTopToContainerHeightConstraint.constant = 0
      if tweet.isRetweet {
        retweetOrReplyIcon.image = UIImage(named: "retweet")
        retweetOrReplyLabel.text = "\(tweet.userName!) Retweeted"
      } else {
        retweetOrReplyIcon.image = UIImage(named: "reply")
        retweetOrReplyLabel.text = "in reply to @\(tweet.inReplyToScreenName!)"
      }
    } else {
      retweetOrReplyContainerView.isHidden = true
      retweetContainerViewHeightConstraint.constant = 0
      profileTopToContainerHeightConstraint.constant = 15
    }
    
  }
  
  fileprivate func setupAppearance() {
    profileImageView.layer.cornerRadius = 4.0
    profileImageView.clipsToBounds = true
  }
  
  // MARK: - Behavior
  @IBAction func onTapRetweetButton(_ sender: AnyObject) {
    if tweetToShow.retweeted == true {
      TwitterUser.unretweet(tweetToShow) { (_, error) -> Void in
        if let error = error {
          print("Unretweet Error: \(error.localizedDescription)")
        } else {
          self.updateContent()
        }
      }
    } else {
      TwitterUser.retweet(tweetToShow) { (_, error) -> Void in
        if let error = error {
          print("Retweet Error: \(error.localizedDescription)")
        } else {
          self.updateContent()
        }
      }
    }
  }
  
  @IBAction func onTapFavoriteButton(_ sender: UIButton) {
    if tweetToShow.favorited == true {
      TwitterUser.unfavorite(tweetToShow) { (_, error) -> Void in
        if let error = error {
          print("Unfavorite Error: \(error.localizedDescription)")
        } else {
          self.updateContent()
        }
      }
    } else {
      TwitterUser.favorite(tweetToShow) { (_, error) -> Void in
        if let error = error {
          print("Favorite Error: \(error.localizedDescription)")
        } else {
          self.updateContent()
        }
      }
    }
  }
  
  @IBAction func onTapReplyButton(_ sender: UIButton) {
    delegate?.tweetTableViewCell!(self, didTapReplyButton: sender)
  }
  
  func onTapProfileImage(_ sender: UITapGestureRecognizer) {
    delegate?.tweetTableViewCell!(self, didTapProfileImage: profileImageView)
  }
  
  // MARK: - Lifecycel
  override func awakeFromNib() {
    super.awakeFromNib()
    
    self.layoutMargins = UIEdgeInsets.zero
    self.preservesSuperviewLayoutMargins = false
  }

}
