//
//  TwitterClient.swift
//  Twitter
//
//  Created by Randy Ting on 9/29/15.
//  Copyright © 2015 Randy Ting. All rights reserved.
//

import UIKit

  // MARK: - Credentials
let twitterConsumerKey = "pYUDbmqygahTYTTQ7i0bGNIZp"
let twitterConsumerSecret = "KrzcXMh6IOArfNnyTPdiMizzuMrK3RFmdYfFtyjO8JzG3VoNsr"
let twitterBaseURL = URL(string: "https://api.twitter.com")

class TwitterClient: BDBOAuth1RequestOperationManager {
  
  // MARK: - Properties
  fileprivate var loginCompletion: ((_ user: TwitterUser?, _ error: Error?) -> ())?
  
  // MARK: - Shared Instance
  static let sharedInstance: TwitterClient = {
    return TwitterClient(baseURL: twitterBaseURL, consumerKey: twitterConsumerKey, consumerSecret: twitterConsumerSecret)
  }()
  
  // MARK: - Login
  func loginWithCompletion(_ completion: @escaping (_ user: TwitterUser?, _ error: Error?) -> ()){
    loginCompletion = completion
    
    requestSerializer.removeAccessToken()
    fetchRequestToken(withPath: "oauth/request_token",
      method: "GET",
      callbackURL: URL(string: "randytwitterreduxdemo://oauth"),
      scope: nil,
      success: {
        (requestToken: BDBOAuth1Credential?) -> Void in
        
        let authURL = URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken!.token!)")
        UIApplication.shared.openURL(authURL!)
      }) {
        (error: Error?) -> Void in
        print(error!.localizedDescription)
        self.loginCompletion?(nil, error)
    }
  }
  
  func openURL(_ url: URL) {
    fetchAccessToken(withPath: "oauth/access_token",
      method: "POST",
      requestToken: BDBOAuth1Credential(queryString: url.query),
      success: {
        (accessToken: BDBOAuth1Credential?) -> Void in
        self.requestSerializer.saveAccessToken(accessToken)
        self.getLoggedInUser(self.loginCompletion)
      }) {
        (error: Error?) -> Void in
        self.loginCompletion?(nil, error)
    }
  }
  
  fileprivate func getLoggedInUser(_ completion: ((_ user: TwitterUser?, _ error: Error?) -> ())?){
    get("/1.1/account/verify_credentials.json",
      parameters: nil,
      success: { (operation: AFHTTPRequestOperation?, response: Any?) -> Void in
        
        do {
          
          let JsonDict = try JSONSerialization.jsonObject(with: response as! Data, options: [])
          if let userDetails = JsonDict as? NSDictionary
          {
            let currentUser = TwitterUser.init(dictionary: userDetails)
            completion?(currentUser, nil)
          }
        } catch {
          print(error)
        }
        
      }) { (operation: AFHTTPRequestOperation?, error: Error?) -> Void in
        (completion?(nil, error))!
    }
  }
  
  // MARK: - Access
  func homeTimelineWithParams(_ parameters: TwitterHomeTimelineParameters?, completion: @escaping (_ tweets: [Tweet]?, _ error: Error? ) -> () ){

    get("/1.1/statuses/home_timeline.json",
      parameters: parameters?.dictionary,
      success: { (operation: AFHTTPRequestOperation?, response: Any?) -> Void in
        let tweetsAsArray = response as? [NSDictionary]
        let tweets = Tweet.tweets(array: tweetsAsArray!)
        completion(tweets, nil)
      }) { (operation: AFHTTPRequestOperation?, error: Error?) -> Void in
        completion(nil, error)
    }
  }
  
  func mentionsTimelineWithParams(_ parameters: TwitterHomeTimelineParameters?, completion: @escaping (_ tweets: [Tweet]?, _ error: Error? ) -> () ){
    
    get("/1.1/statuses/mentions_timeline.json",
      parameters: parameters?.dictionary,
      success: { (operation: AFHTTPRequestOperation?, response: Any?) -> Void in
        let tweetsAsArray = response as? [NSDictionary]
        let tweets = Tweet.tweets(array: tweetsAsArray!)
        completion(tweets, nil)
      }) { (operation: AFHTTPRequestOperation?, error: Error?) -> Void in
        completion(nil, error)
    }
  }
  
  func tweetText(_ text: String?, inReplyToStatusID: String?, completion: @escaping (_ success: Bool?, _ error: Error?) -> ()) {

    var parameters: [String:Any?] = ["status":text! as Any?]
    if let inReplyToStatusID = inReplyToStatusID{
      parameters["in_reply_to_status_id"] = inReplyToStatusID as Any??
    }
    post("/1.1/statuses/update.json",
      parameters: parameters,
      constructingBodyWith: { (formData: AFMultipartFormData?) -> Void in
        //
      },
      success: { (operation: AFHTTPRequestOperation?, response: Any?) -> Void in
        completion(true, nil)
      }) { (operation: AFHTTPRequestOperation?, error: Error?) -> Void in
        completion(false, error)
    }
  }
  
  func favorite(_ tweet: Tweet, completion: @escaping (_ response: Any??, _ error: Error?) ->()){
    
    let parameters = ["id": tweet.idString]
    
    post("/1.1/favorites/create.json",
      parameters: parameters,
      constructingBodyWith: { (formData: AFMultipartFormData?) -> Void in
        //
      },
      success: { (operation: AFHTTPRequestOperation?, response: Any?) -> Void in
        let favoriteResponse = response as? NSDictionary
        tweet.favorited = favoriteResponse!["favorited"] as? Bool
        tweet.favoriteCount = favoriteResponse!["favorite_count"] as? Int
        completion(response, nil)
      }) { (operation: AFHTTPRequestOperation?, error: Error?) -> Void in
        completion(nil, error)
    }
  }
  
  func unfavorite(_ tweet: Tweet, completion: @escaping (_ response: Any??, _ error: Error?) ->()){
    
    let parameters = ["id": tweet.idString]
    
    post("/1.1/favorites/destroy.json",
      parameters: parameters,
      constructingBodyWith: { (formData: AFMultipartFormData?) -> Void in
        //
      },
      success: { (operation: AFHTTPRequestOperation?, response: Any?) -> Void in
        let unfavoriteResponse = response as? NSDictionary
        tweet.favorited = unfavoriteResponse!["favorited"] as? Bool
        tweet.favoriteCount = unfavoriteResponse!["favorite_count"] as? Int
        completion(response, nil)
      }) { (operation: AFHTTPRequestOperation?, error: Error?) -> Void in
        completion(nil, error)
    }
  }
  
  func retweet(_ tweet: Tweet, completion: @escaping (_ response: Any??, _ error: Error?) ->()){
    
    let parameters = ["id": tweet.idString]
    
    post("/1.1/statuses/retweet/" + (tweet.idString) + ".json",
      parameters: parameters,
      constructingBodyWith: { (formData: AFMultipartFormData?) -> Void in
        //
      },
      success: { (operation: AFHTTPRequestOperation?, response: Any?) -> Void in
        let retweetedResponse = response as? NSDictionary
        tweet.retweeted = retweetedResponse!["retweeted"] as? Bool
        tweet.retweetCount = retweetedResponse!["retweet_count"] as? Int
        completion(response, nil)
      }) { (operation: AFHTTPRequestOperation?, error: Error?) -> Void in
        completion(nil, error)
    }
  }
  
  func unretweet(_ tweet: Tweet, completion: @escaping (_ response: Any??, _ error: Error?) ->()){
    
    var originalTweetIdString = String()
    
    if tweet.retweeted == false {
      let error = NSError.init(domain: "com.randy.Twitter", code: 0, userInfo: ["Error reason": "Tweet has not been retweeted."])

      completion(nil, error)
    } else {
      if tweet.originalTweet == nil {
        originalTweetIdString = tweet.idString
      } else {
        originalTweetIdString = tweet.originalTweet!.idString
      }
    }
    
    get("https://api.twitter.com/1.1/statuses/show.json?id=" + originalTweetIdString,
      parameters: ["id": originalTweetIdString,
                    "include_my_retweet": true],
      success: { (operation: AFHTTPRequestOperation?, response: Any?) -> Void in
        let tweetResponse = response as? NSDictionary
        let retweetIDString = (tweetResponse!["current_user_retweet"] as! [String:AnyObject])["id_str"] as! String
        
        let parameters = ["id": retweetIDString]
        
        self.post("/1.1/statuses/destroy/" + retweetIDString + ".json",
          parameters: parameters,
          constructingBodyWith: { (formData: AFMultipartFormData?) -> Void in
            //
          },
          success: { (operation: AFHTTPRequestOperation?, response: Any?) -> Void in
            let unretweetedResponse = response as? NSDictionary
            tweet.retweeted = false  // Looks like Twitter's servers take a while to update this to false
            tweet.retweetCount = (unretweetedResponse!["retweet_count"] as? Int)! - 1
            completion(response, nil)
          }) { (operation: AFHTTPRequestOperation?, error: Error?) -> Void in
            completion(nil, error)
        }
        
      }) { (operation: AFHTTPRequestOperation?, error: Error?) -> Void in
        completion(nil, error)
    }
    

  }
  
  func userWithScreenName(_ screenName: String!, completion: @escaping (_ user: TwitterUser?, _ error: Error?) -> ()) {
    
    let parameters: [String:Any?] = ["screen_name":screenName as Any?]
    
    get("/1.1/users/show.json",
      parameters: parameters,
      success: { (operation: AFHTTPRequestOperation?, response: Any?) -> Void in
        let userDictionary = response as! NSDictionary
        let user = TwitterUser(dictionary: userDictionary)
        completion(user, nil)
      }) { (operation: AFHTTPRequestOperation?, error: Error?) -> Void in
        completion(nil, error)
    }
  }
  
  
}
