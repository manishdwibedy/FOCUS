//
//  MessagesViewController.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/6/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import FirebaseDatabase

class MessagesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var messageRef: UInt = 0
    let usersRef = Constants.DB.user
    var userInfo = [String:[String:Any]]()
    var messageMapper = [String: UserMessages]()
    private var _messages = [UserMessages]()
    
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
        backgroundView.backgroundColor = UIColor(hexString: "445464")
        messageTable.backgroundView = backgroundView
        
        self.messageTable.separatorColor = UIColor.white
        self.messageTable.separatorInset = UIEdgeInsets.zero

        
        // Do any additional setup after loading the view.
//        loadInitialTable()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.messages.count == 0{
            loadTable()
        }
        
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
                
                self.usersRef.child(snapshot.key).observeSingleEvent(of: .value, with: {(snapshot) in
                    let user_info = snapshot.value as! [String:Any]
                    let username = user_info["username"] as! String
                    
                    let userMessage = UserMessages(id: snapshot.key, name: username, messageID: message?["messageID"] as! String, readMessages: message?["read"] as! Bool, lastMessageDate: date)
                    self.messageMapper[snapshot.key] = userMessage
                    self.userInfo[snapshot.key] = user_info
                    self.messages.append(userMessage)
                    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let formatter = DateFormatter()
    
        let message = self.messages[indexPath.row]
        cell.textLabel?.text = message.name
        cell.textLabel?.textColor = UIColor.white
        cell.detailTextLabel?.textColor = UIColor.white

        let date = message.lastMessageDate
        cell.detailTextLabel?.text = formatter.timeSince(from: date, numericDates: false)
        
        if !message.readMessages{
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15.0)
            cell.detailTextLabel?.font = UIFont.boldSystemFont(ofSize: 15.0)
        }
        else{
            cell.textLabel?.font = UIFont.italicSystemFont(ofSize: 15)
            cell.detailTextLabel?.font = UIFont.italicSystemFont(ofSize: 15.0)
        }
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
