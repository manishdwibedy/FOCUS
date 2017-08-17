 
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
import Crashlytics
import FBSDKLoginKit
import FirebaseAuth
import DataCache
 
protocol SelectAllContactsDelegate {
    func selectedAllFollowers()
    func deselectAllFollowers()
}

protocol SendInvitationsViewControllerDelegate {
    func contactHasBeenSelected(contact: InviteUser, index: Int)
    func contactHasBeenRemoved(contact: InviteUser, index: Int)
}

class SendInvitationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, SelectAllContactsDelegate{
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var createEventButton: UIButton!
    @IBOutlet weak var friendsTableView: UITableView!
    @IBOutlet weak var contactList: UILabel!
    @IBOutlet weak var contactListView: UIView!
    @IBOutlet weak var navBar: UINavigationBar!
    
    
    let alphabeticalSections = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
    
    var sections = [String]()
    var filteredSection = [String]()
    
    var sectionMapping = [String:Int]()
    var filteredSectionMapping = [String:Int]()
    
    var users = [String:[InviteUser]]()
    var filtered = [String:[InviteUser]]()
    
    var event: Event?
    var image: Data?
    var selectedFriend = [Bool]()
    let store = CNContactStore()
    var contacts = [CNContact]()
    var filteredContacts = [CNContact]()
    var searchingForContact = false
    var isFacebook = false
    var isTwitter = false
    let loginView = FBSDKLoginManager()
    var selectedRow = [IndexPath]()
    var delegate: showMarkerDelegate?
    
    var selectedUsers = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        formatNavBar()
        
        self.contactList.textColor = UIColor.white
        self.createEventButton.roundCorners(radius: 9.0)
        
        self.friendsTableView.delegate = self
        self.friendsTableView.dataSource = self

        self.searchBar.layer.borderWidth = 0.0
        
        //        search bar attributes
        let placeholderAttributes: [String : AnyObject] = [NSForegroundColorAttributeName: UIColor.white]
        let attributedPlaceholder: NSAttributedString = NSAttributedString(string: "Search", attributes: placeholderAttributes)
        
        //        search bar placeholder
        let textFieldInsideSearchBar = self.searchBar.value(forKey: "searchField") as? UITextField

        textFieldInsideSearchBar?.attributedPlaceholder = attributedPlaceholder
        textFieldInsideSearchBar?.textColor = UIColor.white
        textFieldInsideSearchBar?.backgroundColor = UIColor(red: 38/255.0, green: 83/255.0, blue: 126/255.0, alpha: 1.0)
        
        //        search bar glass icon
        let glassIconView = textFieldInsideSearchBar?.leftView as! UIImageView
        glassIconView.image = glassIconView.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        glassIconView.tintColor = UIColor.white
        
        //        search bar clear button
        textFieldInsideSearchBar?.clearButtonMode = .whileEditing
        let clearButton = textFieldInsideSearchBar?.value(forKey: "clearButton") as! UIButton
        clearButton.setImage(clearButton.imageView?.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: .normal)
        clearButton.tintColor = UIColor.white
        
        UIBarButtonItem.appearance().setTitleTextAttributes(placeholderAttributes, for: .normal)
        
        
        let inviteListCellNib = UINib(nibName: "InviteListTableViewCell", bundle: nil)
        friendsTableView.register(inviteListCellNib, forCellReuseIdentifier: "personToInvite")
        
        let selectedAllContactsCellNib = UINib(nibName: "SelectAllContactsTableViewCell", bundle: nil)
        friendsTableView.register(selectedAllContactsCellNib, forCellReuseIdentifier: "selectAllContactsCell")
        
//        if CNContactStore.authorizationStatus(for: .contacts) == .authorized{
//            self.retrieveContactsWithStore(store: self.store)
//        }
//        else{
//            self.store.requestAccess(for: CNEntityType.contacts) { (isGranted, error) in
//                self.retrieveContactsWithStore(store: self.store)
//            }
//        }
        
