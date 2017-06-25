
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
import SCLAlertView
import MessageUI

protocol SelectAllContactsDelegate {
    func selectedAllFollowers()
    func deselectAllFollowers()
}

protocol SendInvitationsViewControllerDelegate {
    func contactHasBeenSelected(contact: String, index: Int)
    func contactHasBeenRemoved(contact: String, index: Int)
}

class SendInvitationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, SendInvitationsViewControllerDelegate, SelectAllContactsDelegate, MFMessageComposeViewControllerDelegate{
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var createEventButton: UIButton!
    @IBOutlet weak var friendsTableView: UITableView!
    @IBOutlet weak var contactList: UILabel!
    @IBOutlet weak var contactListView: UIView!
    
    @IBOutlet weak var facebookSwitch: UISwitch!
    @IBOutlet weak var twitterSwitch: UISwitch!
    let alphabeticalSections = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
    
    var sections = [String]()
    var filteredSection = [String]()
    
    var sectionMapping = [String:Int]()
    var filteredSectionMapping = [String:Int]()
    
    
    var users = [String:[CNContact]]()
    var filtered = [String:[CNContact]]()
    
    
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
        
//        self.searchBar.isTranslucent = false
        
        self.friendsTableView.delegate = self
        self.friendsTableView.dataSource = self
        
        self.friendsTableView.allowsSelection = false

        self.searchBar.layer.borderColor = UIColor.clear.cgColor
        var textFieldInsideSearchBar = self.searchBar.value(forKey: "searchField") as? UITextField
        
        textFieldInsideSearchBar?.textColor = UIColor.white

        
        if let txfSearchField = self.searchBar.value(forKey: "_searchField") as? UITextField {
            txfSearchField.borderStyle = .none
            txfSearchField.backgroundColor = UIColor(red: 24/255.0, green: 44/255.0, blue: 67/255.0, alpha: 1.0)
        }
        
        self.searchBar.isTranslucent = false
        self.searchBar.backgroundImage = UIImage()
        
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
            self.store.requestAccess(for: CNEntityType.contacts) { (isGranted, error) in
                self.retrieveContactsWithStore(store: self.store)
            }
        }
        
        self.sortContacts()
        
        hideKeyboardWhenTappedAround()
    }
    
    func setSelectedFriends(){
        for _ in 0...contacts.count{
            selectedFriend.append(false)
        }
    }
    
    func retrieveContactsWithStore(store: CNContactStore) {
        self.contacts.removeAll()
        do {
            
            let contactStore = CNContactStore()
            let keys = [CNContactPhoneNumbersKey, CNContactFamilyNameKey, CNContactGivenNameKey, CNContactNicknameKey, CNContactPhoneNumbersKey, CNContactImageDataKey]
            let request1 = CNContactFetchRequest(keysToFetch: keys  as [CNKeyDescriptor])
            
            try? contactStore.enumerateContacts(with: request1) { (contact, error) in
                if contact.phoneNumbers.count > 0 && (contact.givenName.characters.count > 0 || contact.familyName.characters.count > 0){
                    self.contacts.append(contact)
                }
                
            }
            
            for contact in contacts{
                if let name = contact.givenName as? String{
                    let first = String(describing: name.characters.first!).uppercased()
                    
                    
                    if !self.sections.contains(first){
                        self.sections.append(first)
                        self.sectionMapping[first] = 1
                        self.users[first] = [contact]
                    }
                    else{
                        self.sectionMapping[first] = self.sectionMapping[first]! + 1
                        self.users[first]?.append(contact)
                    }
                }
            }
            self.filteredSectionMapping = self.sectionMapping
            self.filteredSection = self.sections
            self.filtered = self.users
            
            self.setSelectedFriends()
            self.filteredSection.sort()
            friendsTableView.reloadData()
        } catch {
            print(error)
        }
    }

    @IBAction func createEvent(_ sender: Any) {
        Event.clearCache()
        let id = self.event?.saveToDB(ref: Constants.DB.event)
        
        Constants.DB.event_locations!.setLocation(CLLocation(latitude: Double(event!.latitude!)!, longitude: Double(event!.longitude!)!), forKey: id) { (error) in
            if (error != nil) {
                debugPrint("An error occured: \(error)")
            } else {
                print("Saved location successfully!")
            }
        }
    
        for interest in (event?.category?.components(separatedBy: ","))!{
            Constants.DB.event_interests.child(interest).childByAutoId().setValue(["event-id": id])
        }
        
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
        
        if twitterSwitch.isOn{
            Share.loginAndShareTwitter(withStatus: "Please come to \(String(describing: self.event?.title))")
        }
        
        if facebookSwitch.isOn{
            do{
                try Share.facebookShare(with: URL(string:"http://mapofyourworld.com")!, description: "Please come to \(self.event?.title)")
            }
            catch{
                SCLAlertView().showError("Facebook Error", subTitle: "Could not post to facebook")
            }
            
        }
        
        let messageVC = MFMessageComposeViewController()
        
        let friendList = zip(selectedFriend,self.contacts ).filter { $0.0 }.map { $1.phoneNumbers }
        
        var phoneNumbers = [String]()
        for friendPhoneList in friendList{
            for number in friendPhoneList{
                phoneNumbers.append((number.value.value(forKey: "digits") as? String)!)
            }
        }
        
        messageVC.body = "Please come to \(self.event?.title)"
        messageVC.recipients = phoneNumbers
        messageVC.messageComposeDelegate = self;
        
        self.present(messageVC, animated: false, completion: nil)
        
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController!, didFinishWith result: MessageComposeResult) {
        switch (result) {
        case .cancelled:
            print("Message was cancelled")
            self.dismiss(animated: true, completion: nil)
        case .failed:
            print("Message failed")
            self.dismiss(animated: true, completion: nil)
        case .sent:
            print("Message was sent")
            self.dismiss(animated: true, completion: nil)
        default:
            break;
        }
    }
    
    private func formatNavBar(){
        self.navigationItem.title = "Send Invites"
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
    }
    
    // MARK: - Tableview Delegate Methods

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.filteredSection.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return 1
        } else {
            return self.filteredSectionMapping[self.filteredSection[section-1]]!
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        var sections = [""]
        sections += self.filteredSection
        return sections
    }
    
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        tableView.scrollToRow(at: IndexPath(row: 0, section: index), at: UITableViewScrollPosition.top , animated: false)
        
        var temp = self.filteredSection as NSArray
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
            personToInviteCell.inviteConfirmationButton.tag = indexPath.row
            
            let section = filteredSection[indexPath.section-1]
            
            let user = self.filtered[section]?[indexPath.row]
            personToInviteCell.usernameLabel.text = user?.givenName
            personToInviteCell.fullNameLabel.text = user?.familyName
