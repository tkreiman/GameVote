//
//  ChatViewController.swift
//  Game Vote
//
//  Created by Tobias Kreiman on 4/27/16.
//  Copyright © 2016 Tobias Kreiman. All rights reserved.
//

import UIKit
import Parse
import JSQMessagesViewController


class ChatViewController: JSQMessagesViewController {
    
    var fromGame: String?
    var messages = [JSQMessage]()
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    var timer = NSTimer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.setupBubbles()
        
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        
        
        self.senderId = "tester"
        if self.senderDisplayName == "" {
            self.senderDisplayName = " "
        }
        
        
        
        timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "getMessages", userInfo: nil, repeats: true)
    
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    override func viewDidDisappear(animated: Bool) {
        timer.invalidate()
    }
    
    func getMessages() {
        guard Connection.isConnectedToInternet() == true else {
            print("not connected")
            self.timer.invalidate()
            self.performSegueWithIdentifier("showErrorFromChat", sender: self)
            
            return
        }
        
        let query = PFQuery(className: "Message")
        query.whereKey("fromGame", equalTo: self.fromGame!)
        query.limit = 50
        query.findObjectsInBackgroundWithBlock { (result, error) in
            
            if error == nil {
                if let returnedMessages = result {
                    self.messages = []
                    
                    for message in returnedMessages {
                        
                        self.addMessage(message["text"] as! String, displayName: message["sender"] as! String)
                        
                    }
                    
                    
                }
            }
        }
        
    }
    
    func addMessage(text: String, displayName: String) {
        
        let message = JSQMessage(senderId: "test", displayName: displayName, text: text)
        messages.append(message)
        
        
        finishReceivingMessage()
        
    }
    
    
    
    func setupBubbles() {
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = factory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
        incomingBubbleImageView = factory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    }
    
    func dismissChatView() {
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    
    
    
    // MARK: - JSQMessageView setup
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.item]
        return NSAttributedString(string: message.senderDisplayName)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        cell.textView?.textColor = UIColor.blackColor()
        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 15
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        if senderId == "tester" {
            return incomingBubbleImageView
        }
        return incomingBubbleImageView
        
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        guard Connection.isConnectedToInternet() == true else {
            self.timer.invalidate()
            print("not connected")
            self.performSegueWithIdentifier("showErrorFromChat", sender: self)
            
            return
        }
        
        addMessage(text, displayName: self.senderDisplayName)
        
        let newMessage = PFObject(className: "Message")
        newMessage["text"] = text
        newMessage["sender"] = senderDisplayName
        newMessage["fromGame"] = self.fromGame
        newMessage.saveInBackground()
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
    }
    
    
    
}
