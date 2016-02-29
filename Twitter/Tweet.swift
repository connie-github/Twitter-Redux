//
//  Tweet.swift
//  Twitter
//

import UIKit
import AFNetworking

class Tweet: NSObject {
    var dictionary: NSDictionary
    var idString: String!
    var author: User?
    var tweetText: String?
    var createdAt: NSDate?
    var retweeted: Bool?
    var retweetCount: Int?
    var favorited: Bool?
    var favoriteCount: Int?
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary

        idString = dictionary["id_str"] as! String
        author = User(dictionary: (dictionary["user"] as? NSDictionary)!)
        tweetText = dictionary["text"] as? String
        
        let createdAtString = dictionary["created_at"] as? String
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        createdAt = formatter.dateFromString(createdAtString!)
        
        retweeted = dictionary["retweeted"] as? Bool
        retweetCount = dictionary["retweet_count"] as? Int
        
        favorited = dictionary["favorited"] as? Bool
        favoriteCount = dictionary["favorite_count"] as? Int
    }


    class func tweetsWithArray(array: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        for dictionary in array {
            tweets.append(Tweet(dictionary: dictionary))
        }
        return tweets
    }
}
