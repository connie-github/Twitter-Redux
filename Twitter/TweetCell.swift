//
//  TweetCell.swift
//  Twitter
//

import UIKit


protocol TweetCellDelegate {
    func updateTweetCell(tweet: Tweet, cell: TweetCell)
    func callComposeSegueFromTweetCell(tweet: Tweet)
    func callProfileSegueFromTweetCell(user: User)
}

class TweetCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var favoriteCountLabel: UILabel!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var delegate: TweetCellDelegate?
    
    var tweet: Tweet! {
        didSet {
            if tweet.author?.profileImageUrl != nil {
                profileImage.setImageWithURL(tweet.author!.profileImageUrl!)
            }
            
            nameLabel.text = tweet.author?.name
            usernameLabel.text = "@\(tweet.author!.screenname!)"
            tweetTextLabel.text = tweet.tweetText
            
            retweetButton.selected = tweet.retweeted!
            retweetCountLabel.text = "\(tweet.retweetCount!)"
            
            favoriteButton.selected = tweet.favorited!
            favoriteCountLabel.text = "\(tweet.favoriteCount!)"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImage.layer.cornerRadius = 4
        profileImage.clipsToBounds = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "onProfileImageTap:")
        profileImage.userInteractionEnabled = true
        profileImage.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func onProfileImageTap(gesture: UIGestureRecognizer!) {
        self.delegate?.callProfileSegueFromTweetCell(tweet.author!)
    }
    
    @IBAction func onReply(sender: AnyObject) {
        self.delegate?.callComposeSegueFromTweetCell(tweet)
    }

    @IBAction func onRetweet(sender: AnyObject) {
        TwitterClient.sharedInstance.retweet(tweet.idString!, completion: { (tweet: Tweet?, error: NSError?) -> () in
            if tweet != nil {
                self.retweetButton.selected = tweet!.retweeted!
                self.retweetCountLabel.text = "\(tweet!.retweetCount!)"
                
                self.tweet.retweetCount = tweet!.retweetCount!
                self.tweet.retweeted = tweet!.retweeted!
                self.tweet.favoriteCount = tweet!.favoriteCount!
                self.delegate?.updateTweetCell(self.tweet, cell: self)
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
                self.tweet = tweet!
                self.delegate?.updateTweetCell(tweet!, cell: self)
            }
        })
    }
    
    func unfavorite(idString: String!) {
        let params : NSDictionary = ["id": idString]
        TwitterClient.sharedInstance.unfavorite(params, completion: { (tweet: Tweet?, error: NSError?) -> () in
            if tweet != nil {
                self.tweet = tweet!
                self.delegate?.updateTweetCell(tweet!, cell: self)
            }
        })
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
