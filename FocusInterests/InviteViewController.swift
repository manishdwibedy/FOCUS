//
//  InvitevViewController.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 6/8/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import Contacts
import FirebaseStorage

class InviteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SendInvitationsViewControllerDelegate{
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var friendsTableView: UITableView!
    @IBOutlet weak var contactList: UILabel!
    @IBOutlet weak var contactListView: UIView!
    
    let alphabeticalSections = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
    
    
    var inviteCellData = [InviteUser]()
    
    var parentCell: SearchPlaceCell!
    var type = ""
    var id = ""
    var place: Place?
    var event: Event?
    
    var selected = [Bool]()

    
    var image: Data?
    var selectedFriend = [Bool]()
    let store = CNContactStore()
    var contacts = [CNContact]()

    override func viewDidLoad() {
        super.viewDidLoad()
        formatNavBar()
        self.sendButton.roundCorners(radius: 10.0)
        
        self.friendsTableView.delegate = self
        self.friendsTableView.dataSource = self
        
        self.friendsTableView.allowsSelection = false
        
        if contacts.count <= 0 {
            contactListView.isHidden = true
        }else{
            contactListView.isHidden = false
        }
        
        let inviteListCellNib = UINib(nibName: "InviteListTableViewCell", bundle: nil)
        friendsTableView.register(inviteListCellNib, forCellReuseIdentifier: "personToInvite")
        
        let selectedTimeListCellNib = UINib(nibName: "SelectedTimeTableViewCell", bundle: nil)
        friendsTableView.register(selectedTimeListCellNib, forCellReuseIdentifier: "selectedTimeCell")
        
        
        Constants.DB.user.queryLimited(toFirst: 10).observeSingleEvent(of: .value, with: { (snapshot) in
            let data = snapshot.value as? NSDictionary
            if let data = data
            {
                for (_,value) in data
                {
                    if let info = value as? [String: Any]{
                        if let uid = info["firebaseUserId"] as? String, let username = info["username"] as? String, let fullname = info["fullname"] as? String{
                            let newData = InviteUser(UID: uid, username: username, fullname: fullname)
                            self.inviteCellData.append(newData)
                        }
                    }
                }
            }
            
            for _ in 0..<self.inviteCellData.count{
                self.selected.append(false)
            }
            self.friendsTableView.reloadData()
        })
        
        
        hideKeyboardWhenTappedAround()
    }
    
    func setSelectedFriends(){
        for _ in 0...contacts.count{
            selectedFriend.append(false)
        }
    }
    
    private func formatNavBar(){
        self.navigationItem.title = "Send Invites"
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
    }
    
    // MARK: - Tableview Delegate Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return 1
        }
        return inviteCellData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.alphabeticalSections
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        var temp = self.alphabeticalSections as NSArray
        return temp.index(of: title)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(indexPath.section == 0){
            let selectedTimeTableCell = tableView.dequeueReusableCell(withIdentifier: "selectedTimeCell", for: indexPath) as! SelectedTimeTableViewCell
            return selectedTimeTableCell
        }
        
        let personToInviteCell = tableView.dequeueReusableCell(withIdentifier: "personToInvite", for: indexPath) as! InviteListTableViewCell
        personToInviteCell.delegate = self

        personToInviteCell.usernameLabel.text = self.inviteCellData[indexPath.row].username //will need to change this to the username of user
        personToInviteCell.fullNameLabel.text = self.inviteCellData[indexPath.row].fullname
        
        personToInviteCell.inviteConfirmationButton.tag = indexPath.row
        return personToInviteCell
    }
    
    func contactHasBeenSelected(contact: String, index: Int){
        contactListView.isHidden = false
        if self.selected[index] == false
        {
            self.selected[index] = true
            if contactList.text!.isEmpty {
                contactList.text = "\(contact)"
            }else{
                contactList.text = contactList.text! + ",\(contact)"
            }
        }

        
    }
    
    
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func inviteUsers(_ sender: Any) {
        
        let time = NSDate().timeIntervalSince1970
        
        let inviteUIDList = zip(selected,self.inviteCellData ).filter { $0.0 }.map { $1.UID }
        
        
        for UID in inviteUIDList{
            var name = ""
            if type == "place"{
                name = (place?.name)!
                Constants.DB.user.child(AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: { snapshot in
                    let user = snapshot.value as? [String : Any] ?? [:]
                    
                    let fullname = user["fullname"] as? String
                    sendNotification(to: self.id, title: "\(String(describing: fullname)) invited you to \(String(describing: self.place?.name))", body: "")
                })
                Constants.DB.places.child(id).child("invitations").childByAutoId().updateChildValues(["toUID":UID, "fromUID":AuthApi.getFirebaseUid()!,"time": Double(time)])
            }
            else{
                name = (event?.title)!
                Constants.DB.user.child(AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: { snapshot in
                    let user = snapshot.value as? [String : Any] ?? [:]
                    
                    let fullname = user["fullname"] as? String
                    sendNotification(to: self.id, title: "\(String(describing: fullname)) invited you to \(String(describing: self.place?.name))", body: "")
                })
                Constants.DB.event.child(id).child("invitations").childByAutoId().updateChildValues(["toUID":UID, "fromUID":AuthApi.getFirebaseUid()!,"time": Double(time)])
            }
            
            Constants.DB.user.child(UID).child("invitations").child(self.type).childByAutoId().updateChildValues(["ID":id, "time":time,"fromUID":AuthApi.getFirebaseUid()!])
            
            Constants.DB.user.child(AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: { snapshot in
                
                let user = snapshot.value as? [String : Any] ?? [:]
                
                let username = user["username"] as? String
                
                sendNotification(to: UID, title: "Invitations", body: "\(username!) invited you to \(name)")
                
            })
        }
        
        dismiss(animated: true, completion: nil)
    }
}

struct InviteUser{
    let UID: String
    let username: String
    let fullname: String
}

