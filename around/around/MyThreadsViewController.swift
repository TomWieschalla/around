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
    
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var slideLabel: UILabel!
    var myThreads = [String]()
    
    // MARK: - Base
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: Load user specific threads from backend api
        // myThreads =
        
        loadSlideButton()
        loadSlideButtonAnimation()
    }
    
    override func viewDidAppear(animated: Bool) {
        //loadSlideButtonAnimation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Button and Animation
    
    func loadSlideButton() {
        let swipeButtonLeft = UISwipeGestureRecognizer(target: self, action: #selector(MyThreadsViewController.buttonLeft))
        swipeButtonLeft.direction = UISwipeGestureRecognizerDirection.Left
        
        let swipeView = UIView()
        swipeView.frame = CGRectMake(slideLabel.frame.origin.x, slideLabel.frame.origin.y, slideLabel.frame.size.width+addButton.frame.size.width, slideLabel.frame.size.height)
        
        swipeView.addGestureRecognizer(swipeButtonLeft)
        self.view.addSubview(swipeView)
    }
    
    
    func loadSlideButtonAnimation() {
        
        let textWidth : CGFloat = slideLabel!.frame.width
        let textHeight : CGFloat = slideLabel!.frame.height
        
        UIGraphicsBeginImageContext(slideLabel.bounds.size)
        slideLabel.layer .renderInContext(UIGraphicsGetCurrentContext()!)
        let swipeImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        slideLabel.hidden = true
        
        let textLayer = CALayer()
        textLayer.contents = swipeImage.CGImage
        textLayer.frame = CGRectMake(slideLabel.frame.origin.x, slideLabel.frame.origin.y, textWidth, textHeight)
        
        let maskLayer = CALayer()
        maskLayer.backgroundColor = UIColor(colorLiteralRed: 0.0, green: 0.0, blue: 0.0, alpha: 0.0).CGColor
        maskLayer.contents = UIImage(named: "Mask.png")?.CGImage
        maskLayer.contentsGravity = kCAGravityCenter
        maskLayer.frame = CGRectMake(-textWidth, 0.0, textWidth*2, textHeight)
        
        let maskAnimation = CABasicAnimation(keyPath: "position.x")
        maskAnimation.fromValue = NSNumber(float: Float(textWidth))
        maskAnimation.toValue = NSNumber(float: Float(textLayer.frame.origin.x-75))
        maskAnimation.repeatCount = Float.infinity
        maskAnimation.duration = 1.0
        maskAnimation.removedOnCompletion = false
        
        maskLayer .addAnimation(maskAnimation, forKey: "slideAnim")
        
        textLayer.mask = maskLayer
        self.view.layer.addSublayer(textLayer)
        
    }
    
    func buttonLeft() {
        let addThreadController = self.storyboard?.instantiateViewControllerWithIdentifier("addThreadView")
        self.navigationController!.pushViewController(addThreadController!, animated: true)
    }
    
    // MARK: - TableView
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if myThreads.isEmpty {
            return 1
        } else {
            return myThreads.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: nil)
        if myThreads.isEmpty {
            cell.textLabel?.text = "Keine eigenen Threads vorhanden"
            cell.textLabel?.font = UIFont.systemFontOfSize(14.0)
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        } else {
            cell.textLabel?.text = myThreads[indexPath.row]
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
