//
//  TweetsViewController.swift
//  Twitter
//

import UIKit


enum TweetsControllerType {
    case Home
    case Mentions
}

class TweetsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TweetCellDelegate, TweetDetailViewControllerDelegate, ComposeViewControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl: UIRefreshControl!
    var tweets: [Tweet]!
    var replyTweet: Tweet?
    var targetUser: User?
    var controllerType: TweetsControllerType?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        // Pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        // Navigation view
        navigationController?.navigationBar.barTintColor = UIColor(red: 85/255, green: 172/255, blue: 238/255, alpha: 1)
        navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
        navigationItem.rightBarButtonItem?.tintColor = UIColor.whiteColor()
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        imageView.contentMode = .ScaleAspectFit
        imageView.image = UIImage(named: "twitter_logo_white.png")
        navigationItem.titleView = imageView
        
        fetchTweets()
    }
    
    func fetchTweets() {
        switch controllerType! {
        case .Home:
            TwitterClient.sharedInstance.homeTimelineWithParams(nil) { (tweets, error) -> () in
                self.tweets = tweets
                self.tableView.reloadData()
            }
        case .Mentions:
            TwitterClient.sharedInstance.mentionsTimelineWithParams(nil) { (tweets, error) -> () in
                self.tweets = tweets
                self.tableView.reloadData()
            }
        }
    }

    func refreshControlAction(refreshControl: UIRefreshControl) {
        fetchTweets()
        refreshControl.endRefreshing()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tweets != nil {
            return tweets!.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TweetCell", forIndexPath: indexPath) as! TweetCell
        cell.tweet = tweets[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    // Unselect cell
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // TweetCellDelegate methods
    func updateTweetCell(tweet: Tweet, cell: TweetCell) {
        let indexPath = tableView.indexPathForCell(cell)!
        tweets[indexPath.row] = tweet
    }
    
    func callComposeSegueFromTweetCell(tweet: Tweet) {
        replyTweet = tweet
        self.performSegueWithIdentifier("composeTweetSegue", sender: self)
    }
    
    func callProfileSegueFromTweetCell(user: User) {
        targetUser = user
        self.performSegueWithIdentifier("profileSegue", sender: self)
    }
    
    // TweetDetailViewControllerDelegate methods
    func updateTweetDetailView(tweet: Tweet, index: Int) {
        tweets[index] = tweet
        tableView.reloadData()
    }
    
    func callComposeSegueFromTweetDetailView(tweet: Tweet) {
        replyTweet = tweet
        self.performSegueWithIdentifier("composeTweetSegue", sender: self)
    }
    
    func callProfileSegueFromTweetDetailView(user: User) {
        targetUser = user
        self.performSegueWithIdentifier("profileSegue", sender: self)
    }
    
    // ComposeViewControllerDelegate methods
    func composeTweet(tweet: Tweet) {
        tweets.insert(tweet, atIndex: 0)
        tableView.reloadData()
    }
    

    @IBAction func onLogout(sender: AnyObject) {
        User.currentUser?.logout()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    
        if segue.identifier == "composeTweetSegue" {
            let destinationViewController = segue.destinationViewController as! ComposeViewController
            if replyTweet != nil {
                destinationViewController.replyTweet = replyTweet
                replyTweet = nil
            }
            destinationViewController.delegate = self
        } else if segue.identifier == "tweetDetailSegue" {
            let destinationViewController = segue.destinationViewController as! TweetDetailViewController
            let indexPath = tableView.indexPathForCell(sender as! UITableViewCell)!
            destinationViewController.tweet = tweets[indexPath.row]
            destinationViewController.delegate = self
        } else if segue.identifier == "profileSegue" {
            let destinationVC = segue.destinationViewController as! ProfileViewController
            if targetUser != nil {
                destinationVC.user = targetUser
            }
        }
    }
    
}
