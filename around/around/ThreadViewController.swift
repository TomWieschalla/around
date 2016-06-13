//
//  ThreadViewController.swift
//  around
//
//  Created by Tom Wieschalla  on 25.05.16.
//  Copyright © 2016 Beuth. All rights reserved.
//

import UIKit
import Firebase
import JSQMessagesViewController

class ThreadViewController: JSQMessagesViewController {

    // MARK: Properties
    
    // Storyboard
    var newStoryboard: UIStoryboard?
    
    // Chat-Thread
    var thread: Thread
    
    // Messages-Array
    var messages = [JSQMessage]()
    
    // Outgoing and Incoming Chatmessagebubble
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    
    // Firebase db access
    let rootRef = FIRDatabase.database().reference()
    
    // specific db reference
    var messageRef: FIRDatabaseReference!
    var userIsTypingRef: FIRDatabaseReference!
    
    // attributes for typing recognition
    private var localTyping = false
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
    }
    
    /**
        This method initializes the ViewController
     
        - thread: ChatThread
     */
    init(thread: Thread) {
        self.thread = thread
        super.init(nibName: nil, bundle: nil)
    }
    
    /**
        required init function
     */
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
        This method sets the ui settings up and initializes the message reference
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUISettings()
        messageRef = rootRef.child("Chat"+thread.threadID)
        
        let infoButton = UIButton(type: UIButtonType.InfoLight)
        infoButton.addTarget(self, action: #selector(showInfo), forControlEvents: UIControlEvents.TouchUpInside)
        let barItem = UIBarButtonItem(customView: infoButton)
        self.navigationItem.setRightBarButtonItem(barItem, animated: true)
        
        self.observeMessages()
        self.observeTyping()
    }
    
    /**
        This method initializes the chat and typing observation
     */
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //self.observeMessages()
        //self.observeTyping()
    }
    
    @objc private func showInfo() {
        let infoVC = newStoryboard!.instantiateViewControllerWithIdentifier("infoThreadViewController") as! InfoThreadViewController
        infoVC.threadName = thread.title
        infoVC.threadDescription = thread.threadDescription
        infoVC.threadRange = String(thread.range)
        self.navigationController?.pushViewController(infoVC, animated: true)
    }
    
    /**
        This method sets ui settings up
     */
    private func setUpUISettings() {
        self.setupBubbles()
        
        // deactivates avatar views
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
    }
    
    /**
        This method sets the chat messages bubble color up
     */
    private func setupBubbles() {
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = factory.outgoingMessagesBubbleImageWithColor(
            UIColor.jsq_messageBubbleBlueColor())
        incomingBubbleImageView = factory.incomingMessagesBubbleImageWithColor(
            UIColor.jsq_messageBubbleLightGrayColor())
    }
    
    /**
        This method initializes the observation of incoming messages
     */
    private func observeMessages() {

        // only shows the last 25 messages
        let messagesQuery = messageRef.queryLimitedToLast(25)

        // reacts if a new message comes into the database
        messagesQuery.observeEventType(.ChildAdded) { (snapshot: FIRDataSnapshot!) in

            // gets the attributes from the snapshot(JSON Object from db)
            let id = snapshot.value!["senderId"] as! String
            let text = snapshot.value!["text"] as! String

            // adds the incoming message to the view
            self.addMessage(id, text: text)
            
            self.finishReceivingMessage()
        }
    }
    
    /**
        This method observes if some user is typing
     */
    private func observeTyping() {
        // creates a firebase db reference
        let typingIndicatorRef = rootRef.child("typingIndicator")
        userIsTypingRef = typingIndicatorRef.child(self.senderId)
        
        // delete reference when user escapes
        userIsTypingRef.onDisconnectRemoveValue()
    }
    
    /**
        This method adds messages to the ThreadViewController and messages Array
     
        - id: senderId/UserId
        - String: text
     */
    func addMessage(id: String, text: String) {
        let message = JSQMessage(senderId: id, displayName: self.senderDisplayName, text: text)
        messages.append(message)
    }
    
    // MARK: - Data Source Methods
    
    /**
        This method returns messages related to chronicle order
     */
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }
    
    /**
        This method returns the number of messages (max 25)
     */
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    /**
        This method returns the correct bubble depending on who sent the message
     */
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.row]
        if message.senderId == senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.row]
        
        if message.senderId == self.senderId {
            cell.textView!.textColor = UIColor.whiteColor()
        } else {
            cell.textView!.textColor = UIColor.blackColor()
        }
        
        return cell
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        let itemRef = messageRef.childByAutoId()
        let messageItem = [
        "text": text,
        "senderId":senderId
        ]
        itemRef.setValue(messageItem)
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        finishSendingMessage()
        isTyping = false
    }
    
    override func textViewDidChange(textView: UITextView) {
        super.textViewDidChange(textView)
        isTyping = textView.text != ""
    }

}
