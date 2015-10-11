//
//  TwitterUser.swift
//  Twitter
//
//  Created by Randy Ting on 9/30/15.
//  Copyright © 2015 Randy Ting. All rights reserved.
//

import UIKit

  // MARK: - Global Notification Keys
let userDidLoginNotification = "userDidLoginNotification"
let userDidLogoutNotification = "userDidLogoutNotification"

class TwitterUser: NSObject {
  
  // MARK: - Constants
  static let currentUserKey = "kCurrentUserKey"
  
  // MARK: - Instance Properties
  let name: String!
  let screenname: String!
  let profileImageURLString: String!
  let idString: String!
  let userDescription: String!
  let followersCount: Int!
  let friendsCount: Int!
  let statusesCount: Int!
  let profileBackgroundImageURLString: String!
  var profileBannerImageURLString: String?
  
  // MARK: - Initialization
  init(dictionary: NSDictionary){
    
    name = dictionary["name"] as? String
    screenname = dictionary["screen_name"] as? String
    idString = dictionary["id_str"] as? String
    userDescription = dictionary["description"] as? String
    followersCount = dictionary["followers_count"] as? Int
    friendsCount = dictionary["friends_count"] as? Int
    statusesCount = dictionary["statuses_count"] as? Int
    
    let profileImageURLStringRaw = dictionary["profile_image_url_https"] as? String
    let range = profileImageURLStringRaw!.rangeOfString("normal", options: .RegularExpressionSearch)
    profileImageURLString = profileImageURLStringRaw!.stringByReplacingCharactersInRange(range!, withString: "bigger")
    
    profileBackgroundImageURLString = dictionary["profile_background_image_url_https"] as? String

    if let profileBannerImageURLString = dictionary["profile_banner_url"] as? String  {
      self.profileBannerImageURLString = profileBannerImageURLString + "/mobile_retina"
    }
    
    super.init()
  }
  
  // MARK: - NSCoding
  required init(coder aDecoder: NSCoder) {
    self.name = aDecoder.decodeObjectForKey("name") as! String
    self.screenname = aDecoder.decodeObjectForKey("screenname") as! String
    self.profileImageURLString = aDecoder.decodeObjectForKey("profileImageURLString") as! String
    self.idString =  aDecoder.decodeObjectForKey("userIDString") as! String
    self.userDescription = aDecoder.decodeObjectForKey("userDescription") as! String
    self.followersCount = aDecoder.decodeObjectForKey("followersCount") as! Int
    self.friendsCount = aDecoder.decodeObjectForKey("friendsCount") as! Int
    self.statusesCount = aDecoder.decodeObjectForKey("statuses_count") as! Int
    self.profileBackgroundImageURLString = aDecoder.decodeObjectForKey("profileBackgroundImageURLString") as! String
    self.profileBannerImageURLString = aDecoder.decodeObjectForKey("profileBannerImageURLString") as? String
  }
  
  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(name, forKey: "name")
    aCoder.encodeObject(screenname, forKey: "screenname")
    aCoder.encodeObject(profileImageURLString, forKey: "profileImageURLString")
    aCoder.encodeObject(idString, forKey: "userIDString")
    aCoder.encodeObject(userDescription, forKey: "userDescription")
    aCoder.encodeObject(followersCount, forKey: "followersCount")
    aCoder.encodeObject(friendsCount, forKey: "friendsCount")
    aCoder.encodeObject(statusesCount, forKey: "statuses_count")
    aCoder.encodeObject(profileBackgroundImageURLString, forKey: "profileBackgroundImageURLString")
    aCoder.encodeObject(profileBannerImageURLString, forKey: "profileBannerImageURLString")
  }
  
  // MARK: - Instance Methods
  func logout() {
    UserManager.sharedInstance.currentUser = nil
    TwitterUser.currentUser = nil
    TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
    NSNotificationCenter.defaultCenter().postNotificationName(userDidLogoutNotification, object: nil)
  }
  
  func homeTimelineWithParams(params: TwitterHomeTimelineParameters?, completion: (tweets: [Tweet]?, error: NSError?) -> ()){
    TwitterClient.sharedInstance.homeTimelineWithParams(params) { (tweets, error) -> () in
      if let error = error {
        completion(tweets: nil, error: error)
      } else {
        completion(tweets: tweets, error: nil)
      }
    }
  }
  
  func profileImageURL() -> NSURL? {
    return NSURL(string: profileImageURLString)
  }
  
  // MARK: - Class Methods
  class func loginWithCompletion(completion: (user: TwitterUser?, error: NSError?) -> ()) {
    TwitterClient.sharedInstance.loginWithCompletion(completion)
  }
  
  class func tweetText(text: String?, inReplyToStatusID: String?, completion: (success: Bool?, error: NSError?) -> ()) {
    TwitterClient.sharedInstance.tweetText(text, inReplyToStatusID: inReplyToStatusID, completion: completion)
  }
  
  class func favorite(tweet: Tweet, completion: (response: AnyObject?, error: NSError?) ->()){
    TwitterClient.sharedInstance.favorite(tweet, completion: completion)
  }
  
  class func unfavorite(tweet: Tweet, completion: (response: AnyObject?, error: NSError?) ->()){
    TwitterClient.sharedInstance.unfavorite(tweet, completion: completion)
  }
  
  class func retweet(tweet: Tweet, completion: (response: AnyObject?, error: NSError?) ->()){
    TwitterClient.sharedInstance.retweet(tweet, completion: completion)
  }
  
  class func unretweet(tweet: Tweet, completion: (response: AnyObject?, error: NSError?) ->()){
    TwitterClient.sharedInstance.unretweet(tweet, completion: completion)
  }
  
  class func userWithScreenName(screenName: String?, completion: (user: TwitterUser?, error: NSError?) -> ()) {
    TwitterClient.sharedInstance.userWithScreenName(screenName, completion: completion)
  }
  
  // MARK: - Class Variables
  class var currentUser: TwitterUser?{
    get {
    if let archivedUser = NSUserDefaults.standardUserDefaults().objectForKey(currentUserKey) {
    return NSKeyedUnarchiver.unarchiveObjectWithData(archivedUser as! NSData) as? TwitterUser
    }
    return nil
    }
    set(user) {
      if let user = user {
        let archivedUser = NSKeyedArchiver.archivedDataWithRootObject(user)
        NSUserDefaults.standardUserDefaults().setObject(archivedUser, forKey: currentUserKey)
      } else {
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: currentUserKey)
      }
      NSUserDefaults.standardUserDefaults().synchronize()
    }
  }
  
}
