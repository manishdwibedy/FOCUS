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
import MessageUI

class InviteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SendInvitationsViewControllerDelegate, MFMessageComposeViewControllerDelegate{
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var friendsTableView: UITableView!
    @IBOutlet weak var contactList: UILabel!
    @IBOutlet weak var contactListView: UIView!
    @IBOutlet weak var timeOut: UIButton!
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeButton: UIButton!
    @IBOutlet weak var friendListBottom: NSLayoutConstraint!
   
    @IBOutlet weak var inviteTableTop: NSLayoutConstraint!
    var sections = [String]()
    var sectionMapping = [String:Int]()
    var users = [String:[InviteUser]]()
    
    var parentCell: SearchPlaceCell!
    var type = ""
    var id = ""
    var place: Place?
    var event: Event?
    
    var selected = [InviteUser:Bool]()
    
    let store = CNContactStore()
    let datePicker = UIDatePicker()
    let timePicker = UIDatePicker()
    let dateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    var inviteTime = ""

    var searchPlace: SearchPlacesViewController? = nil
    var searchEvent: SearchEventsViewController? = nil
    var image: Data?
    var selectedFriend = [Bool]()
    var contacts = [CNContact]()

    override func viewDidLoad() {
        super.viewDidLoad()
        formatNavBar()
        self.sendButton.roundCorners(radius: 10.0)
        
        self.friendsTableView.delegate = self
        self.friendsTableView.dataSource = self
        
        self.friendsTableView.allowsSelection = true
        
        if contacts.count <= 0 {
            contactListView.isHidden = true
        }else{
            contactListView.isHidden = false
        }
        
        let startDate = event?.date?.components(separatedBy: ",")[1].trimmingCharacters(in: .whitespaces)
        timeButton.setTitle(startDate, for: .normal)
        
        let inviteListCellNib = UINib(nibName: "InviteListTableViewCell", bundle: nil)
        friendsTableView.register(inviteListCellNib, forCellReuseIdentifier: "personToInvite")
        
//        let selectedTimeListCellNib = UINib(nibName: "SelectedTimeTableViewCell", bundle: nil)
//        friendsTableView.register(selectedTimeListCellNib, forCellReuseIdentifier: "selectedTimeCell")
        
        if type != "invite"{
            Constants.DB.user.observeSingleEvent(of: .value, with: { (snapshot) in
                let data = snapshot.value as? NSDictionary
                if let data = data
                {
                    //                self.inviteCellData.removeAll()
                    for (_,value) in data
                    {
                        if let info = value as? [String: Any]{
                            if let uid = info["firebaseUserId"] as? String, let username = info["username"] as? String, let fullname = info["fullname"] as? String{
                                let newData = InviteUser(UID: uid, username: username, fullname: fullname)
                                self.selected[newData] = false
                                if newData.UID != AuthApi.getFirebaseUid(){
                                    //                                self.inviteCellData.append(newData)
                                    
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
                
                self.sections.sort()
                self.friendsTableView.reloadData()
            })
        }
        else{
            inviteTableTop.constant = 0
            timeLabel.isHidden = true
            timeButton.isHidden = true
            self.sections.removeAll()
            self.sectionMapping.removeAll()
            self.users.removeAll()
            do {
                
                let contactStore = CNContactStore()
                let keys = [CNContactPhoneNumbersKey, CNContactFamilyNameKey, CNContactGivenNameKey, CNContactNicknameKey, CNContactPhoneNumbersKey, CNContactImageDataKey]
                let request1 = CNContactFetchRequest(keysToFetch: keys  as [CNKeyDescriptor])
                
                try? contactStore.enumerateContacts(with: request1) { (contact, error) in
                    if contact.phoneNumbers.count > 0 && (contact.givenName.characters.count > 0 || contact.familyName.characters.count > 0){
                        print(contact)
                        self.contacts.append(contact)
                    }
                    
                }
                
                for contact in contacts{
                    if let name = contact.givenName as? String{
                        let first = String(describing: name.characters.first!).uppercased()
                        
                        var numbers = [String]()
                        for number in contact.phoneNumbers{
                            numbers.append(number.value.stringValue)
                        }
                        let user = InviteUser(UID: numbers.joined(separator: ","), username: contact.givenName, fullname: contact.familyName)
                        self.selected[user] = false
                        if !self.sections.contains(first){
                            self.sections.append(first)
                            self.sectionMapping[first] = 1
                            self.users[first] = [user]
                        }
                        else{
                            self.sectionMapping[first] = self.sectionMapping[first]! + 1
                            self.users[first]?.append(user)
                        }
                    }
                }
                
                self.sections.sort()
                friendsTableView.reloadData()
            } catch {
                print(error)
            }
        }
        
        
        
        self.timePicker.datePickerMode = .time
        self.timePicker.minuteInterval = 5
        
        self.datePicker.datePickerMode = .date
        self.dateFormatter.dateFormat = "MMM d yyyy"
        self.timeFormatter.dateFormat = "h:mm a"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "h:mm a"
        
        if let date = startDate{
            let startDate = dateFormatter.date(from: date)
            timePicker.date = startDate!
        }
        
        self.timePicker.addTarget(self, action: #selector(pickerChange(sender:)), for: UIControlEvents.valueChanged)
        
        self.friendsTableView.tableFooterView = UIView()
        hideKeyboardWhenTappedAround()
        
        let attrs = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "Avenir-Black", size: 18)!
        ]
        
        navBar.titleTextAttributes = attrs
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
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.sectionMapping[self.sections[section]]!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.sections
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        tableView.scrollToRow(at: IndexPath(row: 0, section: index), at: UITableViewScrollPosition.top , animated: false)
        
        var temp = self.sections as NSArray
        return temp.index(of: title)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = sections[indexPath.section]
        let user = self.users[section]?[indexPath.row]

        
        let personToInviteCell = tableView.dequeueReusableCell(withIdentifier: "personToInvite", for: indexPath) as! InviteListTableViewCell
        personToInviteCell.delegate = self
        personToInviteCell.user = user
        
        if self.selected[user!]!{
            personToInviteCell.inviteConfirmationButton.isSelected = true
        }
        else{
            personToInviteCell.inviteConfirmationButton.isSelected = false
        }
        
        
        
        personToInviteCell.usernameLabel.text = user?.username
        personToInviteCell.fullNameLabel.text = user?.fullname
        
        personToInviteCell.inviteConfirmationButton.tag = indexPath.row
        return personToInviteCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        tableView.deselectRow(at: indexPath, animated: true)

        let section = sections[indexPath.section]
        let user = self.users[section]?[indexPath.row]

        
        let personToInviteCell = tableView.dequeueReusableCell(withIdentifier: "personToInvite", for: indexPath) as! InviteListTableViewCell
        
        
        if !self.selected[user!]!{
            personToInviteCell.inviteConfirmationButton.isSelected = true
            contactHasBeenSelected(contact: (user?.username)!, index: index)
        }
        else{
            personToInviteCell.inviteConfirmationButton.isSelected = false
            contactHasBeenRemoved(contact: (user?.username)!, index: index)
        }
    }
    func contactHasBeenSelected(contact: String, index: Int){
        contactListView.isHidden = false
        
        let section = String(describing: contact.characters.first!)
        let user = self.users[section.uppercased()]?[index]

        
        if self.selected[user!]! == false
        {
            self.selected[user!]! = true
            
            var selectedFriends = [String]()
            for (user, flag) in self.selected{
                if flag{
                    selectedFriends.append(user.username)
                }
            }
            
            if selectedFriends.count > 0{
                friendListBottom.constant = 57
            }
            contactList.text = selectedFriends.joined(separator: ", ")
            friendsTableView.reloadData()
        }

        
    }
    
    func contactHasBeenRemoved(contact: String, index: Int) {
        let section = String(describing: contact.characters.first!)
        let user = self.users[section.uppercased()]?[index]

        if self.selected[user!]! == true
        {
            self.selected[user!]! = false
            var selectedFriends = [String]()
            for (user, flag) in self.selected{
                if flag{
                    selectedFriends.append(user.username)
                }
            }
            if selectedFriends.count == 0{
                contactListView.isHidden = true
                friendListBottom.constant = 0
            }
            contactList.text = selectedFriends.joined(separator: ", ")
            friendsTableView.reloadData()
        }
    }
    
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func inviteUsers(_ sender: Any) {
        
        if type != "invite"{
            let time = NSDate().timeIntervalSince1970
            
            var inviteUIDList = [String]()
            
            for (user, flag) in self.selected{
                if flag{
                    inviteUIDList.append(user.UID)
                }
            }
            
            for UID in inviteUIDList{
                var name = ""
                if type == "place"{
                    name = (place?.name)!
                    Constants.DB.user.child(AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: { snapshot in
                        let user = snapshot.value as? [String : Any] ?? [:]
                        
                        let fullname = user["fullname"] as? String
                        sendNotification(to: UID, title: "\(String(describing: fullname)) invited you to \(String(describing: self.place?.name))", body: "", actionType: "", type: "place", item_id: "",item_name: "")
                    })
                    Constants.DB.places.child(id).child("invitations").childByAutoId().updateChildValues(["toUID":UID, "fromUID":AuthApi.getFirebaseUid()!,"time": Double(time),"inviteTime":inviteTime,"status": "sent"])
                    searchPlace?.showPopup = true
                }
                else{
                    name = (event?.title)!
                    Constants.DB.user.child(AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: { snapshot in
                        let user = snapshot.value as? [String : Any] ?? [:]
                        
                        let fullname = user["fullname"] as? String
                        sendNotification(to: UID, title: "\(String(describing: fullname)) invited you to \(String(describing: self.place?.name))", body: "", actionType: "", type: "event", item_id: "", item_name: "")
                    })
                    Constants.DB.event.child(id).child("invitations").childByAutoId().updateChildValues(["toUID":UID, "fromUID":AuthApi.getFirebaseUid()!,"time": Double(time),"status": "sent"])
                    searchEvent?.showInvitePopup = true
                }
                
                Constants.DB.user.child(UID).child("invitations").child(self.type).childByAutoId().updateChildValues(["ID":id, "time":time,"fromUID":AuthApi.getFirebaseUid()!,"inviteTime":inviteTime])
                
                Constants.DB.user.child(AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: { snapshot in
                    
                    let user = snapshot.value as? [String : Any] ?? [:]
                    
                    let username = user["username"] as? String
                    
                    sendNotification(to: UID, title: "Invitations", body: "\(username!) invited you to \(name)", actionType: "", type: "", item_id: "", item_name: "")
                    
                })
            }
            dismiss(animated: true, completion: nil)
        }
        else{
            let messageVC = MFMessageComposeViewController()
            
            
            var inviteUIDList = [String]()
            
            for (user, flag) in self.selected{
                if flag{
                    inviteUIDList.append(user.UID)
                }
            }
            
            for UID in inviteUIDList{
                inviteUIDList.append(UID)
            }
            
            messageVC.body = "Open this link to join me on FOCUS and create a Map of Your World:"
            messageVC.recipients = inviteUIDList
            messageVC.messageComposeDelegate = self
            
            self.present(messageVC, animated: false, completion: nil)
        }
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
    
    @IBAction func timePushed(_ sender: Any) {
        
        timePicker.frame = CGRect(x: 0, y: (self.view.frame.height)-(timePicker.frame.height), width: self.view.frame.width, height: timePicker.frame.height)
        timePicker.backgroundColor = UIColor.white
        timePicker.inputAccessoryView
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(screenTapWithPicker(sender:)))
        self.view.addGestureRecognizer(tap)
    
        self.view.addSubview(timePicker)
    }
    
    
    func screenTapWithPicker(sender: UITapGestureRecognizer)
    {
        timePicker.removeFromSuperview()
    }
    
    func pickerChange(sender: UIDatePicker)
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let dateString = dateFormatter.string(from: sender.date)
        timeOut.setTitle(dateString, for: UIControlState.normal)
        inviteTime = dateString
    }
    
    
}

class InviteUser: Hashable, Equatable{
    let UID: String
    let username: String
    let fullname: String
    
    init(UID: String, username: String, fullname: String) {
        self.UID = UID
        self.username = username
        self.fullname = fullname
    }
    
    var hashValue : Int {
        get {
            return "\(self.UID)".hashValue
        }
    }
    
    static func ==(lhs: InviteUser, rhs: InviteUser) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