        Constants.DB.user.observeSingleEvent(of: .value, with: { (snapshot) in
            let data = snapshot.value as? NSDictionary
            if let data = data
            {
                //                self.inviteCellData.removeAll()
                for (_,value) in data
                {
                    if let info = value as? [String: Any]{
                        if let uid = info["firebaseUserId"] as? String, let username = info["username"] as? String, let fullname = info["fullname"] as? String, let image = info["image_string"] as? String{
                            let newData = InviteUser(UID: uid, username: username, fullname: fullname, image: image)
//                            self.selected[newData] = false
                            if newData.UID != AuthApi.getFirebaseUid(){
                                let first = String(describing: newData.username.characters.first!).uppercased()
                                
                                if !self.sections.contains(first){
                                    self.sections.append(first)
                                    self.sectionMapping[first] = 1
                                    self.users[first] = [newData]
                                }
                                else{
                                    self.sectionMapping[first] = self.sectionMapping[first]! + 1
                                    self.users[first]?.append(newData)
                                }
                            }
                        }
                    }
                }
            }
            self.filteredSectionMapping = self.sectionMapping
            self.filteredSection = self.sections
            self.filtered = self.users
    
            self.setSelectedFriends()
            self.filteredSection.sort()
            self.friendsTableView.reloadData()
        })
        
        let attrs = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "Avenir-Black", size: 18)!
        ]
        
        self.navBar.titleTextAttributes = attrs
        
        self.navBar.barTintColor = Constants.color.navy
        self.view.backgroundColor = Constants.color.navy
        
        hideKeyboardWhenTappedAround()
    }
    
    func setSelectedFriends(){
        for _ in 0...contacts.count{
            selectedFriend.append(false)
        }
    }
    
//    func retrieveContactsWithStore(store: CNContactStore) {
//        self.contacts.removeAll()
//        let contactStore = CNContactStore()
//        let keys = [CNContactPhoneNumbersKey, CNContactFamilyNameKey, CNContactGivenNameKey, CNContactNicknameKey, CNContactPhoneNumbersKey, CNContactImageDataKey]
//        let request1 = CNContactFetchRequest(keysToFetch: keys  as [CNKeyDescriptor])
//        
//        try? contactStore.enumerateContacts(with: request1) { (contact, error) in
//            if contact.phoneNumbers.count > 0 && (contact.givenName.characters.count > 0 || contact.familyName.characters.count > 0){
//                self.contacts.append(contact)
//            }
//            
//        }
//        
//        for contact in contacts{
//            if !contact.givenName.isEmpty{
//                let first = String(describing: contact.givenName.characters.first!).uppercased()
//                
//                
//                if !self.sections.contains(first){
//                    self.sections.append(first)
//                    self.sectionMapping[first] = 1
//                    self.users[first] = [contact]
//                }
//                else{
//                    self.sectionMapping[first] = self.sectionMapping[first]! + 1
//                    self.users[first]?.append(contact)
//                }
//            }
//        }
//        self.filteredSectionMapping = self.sectionMapping
//        self.filteredSection = self.sections
//        self.filtered = self.users
//        
//        self.setSelectedFriends()
//        self.filteredSection.sort()
//        friendsTableView.reloadData()   
//    }

    @IBAction func createEvent(_ sender: Any) {
//        Event.clearCache()
//        let id = self.event?.saveToDB(ref: Constants.DB.event)
//        
//        var events = (DataCache.instance.readObject(forKey: "events") as? [Event])!
//        events.append(event!)
//        DataCache.instance.write(object: events as NSCoding, forKey: "events")
//        
//        
//        Answers.logCustomEvent(withName: "Create Event",
//                               customAttributes: [
//                                "FOCUS": event?.category!
//            ])
//        
////        nil is in line below
//        Constants.DB.event_locations!.setLocation(CLLocation(latitude: Double(event!.latitude!)!, longitude: Double(event!.longitude!)!), forKey: id) { (error) in
//            if (error != nil) {
//                debugPrint("An error occured: \(String(describing: error))")
//            } else {
//                print("Saved location successfully!")
//            }
//        }
//    
//        for interest in event!.category!.components(separatedBy: ";"){
//            Constants.DB.event_interests.child(interest).childByAutoId().setValue(["event-id": id])
//        }
//        
//        if let data = self.image{
//            let imageRef = Constants.storage.event.child("\(id!).jpg")
//            
//            // Create file metadata including the content type
//            let metadata = StorageMetadata()
//            metadata.contentType = "image/jpeg"
//            
//            let _ = imageRef.putData(data, metadata: metadata) { (metadata, error) in
//                guard let metadata = metadata else {
//                    // Uh-oh, an error occurred!
//                    print("\(error!)")
//                    return
//                }
//                // Metadata contains file metadata such as size, content-type, and download URL.
//                let _ = metadata.downloadURL
//            }
//        }
//        
//        let time = NSDate().timeIntervalSince1970
//        for UID in self.selectedUsers{
//            var name = (event?.title)!
//            Constants.DB.user.child(AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: { snapshot in
//                let user = snapshot.value as? [String : Any] ?? [:]
//                
//                let username = user["username"] as! String
//                sendNotification(to: UID, title: "New Invite", body: "\(String(describing: username)) invited you to \(String(describing: name))", actionType: "", type: "event", item_id: "", item_name: "")
//            })
//            Constants.DB.event.child(id!).child("invitations").childByAutoId().updateChildValues(["toUID":UID, "fromUID":AuthApi.getFirebaseUid()!,"time": Double(time),"status": "sent"])
//        
//            Constants.DB.user.child(UID).child("invitations/event").queryOrdered(byChild: "ID").queryEqual(toValue: id).observeSingleEvent(of: .value, with: {snapshot in
//                
//                if snapshot.value == nil{
//                    Constants.DB.user.child(UID).child("invitations/event").childByAutoId().updateChildValues(["ID":self.event?.id, "time":time,"fromUID":AuthApi.getFirebaseUid()!, "name": name, "status": "unknown", "inviteTime": time])
//                    
//                }
//            })
//            Answers.logCustomEvent(withName: "Invite User",
//                                   customAttributes: [
//                                    "type": "event",
//                                    "user": AuthApi.getFirebaseUid()!,
//                                    "invited": UID,
//                                    "name": name
//            ])
//            
//        }
    
//        Messaging
//        let messageVC = MFMessageComposeViewController()
//        
//        let friendList = zip(selectedFriend,self.contacts ).filter { $0.0 }.map { $1.phoneNumbers }
//        
//        var phoneNumbers = [String]()
//        for friendPhoneList in friendList{
//            for number in friendPhoneList{
//                phoneNumbers.append((number.value.value(forKey: "digits") as? String)!)
//            }
//        }
//        
//        if phoneNumbers.count > 0{
//            messageVC.body = "Please come to \(String(describing: self.event?.title))"
//            messageVC.recipients = phoneNumbers
//            messageVC.messageComposeDelegate = self;
//
//            
//        }
        
        let event = Event(title: "", description: "", fullAddress: "", shortAddress: "", latitude: "", longitude: "", date: "", creator: "", category: "", privateEvent: false)
        delegate?.showEventMarker(event: event)
        performSegue(withIdentifier: "unwindBackToExplorePage", sender: self)
    }
    
