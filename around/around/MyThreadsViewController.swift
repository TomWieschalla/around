//
//  MyThreadsViewController.swift
//  around
//
//  Created by Tom Wieschalla  on 02.05.16.
//  Copyright © 2016 Beuth. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Firebase

class MyThreadsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var myThreadsTableView: UITableView!
    
    var threadDictionary : [String:AnyObject] = [:]
    var allThreads = [Thread]()
    
    @IBOutlet weak var newThreadButton: UIButton!
    
    // MARK: - Base
    
    override func viewDidLoad() {
        super.viewDidLoad()

        allThreads = [Thread]()
        let rootRef = FIRDatabase.database().reference()
        let threadsRef = rootRef.child(AppDelegate.USERNAME+"_threads")
        
        threadsRef.observeEventType(.ChildAdded) { (snapshot: FIRDataSnapshot!) in
            
            let title = snapshot.value!["title"] as! String
            let threadDesc = snapshot.value!["description"] as! String
            let range = snapshot.value!["range"] as! Int
            
            let newThread: Thread = Thread(threadID: snapshot.key, title: title, description: threadDesc, range: range)
            self.allThreads.append(newThread)
            self.myThreadsTableView.reloadData()
        }
        
        newThreadButton.layer.cornerRadius = 5
    
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    override func viewWillAppear(animated: Bool) {
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - TableView
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if allThreads.isEmpty {
            return 1
        } else {
            return allThreads.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: nil)
        if allThreads.isEmpty {
            cell.textLabel?.text = "Keine eigenen Threads vorhanden"
            cell.textLabel?.font = UIFont.systemFontOfSize(14.0)
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        } else {
            cell.textLabel?.text = allThreads[indexPath.row].title
            cell.detailTextLabel?.text = allThreads[indexPath.row].threadDescription
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if allThreads.count > 0 {
            let navVC = self.navigationController
            let chatVC = ThreadViewController(thread: allThreads[indexPath.row])
            chatVC.senderId = AppDelegate.SENDER_ID
            chatVC.senderDisplayName = AppDelegate.USERNAME
            chatVC.title = allThreads[indexPath.row].title
            chatVC.thread = allThreads[indexPath.row]
            navVC?.pushViewController(chatVC, animated: true)
        }
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