//            personToInviteCell.usernameLabel.text = "Alex"
//            personToInviteCell.fullNameLabel.text = "Alex Jang"

            return personToInviteCell
        }
    }
    
    func contactHasBeenSelected(contact: String, index: Int){
        selectedFriend[index] = true
        let friendList = zip(selectedFriend,self.contacts ).filter { $0.0 }.map { $1.givenName }
        if friendList.count > 0{
            contactListView.isHidden = false
        }
        else{
            contactListView.isHidden = true
        }
        contactList.text = friendList.joined(separator: ",")
    }
    
    func contactHasBeenRemoved(contact: String, index: Int){
        selectedFriend[index] = false
        let friendList = zip(selectedFriend,self.contacts ).filter { $0.0 }.map { $1.givenName }
        if friendList.count > 0{
            contactListView.isHidden = false
        }
        else{
            contactListView.isHidden = true
        }
        contactList.text = friendList.joined(separator: ",")
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
            self.filteredSection = self.sections
            self.filteredSectionMapping = self.sectionMapping
            self.filtered = self.users
            
            self.searchBar.endEditing(true)
            self.friendsTableView.reloadData()
        }else{
            let searchPredicate = NSPredicate(format: "givenName CONTAINS[C] %@", searchText)
            var filteredUser = [CNContact]()
            for section in sections {
                let users = self.users[section]
                let array = (users as! NSArray).filtered(using: searchPredicate)
                for val in array{
                    filteredUser.append(val as! CNContact)
                }
            }
            
            filteredSection.removeAll()
            filtered.removeAll()
            filteredSectionMapping.removeAll()
            for user in filteredUser{
                if let name = user.givenName as? String{
                    let first = String(describing: name.characters.first!).uppercased()
                    
                    
                    if !self.filteredSection.contains(first){
                        self.filteredSection.append(first)
                        self.filteredSectionMapping[first] = 1
                        self.filtered[first] = [user]
                    }
                    else{
                        self.filteredSectionMapping[first] = self.filteredSectionMapping[first]! + 1
                        self.filtered[first]?.append(user)
                    }
                }
                
            }
            self.filteredSection.sort()
            self.friendsTableView.reloadData()
        }
    }
    
    func sortContacts(){
//        if(searchingForContact){
//            self.filteredContacts.sort { (nameOne, nameTwo) -> Bool in
//                let stringOfNameOne = String(describing: nameOne.givenName)
//                let stringOfNameTwo = String(describing: nameTwo.givenName)
//                
//                return stringOfNameOne.lowercased() < stringOfNameTwo.lowercased()
//            }
//        }else{
//            self.users.sort { (nameOne, nameTwo) -> Bool in
//                let stringOfNameOne = String(describing: nameOne.givenName)
//                let stringOfNameTwo = String(describing: nameTwo.givenName)
//                
//                return stringOfNameOne.lowercased() < stringOfNameTwo.lowercased()
//            }
//        }
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