//    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
//        switch (result) {
//        case .cancelled:
//            print("Message was cancelled")
//            self.dismiss(animated: true, completion: nil)
//        case .failed:
//            print("Message failed")
//            self.dismiss(animated: true, completion: nil)
//        case .sent:
//            print("Message was sent")
//            self.dismiss(animated: true, completion: nil)
//        default:
//            break;
//        }
//    }
 
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
        return 60
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        var sections = [""]
        sections += self.filteredSection
        return sections
    }
    
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        tableView.scrollToRow(at: IndexPath(row: 0, section: index), at: UITableViewScrollPosition.top , animated: false)
        
        let temp = self.filteredSection as NSArray
        return temp.index(of: title)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if(indexPath.section == 0){
            let selectedAllFollowersTableCell = tableView.dequeueReusableCell(withIdentifier: "selectAllContactsCell", for: indexPath) as! SelectAllContactsTableViewCell
            selectedAllFollowersTableCell.delegate = self
            
            if selectedRow.contains(indexPath){
                selectedAllFollowersTableCell.selectAllFollowersButton.isSelected = true
            }else{
                selectedAllFollowersTableCell.selectAllFollowersButton.isSelected = false
            }
            
            cell = selectedAllFollowersTableCell
        } else {
            let personToInviteCell = tableView.dequeueReusableCell(withIdentifier: "personToInvite", for: indexPath) as! InviteListTableViewCell
            
            personToInviteCell.cellIndexTag = indexPath.row
            if selectedRow.contains(indexPath){
                personToInviteCell.inviteConfirmationButton.isSelected = true
                
                print("single cell \(indexPath)")
                print("found single selected cell at section: \(indexPath.section) row: \(indexPath.row)")
            }else{
                
                personToInviteCell.inviteConfirmationButton.isSelected = false
//                personToInviteCell.inviteConfirmationButton.imageView?.image = #imageLiteral(resourceName: "Interest_blank")
                
            }
            
            let section = filteredSection[indexPath.section-1]
            
            let user = self.filtered[section]?[indexPath.row]
            personToInviteCell.user = user
            personToInviteCell.usernameLabel.text = user?.username
            personToInviteCell.fullNameLabel.text = user?.fullname
            
            if let image = user?.image_string{
                if let url = URL(string: image){
                personToInviteCell.userProfileImage.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "placeholder_people"))
                }
            }
            
            
            
            cell = personToInviteCell
        }
        return cell
    }
    
