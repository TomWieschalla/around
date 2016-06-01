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

    // Firebase db access
    var dataBaseRef: FIRDatabaseReference!
    
    /**
        This method loads the twitter login button and initializes the database connection
     */
    override func viewDidLoad() {
        super.viewDidLoad()

        let logInButton = TWTRLogInButton { (session, error) in
            if session  != nil {
                // sets the twitter username as a global attribute
                AppDelegate.USERNAME = session!.userName
                self.connectDatabase(session!)
            } else {
                NSLog("Login error: %@", error!.localizedDescription);
            }
        }
        
        // sets UI settings up
        logInButton.center = self.view.center
        self.view.addSubview(logInButton)

    }
    
    /**
        This method initializes the connection to the firebase db with the help of the twitter login
        session

        - session: Twitter login session
     */
    func connectDatabase(session: TWTRSession) {
        dataBaseRef = FIRDatabase.database().reference()
        let credential = FIRTwitterAuthProvider.credentialWithToken(session.authToken, secret: session.authTokenSecret)
        FIRAuth.auth()?.signInWithCredential(credential) {(user,error) in
            if error != nil {
                NSLog("Firebase-Twitter Authentification failed", error!.localizedDescription)
            } else {
                // sets the firebase userid as a global attribute
                AppDelegate.SENDER_ID = (user?.uid)!
                
                // pushes to the main navigation controller (TabBarController)
                let tabBar = self.storyboard?.instantiateViewControllerWithIdentifier("MainTabBarController")
                self.presentViewController(tabBar!, animated: true, completion: nil)
            }
        }
    }

}
