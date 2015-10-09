//
//  TwitterClient.swift
//  Twitter
//
//  Created by Randy Ting on 9/29/15.
//  Copyright © 2015 Randy Ting. All rights reserved.
//

import UIKit
import SwiftyJSON

  // MARK: - Credentials
let twitterConsumerKey = "k1czNm79JKV5T5WLd8lPSSDBB"
let twitterConsumerSecret = "kJzE1C4Giq4MTHNVshWRgJqLDL7Mx4ShHSjS7ZmxzyQWvIoGLw"
let twitterBaseURL = NSURL(string: "https://api.twitter.com")

class TwitterClient: BDBOAuth1RequestOperationManager {
  
  // MARK: - Properties
  private var loginCompletion: ((user: TwitterUser?, error: NSError?) -> ())?
  
  // MARK: - Shared Instance
  class var sharedInstance: TwitterClient {
    struct Static {
      static let instance = TwitterClient(baseURL: twitterBaseURL, consumerKey: twitterConsumerKey, consumerSecret: twitterConsumerSecret)
    }
    return Static.instance
  }
  
  // MARK: - Login
  func loginWithCompletion(completion: (user: TwitterUser?, error: NSError?) -> ()){
    loginCompletion = completion
    
    requestSerializer.removeAccessToken()
    fetchRequestTokenWithPath("oauth/request_token",
      method: "GET",
      callbackURL: NSURL(string: "randytwitterdemo://oauth"),
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
        let userDetails = JSON.init(response)
        let currentUser = TwitterUser.init(dictionary: userDetails.dictionary!)
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
        let tweetsAsJSON  = JSON.init(response).array!
        let tweets = Tweet.tweets(array: tweetsAsJSON)
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
        let favoriteResponseAsJSON  = JSON.init(response).dictionary!
        tweet.favorited = favoriteResponseAsJSON["favorited"]?.bool
        tweet.favoriteCount = favoriteResponseAsJSON["favorite_count"]?.int
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
        let unfavoriteResponseAsJSON  = JSON.init(response).dictionary!
        tweet.favorited = unfavoriteResponseAsJSON["favorited"]?.bool
        tweet.favoriteCount = unfavoriteResponseAsJSON["favorite_count"]?.int
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
        let retweetedResponseAsJSON  = JSON.init(response).dictionary!
        tweet.retweeted = retweetedResponseAsJSON["retweeted"]?.bool
        tweet.retweetCount = retweetedResponseAsJSON["retweet_count"]?.int
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
      if tweet.retweetedStatus == nil {
        originalTweetIdString = tweet.idString
      } else {
        originalTweetIdString = tweet.originalTweetIdString!
      }
    }
    
    GET("https://api.twitter.com/1.1/statuses/show.json?id=" + originalTweetIdString,
      parameters: ["id": originalTweetIdString,
                    "include_my_retweet": true],
      success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
        let tweetAsJSON  = JSON.init(response).dictionary!
        let retweetIDString = (tweetAsJSON["current_user_retweet"]?["id_str"].string)!
        
        let parameters = ["id": retweetIDString]
        
        self.POST("/1.1/statuses/destroy/" + retweetIDString + ".json",
          parameters: parameters,
          constructingBodyWithBlock: { (formData: AFMultipartFormData!) -> Void in
            //
          },
          success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            let unretweetedResponseAsJSON  = JSON.init(response).dictionary!
            tweet.retweeted = false  // Looks like Twitter's servers take a while to update this to false
            tweet.retweetCount = (unretweetedResponseAsJSON["retweet_count"]?.int)! - 1
            completion(response: response, error: nil)
          }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
            completion(response: nil, error: error)
        }
        
      }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
        completion(response: nil, error: error)
    }
    

  }
  
  
}