//    MARK: SELECT CELL
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexRow = indexPath.row
        let indexSection = indexPath.section
        print("selecting in didselect")
        guard let indexPathForSelectedRows = tableView.indexPathsForSelectedRows?.sorted() else {
            print("no index path")
            return
        }
        
        let amountOfSelectedRows = indexPathForSelectedRows.count
        
        if indexPath.section == 0 && indexPath.row == 0{
            
            selectedRow = [[0,0]]
            let selectedAllFollowersTableCell = tableView.cellForRow(at: indexPath) as? SelectAllContactsTableViewCell
            selectedAllFollowersTableCell?.selectAllFollowersButton.isSelected = true
            
            self.selectedAllFollowers()
            if amountOfSelectedRows <= 1{
                print("do not need to deselectcells")
            }else{
                for cellIndex in 1...indexPathForSelectedRows.count-1{
                    tableView.deselectRow(at: indexPathForSelectedRows[cellIndex], animated: false)
                    let singleFollowerCell = tableView.cellForRow(at: indexPath) as? InviteListTableViewCell
                    singleFollowerCell?.inviteConfirmationButton.isSelected = false
                }
                
                for visibleCellsIndex in 1...tableView.visibleCells.count-1{
                    let singleFollowerCell = tableView.visibleCells[visibleCellsIndex] as? InviteListTableViewCell
                    singleFollowerCell?.inviteConfirmationButton.isSelected = false
                    
                    
                }
                self.deselectAllFollowers()
            }
        }else{
            let personToInviteCell = tableView.cellForRow(at: indexPath) as? InviteListTableViewCell
            
            if !self.selectedRow.contains(indexPath){
                
                print("found single cell \(indexPath)")
                personToInviteCell?.inviteConfirmationButton.isSelected = true
                self.contactHasBeenSelectedAtIndex(contact: (personToInviteCell?.user)!, index: indexPath)
                selectedRow = indexPathForSelectedRows
                
                if self.selectedRow.contains(IndexPath(row: 0, section: 0)){
                    tableView.deselectRow(at: IndexPath(row: 0, section: 0), animated: false)
                    selectedRow.remove(at: 0)
                    let selectedAllFollowersTableCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? SelectAllContactsTableViewCell
                    selectedAllFollowersTableCell?.selectAllFollowersButton.isSelected = false
                    selectedRow = indexPathForSelectedRows
                }
            }
        }
        print("new selected row \(indexPathForSelectedRows.sorted())")
    }
    
    
//    MARK: DESELECT CELL
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print("deselecting in diddeSelect")
        guard let indexPathForSelectedRows = tableView.indexPathsForSelectedRows?.sorted() else {
//            here we are resetting the entire selected row.  this accounts for when there's only been one cell selected
            if indexPath.section == 0 && indexPath.row == 0{
                if let selectedAllFollowersTableCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? SelectAllContactsTableViewCell{
                    selectedAllFollowersTableCell.selectAllFollowersButton.isSelected = false
                }
                self.deselectAllFollowers()
            }else{
                if let personToInviteCell = tableView.cellForRow(at: IndexPath(row: indexPath.row, section: indexPath.section)) as? InviteListTableViewCell{
                    personToInviteCell.inviteConfirmationButton.isSelected = false
                    self.contactHasBeenRemovedAtIndex(contact: personToInviteCell.user!, index: indexPath)
                }
            }
            selectedRow = [[]]
            return
        }
        
