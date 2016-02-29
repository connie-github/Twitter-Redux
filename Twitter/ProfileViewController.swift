//
//  ProfileViewController.swift
//  Twitter
//

import UIKit

class ProfileViewController: UIViewController {

    
    @IBOutlet weak var profileBannerImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var tweetCountLabel: UILabel!
    @IBOutlet weak var followerCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Navigation view
        navigationController?.navigationBar.barTintColor = UIColor(red: 85/255, green: 172/255, blue: 238/255, alpha: 1)
        navigationItem.title = user.name!
        
        profileBannerImage.contentMode = UIViewContentMode.ScaleAspectFill
        profileBannerImage.clipsToBounds = true
        profileImage.layer.cornerRadius = 4
        profileImage.clipsToBounds = true

        if user.profileBannerImageURL != nil {
            profileBannerImage.setImageWithURL(user.profileBannerImageURL!)
        }
        if user.profileImageUrl != nil {
            profileImage.setImageWithURL(user.profileImageUrl!)
        }
        nameLabel.text = user.name!
        usernameLabel.text = "@\(user.screenname!)"
        tweetCountLabel.text = "\(user.tweetCount!)"
        followerCountLabel.text = "\(user.followerCount!)"
        followerCountLabel.text = "\(user.followingCount!)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
