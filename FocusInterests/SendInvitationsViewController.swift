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

protocol SelectAllContactsDelegate {
    func selectedAllFollowers()
    func deselectAllFollowers()
}

protocol SendInvitationsViewControllerDelegate {
    func contactHasBeenSelected(contact: String, index: Int)
}

class SendInvitationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, SendInvitationsViewControllerDelegate, SelectAllContactsDelegate{
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var createEventButton: UIButton!
    @IBOutlet weak var friendsTableView: UITableView!
    @IBOutlet weak var contactList: UILabel!
    @IBOutlet weak var contactListView: UIView!
    
    let alphabeticalSections = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
    
    var event: Event?
    var image: Data?
    var selectedFriend = [Bool]()
    let store = CNContactStore()
    var contacts = [CNContact]()
    var filteredContacts = [CNContact]()
    var searchingForContact = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        formatNavBar()
        
        self.createEventButton.roundCorners(radius: 10.0)
        
        self.searchBar.isTranslucent = false
        
        self.searchBar.barTintColor = UIColor(red: 122/255.0, green: 201/255.0, blue: 1/255.0, alpha: 1.0)
        
        self.searchBar.layer.cornerRadius  = 6;
        self.searchBar.clipsToBounds = true
        self.searchBar.layer.borderWidth = 1
        
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
        
        let selectedAllContactsCellNib = UINib(nibName: "SelectAllContactsTableViewCell", bundle: nil)
        friendsTableView.register(selectedAllContactsCellNib, forCellReuseIdentifier: "selectAllContactsCell")
        
        if CNContactStore.authorizationStatus(for: .contacts) == .authorized{
            self.retrieveContactsWithStore(store: self.store)
        }
        else{
            
        }
        
        self.sortContacts()
        
        hideKeyboardWhenTappedAround()
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
                self.contacts.append(contact)
            }
            self.setSelectedFriends()
            friendsTableView.reloadData()
        } catch {
            print(error)
        }
    }

    @IBAction func createEvent(_ sender: Any) {
        Event.clearCache()
        let id = self.event?.saveToDB(ref: Constants.DB.event)
        
        if let data = self.image{
            let imageRef = Constants.storage.event.child("\(id!).jpg")
            
            // Create file metadata including the content type
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            let _ = imageRef.putData(data, metadata: metadata) { (metadata, error) in
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
    
    // MARK: - Tableview Delegate Methods

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return 1
        } else {
            
            if(searchingForContact) {
                return filteredContacts.count
            }
            
            return contacts.count
        }
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
            let selectedAllFollowersTableCell = tableView.dequeueReusableCell(withIdentifier: "selectAllContactsCell", for: indexPath) as! SelectAllContactsTableViewCell
            selectedAllFollowersTableCell.delegate = self
            return selectedAllFollowersTableCell
        } else {
            let personToInviteCell = tableView.dequeueReusableCell(withIdentifier: "personToInvite", for: indexPath) as! InviteListTableViewCell
            personToInviteCell.delegate = self
            
            if(searchingForContact){
                personToInviteCell.usernameLabel.text = self.filteredContacts[indexPath.row].givenName
                personToInviteCell.fullNameLabel.text = self.filteredContacts[indexPath.row].familyName
            }else {
                personToInviteCell.usernameLabel.text = self.contacts[indexPath.row].givenName //will need to change this to the username of user
                personToInviteCell.fullNameLabel.text = self.contacts[indexPath.row].familyName
            }
            
            return personToInviteCell
        }
    }
    
    func contactHasBeenSelected(contact: String, index: Int){
        print(contact)
        contactListView.isHidden = false
        if contactList.text!.isEmpty {
            contactList.text = "\(contact)"
        }else{
            contactList.text = contactList.text! + ",\(contact)"
        }
    }
    
    func deselectAllFollowers() {
        contactListView.isHidden = true
        contactList.text = ""
    }
    
    func selectedAllFollowers() {
        contactListView.isHidden = false
        for contactIndex in 0...contacts.count-1{
            contactList.text = contactList.text! + ",\(contacts[contactIndex].givenName)"
        }
    }
    
//    MARK: SEARCH BAR DELEGATE METHODS
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(self.searchBar == nil || self.searchBar.text == ""){
            self.searchingForContact = false
            self.searchBar.endEditing(true)
            self.friendsTableView.reloadData()
        }else{
            self.searchingForContact = true
            self.filteredContacts = self.contacts.filter({ singleContact in
                return singleContact.givenName.lowercased() == self.searchBar.text!.lowercased()
            })
            self.sortContacts()
            self.friendsTableView.reloadData()
        }
    }
    
    func sortContacts(){
        if(searchingForContact){
            self.filteredContacts.sort { (nameOne, nameTwo) -> Bool in
                let stringOfNameOne = String(describing: nameOne.givenName)
                let stringOfNameTwo = String(describing: nameTwo.givenName)
                
                return stringOfNameOne.lowercased() < stringOfNameTwo.lowercased()
            }
        }else{
            self.contacts.sort { (nameOne, nameTwo) -> Bool in
                let stringOfNameOne = String(describing: nameOne.givenName)
                let stringOfNameTwo = String(describing: nameTwo.givenName)
                
                return stringOfNameOne.lowercased() < stringOfNameTwo.lowercased()
            }
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchingForContact = true
        self.searchBar.endEditing(true)
        self.friendsTableView.reloadData()
    }
    
    @IBAction func backPressed(_ sender: UIBarButtonItem) {
//        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)

    }
}
