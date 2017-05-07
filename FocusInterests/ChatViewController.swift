//
//  ChatViewController.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/6/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import FirebaseDatabase

class ChatViewController: JSQMessagesViewController {
    var user = [String:String]()
    var messages = [JSQMessage]()
    let messagesRef = Constants.DB.messages
    let messageContentRef = Constants.DB.message_content
    var messageID: String?
    var names = [String:String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // tell JSQMessagesViewController
        // who is the current user
        self.senderId = AuthApi.getFirebaseUid()
        self.senderDisplayName = "Dummy Name"
        
        self.names = [
            self.senderId: self.senderDisplayName,
            self.user["firebaseUserId"]!: self.user["username"]!
        ]
        self.inputToolbar.contentView.leftBarButtonItem = nil;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getMessageID()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        print("load earlier")
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let message = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text)
        
        if messages.count == 0{
            self.startConversion(message!)
        }
        else{
            self.continueConversion(message!)
        }
        messages.append(message!)
        
        finishSendingMessage()
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.row]
        let messageUsername = message.senderDisplayName
        
        return NSAttributedString(string: messageUsername!)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return 35
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        return 30
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return JSQMessagesAvatarImage(avatarImage: UIImage(named:"tinyB"), highlightedImage: nil, placeholderImage: UIImage(named:"tinyB"))
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        
        let message = messages[indexPath.row]
        
        if self.senderId == message.senderId {
            return bubbleFactory?.outgoingMessagesBubbleImage(with: .green)
        } else {
            return bubbleFactory?.incomingMessagesBubbleImage(with: .blue)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {

        return NSAttributedString(string: "asdasda")
    }
    
    func getMessages(){
        var messages_list = [JSQMessage]()
        
        messageContentRef.child(self.messageID!).queryOrdered(byChild: "date").queryLimited(toLast: 2).observe(.childAdded, with: {(snapshot) in
            let message_data = snapshot.value as? [String:String]
            
            
            let message = JSQMessage(senderId: message_data?["sender_id"], displayName: self.names[(message_data?["sender_id"]!)!], text: message_data?["text"])
            self.messages.append(message!)
            
            
            self.collectionView.reloadData()

        })
    }
    
    func continueConversion(_ message: JSQMessage){
        let conversion = self.messageContentRef.child(self.messageID!)
        
        let newMessage = conversion.childByAutoId()
        let messageDictionary = [
            "sender_id" : AuthApi.getFirebaseUid(),
            "text" : message.text,
            ]
        
        newMessage.setValue(messageDictionary)
    }
    
    func getMessageID(){
        messagesRef.child(self.senderId).child(self.user["firebaseUserId"]!).observeSingleEvent(of: .value, with: { (snapshot) in
            let val = snapshot.value as! [String:String]
            if let ID = val["messageID"]{
                self.messageID = ID
                self.getMessages()
            }
            else{
                self.messageID = nil
            }
            
            
        })
    }
    
    func startConversion(_ message: JSQMessage){
        if self.messageID == nil{
            
            let newMessage = messageContentRef.childByAutoId()
            let messageDictionary = [[
                "sender_id" : AuthApi.getFirebaseUid(),
                "text" : message.text,
                "date": Date()
            ]]
            
            self.messageID = newMessage.key
            newMessage.setValue(messageDictionary)
            
            self.addMessageID()
        }
        
    }
    
    func addMessageID(){
        let one = self.messagesRef.child(self.senderId).child(user["firebaseUserId"]!)
        let two = self.messagesRef.child(user["firebaseUserId"]!).child(self.senderId)
        one.setValue(["messageID": self.messageID])
        two.setValue(["messageID": self.messageID])
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
