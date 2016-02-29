//
//  ComposeViewController.swift
//  Twitter
//

import UIKit


protocol ComposeViewControllerDelegate {
    func composeTweet(tweet: Tweet)
}

class ComposeViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var tweetTextView: UITextView!
    @IBOutlet weak var characterCountLabel: UILabel!
    @IBOutlet weak var tweetButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var delegate: ComposeViewControllerDelegate?
    var replyTweet: Tweet?
    var user = User.currentUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if user.profileImageUrl != nil {
            profileImage.setImageWithURL(user.profileImageUrl!)
        }
        profileImage.layer.cornerRadius = 4
        profileImage.clipsToBounds = true
        
        nameLabel.text = user.name
        usernameLabel.text = "@\(user.screenname!)"
        
        tweetTextView.delegate = self
        if replyTweet != nil {
            tweetTextView.text = "@\(replyTweet!.author!.screenname!) "
        }

        characterCountLabel.text = "\(140-tweetTextView.text.characters.count)"

        tweetButton.layer.cornerRadius = 4
        if tweetTextView.text.characters.count == 0 {
            tweetButton.enabled = false
            tweetButton.alpha = 0.3
        }
        
        tweetTextView.becomeFirstResponder()
    }
    
    
    // UITextViewDelegate method
    func textViewDidChange(textView: UITextView) {
        characterCountLabel.text = "\(140-textView.text.characters.count)"
        if textView.text.characters.count > 0 {
            tweetButton.enabled = true
            tweetButton.alpha = 1
        } else {
            tweetButton.enabled = false
            tweetButton.alpha = 0.3
        }
    }
    
    
    @IBAction func onTweet(sender: AnyObject) {
        var params: Dictionary = ["status" : tweetTextView.text]
        if replyTweet != nil {
            params["in_reply_to_status_id"] = replyTweet!.idString
        }
        TwitterClient.sharedInstance.postTweet(params as NSDictionary, completion: { (tweet: Tweet?, error: NSError?) -> () in
            if tweet != nil {
                self.delegate?.composeTweet(tweet!)
                self.navigationController?.popViewControllerAnimated(true)
            }
        })
    }
    
    
    @IBAction func onCancel(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
