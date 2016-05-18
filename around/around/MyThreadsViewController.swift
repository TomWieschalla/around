//
//  MyThreadsViewController.swift
//  around
//
//  Created by Tom Wieschalla  on 02.05.16.
//  Copyright © 2016 Beuth. All rights reserved.
//

import UIKit

class MyThreadsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var myThreadsTableView: UITableView!
    
    var threadDictionary : [String:AnyObject] = [:]
    var allThreads = [Thread]()
    
    @IBOutlet weak var newThreadButton: UIButton!
    
    // MARK: - Base
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: Load user specific threads from backend api
        // myThreads =
        
        newThreadButton.layer.cornerRadius = 5
    
    }
    
    override func viewWillAppear(animated: Bool) {
        let defaults = NSUserDefaults.standardUserDefaults()
        threadDictionary = defaults.dictionaryForKey(AppDelegate.USERNAME)!
        let threads = threadDictionary.values
        for data in threads {
            let thread : Thread = NSKeyedUnarchiver.unarchiveObjectWithData(data as! NSData) as! Thread
            allThreads.append(thread)
        }
        self.myThreadsTableView.reloadData()
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
        let cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: nil)
        if allThreads.isEmpty {
            cell.textLabel?.text = "Keine eigenen Threads vorhanden"
            cell.textLabel?.font = UIFont.systemFontOfSize(14.0)
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        } else {
            cell.textLabel?.text = allThreads[indexPath.row].title
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //TODO
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
