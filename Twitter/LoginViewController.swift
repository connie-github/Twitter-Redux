//
//  LoginViewController.swift
//  Twitter
//

import UIKit


class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func onLogin(sender: AnyObject) {
        TwitterClient.sharedInstance.loginWithCompletion() {
            (user: User?, error: NSError?) in
            if user != nil {
                let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                
                let hamburgerViewController = storyboard.instantiateViewControllerWithIdentifier("HamburgerViewController") as!HamburgerViewController
                
                let menuViewController = storyboard.instantiateViewControllerWithIdentifier("MenuViewController") as! MenuViewController
                
                menuViewController.hamburgerViewController = hamburgerViewController
                hamburgerViewController.menuViewController = menuViewController
                
                self.presentViewController(hamburgerViewController, animated: false, completion: nil)
                // perform segue
                // self.performSegueWithIdentifier("loginSegue", sender: self)
            } else {
                // handle error
                print("login error")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

