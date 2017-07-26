//
//  NewMessageViewController.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/6/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import FirebaseDatabase
import JSQMessagesViewController

class NewMessageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var backButton: UIBarButtonItem!

    let alphabeticalSections = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
    
    
    var sections = [String]()
    var filteredSection = [String]()
    
    var sectionMapping = [String:Int]()
    var filteredSectionMapping = [String:Int]()
    
    
    var users = [String:[[String: Any]]]()
    var filtered = [String:[[String: Any]]]()
    
    var usersInMemory: Set<String> = []
    var searching = false
    let userRef = Constants.DB.user
    var addPin = false
    var pinMessage: String? = nil
    var pinImage: UIImage? = nil
    
    @IBOutlet weak var search: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSearchBar()

        self.tableView.separatorColor = UIColor.white

        let nib = UINib(nibName: "NewMessageTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "newMessageCell")
        
        self.navigationItem.title = "New Message"

        let backBarItem = UIBarButtonItem(image: #imageLiteral(resourceName: "BackArrow"), style: .done, target: self, action: #selector(NewMessageViewController.goBack))
        backBarItem.tintColor = UIColor.white

        self.navigationItem.setLeftBarButton(backBarItem, animated: true)
        self.navigationItem.setRightBarButton(UIBarButtonItem(title: "", style: .plain, target: nil, action: nil), animated: false)
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        hideKeyboardWhenTappedAround()
        
    }
    
    func goBack(){
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.usersInMemory.insert(AuthApi.getFirebaseUid()!)
        loadInitialTable()
        //loadRestUsers()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupSearchBar(){
        self.search.searchBarStyle = .prominent
        
        self.search.setValue("Cancel", forKey:"_cancelButtonText")
        self.search.placeholder = "Search"
        let textFieldInsideSearchBar = self.search.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.white
        textFieldInsideSearchBar?.backgroundColor = UIColor(red: 38/255.0, green: 83/255.0, blue: 126/255.0, alpha: 1.0)
        textFieldInsideSearchBar?.clearButtonMode = .whileEditing
        let clearButton = textFieldInsideSearchBar?.value(forKey: "clearButton") as! UIButton
        clearButton.setImage(clearButton.imageView?.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: .normal)
        clearButton.tintColor = UIColor.white
        
        let cancelButtonsInSearchBar: [String: AnyObject] = [NSFontAttributeName: UIFont(name: "Avenir-Black", size: 15)!]
        UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonsInSearchBar, for: .normal)
        
        self.search.delegate = self
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.filteredSection.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredSectionMapping[self.filteredSection[section]]!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newMessageCell", for: indexPath) as! NewMessageTableViewCell
        
        cell.textLabel?.textColor = UIColor.white
        cell.fullNameLabel.textColor = UIColor.white
        let section = filteredSection[indexPath.section]
        
        let user = self.filtered[section]?[indexPath.row]
        cell.usernameLabel.text = user?["username"] as! String?
        cell.fullNameLabel.text = user?["fullname"] as? String
        
        if let image_string = user?["image_string"] as? String{
            if let url = URL(string: image_string){
                cell.userProfileImage.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "placeholder_people"))
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = self.filteredSection[indexPath.section]
        let user = self.filtered[section]?[indexPath.row]
        self.performSegue(withIdentifier: "show_chat", sender: user)
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.filteredSection
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        
        tableView.scrollToRow(at: IndexPath(row: 0, section: index), at: UITableViewScrollPosition.top , animated: false)
//        return sortedContactKeys.index(of: title)!

        var temp = self.filteredSection as NSArray
        return temp.index(of: title)
    }
    
    func loadInitialTable(){
        
        let ref = Constants.DB.user
        var followingIndex = 0
        
        ref.child(AuthApi.getFirebaseUid()!).child("following/people").observeSingleEvent(of: .value, with: {snapshot in
            if let value = snapshot.value as? [String:Any]{
                for (_, people) in value{
                    let followingCount = value.count
                    if let peopleData = people as? [String:Any]{
                        let UID = peopleData["UID"] as! String
                        ref.child(UID).observeSingleEvent(of: .value, with: { snapshot in
                            if let user = snapshot.value as? [String:Any]{
                                if let username = user["username"] as? String{
                                    if username.characters.count > 0{
                                        let first = String(describing: username.characters.first!).uppercased()
                                        
                                        self.usersInMemory.insert(user["firebaseUserId"] as! String)
                                        followingIndex += 1
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
                                    
                                    if followingCount == followingIndex{
                                        self.sections.sort()
                                        self.filteredSectionMapping = self.sectionMapping
                                        self.filteredSection = self.sections
                                        self.filtered = self.users
                                        self.tableView.reloadData()
                                    }
                                }
                            }
                        })
                    }
                }
            }
        })
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searching = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.searching = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searching = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searching = false;
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.characters.count > 0{
            self.filteredSection.removeAll()
            self.filteredSectionMapping.removeAll()
            self.filtered.removeAll()
            
            
            self.userRef.queryOrdered(byChild: "username").queryStarting(atValue: searchText.lowercased()).queryEnding(atValue: searchText.lowercased()+"\u{f8ff}").observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                if let users = snapshot.value as? [String:[String:Any]]{
                    
                    for (id, user) in users{
                        if !self.usersInMemory.contains(id){
                            if let username = user["username"] as? String{
                                if username.characters.count > 0{
                                    let first = String(describing: username.characters.first!).uppercased()
                                    
                                    self.usersInMemory.insert(id)
                                    
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
                        }
                    }
                    self.filteredSection.sort()
                    self.tableView.reloadData()
                }
            })
            
            self.userRef.queryOrdered(byChild: "fullname_lowered").queryStarting(atValue: searchText.lowercased()).queryEnding(atValue: searchText.lowercased()+"\u{f8ff}").observeSingleEvent(of: .value, with: { snapshot in
                // Get user value
                if let users = snapshot.value as? [String:[String:Any]]{
                    
                    for (id, user) in users{
                        if !self.usersInMemory.contains(id){
                            if let username = user["username"] as? String{
                                if username.characters.count > 0{
                                    let first = String(describing: username.characters.first!).uppercased()
                                    
                                    self.usersInMemory.insert(id)
                                    
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
                        }
                    }
                    self.filteredSection.sort()
                    self.tableView.reloadData()
                }
            })
            
        }
        else{
            self.filteredSection = self.sections
            self.filteredSectionMapping = self.sectionMapping
            self.filtered = self.users
        }
        self.filteredSection.sort()
        self.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show_chat"{
            let VC = segue.destination as! ChatViewController
            let user = sender as? [String:Any]
            VC.user = user!
            VC.addPin = self.addPin
            VC.pinMessage = self.pinMessage
            VC.pinImage = self.pinImage
        }
    }
}
