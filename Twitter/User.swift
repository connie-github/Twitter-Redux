//
//  User.swift
//  Twitter
//

import UIKit
import AFNetworking

var _currentUser: User?
let currentUserKey = "kCurrentUserKey"
let userDidLoginNotification = "userDidLoginNotification"
let userDidLogoutNotification = "userDidLogoutNotification"


class User: NSObject {
    var dictionary: NSDictionary
    var name: String?
    var screenname: String?
    var profileImageUrl: NSURL?
    var profileBannerImageURL: NSURL?
    var tagline: String?
    var tweetCount: Int?
    var followerCount: Int?
    var followingCount: Int?

    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        
        name = dictionary["name"] as? String
        screenname = dictionary["screen_name"] as? String
        let profileImageUrlString = dictionary["profile_image_url"] as? String
        if profileImageUrlString != nil {
            profileImageUrl = NSURL(string: profileImageUrlString!)!
        }
        let profileBannerImageURLString = dictionary["profile_banner_url"] as? String
        if profileBannerImageURLString != nil {
            profileBannerImageURL = NSURL(string: profileBannerImageURLString!)
        }
        tagline = dictionary["description"] as? String
        tweetCount = dictionary["statuses_count"] as? Int
        followerCount = dictionary["followers_count"] as? Int
        followingCount = dictionary["friends_count"] as? Int
        

    }
    
    func logout() {
        User.currentUser = nil
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        
        NSNotificationCenter.defaultCenter().postNotificationName(userDidLogoutNotification, object: nil)
    }
    
    
    class var currentUser: User? {
        get {
            if _currentUser == nil {
                let data = NSUserDefaults.standardUserDefaults().objectForKey(currentUserKey) as? NSData
                if data != nil {
                    do {
                        let dictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
                        _currentUser = User(dictionary: dictionary)
                    } catch {
                        print("JSON error")
                    }
                }
            }
            return _currentUser
        }
        
        set(user) {
            _currentUser = user
            
            if _currentUser != nil {
                do {
                    let data = try NSJSONSerialization.dataWithJSONObject(user!.dictionary, options: [])
                    NSUserDefaults.standardUserDefaults().setObject(data, forKey: currentUserKey)
                } catch {
                    print("JSON error")
                }
            } else {
                NSUserDefaults.standardUserDefaults().setObject(nil, forKey: currentUserKey)
            }
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
}






