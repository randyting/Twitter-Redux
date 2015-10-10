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
  
  // MARK: - Initialization
  init(dictionary: NSDictionary){
    
    name = dictionary["name"] as? String
    screenname = dictionary["screen_name"] as? String
    
    let profileImageURLStringRaw = dictionary["profile_image_url_https"] as? String
    let range = profileImageURLStringRaw!.rangeOfString("normal", options: .RegularExpressionSearch)
    profileImageURLString = profileImageURLStringRaw!.stringByReplacingCharactersInRange(range!, withString: "bigger")
    
    super.init()
    TwitterUser.currentUser = self
  }
  
  // MARK: - NSCoding
  required init(coder aDecoder: NSCoder) {
    self.name = aDecoder.decodeObjectForKey("name") as! String
    self.screenname = aDecoder.decodeObjectForKey("screenname") as! String
    self.profileImageURLString = aDecoder.decodeObjectForKey("profileImageURLString") as! String
  }
  
  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(name, forKey: "name")
    aCoder.encodeObject(screenname, forKey: "screenname")
    aCoder.encodeObject(profileImageURLString, forKey: "profileImageURLString")
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
