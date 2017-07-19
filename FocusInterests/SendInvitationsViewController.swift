 
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
    
    @IBOutlet weak var navBar: UINavigationBar!
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
    
    var isFacebook = false
    var isTwitter = false
    let loginView = FBSDKLoginManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        formatNavBar()
        
        self.createEventButton.roundCorners(radius: 10.0)
        
//        self.searchBar.isTranslucent = false
        
        self.friendsTableView.delegate = self
        self.friendsTableView.dataSource = self

        self.searchBar.layer.borderWidth = 0.0
        
        //        search bar attributes
        let placeholderAttributes: [String : AnyObject] = [NSForegroundColorAttributeName: UIColor.white]
        let attributedPlaceholder: NSAttributedString = NSAttributedString(string: "Search", attributes: placeholderAttributes)
        
        //        search bar placeholder
        let textFieldInsideSearchBar = self.searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.backgroundColor = Constants.color.navy
        textFieldInsideSearchBar?.attributedPlaceholder = attributedPlaceholder
        textFieldInsideSearchBar?.textColor = UIColor.white
        
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
    
    func retrieveContactsWithStore(store: CNContactStore) {
        self.contacts.removeAll()
        let contactStore = CNContactStore()
        let keys = [CNContactPhoneNumbersKey, CNContactFamilyNameKey, CNContactGivenNameKey, CNContactNicknameKey, CNContactPhoneNumbersKey, CNContactImageDataKey]
        let request1 = CNContactFetchRequest(keysToFetch: keys  as [CNKeyDescriptor])
        
        try? contactStore.enumerateContacts(with: request1) { (contact, error) in
            if contact.phoneNumbers.count > 0 && (contact.givenName.characters.count > 0 || contact.familyName.characters.count > 0){
                self.contacts.append(contact)
            }
            
        }
        
        for contact in contacts{
            if !contact.givenName.isEmpty{
                let first = String(describing: contact.givenName.characters.first!).uppercased()
                
                
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
    }

    @IBAction func createEvent(_ sender: Any) {
        Event.clearCache()
        let id = self.event?.saveToDB(ref: Constants.DB.event)
        
        
        Answers.logCustomEvent(withName: "Create Event",
                               customAttributes: [
                                "FOCUS": event?.category!
            ])
        
        Constants.DB.event_locations!.setLocation(CLLocation(latitude: Double(event!.latitude!)!, longitude: Double(event!.longitude!)!), forKey: id) { (error) in
            if (error != nil) {
                debugPrint("An error occured: \(String(describing: error))")
            } else {
                print("Saved location successfully!")
            }
        }
    
        for interest in (event?.category?.components(separatedBy: ";"))!{
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
            Share.postToTwitter(withStatus: "Please come to \(String(describing: self.event?.title))")
        }
        
        if facebookSwitch.isOn{
            do{
                try Share.facebookShare(with: URL(string:"http://mapofyourworld.com")!, description: "Please come to \(String(describing: self.event?.title))")
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
        
        if phoneNumbers.count > 0{
            messageVC.body = "Please come to \(String(describing: self.event?.title))"
            messageVC.recipients = phoneNumbers
            messageVC.messageComposeDelegate = self;
            
            self.present(messageVC, animated: false, completion: nil)
            
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let VC = storyboard.instantiateViewController(withIdentifier: "home") as? HomePageViewController
        
        
        self.present(VC!, animated: true, completion: nil)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
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
        print("cell with path: \(indexPath.row)")
        var cell = UITableViewCell()
        if(indexPath.section == 0){
            let selectedAllFollowersTableCell = tableView.dequeueReusableCell(withIdentifier: "selectAllContactsCell", for: indexPath) as! SelectAllContactsTableViewCell
            selectedAllFollowersTableCell.delegate = self
            cell = selectedAllFollowersTableCell
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

            cell = personToInviteCell
        }
        return cell
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if indexPath.section == 0{
//            tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.setSelected(true, animated: false)
//        }
//    }
    
//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        if indexPath.section == 0{
//            tableView.deselectRow(at: self.friendsTableView.indexPathForSelectedRow!, animated: false)
//            let selectedAllFollowersTableCell = tableView.dequeueReusableCell(withIdentifier: "selectAllContactsCell", for: indexPath) as! SelectAllContactsTableViewCell
//            selectedAllFollowersTableCell.setSelected(false, animated: false)
//        }else if indexPath.section == 1{
//            tableView.deselectRow(at: IndexPath(row: 0, section: 0), animated: false)
//        }
//    }
    
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
                let array = (users! as NSArray).filtered(using: searchPredicate)
                for val in array{
                    filteredUser.append(val as! CNContact)
                }
            }
            
            filteredSection.removeAll()
            filtered.removeAll()
            filteredSectionMapping.removeAll()
            for user in filteredUser{
                let first = String(describing: user.givenName.characters.first!).uppercased()
                
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
            self.filteredSection.sort()
            self.friendsTableView.reloadData()
        }
    }
    
    @IBAction func shareOnFB(_ sender: Any) {
        if AuthApi.getFacebookToken() == nil{
            
            loginView.logIn(withReadPermissions: ["public_profile", "email", "user_friends"], from: self) { (result, error) in
                if error != nil {
                    print(error?.localizedDescription ?? "")
                    self.showLoginFailedAlert(loginType: "Facebook")
                } else {
                    if let res = result {
                        if res.isCancelled {
                            return
                        }
                        if let tokenString = FBSDKAccessToken.current().tokenString {
                            let credential = FacebookAuthProvider.credential(withAccessToken: tokenString)
                            Auth.auth().currentUser?.link(with: credential) { (user, error) in
                                if error != nil {
                                    AuthApi.set(facebookToken: tokenString)
                                    self.isFacebook = true
                                    self.facebookSwitch.isOn = true
                                    return
                                }
                            }
                        }
                    } else {
                        self.isFacebook = false
                        self.facebookSwitch.isOn = false
                        self.showLoginFailedAlert(loginType: "Facebook")
                    }
                }
            }
        }
        else{
            self.isFacebook = true
            self.facebookSwitch.isOn = true
        }
    }
    
    @IBAction func shareOnTwitter(_ sender: Any) {
        if AuthApi.getTwitterToken() == nil{
            Share.loginTwitter()
        }
        
        if AuthApi.getTwitterToken() != nil{
            isTwitter = true
            self.twitterSwitch.isOn = true
        }
        else{
            isTwitter = true
            self.twitterSwitch.isOn = true
            
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
