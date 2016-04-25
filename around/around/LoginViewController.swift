//
//  LoginViewController.swift
//  around
//
//  Created by Tom Wieschalla  on 25.04.16.
//  Copyright © 2016 Beuth. All rights reserved.
//

import UIKit
import TwitterKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let logInButton = TWTRLogInButton { (session, error) in
            if session  != nil {
                let tabBar = self.storyboard?.instantiateViewControllerWithIdentifier("MainViewController")
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
