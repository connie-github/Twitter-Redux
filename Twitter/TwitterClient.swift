//
//  TwitterClient.swift
//  Twitter
//

import UIKit
import AFNetworking
import BDBOAuth1Manager


let twitterConsumerKey = "oV6uXRz7AEuquotglACkPZPcS"
let twitterConsumerSecret = "pITG7kMxIQ6XyM2sRzkhbXwwM0BOmTLqOJ7yY7X3X7AK2B25Vr"
let twitterBaseURL = NSURL(string: "https://api.twitter.com")


class TwitterClient: BDBOAuth1SessionManager {
    
    // loginCompletion holds closure until ready to use
    var loginCompletion: ((user: User?, error: NSError?) -> ())?
    
    class var sharedInstance: TwitterClient {
        struct Static {
            static let instance = TwitterClient(baseURL: twitterBaseURL, consumerKey: twitterConsumerKey, consumerSecret: twitterConsumerSecret)
        }
        return Static.instance
    }
    
    func homeTimelineWithParams(params: NSDictionary?, completion: (tweets: [Tweet]?, error: NSError?) -> ()) {
        GET("1.1/statuses/home_timeline.json",
            parameters: params,
            success: { (operation: NSURLSessionDataTask!, response: AnyObject?) -> Void in
                print("fetched home timeline")
                let tweets = Tweet.tweetsWithArray(response as! [NSDictionary])
                completion(tweets: tweets, error: nil)
            }, failure: { (operation: NSURLSessionDataTask?, error: NSError!) -> Void in
                print("error getting home timeline")
                completion(tweets: nil, error: error)
            }
        )
    }
    
    func mentionsTimelineWithParams(params: NSDictionary?, completion: (tweets: [Tweet]?, error: NSError?) -> ()) {
        self.GET("1.1/statuses/mentions_timeline.json",
            parameters: params,
            success: { (operation: NSURLSessionDataTask!, response: AnyObject) -> Void in
                print("fetched mentions timeline")
                let tweets = Tweet.tweetsWithArray(response as! [NSDictionary])
                completion(tweets: tweets, error: nil)
            },
            failure: { (operation: NSURLSessionDataTask?, error: NSError) -> Void in
                print("error getting mentions timeline")
                completion(tweets: nil, error: error)
            }
        )
    }
    
    func loginWithCompletion(completion: (user: User?, error: NSError?) -> ()) {
        loginCompletion = completion
        
        // fetch request token & redirect to authorization page
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        TwitterClient.sharedInstance.fetchRequestTokenWithPath("oauth/request_token",
            method: "GET",
            callbackURL: NSURL(string: "cptwitterdemo://oauth"),
            scope: nil,
            success: { (requestToken: BDBOAuth1Credential!) -> Void in
                print("Got request token")
                let authURL = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)")
                UIApplication.sharedApplication().openURL(authURL!)
            }, failure: { (error: NSError!) -> Void in
                print("Failed to get request token")
                self.loginCompletion?(user: nil, error: error)
            }
        )
    }
    
    func openURL(url: NSURL) {
        fetchAccessTokenWithPath("oauth/access_token",
            method: "POST",
            requestToken: BDBOAuth1Credential(queryString: url.query),
            success: { (accessToken: BDBOAuth1Credential!) -> Void in
                print("Got access token")
                TwitterClient.sharedInstance.requestSerializer.saveAccessToken(accessToken)
            
                TwitterClient.sharedInstance.GET("1.1/account/verify_credentials.json",
                    parameters: nil,
                    success: { (operation: NSURLSessionDataTask!, response: AnyObject?) -> Void in
                        // print(response)
                        let user = User(dictionary: response as! NSDictionary)
                        User.currentUser = user // persist user as currentUser
                        print(user.name)
                        self.loginCompletion?(user: user, error: nil)
                    }, failure: { (operation: NSURLSessionDataTask?, error: NSError!) -> Void in
                        print("error getting current user")
                        self.loginCompletion?(user: nil, error: error)
                    }
                )
            }, failure: { (error: NSError!) -> Void in
                print("Failed to get access token")
                self.loginCompletion?(user: nil, error: error)
            }
        )
    }
    
    
    func postTweet(params: NSDictionary?, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        POST("1.1/statuses/update.json",
            parameters: params,
            success: { (operation: NSURLSessionDataTask!, response: AnyObject!) -> Void in
                print("posted tweet")
                let tweet = Tweet(dictionary: response as! NSDictionary)
                completion(tweet: tweet, error: nil)
            }, failure: { (operation: NSURLSessionDataTask?, error: NSError!) -> Void in
                print("error posting tweet")
                print(error)
                completion(tweet: nil, error: error)
            }
        )
    }

    func retweet(id: String, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        POST("1.1/statuses/retweet/\(id).json",
            parameters: nil,
            success: { (operation: NSURLSessionDataTask!, response: AnyObject!) -> Void in
                print("posted retweet")
                let tweet = Tweet(dictionary: response as! NSDictionary)
                completion(tweet: tweet, error: nil)
            }, failure: { (operation: NSURLSessionDataTask?, error: NSError!) -> Void in
                print("error retweeting")
                print(error)
                completion(tweet: nil, error: error)
            }
        )
    }
    
    func unretweet(id: String, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        POST("1.1/statuses/unretweet/\(id).json",
            parameters: nil,
            success: { (operation: NSURLSessionDataTask!, response: AnyObject) -> Void in
                print("unretweeted")
                let tweet = Tweet(dictionary: response as! NSDictionary)
                completion(tweet: tweet, error: nil)
            }, failure: { (operation: NSURLSessionDataTask?, error: NSError) -> Void in
                print("error unretweeting")
                print(error)
                completion(tweet: nil, error: error)
            }
        )
    }
    
    func favorite(params: NSDictionary!, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        POST("1.1/favorites/create.json",
            parameters: params,
            success: { (operation: NSURLSessionDataTask!, response: AnyObject!) -> Void in
                print("favorited tweet")
                let tweet = Tweet(dictionary: response as! NSDictionary)
                completion(tweet: tweet, error: nil)
            }, failure: { (operation: NSURLSessionDataTask?, error: NSError!) -> Void in
                print("error favoriting tweet")
                print(error)
                completion(tweet: nil, error: error)
            }
        )
    }
    
    func unfavorite(params: NSDictionary!, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        POST("1.1/favorites/destroy.json",
            parameters: params,
            success: { (operation: NSURLSessionDataTask!, response: AnyObject!) -> Void in
                print("unfavorited tweet")
                let tweet = Tweet(dictionary: response as! NSDictionary)
                completion(tweet: tweet, error: nil)
            }, failure: { (operation: NSURLSessionDataTask?, error: NSError!) -> Void in
                print("error unfavoriting tweet")
                print(error)
                completion(tweet: nil, error: error)
            }
        )
    }


}
