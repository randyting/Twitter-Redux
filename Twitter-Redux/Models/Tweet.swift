//
//  Tweet.swift
//  Twitter
//
//  Created by Randy Ting on 9/30/15.
//  Copyright © 2015 Randy Ting. All rights reserved.
//

import UIKit
import SwiftyJSON

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
  let retweetedStatus: [String:JSON]?
  let originalTweetIdString: String?
  var mediaURL: NSURL?
  
  var favorited: Bool!
  var retweeted: Bool!
  
  // MARK: - Init
  init(dictionary: [String: JSON]) {
    
    createdAt = dictionary["created_at"]!.string
    favoriteCount = dictionary["favorite_count"]?.int
    idString = dictionary["id_str"]?.string
    retweetCount = dictionary["retweet_count"]?.int
    text = dictionary["text"]?.string
    userName = dictionary["user"]!["name"].string
    userScreenname = dictionary["user"]!["screen_name"].string
    id = dictionary["id"]?.uInt64
    retweetedStatus = dictionary["retweeted_status"]?.dictionary
    originalTweetIdString = dictionary["retweeted_status"]?["id_str"].string
    
    var profileImageURLString = dictionary["user"]!["profile_image_url_https"].string
    let range = profileImageURLString!.rangeOfString("normal.jpg", options: .RegularExpressionSearch)
    if let range = range {
      profileImageURLString = profileImageURLString!.stringByReplacingCharactersInRange(range, withString: "bigger.jpg")
    }
    profileImageURL = NSURL(string: profileImageURLString!)
    
    
    if let mediaURLString = dictionary["entities"]?["media"][0]["media_url_https"].string {
      mediaURL = NSURL(string: mediaURLString)
    }
    
    favorited = dictionary["favorited"]?.bool
    retweeted = dictionary["retweeted"]?.bool
    
    super.init()
  }
  
  // MARK: - Class Methods
  class func tweets(array array: [JSON]) -> [Tweet] {
    var tweets = [Tweet]()
    for tweet in array {
      let tweetDictionary = tweet.dictionary!
      tweets.append(Tweet.init(dictionary: tweetDictionary ))
    }
    return tweets
  }
  
}
