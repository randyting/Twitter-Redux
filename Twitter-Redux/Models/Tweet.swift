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
  let profileImageURL: NSURL!
  let retweetedStatus: NSDictionary!
  let originalTweetIdString: String?
  var mediaURL: NSURL?
  
  var favorited: Bool!
  var retweeted: Bool!
  
  // MARK: - Init
  init(dictionary: NSDictionary) {
    
    createdAt = dictionary["created_at"] as? String
    favoriteCount = dictionary["favorite_count"] as? Int
    idString = dictionary["id_str"] as? String
    retweetCount = dictionary["retweet_count"] as? Int
    text = dictionary["text"] as? String
    userName = dictionary["user"]!["name"] as? String
    userScreenname = dictionary["user"]!["screen_name"] as? String
    id = dictionary["id"] as? UInt64
    retweetedStatus = dictionary["retweeted_status"] as? NSDictionary
    originalTweetIdString = dictionary["retweeted_status"]?["id_str"] as? String
    
    var profileImageURLString = dictionary["user"]!["profile_image_url_https"] as? String
    let range = profileImageURLString!.rangeOfString("normal.jpg", options: .RegularExpressionSearch)
    if let range = range {
      profileImageURLString = profileImageURLString!.stringByReplacingCharactersInRange(range, withString: "bigger.jpg")
    }
    profileImageURL = NSURL(string: profileImageURLString!)
    
    
//    if let mediaURLString = (dictionary["entities"]?["media"] as? NSArray)![0]["media_url_https"] as? String {
//      mediaURL = NSURL(string: mediaURLString)
//    }
    
    favorited = dictionary["favorited"] as? Bool
    retweeted = dictionary["retweeted"] as? Bool
    
    super.init()
  }
  
  // MARK: - Class Methods
  class func tweets(array array: [NSDictionary]) -> [Tweet] {
    var tweets = [Tweet]()
    for tweet in array {
      tweets.append(Tweet.init(dictionary: tweet ))
    }
    return tweets
  }
  
}
