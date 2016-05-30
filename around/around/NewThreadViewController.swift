//
//  NewThreadViewController.swift
//  around
//
//  Created by Tom Wieschalla  on 10.05.16.
//  Copyright © 2016 Beuth. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

class NewThreadViewController: UIViewController,UITextViewDelegate,UITextFieldDelegate{

    @IBOutlet weak var createThreadButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var rangeLabel: UILabel!
    @IBOutlet weak var rangeSlider: UISlider!
    @IBOutlet weak var rangeValueLabel: UILabel!
    
    var threadName = ""
    var threadDescription = ""
    var range: Int = 50
    let defaults = NSUserDefaults.standardUserDefaults()
    var threadDictionary : [String:AnyObject] = [:]
    let rootRef = FIRDatabase.database().reference()
    
    let DESCRIPTION_PLACEHOLDER = "Ein möglichst kurzer und beschreibender Name hilft bei der Veröffentlichung deines Threads. Eine aussagekräftige Beschreibung erhöht die Nützlichkeit des Threads. Je größer die Reichweite, desto höher ist die Wahrscheinlichkeit, Beiträge zu erhalten."
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set slider value
        let startValue = Int(rangeSlider.value)
        rangeValueLabel.text = "\(startValue)"
        
        // set delegates
        descriptionTextView.delegate = self
        nameTextField.delegate = self
        
        // get threads
        threadDictionary = defaults.dictionaryForKey(AppDelegate.USERNAME)!
        
        initUI()
    }
    
    override func viewWillDisappear(animated: Bool) {
        defaults.setValue(threadDictionary, forKey: AppDelegate.USERNAME)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UI
    
    func initUI() {
        self.title = "Neu"
        createLineViews()
        createThreadButton.layer.cornerRadius = 5
        descriptionTextView.textColor = UIColor.lightGrayColor()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    
    func createLineViews() {
        let labelArray :[UILabel] = [nameLabel,descriptionLabel,rangeLabel]
        for label in labelArray {
            let position : CGPoint = label.frame.origin
            let width = label.frame.size.width
            let height = label.frame.size.height
            let lineView : UIView = UIView()
            lineView.frame = CGRectMake(position.x, position.y+height, width, 1)
            lineView.backgroundColor = UIColor.grayColor()
            lineView.alpha = 0.8
            self.view.addSubview(lineView)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func createThreadButtonClicked(sender: AnyObject) {
        if threadName == "" {
            let alert : UIAlertController = UIAlertController(title: "Achtung", message: "Bitte einen Namen für deinen Thread wählen", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else if threadDescription == "" {
            let alert : UIAlertController = UIAlertController(title: "Achtung", message: "Bitte eine Beschreibung für deinen Thread wählen", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            // save Thread
            let threadsRef = rootRef.child(AppDelegate.USERNAME+"_threads")
            let threadRef = threadsRef.childByAutoId()
            let threadItem = [
            "title": threadName,
            "description": threadDescription,
            "range": range
            ]
            threadRef.setValue(threadItem)
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
    }

    @IBAction func sliderValueChanged(sender: UISlider) {
        range = Int(sender.value)
        rangeValueLabel.text = "\(range)"
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if descriptionTextView.textColor == UIColor.lightGrayColor() {
            descriptionTextView.text = ""
            descriptionTextView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        threadDescription = textView.text
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if threadDescription.isEmpty {
            descriptionTextView.text = DESCRIPTION_PLACEHOLDER
            descriptionTextView.textColor = UIColor.lightGrayColor()
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.text!.isEmpty {
            threadName = ""
        } else {
            threadName = textField.text!
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }

}
