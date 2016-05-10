//
//  NewThreadViewController.swift
//  around
//
//  Created by Tom Wieschalla  on 10.05.16.
//  Copyright © 2016 Beuth. All rights reserved.
//

import UIKit

class NewThreadViewController: UIViewController,UITextViewDelegate{

    @IBOutlet weak var createThreadButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var rangeLabel: UILabel!
    @IBOutlet weak var rangeSlider: UISlider!
    @IBOutlet weak var rangeValueLabel: UILabel!
    
    var threadDescription = ""
    
    let DESCRIPTION_PLACEHOLDER = "Ein möglichst kurzer und beschreibender Name hilft bei der Veröffentlichung deines Threads. Eine aussagekräftige Beschreibung erhöht die Nützlichkeit des Threads. Je größer die Reichweite, desto höher ist die Wahrscheinlichkeit, Beiträge zu erhalten."
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set slider value
        let startValue = Int(rangeSlider.value)
        rangeValueLabel.text = "\(startValue)"
        
        // set delegates
        descriptionTextView.delegate = self
        
        initUI()
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
        self.navigationController?.popToRootViewControllerAnimated(true)
    }

    @IBAction func sliderValueChanged(sender: UISlider) {
        let currentValue = Int(sender.value)
        rangeValueLabel.text = "\(currentValue)"
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
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }

}
