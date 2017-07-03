//
//  MessagesViewController.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/6/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import FirebaseDatabase
import SDWebImage

class MessagesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var messageRef: UInt = 0
    let usersRef = Constants.DB.user
    var userInfo = [String:[String:Any]]()
    var messageMapper = [String: UserMessages]()
    private var _messages = [UserMessages]()
    
    
    var contentMapping = [String: UserMessages]()
    
    
    @IBOutlet weak var messageTable: UITableView!
    var messages: [UserMessages]{
        get{
            return _messages
        }
        set(newList){
            _messages = newList.sorted {
                
                if $0.readMessages == $1.readMessages{
                    return $0.lastMessageDate > $1.lastMessageDate
                }
                return !$0.readMessages && $1.readMessages
                
            }
            messageTable.reloadData()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        messageTable.tableFooterView = UIView()
        
        
        let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: self.messageTable.bounds.size.width, height: self.messageTable.bounds.size.height))
        backgroundView.backgroundColor = Constants.color.navy
        messageTable.backgroundView = backgroundView
        
        let nib = UINib(nibName: "MessageTableViewCell", bundle: nil)
        messageTable.register(nib, forCellReuseIdentifier: "cell")
        
        self.messageTable.separatorColor = UIColor.white
        self.messageTable.separatorInset = UIEdgeInsets.zero

        hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
//        loadInitialTable()
        
        self.navigationController?.navigationBar.titleTextAttributes = Constants.navBar.attrs
        self.navigationController?.navigationBar.barTintColor = Constants.color.navy
        
        
        var backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "BackArrow"), style: .plain, target: self, action: #selector(compose))
        
        self.navigationItem.rightBarButtonItem = backButton

    }
    
    func compose(sender: UIBarButtonItem) {
        // Perform your custom actions
        // ...
        // Go back to the previous ViewController
        let composeVC = UIStoryboard(name: "Messages", bundle: nil).instantiateViewController(withIdentifier: "compose") as! NewMessageViewController
        self.navigationController?.pushViewController(composeVC, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.messages.removeAll()
        loadTable()
        
        listenForChanges()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Constants.DB.messages.removeObserver(withHandle: self.messageRef)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goBack(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func loadTable(){
        messageRef = Constants.DB.messages.child(AuthApi.getFirebaseUid()!).queryOrdered(byChild: "read").queryLimited(toLast: 20).observe(.childAdded, with: {(snapshot) in

            let message = snapshot.value as? [String:Any]
            
            if let unix = message?["date"] as? Double{
                let date = Date(timeIntervalSince1970: unix)
                
                self.usersRef.child(snapshot.key).keepSynced(true)
                self.usersRef.child(snapshot.key).observeSingleEvent(of: .value, with: {(snapshot) in
                    if let value = snapshot.value{
                        if let user_info = value as? [String:Any]{
                            let username = user_info["username"] as! String
                            let image_string = user_info["image_string"] as! String
                            
                            let userMessage = UserMessages(id: snapshot.key, name: username, messageID: message?["messageID"] as! String, readMessages: message?["read"] as! Bool, lastMessageDate: date, image_string: image_string)
                            
                            self.messageMapper[snapshot.key] = userMessage
                            self.userInfo[snapshot.key] = user_info
                            self.contentMapping[userMessage.messageID] = userMessage
                            
                            Constants.DB.message_content.child(userMessage.messageID).queryOrdered(byChild: "date").queryLimited(toLast: 1).observe(.childAdded, with: {(snapshot) in
                                let message_data = snapshot.value as? [String:Any]
                                let id = userMessage.messageID
                                
                                if let text = message_data?["text"]{
                                    let message = self.contentMapping[id]
                                    message?.addLastContent(lastContent: text as! String)
                                }
                                else{
                                    let message = self.contentMapping[id]
                                    message?.addLastContent(lastContent: "sent a photo")
                                }
                                
                                self.messages.append(userMessage)
                                self.messageTable.reloadData()
                            })
                        }
                    }
                })
            }
        })
    }
    
    func listenForChanges(){
        Constants.DB.messages.child(AuthApi.getFirebaseUid()!).queryOrdered(byChild: "read").queryLimited(toLast: 20).observe(.childChanged, with: {(snapshot) in
            
            let message = snapshot.value as? [String:Any]
            let userMessage = self.messageMapper[snapshot.key]
            
            if let index = self.messages.index(where: {$0.messageID == userMessage?.messageID}) {
                // do something with fooOffset
                let date = Date(timeIntervalSince1970: message?["date"] as! Double)
                
                userMessage?.lastMessageDate = date
                userMessage?.readMessages = message?["read"] as! Bool
                self.messages[index] = userMessage!
            }

            
        })

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self._messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MessageTableViewCell
        let formatter = DateFormatter()
    
        let message = self.messages[indexPath.row]
        cell.username.text = message.name
        
        
        
        let block: SDWebImageCompletionBlock = {(image, error, cacheType, imageURL) -> Void in
            cell.userImage.roundedImage()
        }
        
        let placeholderImage = UIImage(named: "UserPhoto")
        
        if let url = URL(string: message.image_string){
            cell.userImage.sd_setImage(with: url, placeholderImage: placeholderImage, options: SDWebImageOptions.highPriority, completed: block)
            cell.userImage.setShowActivityIndicator(true)
            cell.userImage.setIndicatorStyle(.gray)
        }
        
        cell.content.text = message.lastContent
        
        let date = message.lastMessageDate
        cell.time.text = formatter.timeSince(from: date, numericDates: false)
        
        if !message.readMessages{
            
            cell.textLabel?.font = UIFont(name: "Avenir-Book", size: 15)
            cell.detailTextLabel?.font = UIFont(name: "Avenir-Book", size: 15)
        }
        else{
            cell.textLabel?.font = UIFont(name: "Avenir-Book", size: 15)
            cell.detailTextLabel?.font = UIFont(name: "Avenir-Book", size: 15)
        }
        
        cell.backgroundColor = .clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = self.messages[indexPath.row]
        let user_info = self.userInfo[message.id]
        self.performSegue(withIdentifier: "show_user_chat", sender: user_info)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show_user_chat"{
            let VC = segue.destination as! ChatViewController
            VC.user = sender as! [String:Any]
        }
        
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
