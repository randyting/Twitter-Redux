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
    let range = profileImageURLStringRaw!.range(of: "normal", options: .regularExpression)
    profileImageURLString = profileImageURLStringRaw!.replacingCharacters(in: range!, with: "bigger")
    
    profileBackgroundImageURLString = dictionary["profile_background_image_url_https"] as? String

    if let profileBannerImageURLString = dictionary["profile_banner_url"] as? String  {
      self.profileBannerImageURLString = profileBannerImageURLString + "/mobile_retina"
    }
    
    super.init()
  }
  
  // MARK: - NSCoding
  required init(coder aDecoder: NSCoder) {
    self.name = aDecoder.decodeObject(forKey: "name") as! String
    self.screenname = aDecoder.decodeObject(forKey: "screenname") as! String
    self.profileImageURLString = aDecoder.decodeObject(forKey: "profileImageURLString") as! String
    self.idString =  aDecoder.decodeObject(forKey: "userIDString") as! String
    self.userDescription = aDecoder.decodeObject(forKey: "userDescription") as! String
    self.followersCount = aDecoder.decodeObject(forKey: "followersCount") as! Int
    self.friendsCount = aDecoder.decodeObject(forKey: "friendsCount") as! Int
    self.statusesCount = aDecoder.decodeObject(forKey: "statuses_count") as! Int
    self.profileBackgroundImageURLString = aDecoder.decodeObject(forKey: "profileBackgroundImageURLString") as! String
    self.profileBannerImageURLString = aDecoder.decodeObject(forKey: "profileBannerImageURLString") as? String
  }
  
  func encodeWithCoder(_ aCoder: NSCoder) {
    aCoder.encode(name, forKey: "name")
    aCoder.encode(screenname, forKey: "screenname")
    aCoder.encode(profileImageURLString, forKey: "profileImageURLString")
    aCoder.encode(idString, forKey: "userIDString")
    aCoder.encode(userDescription, forKey: "userDescription")
    aCoder.encode(followersCount, forKey: "followersCount")
    aCoder.encode(friendsCount, forKey: "friendsCount")
    aCoder.encode(statusesCount, forKey: "statuses_count")
    aCoder.encode(profileBackgroundImageURLString, forKey: "profileBackgroundImageURLString")
    aCoder.encode(profileBannerImageURLString, forKey: "profileBannerImageURLString")
  }
  
  // MARK: - Instance Methods
  func logout() {
    UserManager.sharedInstance.currentUser = nil
    TwitterUser.currentUser = nil
    TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
    NotificationCenter.default.post(name: Notification.Name(rawValue: userDidLogoutNotification), object: nil)
  }
  
  func homeTimelineWithParams(_ params: TwitterHomeTimelineParameters?, completion: @escaping (_ tweets: [Tweet]?, _ error: Error?) -> ()){
    TwitterClient.sharedInstance.homeTimelineWithParams(params, completion: completion as! ([Tweet]?, Error?) -> ())
  }
  
  func mentionsTimelineWithParams(_ params: TwitterHomeTimelineParameters?, completion: @escaping (_ tweets: [Tweet]?, _ error: Error?) -> ()){
    TwitterClient.sharedInstance.mentionsTimelineWithParams(params, completion: completion as! ([Tweet]?, Error?) -> ())
  }
  
  func profileImageURL() -> URL? {
    return URL(string: profileImageURLString)
  }
  
  // MARK: - Class Methods
  class func loginWithCompletion(_ completion: @escaping (_ user: TwitterUser?, _ error: Error?) -> ()) {
    TwitterClient.sharedInstance.loginWithCompletion (completion)
  }
  
  class func tweetText(_ text: String?, inReplyToStatusID: String?, completion: @escaping (_ success: Bool?, _ error: Error?) -> ()) {
    TwitterClient.sharedInstance.tweetText(text, inReplyToStatusID: inReplyToStatusID, completion: completion as! (Bool?, Error?) -> ())
  }
  
  class func favorite(_ tweet: Tweet, completion: @escaping (_ response: AnyObject?, _ error: Error?) ->()){
    TwitterClient.sharedInstance.favorite(tweet, completion: completion as! (AnyObject?, Error?) -> () as! (Any??, Error?) -> ())
  }
  
  class func unfavorite(_ tweet: Tweet, completion: @escaping (_ response: AnyObject?, _ error: Error?) ->()){
    TwitterClient.sharedInstance.unfavorite(tweet, completion: completion as! (AnyObject?, Error?) -> () as! (Any??, Error?) -> ())
  }
  
  class func retweet(_ tweet: Tweet, completion: @escaping (_ response: AnyObject?, _ error: Error?) ->()){
    TwitterClient.sharedInstance.retweet(tweet, completion: completion as! (AnyObject?, Error?) -> () as! (Any??, Error?) -> ())
  }
  
  class func unretweet(_ tweet: Tweet, completion: @escaping (_ response: AnyObject?, _ error: Error?) ->()){
    TwitterClient.sharedInstance.unretweet(tweet, completion: completion as! (AnyObject?, Error?) -> () as! (Any??, Error?) -> ())
  }
  
  class func userWithScreenName(_ screenName: String?, completion: @escaping (_ user: TwitterUser?, _ error: Error?) -> ()) {
    TwitterClient.sharedInstance.userWithScreenName(screenName, completion: completion as! (TwitterUser?, Error?) -> ())
  }
  
  // MARK: - Class Variables
  class var currentUser: TwitterUser?{
    get {
    if let archivedUser = UserDefaults.standard.object(forKey: currentUserKey) {
    return NSKeyedUnarchiver.unarchiveObject(with: archivedUser as! Data) as? TwitterUser
    }
    return nil
    }
    set(user) {
      if let user = user {
        let archivedUser = NSKeyedArchiver.archivedData(withRootObject: user)
        UserDefaults.standard.set(archivedUser, forKey: currentUserKey)
      } else {
        UserDefaults.standard.set(nil, forKey: currentUserKey)
      }
      UserDefaults.standard.synchronize()
    }
  }
  
}
