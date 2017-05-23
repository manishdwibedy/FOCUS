//
//  SendInvitationsViewController.swift
//  FocusInterests
//
//  Created by Amber Spadafora on 5/16/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import Contacts
import FirebaseStorage

class SendInvitationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var inviteFromContactsBttn: UIButton!
    @IBOutlet weak var createEventBttn: UIButton!
    @IBOutlet weak var friendsTableView: UITableView!
    var event: Event?
    var image: Data?
    var selectedFriend = [Bool]()
    let store = CNContactStore()
    var contacts = [CNContact]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formatNavBar()
        formatSubViews()
        self.friendsTableView.delegate = self
        self.friendsTableView.dataSource = self
        
        if CNContactStore.authorizationStatus(for: .contacts) == .authorized{
            inviteFromContactsBttn.isEnabled = false
            self.retrieveContactsWithStore(store: self.store)
        }
        else{
            
        }
        
        friendsTableView.tableFooterView = UIView()
    }
    
    func setSelectedFriends(){
        for _ in 0...contacts.count{
            selectedFriend.append(false)
        }
    }
    
    @IBAction func inviteFromContacts(_ sender: UIButton) {
        if CNContactStore.authorizationStatus(for: .contacts) == .notDetermined {
            
            
            self.store.requestAccess(for: CNEntityType.contacts) { (isGranted, error) in
                self.retrieveContactsWithStore(store: self.store)
            }
            
        } else if CNContactStore.authorizationStatus(for: .contacts) == .authorized {
            self.retrieveContactsWithStore(store: store)
        }
    }
    
    func retrieveContactsWithStore(store: CNContactStore) {
        self.contacts.removeAll()
        do {
            
            let contactStore = CNContactStore()
            let keys = [CNContactPhoneNumbersKey, CNContactFamilyNameKey, CNContactGivenNameKey, CNContactNicknameKey, CNContactPhoneNumbersKey, CNContactImageDataKey]
            let request1 = CNContactFetchRequest(keysToFetch: keys  as [CNKeyDescriptor])
            
            try? contactStore.enumerateContacts(with: request1) { (contact, error) in
                print("\(contact.givenName) \(contact.familyName)")
                print(contact.phoneNumbers)
                print(contact.imageData)
                self.contacts.append(contact)
            }
            self.setSelectedFriends()
            friendsTableView.reloadData()
        } catch {
            print(error)
        }
    }
    
    @IBAction func createEvents(_ sender: UIButton) {
        let id = self.event?.saveToDB(ref: Constants.DB.event)
        
        if let data = self.image{
            let imageRef = Constants.storage.event.child("\(id!).jpg")
            
            // Create file metadata including the content type
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            
            let _ = imageRef.put(data, metadata: metadata) { (metadata, error) in
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    print("\(error!)")
                    return
                }
                // Metadata contains file metadata such as size, content-type, and download URL.
                let _ = metadata.downloadURL
            }
        }
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
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = friendsTableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! InviteFriendTableViewCell
        
        cell.friendIconImageView.layer.cornerRadius = 50.0
        cell.friendIconImageView.clipsToBounds = true
        let friend = self.contacts[indexPath.row]
        
        cell.friendLabel.text = "\(friend.givenName) \(friend.familyName)"
        if let data = friend.imageData{
            cell.friendIconImageView.image = UIImage(data: data)
        }
        
        if selectedFriend[indexPath.row]{
            cell.selectedFriend.image = UIImage(named: "Interest_Filled")
        }
        else{
            cell.selectedFriend.image = UIImage(named: "Interest_blank")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = friendsTableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! InviteFriendTableViewCell
        
        self.selectedFriend[indexPath.row] = !self.selectedFriend[indexPath.row]
        
        if selectedFriend[indexPath.row]{
            cell.selectedFriend.image = UIImage(named: "Interest_Filled")
        }
        else{
            cell.selectedFriend.image = UIImage(named: "Interest_blank")
        }
        tableView.reloadData()
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
    

    @IBAction func backPressed(_ sender: UIBarButtonItem) {
//        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)

    }
}
