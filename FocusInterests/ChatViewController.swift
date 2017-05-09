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

class ChatViewController: JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var user = [String:String]()
    var messages = [JSQMessage]()
    let messagesRef = Constants.DB.messages
    let messageContentRef = Constants.DB.message_content
    var messageID: String?
    var names = [String:String]()
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // tell JSQMessagesViewController
        // who is the current user
        self.senderId = AuthApi.getFirebaseUid()
        self.senderDisplayName = "USER 1"
        
        self.names = [
            self.senderId: self.senderDisplayName,
            self.user["firebaseUserId"]!: self.user["username"]!
        ]
        
        getMessageID()
        
        self.navigationItem.title = self.user["username"]!
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.messagesRef.removeAllObservers()
        self.messageContentRef.removeAllObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        
        let endDate = self.messages[0].date.timeIntervalSince1970
        let roundedEndDate = round(self.messages[0].date.timeIntervalSince1970)
        var earlierMessage = [JSQMessage]()
        
        messageContentRef.child(self.messageID!).queryEnding(atValue: roundedEndDate).queryOrdered(byChild: "date").queryLimited(toLast: 2).observeSingleEvent(of: .value, with: {(snapshot) in
            let messages = snapshot.value as? [String:[String:Any]]
            
            
            for (_,message_data) in messages!{
                let id = message_data["sender_id"] as! String
                let name = self.names[(message_data["sender_id"]! as! String)]
                let date = Date(timeIntervalSince1970: TimeInterval(message_data["date"] as! Double))
                let text = message_data["text"] as! String
                
                let message = JSQMessage(senderId: id, senderDisplayName: name, date: date, text: text)
                
                if date.timeIntervalSince1970 < endDate{
                    earlierMessage.append(message!)
                }
            }
            if earlierMessage.count == 0{
                self.showLoadEarlierMessagesHeader = false
            }
            
            self.messages = earlierMessage + self.messages
            
            self.collectionView.reloadData()
            }
        )
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
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        
        let alertController = UIAlertController(title: "Add media", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "Add image from gallery", style: .default) { action in
            self.addImage()
        }
        alertController.addAction(OKAction)
        
        self.present(alertController, animated: true)

    }
    
    func addImage(){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.dismiss(animated: true, completion: { () -> Void in

        })

        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
        let image = JSQPhotoMediaItem(image: chosenImage)
        let message = JSQMessage(senderId: self.senderId, senderDisplayName: self.senderDisplayName, date: Date(), media: image)
        
        self.messages.append(message!)
        self.collectionView.reloadData()
        self.scrollToBottom(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("cancelled")
    }
    
    func getMessages(){
        messageContentRef.child(self.messageID!).queryOrdered(byChild: "date").queryLimited(toLast: 2).observe(.childAdded, with: {(snapshot) in
            let message_data = snapshot.value as? [String:Any]
        
            let id = message_data?["sender_id"] as! String
            let name = self.names[(message_data?["sender_id"]! as! String)]
            let date = Date(timeIntervalSince1970: TimeInterval(message_data?["date"] as! Double))
            let text = message_data?["text"] as! String
            
            let message = JSQMessage(senderId: id, senderDisplayName: name, date: date, text: text)
            
            self.messages.append(message!)
            self.collectionView.reloadData()
            self.scrollToBottom(animated: true)
            
            self.showLoadEarlierMessagesHeader = true
            
        })
    }
    
    func continueConversion(_ message: JSQMessage){
        let conversion = self.messageContentRef.child(self.messageID!)
        
        let newMessage = conversion.childByAutoId()
        let messageDictionary: [String: Any] = [
            "sender_id" : AuthApi.getFirebaseUid(),
            "text" : message.text,
            "date": Date().timeIntervalSince1970
            ]
        
        newMessage.setValue(messageDictionary)
    }
    
    func getMessageID(){
        messagesRef.child(self.senderId).child(self.user["firebaseUserId"]!).observeSingleEvent(of: .value, with: { (snapshot) in
            let val = snapshot.value as? [String:String]
            if let ID = val?["messageID"]{
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
                "date": Date().timeIntervalSince1970
            ]]
            
            self.messageID = newMessage.key
            newMessage.setValue(messageDictionary)
            
            self.addMessageID()
        }
        
    }
    
    func addMessageID(){
        let one = self.messagesRef.child(self.senderId).child(user["firebaseUserId"]!)
        let two = self.messagesRef.child(user["firebaseUserId"]!).child(self.senderId)
        
        let content = [
            "messageID": self.messageID
        ]
        one.setValue(content)
        two.setValue(content)
        
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
