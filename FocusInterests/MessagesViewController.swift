//
//  MessagesViewController.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/6/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class MessagesViewController: UIViewController {

    var messageRef: UInt = 0
    let usersRef = Constants.DB.user
    var messages = [UserMessages]()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        loadInitialTable()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTable()
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
        messageRef = Constants.DB.messages.child(AuthApi.getFirebaseUid()!).queryOrdered(byChild: "unread").queryLimited(toLast: 20).observe(.childAdded, with: {(snapshot) in
            
            let users = snapshot.value as? [String:[String:Any]]
            
            
            for (userID, message_data) in users!{
                self.usersRef.child(userID).child("username").observeSingleEvent(of: .value, with: {(snapshot) in
                    let username = snapshot.value as! String
                    let user = UserMessages(id: userID, name: username, messageID: message_data["messageID"] as! String, unreadMessages: message_data["unread"] as! Bool)
                    self.messages.append(user)
                    
                })
            }
        })
        
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
