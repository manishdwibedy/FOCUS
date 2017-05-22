//
//  SendInvitationsViewController.swift
//  FocusInterests
//
//  Created by Amber Spadafora on 5/16/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class SendInvitationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var inviteFromContactsBttn: UIButton!
    @IBOutlet weak var createEventBttn: UIButton!
    @IBOutlet weak var friendsTableView: UITableView!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        formatNavBar()
        formatSubViews()
        self.friendsTableView.delegate = self
        self.friendsTableView.dataSource = self
    }
    
    
    @IBAction func inviteFromContacts(_ sender: UIButton) {
    }
    
    @IBAction func createEvents(_ sender: UIButton) {
    }

    private func formatNavBar(){
        self.navigationItem.title = "Send Invites"
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
    }
    
    func formatSubViews(){
        self.inviteFromContactsBttn.layer.cornerRadius = 10.0
        self.createEventBttn.layer.cornerRadius = 10.0
        self.friendsTableView.layer.cornerRadius = 10.0
    }
    
    // MARK: - Tableview Delegate Methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = friendsTableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! InviteFriendTableViewCell
        
        cell.friendIconImageView.layer.cornerRadius = 50.0
        cell.friendIconImageView.clipsToBounds = true
        
        return cell
    }
    
    func postOnTwitter(text: String){
        if AuthApi.getTwitterToken() == nil{
            do{
                try Share.loginAndShareTwitter(withStatus: text)
            }
            catch{
                
            }
            
        }
        else{
            Share.postToTwitter(withStatus: text)
        }
    }
    

}