//            here if there is more than 1 cell selected then we are removing each cell one by one depending if invite all is clicked or a single user
        if indexPath.section == 0 && indexPath.row == 0{
            if let selectedAllFollowersTableCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? SelectAllContactsTableViewCell{
                selectedAllFollowersTableCell.selectAllFollowersButton.isSelected = false
                self.deselectAllFollowers()
            }
        }else{
            if let personToInviteCell = tableView.cellForRow(at: IndexPath(row: indexPath.row, section: indexPath.section)) as? InviteListTableViewCell{
                personToInviteCell.inviteConfirmationButton.isSelected = false
                self.contactHasBeenRemovedAtIndex(contact: personToInviteCell.user!, index: indexPath)
            }
        }
        print("new selected row \(indexPathForSelectedRows.sorted())")
        selectedRow = indexPathForSelectedRows
    }
    
    func contactHasBeenSelectedAtIndex(contact: InviteUser, index: IndexPath){
//        selectedFriend[index] = true
//        let friendList = zip(selectedFriend,self.contacts ).filter { $0.0 }.map { $1.givenName }
//        if friendList.count > 0{
//            contactListView.isHidden = false
//            contactList.text = friendList.joined(separator: ",")
//        }
//        self.selectedUsers.append(contact.UID)
//        contactList.text = friendList.joined(separator: ",")
//        print("contact: \(contact)")
    }
    
    func contactHasBeenRemovedAtIndex(contact: InviteUser, index: IndexPath){
//        selectedFriend[index] = false
//        let friendList = zip(selectedFriend,self.contacts ).filter { $0.0 }.map { $1.givenName }
//        if friendList.count > 0{
//            contactListView.isHidden = false
//        }
//        else{
//            contactListView.isHidden = true
//        }
//        
//        if let index = self.selectedUsers.index(of: contact.UID) {
//            self.selectedUsers.remove(at: index)
//        }
//        contactList.text = friendList.joined(separator: ",")
    }
    func deselectAllFollowers() {
        contactList.text = ""
    }
    
    func selectedAllFollowers() {
        
//        for contactIndex in 0..<selectedFriend.count{
//            contactList.text = contactList.text! + ",\(contacts[contactIndex].givenName)"
//        }
    }
    
//    MARK: SEARCH BAR DELEGATE METHODS
    
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        if(self.searchBar == nil || self.searchBar.text == ""){
//            self.filteredSection = self.sections
//            self.filteredSectionMapping = self.sectionMapping
//            self.filtered = self.users
//            
//            self.searchBar.endEditing(true)
//            self.friendsTableView.reloadData()
//        }else{
//            let searchPredicate = NSPredicate(format: "givenName CONTAINS[C] %@", searchText)
//            var filteredUser = [CNContact]()
//            for section in sections {
//                let users = self.users[section]
//                let array = (users! as NSArray).filtered(using: searchPredicate)
//                for val in array{
//                    filteredUser.append(val as! CNContact)
//                }
//            }
//            
//            filteredSection.removeAll()
//            filtered.removeAll()
//            filteredSectionMapping.removeAll()
//            for user in filteredUser{
//                let first = String(describing: user.givenName.characters.first!).uppercased()
//                
//                if !self.filteredSection.contains(first){
//                    self.filteredSection.append(first)
//                    self.filteredSectionMapping[first] = 1
//                    self.filtered[first] = [user]
//                }
//                else{
//                    self.filteredSectionMapping[first] = self.filteredSectionMapping[first]! + 1
//                    self.filtered[first]?.append(user)
//                }
//            }
//            self.filteredSection.sort()
//            self.friendsTableView.reloadData()
//        }
//    }
//    
    
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
    
    @IBAction func returnToCreateEvents(){
        performSegue(withIdentifier: "goBackToCreateEvents", sender: self)
    }
    
    @IBAction func backPressed(_ sender: UIBarButtonItem) {
//        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)

    }
    
    func showLoginFailedAlert(loginType: String) {
        let alert = UIAlertController(title: "Login error", message: "There has been an error logging in with \(loginType). Please try again.", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .destructive, handler: nil)
        alert.view.tintColor = UIColor.primaryGreen()
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goBackToCreateEvents"{
            let destinationVC = segue.destination as! EventIconViewController
            destinationVC.event = self.event
            destinationVC.imageData = self.image
        }
    }
    
}
