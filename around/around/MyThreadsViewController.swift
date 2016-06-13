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
    
    // init Firebase DB reference
    let rootRef = FIRDatabase.database().reference()
    
    @IBOutlet weak var newThreadButton: UIButton!
    
    // MARK: - Base
    
    /**
        This method loads all saved threads from firebase and collects them into an array
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUISettings()

        allThreads = [Thread]()
        let threadsRef = rootRef.child(AppDelegate.USERNAME+"_threads")
        
        threadsRef.observeEventType(.ChildAdded) { (snapshot: FIRDataSnapshot!) in
            
            let title = snapshot.value!["title"] as! String
            let threadDesc = snapshot.value!["description"] as! String
            let range = snapshot.value!["range"] as! Int
            
            let newThread: Thread = Thread(threadID: snapshot.key, title: title, description: threadDesc, range: range)
            self.allThreads.append(newThread)
            self.myThreadsTableView.reloadData()
        }
    }
    /**
        This method reloads the data because of selection marks and initialization
     */
    override func viewWillAppear(animated: Bool) {
        self.myThreadsTableView.reloadData()
    }
    
    /**
        This method is setting all UI Settings up
     */
    private func setUISettings() {
        newThreadButton.layer.cornerRadius = 5
    }
    

    
    // MARK: - TableView
    
    /**
        This method defines how much cells should be shown
     */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if allThreads.isEmpty {
            return 1
        } else {
            return allThreads.count
        }
    }
    
    /**
        This method creates the Thread cells with saved properties or shows an inactive cell
        if no Threads exists
     */
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
    
    /**
        This method navigates to the specific ThreadViewController related to which cell was touched
     */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if allThreads.count > 0 {
            let navVC = self.navigationController
            let chatVC = ThreadViewController(thread: allThreads[indexPath.row])
            chatVC.senderId = AppDelegate.SENDER_ID
            chatVC.senderDisplayName = AppDelegate.USERNAME
            chatVC.title = allThreads[indexPath.row].title
            chatVC.thread = allThreads[indexPath.row]
            chatVC.newStoryboard = self.storyboard
            navVC?.pushViewController(chatVC, animated: true)
        }
    }
    
    /**
        This Method deletes the touched tableviewcell, its corresponding Thread and the firebase data
        reference
     */
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let threadId = allThreads[indexPath.row].threadID
            let threadsRef = rootRef.child(AppDelegate.USERNAME+"_threads")
            threadsRef.child(threadId).removeValue()
            allThreads.removeAtIndex(indexPath.row)
            tableView.reloadData()
        }
    }
}
