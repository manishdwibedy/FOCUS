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
import FirebaseStorage
import SDWebImage
import Agrume
import SVPullToRefresh

class ChatViewController: JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    enum source{
        case camera
        case gallery
    }
    
    var user = [String:Any]()
    var messages = [JSQMessage]()
    let messagesRef = Constants.DB.messages
    let messageContentRef = Constants.DB.message_content
    var messageID: String?
    var names = [String:String]()
    var imagePicker = UIImagePickerController()
    var imageMapper = [String:Int]()
    var gotImages = false
    var loadingMessages = false
    var addPin = false
    var pinMessage: String? = nil
    var pinImage: UIImage? = nil
    var delay = [String: Int]()
    var senderImage: UIImage? = nil
    var otherUserImage: UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.senderId = AuthApi.getFirebaseUid()
        self.senderDisplayName = ""
        
        self.names = [
            self.senderId: self.senderDisplayName,
            self.user["firebaseUserId"]! as! String: self.user["username"]! as! String
        ]
        
        FirebaseDownstream.shared.getCurrentUser {[unowned self] (dictionnary) in
            if dictionnary != nil {
                // SET PROFILE PHOTO
                let senderImageURL = dictionnary!["image_string"] as! String

                if let url = URL(string: senderImageURL){
                    SDWebImageManager.shared().downloadImage(with: url, options: .continueInBackground, progress: {
                        (receivedSize :Int, ExpectedSize :Int) in
                        
                    }, completed: {
                        (image : UIImage?, error : Error?, cacheType : SDImageCacheType, finished : Bool, url : URL?) in
                        
                        if image != nil && finished{
                            self.senderImage = image
                            self.collectionView.reloadData()
                        }
                    })
                }
            }
        }
        
        Constants.DB.user.child((user["firebaseUserId"] as? String)!).observeSingleEvent(of: .value, with: {snapshot in
            let data = snapshot.value as? [String:Any]
            let otherUserImageURL = data!["image_string"] as! String
            
            if let url = URL(string: otherUserImageURL){
                SDWebImageManager.shared().downloadImage(with: url, options: .continueInBackground, progress: {
                    (receivedSize :Int, ExpectedSize :Int) in
                    
                }, completed: {
                    (image : UIImage?, error : Error?, cacheType : SDImageCacheType, finished : Bool, url : URL?) in
                    
                    if image != nil && finished{
                        self.otherUserImage = image
                        self.collectionView.reloadData()
                    }
                })
            }
            //self.collectionView.reloadData()
            
        })
        
        self.collectionView.backgroundColor = Constants.color.navy
        
        self.inputToolbar.contentView.textView.backgroundColor = UIColor.clear
        self.inputToolbar.contentView.textView.textColor = UIColor.white
        self.inputToolbar.contentView.textView.roundCorners(radius: 5)
        
        self.inputToolbar.contentView.backgroundColor = Constants.color.navy
        
        self.inputToolbar.contentView.textView.placeHolderTextColor = UIColor.white
        self.inputToolbar.contentView.textView.placeHolder = "Enter the message"
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        markUnread()
        getMessageID()
        
        
        var backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "BackArrow"), style: .plain, target: self, action: #selector(back))

        self.navigationItem.leftBarButtonItem = backButton

        self.collectionView.bounces = false
        loadingMessages = false
        
        let attrs = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "Avenir-Black", size: 18)!
        ]
        
        self.navigationController?.navigationBar.titleTextAttributes = attrs
        self.navigationController?.navigationBar.barTintColor = Constants.color.navy
        
        self.navigationItem.title = self.user["username"]! as? String
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: .UIKeyboardWillHide, object: nil)
    }
    
    func back(sender: UIBarButtonItem) {
        // Perform your custom actions
        // ...
        // Go back to the previous ViewController
        self.navigationController?.popViewController(animated: true)
    }
    
    func keyboardWillAppear(notification: NSNotification){
        Constants.DB.user.child("\(self.senderId!)/typing").setValue(true)
    }
    
    func keyboardWillDisappear(notification: NSNotification){
        Constants.DB.user.child("\(self.senderId!)/typing").setValue(false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.messagesRef.removeAllObservers()
        self.messageContentRef.removeAllObservers()
        NotificationCenter.default.removeObserver(self)
        Constants.DB.user.child("\(self.senderId!)/typing").setValue(false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Constants.DB.user.child(self.user["firebaseUserId"]! as! String).child("typing").observe(.value, with: {(snapshot) in
            if let typing = snapshot.value as? Bool{
                self.showTypingIndicator = typing
            }
            
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadMore() {
        let endDate = self.messages[0].date.timeIntervalSince1970
        let roundedEndDate = round(self.messages[0].date.timeIntervalSince1970)
        var earlierMessage = [JSQMessage]()
        var earlierId = [String]()
        
        //collectionView.collectionViewLayout.springinessEnabled = false
        //collectionView.infiniteScrollingView.startAnimating()
        
        messageContentRef.child(self.messageID!).queryEnding(atValue: roundedEndDate).queryOrdered(byChild: "date").queryLimited(toLast: 25).observeSingleEvent(of: .value, with: {(snapshot) in
            
            let messages = snapshot.value as? [String:[String:Any]]
            
            print(messages)
            if let messages = messages{
                for (messageID,message_data) in messages{
                    let id = message_data["sender_id"] as! String
                    let name = self.names[(message_data["sender_id"]! as! String)]
                    let date = Date(timeIntervalSince1970: TimeInterval(message_data["date"] as! Double))
                    
                    var message: JSQMessage?
                    if let text = message_data["text"] as? String{
                        message = JSQMessage(senderId: id, senderDisplayName: name, date: date, text: text)
                        
                    }
                    else{
                        let image = JSQPhotoMediaItem(image: UIImage(named: "empty_event"))
                        message = JSQMessage(senderId: id, senderDisplayName: name, date: date, media: image)
                        let imageRef = Constants.storage.messages.child("\(messageID).jpg")
                        
                        imageRef.downloadURL(completion: {(url, error) in
                            if let error = error{
                                print("Error occurred: \(error.localizedDescription)")
                            }
                            
                            SDWebImageManager.shared().downloadImage(with: url, options: .continueInBackground, progress: {
                                (receivedSize :Int, ExpectedSize :Int) in
                                
                            }, completed: {
                                (image : UIImage?, error : Error?, cacheType : SDImageCacheType, finished : Bool, url : URL?) in
                                
                                if image != nil && finished{
                                    let JSQimage = JSQPhotoMediaItem(image: image)
                                    let message = JSQMessage(senderId: id, senderDisplayName: name, date: date, media: JSQimage)
                                    
                                    let index = self.imageMapper[messageID]
                                    self.messages[index!] = message!
                                    self.collectionView.reloadData()
                                    
                                }
                            })
                        })
                    }
                    
                    if date.timeIntervalSince1970 < endDate{
                        earlierMessage.append(message!)
                        earlierId.append(messageID)
                    }
                }
            }
            
            if earlierMessage.count == 0{
                self.showLoadEarlierMessagesHeader = false
            }
            
            var earlierMapper = [String:Int]()
            for (index, message) in earlierMessage.enumerated(){
                earlierMapper[earlierId[index]] = index
            }
            for (key, index) in self.imageMapper{
                self.imageMapper[key] = index + earlierMessage.count
            }
            self.imageMapper.update(other: earlierMapper)
            self.messages = earlierMessage + self.messages
            
            //scroll back to current position
            //self.finishReceivingMessage(animated: false)
            self.collectionView.layoutIfNeeded()
            
            print("reloading")
            self.loadingMessages = false
            self.automaticallyScrollsToMostRecentMessage = false

            self.collectionView.reloadData()
        })
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let message = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text)
        
        if messages.count == 0{
            self.startConversion(message!)
        }
        else{
            self.continueConversion(message!)
        }
        self.collectionView.reloadData()
        updateDateRead()
        finishSendingMessage()
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.row]
        
        if indexPath.row == 0 && !loadingMessages{
            loadingMessages = true
        }
        else if indexPath.row == 0 && loadingMessages{
            loadMore()
        }
        
        
        if message.isMediaMessage{
            print("id is \(message.senderId) ")
            
            
        }
        
        
        if self.senderId == message.senderId {
            cell.messageBubbleTopLabel.textInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 45)
            cell.cellBottomLabel.textInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 45)
            
            cell.avatarImageView.roundedImage()
        } else {
            cell.messageBubbleTopLabel.textInsets = UIEdgeInsets(top: 0, left: 45, bottom: 0, right: 0)
            cell.cellBottomLabel.textInsets = UIEdgeInsets(top: 0, left: 45, bottom: 0, right: 0)
            cell.avatarImageView.roundedImage()
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.row]
        let messageUsername = message.senderDisplayName
        
        return NSAttributedString(string: messageUsername!)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return 25
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        return 30
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        let message = messages[indexPath.row]
        
        if self.senderId == message.senderId && self.senderImage != nil{
            return JSQMessagesAvatarImage(avatarImage: self.senderImage, highlightedImage: nil, placeholderImage: UIImage(named:"tinyB"))
        }
        else if self.senderId != message.senderId && self.otherUserImage != nil {
            return JSQMessagesAvatarImage(avatarImage: self.otherUserImage, highlightedImage: nil, placeholderImage: UIImage(named:"tinyB"))
        }

        return JSQMessagesAvatarImage(avatarImage: UIImage(named:"tinyB"), highlightedImage: nil, placeholderImage: UIImage(named:"tinyB"))
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let message = messages[indexPath.row]
        
        if self.senderId == message.senderId {
            return JSQMessagesBubbleImageFactory(bubble: UIImage.jsq_bubbleRegularStrokedTailless(), capInsets: .zero).outgoingMessagesBubbleImage(with: UIColor.white)
        } else {
            return JSQMessagesBubbleImageFactory(bubble: UIImage.jsq_bubbleRegularStrokedTailless(), capInsets: .zero).incomingMessagesBubbleImage(with: UIColor.white)
        }

    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        
        let message = messages[indexPath.row]
        let date = message.date

        let formatter = DateFormatter()

        return NSAttributedString(string: formatter.timeSince(from: date!, numericDates: false))
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        
        let alertController = UIAlertController(title: "Add media", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let galleryAction = UIAlertAction(title: "Add image from gallery", style: .default) { action in
            self.showImagePicker(source: source.gallery)
        }
        let cameraAction = UIAlertAction(title: "Add image from camera", style: .default) { action in
            self.showImagePicker(source: source.camera)
        }
        alertController.addAction(galleryAction)
        alertController.addAction(cameraAction)
        
        self.present(alertController, animated: true)

    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        let message = self.messages[indexPath.row]
        
        if message.isMediaMessage{
            let media = message.media
            
            if (media?.isKind(of: JSQPhotoMediaItem.self))!{
                let imageMedia = media as! JSQPhotoMediaItem
                
                let agrume = Agrume(image: imageMedia.image, backgroundBlurStyle: UIBlurEffectStyle.dark, backgroundColor: .black)
                agrume.statusBarStyle = .lightContent
                agrume.showFrom(self)
            }
        }
        self.view.endEditing(true)
    }
    
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidBeginEditing(textView)
        let len = textView.text.characters.count
        
        if len == 0{
            self.inputToolbar?.contentView?.rightBarButtonItem?.isEnabled = false
        }
        else{
            self.inputToolbar?.contentView?.rightBarButtonItem?.isEnabled = true
        }
    }
    
    func showImagePicker(source: source){
        
        switch source{
        case .gallery:
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary
                imagePicker.allowsEditing = false
                
                self.present(imagePicker, animated: true, completion:  {
                    self.imagePicker.navigationBar.topItem?.rightBarButtonItem?.tintColor = .black
                    self.imagePicker.navigationBar.topItem?.rightBarButtonItem?.isEnabled = true
                })
            }
        case .camera:
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = true
//                self.present(self.pickerController, animated: true, completion: nil)
                self.present(imagePicker, animated: true, completion: nil)
//                
//                self.present(imagePicker, animated: true, completion:  {
//                    self.imagePicker.navigationBar.topItem?.rightBarButtonItem?.tintColor = .black
//                    self.imagePicker.navigationBar.topItem?.rightBarButtonItem?.isEnabled = true
//                })
            }
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.dismiss(animated: true, completion: { () -> Void in

        })

        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
        let image = JSQPhotoMediaItem(image: chosenImage)
        let message = JSQMessage(senderId: self.senderId, senderDisplayName: self.senderDisplayName, date: Date(), media: image)
        
        // reducing the size of the image
        let reducedImage = chosenImage.resizeWithWidth(width: 750)
        let imageData = UIImagePNGRepresentation(reducedImage!)
        

        if let data = imageData{
            
            let messageID = self.addImage(message!)
            let imageRef = Constants.storage.messages.child("\(messageID).jpg")
            
            // Create file metadata including the content type
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            let _ = imageRef.putData(data, metadata: metadata) { (metadata, error) in
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    return
                }
                // Metadata contains file metadata such as size, content-type, and download URL.
                let _ = metadata.downloadURL
                
            }
        }
        gotImages = true
        self.messages.append(message!)
        updateDateRead()
        self.collectionView.reloadData()
        self.scrollToBottom(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        print("cancelled")
    }
    
    func getMessages(){
        messageContentRef.child(self.messageID!).queryOrdered(byChild: "date").queryLimited(toLast: 10).observe(.childAdded, with: {(snapshot) in
            let message_data = snapshot.value as? [String:Any]
        
            let id = message_data?["sender_id"] as! String
            let name = self.names[(message_data?["sender_id"]! as! String)]
            let date = Date(timeIntervalSince1970: TimeInterval(message_data?["date"] as! Double))
            
            var message: JSQMessage?
            if let text = message_data?["text"]{
                message = JSQMessage(senderId: id, senderDisplayName: name, date: date, text: text as! String)
                
                self.messages.append(message!)
                self.collectionView.reloadData()
                self.scrollToBottom(animated: true)
            }
            else{
                if !self.gotImages || id != self.senderId{
                    let image = JSQPhotoMediaItem(image: UIImage(named: "empty_event"))
                    let message = JSQMessage(senderId: id, senderDisplayName: name, date: date, media: image)
                    self.imageMapper[snapshot.key] = self.messages.count
                    
//                    print(message.isMediaMessage)
//                    print(message.senderId)
//                    print(message.text)
//                    print(message.senderDisplayName)
//        
                    
                    // show the placeholder image
                    self.messages.append(message!)
                    
                    self.downloadImage(id: snapshot.key, name: name!, date: date)
//                    let imageRef = Constants.storage.messages.child("\(snapshot.key).jpg")
//                    
//                    
//
//                    
//                    imageRef.downloadURL(completion: {(url, error) in
//                        if let error = error{
//                            print("Error occurred: \(error.localizedDescription)")
//                        }
//                        
//                        SDWebImageManager.shared().downloadImage(with: url, options: .continueInBackground, progress: {
//                            (receivedSize :Int, ExpectedSize :Int) in
//                            
//                        }, completed: {
//                            (image : UIImage?, error : Error?, cacheType : SDImageCacheType, finished : Bool, url : URL?) in
//                            
//                            if image != nil && finished{
//                                let JSQimage = JSQPhotoMediaItem(image: image)
//                                let message = JSQMessage(senderId: id, senderDisplayName: name, date: date, media: JSQimage)
//                                
//                                let index = self.imageMapper[snapshot.key]
//                                self.messages[index!] = message!
//                                self.collectionView.reloadData()
//                                
//                            }
//                        })
//                    })
                }
                
                self.collectionView.reloadData()
                self.scrollToBottom(animated: true)
            }
        })
    }
    
    func downloadImage(id: String, name: String, date: Date){
        let imageRef = Constants.storage.messages.child("\(id).jpg")
        
        
        imageRef.downloadURL(completion: {(url, error) in
            if let error = error{
                if let previous = self.delay[id]{
                    self.delay[id] = previous + 1
                }
                else{
                    self.delay[id] = 1
                }
                
                if self.delay[id]! < 3{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                        self.downloadImage(id: id, name: name, date: date)
                    })
                }
                
                
            }
            
            SDWebImageManager.shared().downloadImage(with: url, options: .continueInBackground, progress: {
                (receivedSize :Int, ExpectedSize :Int) in
                
            }, completed: {
                (image : UIImage?, error : Error?, cacheType : SDImageCacheType, finished : Bool, url : URL?) in
                
                if image != nil && finished{
                    let JSQimage = JSQPhotoMediaItem(image: image)
//                    let message = JSQMessage(senderId: id, senderDisplayName: name, date: date, media: JSQimage)
                    
                    
                    let index = self.imageMapper[id]
                    let message = self.messages[index!]
                    
                    let imageMessage = JSQMessage(senderId: message.senderId, senderDisplayName: message.senderDisplayName, date: message.date, media: JSQimage)
                    
                    self.messages[index!] = imageMessage!
                    self.collectionView.reloadData()
                    
                }
            })
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
    
    func addImage(_ message: JSQMessage) -> String{
        
        if self.messageID == nil{
            
            let threadID = messageContentRef.childByAutoId()
            let newMessage = threadID.childByAutoId()
            
            let messageDictionary: [String: Any] = [
                "sender_id" : AuthApi.getFirebaseUid(),
                "image" : true,
                "date": Date().timeIntervalSince1970
            ]
            
            self.messageID = threadID.key
            newMessage.setValue(messageDictionary)
            self.addMessageID()
            self.getMessages()
            return newMessage.key
        }
        else{
            let conversion = self.messageContentRef.child(self.messageID!)
            
            let newMessage = conversion.childByAutoId()
            let messageDictionary: [String: Any] = [
                "sender_id" : AuthApi.getFirebaseUid(),
                "image" : true,
                "date": Date().timeIntervalSince1970
            ]
            
            newMessage.setValue(messageDictionary)
            return newMessage.key
        }
        
        
    }
    
    func getMessageID(){
        messagesRef.child(self.senderId).child(self.user["firebaseUserId"]! as! String).observeSingleEvent(of: .value, with: { (snapshot) in
            let val = snapshot.value as? [String:Any]
            if let ID = val?["messageID"] as? String{
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
            
            let threadID = messageContentRef.childByAutoId()
            let newMessage = threadID.childByAutoId()
            
            if !message.isMediaMessage {
                let messageDictionary = [
                    "sender_id" : AuthApi.getFirebaseUid(),
                    "text" : message.text,
                    "date": Date().timeIntervalSince1970
                    ] as [String : Any]
                self.messageID = threadID.key
                newMessage.setValue(messageDictionary)
            }
            else{
                let messageDictionary = [
                    "sender_id" : AuthApi.getFirebaseUid(),
                    "image" : true,
                    "date": Date().timeIntervalSince1970
                    ] as [String : Any]
                self.messageID = threadID.key
                newMessage.setValue(messageDictionary)
            }
            
            self.addMessageID()
            self.getMessages()
        }
        
    }
    
    func addMessageID(){
        let one = self.messagesRef.child(self.senderId).child(user["firebaseUserId"]! as! String)
        let two = self.messagesRef.child(user["firebaseUserId"]! as! String).child(self.senderId)
        
        let content = [
            "messageID": self.messageID,
            "date": Date().timeIntervalSince1970,
            "read": false
        ] as [String : Any]
        one.setValue(content)
        two.setValue(content)
        
    }

    func updateDateRead(){
        messagesRef.child("\(self.user["firebaseUserId"]! as! String)/\(self.senderId!)/date").setValue(Date().timeIntervalSince1970)
        messagesRef.child("\(self.user["firebaseUserId"]! as! String)/\(self.senderId!)/read").setValue(false)
    }
    
    func markUnread(){
        messagesRef.child("\(self.senderId!)/\(self.user["firebaseUserId"]! as! String)/read").setValue(true)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapCellAt indexPath: IndexPath!, touchLocation: CGPoint) {
        self.view.endEditing(true)
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
