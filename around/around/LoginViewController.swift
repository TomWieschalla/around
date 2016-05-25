//
//  LoginViewController.swift
//  around
//
//  Created by Tom Wieschalla  on 25.04.16.
//  Copyright © 2016 Beuth. All rights reserved.
//

import UIKit
import TwitterKit
import Firebase

class LoginViewController: UIViewController {

    var dataBase: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        dataBase = FIRDatabase.database().reference()

        let logInButton = TWTRLogInButton { (session, error) in
            if session  != nil {
                let tabBar = self.storyboard?.instantiateViewControllerWithIdentifier("MainViewController")
                AppDelegate.USERNAME = session!.userName
                self.initThreadDictionary()
                self.presentViewController(tabBar!, animated: true, completion: nil)
            } else {
                NSLog("Login error: %@", error!.localizedDescription);
            }
        }
        
        logInButton.center = self.view.center
        self.view.addSubview(logInButton)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initThreadDictionary() {
        let defaults = NSUserDefaults.standardUserDefaults()
        let threadDictionary : [NSObject:AnyObject] = [:]
        defaults.setValue(threadDictionary, forKey: AppDelegate.USERNAME)
    }

}
