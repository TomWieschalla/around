//
//  InfoThreadViewController.swift
//  around
//
//  Created by Tom Wieschalla  on 13.06.16.
//  Copyright © 2016 Beuth. All rights reserved.
//

import UIKit

class InfoThreadViewController: UIViewController {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var descriptionField: UITextView!
    @IBOutlet weak var rangeField: UITextField!
    
    var threadName = ""
    var threadDescription = ""
    var threadRange = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameField.text = threadName
        descriptionField.text = threadDescription
        rangeField.text = threadRange
    }
}
