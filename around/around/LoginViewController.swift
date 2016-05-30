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

    var dataBaseRef: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let logInButton = TWTRLogInButton { (session, error) in
            if session  != nil {
                AppDelegate.USERNAME = session!.userName
                self.initThreadDictionary()
                self.connectDatabase(session!)
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
    
    func connectDatabase(session: TWTRSession) {
        dataBaseRef = FIRDatabase.database().reference()
        let credential = FIRTwitterAuthProvider.credentialWithToken(session.authToken, secret: session.authTokenSecret)
        FIRAuth.auth()?.signInWithCredential(credential) {(user,error) in
            if error != nil {
                NSLog("Firebase-Twitter Authentification failed", error!.localizedDescription)
            } else {
                AppDelegate.SENDER_ID = (user?.uid)!
                let tabBar = self.storyboard?.instantiateViewControllerWithIdentifier("MainViewController")
                self.presentViewController(tabBar!, animated: true, completion: nil)
            }
        }
    }

}
