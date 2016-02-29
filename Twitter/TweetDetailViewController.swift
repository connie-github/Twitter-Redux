//
//  TweetDetailViewController.swift
//  Twitter
//

import UIKit


protocol TweetDetailViewControllerDelegate {
    func updateTweetDetailView(tweet: Tweet, index: Int)
    func callComposeSegueFromTweetDetailView(tweet: Tweet)
    func callProfileSegueFromTweetDetailView(user: User)
}

class TweetDetailViewController: UIViewController {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var favoriteCountLabel: UILabel!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var retweetLabel: UILabel!
    @IBOutlet weak var favoriteLabel: UILabel!
    
    var delegate: TweetDetailViewControllerDelegate?
    var tweet: Tweet!
    var index: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        profileImage.layer.cornerRadius = 4
        profileImage.clipsToBounds = true
        
        updateTweet()
    }
    
    func updateTweet() {
        if tweet.author?.profileImageUrl != nil {
            profileImage.setImageWithURL(tweet.author!.profileImageUrl!)
        }

        nameLabel.text = tweet.author?.name
        usernameLabel.text = "@\(tweet.author!.screenname!)"
        tweetTextLabel.text = tweet.tweetText
        timestampLabel.text = self.formatTimestamp(tweet.createdAt!)
        
        retweetButton.selected = tweet.retweeted!
        retweetCountLabel.text = "\(tweet.retweetCount!)"
        if tweet.retweetCount == 1 {
            retweetLabel.text = "RETWEET"
        } else {
            retweetLabel.text = "RETWEETS"
        }

        favoriteButton.selected = tweet.favorited!
        favoriteCountLabel.text = "\(tweet.favoriteCount!)"
        if tweet.favoriteCount == 1 {
            favoriteLabel.text = "LIKE"
        } else {
            favoriteLabel.text = "LIKES"
        }
    }
    
    func formatTimestamp(date: NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MM/dd/yyyy HH:mm a"
        return formatter.stringFromDate(date)
    }
    
    @IBAction func onProfileImageTap(sender: UITapGestureRecognizer) {
        self.delegate?.callProfileSegueFromTweetDetailView(tweet.author!)

    }
    
    @IBAction func onReply(sender: AnyObject) {
        self.delegate?.callComposeSegueFromTweetDetailView(tweet)
    }
    
    @IBAction func onRetweet(sender: AnyObject) {
        TwitterClient.sharedInstance.retweet(tweet.idString!, completion: { (tweet: Tweet?, error: NSError?) -> () in
            if tweet != nil {
                self.retweetButton.selected = tweet!.retweeted!
                self.retweetCountLabel.text = "\(tweet!.retweetCount!)"
                
                self.tweet.retweetCount = tweet!.retweetCount!
                self.tweet.retweeted = tweet!.retweeted!
                self.tweet.favoriteCount = tweet!.favoriteCount!
                if self.index != nil {
                    self.delegate?.updateTweetDetailView(self.tweet, index: self.index)
                }
            }
        })
    }
    
    @IBAction func onFavorite(sender: AnyObject) {
        if favoriteButton.selected {
            unfavorite(tweet.idString)
        } else {
            favorite(tweet.idString)
        }
    }
    
    func favorite(idString: String!) {
        let params : NSDictionary = ["id": idString]
        TwitterClient.sharedInstance.favorite(params, completion: { (tweet: Tweet?, error: NSError?) -> () in
            if tweet != nil {
                self.tweet? = tweet!
                self.updateTweet()
                if self.index != nil {
                    self.delegate?.updateTweetDetailView(tweet!, index: self.index)
                }
            }
        })
    }
    
    func unfavorite(idString: String!) {
        let params : NSDictionary = ["id": idString]
        TwitterClient.sharedInstance.unfavorite(params, completion: { (tweet: Tweet?, error: NSError?) -> () in
            if tweet != nil {
                self.tweet = tweet!
                self.updateTweet()
                if self.index != nil {
                    self.delegate?.updateTweetDetailView(tweet!, index: self.index)
                }
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
