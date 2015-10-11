//
//  TwitterClient.swift
//  Twitter
//
//  Created by Randy Ting on 9/29/15.
//  Copyright © 2015 Randy Ting. All rights reserved.
//

import UIKit

  // MARK: - Credentials
let twitterConsumerKey = "k1czNm79JKV5T5WLd8lPSSDBB"
let twitterConsumerSecret = "kJzE1C4Giq4MTHNVshWRgJqLDL7Mx4ShHSjS7ZmxzyQWvIoGLw"
let twitterBaseURL = NSURL(string: "https://api.twitter.com")

class TwitterClient: BDBOAuth1RequestOperationManager {
  
  // MARK: - Properties
  private var loginCompletion: ((user: TwitterUser?, error: NSError?) -> ())?
  
  // MARK: - Shared Instance
  static let sharedInstance: TwitterClient = {
    return TwitterClient(baseURL: twitterBaseURL, consumerKey: twitterConsumerKey, consumerSecret: twitterConsumerSecret)
  }()
  
  // MARK: - Login
  func loginWithCompletion(completion: (user: TwitterUser?, error: NSError?) -> ()){
    loginCompletion = completion
    
    requestSerializer.removeAccessToken()
    fetchRequestTokenWithPath("oauth/request_token",
      method: "GET",
      callbackURL: NSURL(string: "randytwitterreduxdemo://oauth"),
      scope: nil,
      success: {
        (requestToken: BDBOAuth1Credential!) -> Void in
        let authURL = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)")
        UIApplication.sharedApplication().openURL(authURL!)
      }) {
        (error: NSError!) -> Void in
        print(error.localizedDescription)
        self.loginCompletion?(user: nil, error: error)
    }
  }
  
  func openURL(url: NSURL) {
    fetchAccessTokenWithPath("oauth/access_token",
      method: "POST",
      requestToken: BDBOAuth1Credential(queryString: url.query),
      success: {
        (accessToken: BDBOAuth1Credential!) -> Void in
        print("Received Access Token")
        self.requestSerializer.saveAccessToken(accessToken)
        self.getLoggedInUser(self.loginCompletion)
      }) {
        (error: NSError!) -> Void in
        self.loginCompletion?(user: nil, error: error)
    }
  }
  
  private func getLoggedInUser(completion: ((user: TwitterUser?, error: NSError?) -> ())?){
    GET("/1.1/account/verify_credentials.json",
      parameters: nil,
      success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
        let userDetails = response as! NSDictionary
        let currentUser = TwitterUser.init(dictionary: userDetails)
        completion?(user: currentUser, error: nil)
        
      }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
        completion?(user: nil, error: error)
    }
  }
  
  // MARK: - Access
  func homeTimelineWithParams(parameters: TwitterHomeTimelineParameters?, completion: (tweets: [Tweet]?, error: NSError? ) -> () ){

    GET("/1.1/statuses/home_timeline.json",
      parameters: parameters?.dictionary,
      success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
        let tweetsAsArray = response as? [NSDictionary]
        let tweets = Tweet.tweets(array: tweetsAsArray!)
        completion(tweets: tweets, error: nil)
      }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
        completion(tweets: nil, error: error)
    }
  }
  
  func tweetText(text: String?, inReplyToStatusID: String?, completion: (success: Bool?, error: NSError?) -> ()) {

    var parameters: [String:AnyObject] = ["status":text!]
    if let inReplyToStatusID = inReplyToStatusID{
      parameters["in_reply_to_status_id"] = inReplyToStatusID
    }
    POST("/1.1/statuses/update.json",
      parameters: parameters,
      constructingBodyWithBlock: { (formData: AFMultipartFormData!) -> Void in
        //
      },
      success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
        completion(success: true, error: nil)
      }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
        completion(success: false, error: error)
    }
  }
  
  func favorite(tweet: Tweet, completion: (response: AnyObject?, error: NSError?) ->()){
    
    let parameters = ["id": tweet.idString]
    
    POST("/1.1/favorites/create.json",
      parameters: parameters,
      constructingBodyWithBlock: { (formData: AFMultipartFormData!) -> Void in
        //
      },
      success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
        let favoriteResponse = response as? NSDictionary
        tweet.favorited = favoriteResponse!["favorited"] as? Bool
        tweet.favoriteCount = favoriteResponse!["favorite_count"] as? Int
        completion(response: response, error: nil)
      }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
        completion(response: nil, error: error)
    }
  }
  
  func unfavorite(tweet: Tweet, completion: (response: AnyObject?, error: NSError?) ->()){
    
    let parameters = ["id": tweet.idString]
    
    POST("/1.1/favorites/destroy.json",
      parameters: parameters,
      constructingBodyWithBlock: { (formData: AFMultipartFormData!) -> Void in
        //
      },
      success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
        let unfavoriteResponse = response as? NSDictionary
        tweet.favorited = unfavoriteResponse!["favorited"] as? Bool
        tweet.favoriteCount = unfavoriteResponse!["favorite_count"] as? Int
        completion(response: response, error: nil)
      }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
        completion(response: nil, error: error)
    }
  }
  
  func retweet(tweet: Tweet, completion: (response: AnyObject?, error: NSError?) ->()){
    
    let parameters = ["id": tweet.idString]
    
    POST("/1.1/statuses/retweet/" + (tweet.idString) + ".json",
      parameters: parameters,
      constructingBodyWithBlock: { (formData: AFMultipartFormData!) -> Void in
        //
      },
      success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
        let retweetedResponse = response as? NSDictionary
        tweet.retweeted = retweetedResponse!["retweeted"] as? Bool
        tweet.retweetCount = retweetedResponse!["retweet_count"] as? Int
        completion(response: response, error: nil)
      }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
        completion(response: nil, error: error)
    }
  }
  
  func unretweet(tweet: Tweet, completion: (response: AnyObject?, error: NSError?) ->()){
    
    var originalTweetIdString = String()
    
    if tweet.retweeted == false {
      let error = NSError.init(domain: "com.randy.Twitter", code: 0, userInfo: ["Error reason": "Tweet has not been retweeted."])
      completion(response: nil, error: error)
    } else {
      if tweet.originalTweet == nil {
        originalTweetIdString = tweet.idString
      } else {
        originalTweetIdString = tweet.originalTweet!.idString
      }
    }
    
    GET("https://api.twitter.com/1.1/statuses/show.json?id=" + originalTweetIdString,
      parameters: ["id": originalTweetIdString,
                    "include_my_retweet": true],
      success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
        let tweetResponse = response as? NSDictionary
        let retweetIDString = (tweetResponse!["current_user_retweet"]?["id_str"] as? String)!
        
        let parameters = ["id": retweetIDString]
        
        self.POST("/1.1/statuses/destroy/" + retweetIDString + ".json",
          parameters: parameters,
          constructingBodyWithBlock: { (formData: AFMultipartFormData!) -> Void in
            //
          },
          success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            let unretweetedResponse = response as? NSDictionary
            tweet.retweeted = false  // Looks like Twitter's servers take a while to update this to false
            tweet.retweetCount = (unretweetedResponse!["retweet_count"] as? Int)! - 1
            completion(response: response, error: nil)
          }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
            completion(response: nil, error: error)
        }
        
      }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
        completion(response: nil, error: error)
    }
    

  }
  
  func userWithScreenName(screenName: String!, completion: (user: TwitterUser?, error: NSError?) -> ()) {
    
    let parameters: [String:AnyObject] = ["screen_name":screenName]
    
    GET("/1.1/users/show.json",
      parameters: parameters,
      success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
        let userDictionary = response as! NSDictionary
        let user = TwitterUser(dictionary: userDictionary)
        completion(user: user, error: nil)
      }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
        completion(user:nil, error: error)
    }
  }
  
  
}
