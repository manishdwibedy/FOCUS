//
//  MessagesViewController.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/6/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import FirebaseDatabase

class MessagesViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var messageRef: UInt = 0
    let usersRef = Constants.DB.user
    private var _messages = [UserMessages]()
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
            tableView.reloadData()
        }
    }
    var messageMapper = [String: UserMessages]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        // Do any additional setup after loading the view.
//        loadInitialTable()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
            
            let date = Date(timeIntervalSince1970: message?["date"] as! Double)
            let userMessage = UserMessages(id: snapshot.key, name: snapshot.key, messageID: message?["messageID"] as! String, readMessages: message?["read"] as! Bool, lastMessageDate: date)
            self.messageMapper[snapshot.key] = userMessage
            self.messages.append(userMessage)
//            let users = snapshot.value as? [String:[String:Any]]
//            
//            
//            for (userID, message_data) in users!{
//                self.usersRef.child(userID).child("username").observeSingleEvent(of: .value, with: {(snapshot) in
//                    let username = snapshot.value as! String
//                    let user = UserMessages(id: userID, name: username, messageID: message_data["messageID"] as! String, unreadMessages: message_data["read"] as! Bool)
//                    self.messages.append(user)
//                    
//                })
//            }
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
        let date = message.lastMessageDate
        cell.detailTextLabel?.text = formatter.timeSince(from: date, numericDates: false)
        
        if !message.readMessages{
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15.0)
            cell.detailTextLabel?.font = UIFont.boldSystemFont(ofSize: 15.0)
        }
        return cell
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
