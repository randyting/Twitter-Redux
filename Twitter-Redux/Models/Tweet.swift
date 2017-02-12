//
//  Tweet.swift
//  Twitter
//
//  Created by Randy Ting on 9/30/15.
//  Copyright © 2015 Randy Ting. All rights reserved.
//

import UIKit

class Tweet: NSObject {
  
  // MARK: - Properties
  let createdAt: String!
  var favoriteCount: Int!
  let idString: String!
  let id: UInt64!
  var retweetCount: Int!
  let text: String!
  let userName: String!
  let userScreenname: String!
  let profileImageURL: URL!
  var mediaURL: URL?
  var inReplyToScreenName: String?
  var favorited: Bool!
  var retweeted: Bool!
  
  var originalTweet: Tweet?
  
  var isRetweet: Bool {
    if let _ = originalTweet {
      return true
    } else {
      return false
    }
  }
  
  var isReply: Bool {
    if let _ = inReplyToScreenName {
      return true
    } else {
      return false
    }
  }
  
  // MARK: - Init
  init(dictionary: NSDictionary) {
    
    createdAt = dictionary["created_at"] as? String
    favoriteCount = dictionary["favorite_count"] as? Int
    idString = dictionary["id_str"] as? String
    retweetCount = dictionary["retweet_count"] as? Int
    text = dictionary["text"] as? String
    userName = (dictionary["user"] as! [String:AnyObject])["name"] as? String
    userScreenname = (dictionary["user"] as! [String:AnyObject])["screen_name"] as? String
    id = UInt64(idString)
    
    inReplyToScreenName = dictionary["in_reply_to_screen_name"] as? String
    
    let retweetedStatus = dictionary["retweeted_status"] as? NSDictionary
    if let retweetedStatus = retweetedStatus {
      originalTweet = Tweet(dictionary: retweetedStatus)
    }
    
    var profileImageURLString = (dictionary["user"] as! [String:AnyObject])["profile_image_url_https"] as? String
    let range = profileImageURLString!.range(of: "normal.jpg", options: .regularExpression)
    if let range = range {
      profileImageURLString = profileImageURLString!.replacingCharacters(in: range, with: "bigger.jpg")
    }
    profileImageURL = URL(string: profileImageURLString!)
    
    favorited = dictionary["favorited"] as? Bool
    retweeted = dictionary["retweeted"] as? Bool
    
    super.init()
  }
  
  // MARK: - Class Methods
  class func tweets(array: [NSDictionary]) -> [Tweet] {
    var tweets = [Tweet]()
    for tweet in array {
      tweets.append(Tweet.init(dictionary: tweet ))
    }
    return tweets
  }
  
}
