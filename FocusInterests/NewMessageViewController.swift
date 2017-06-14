//
//  NewMessageViewController.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/6/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import FirebaseDatabase

class NewMessageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    @IBOutlet weak var tableView: UITableView!

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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        self.setupSearchBar()
        
        let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height))
        backgroundView.backgroundColor = UIColor(hexString: "445464")
        tableView.backgroundView = backgroundView
        
        self.tableView.separatorColor = UIColor.white
        self.tableView.separatorInset = UIEdgeInsets.zero
        
        let nib = UINib(nibName: "NewMessageTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "newMessageCell")
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        hideKeyboardWhenTappedAround()
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
        let search = UISearchBar()
        search.searchBarStyle = .prominent
        search.placeholder = "Search..."
        let textFieldInsideSearchBar = search.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.backgroundColor = UIColor.white
        search.delegate = self
        self.navigationItem.titleView = search
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
        
        let section = filteredSection[indexPath.section]
        
        let user = self.filtered[section]?[indexPath.row]
        cell.usernameLabel.text = user?["username"] as! String?
        cell.fullNameLabel.text = user?["fullname"] as? String
        
//        cell.preservesSuperviewLayoutMargins = false
//        cell.separatorInset = UIEdgeInsets.zero
//        cell.layoutMargins = UIEdgeInsets.zero

        
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
        print("loading user list")
        self.userRef.queryLimited(toLast: 10).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let users = snapshot.value as? [String:[String:Any]]
            
            for (id, user) in users!{
                if !self.usersInMemory.contains(id){
                    if let username = user["username"] as? String{
                        let first = String(describing: username.characters.first!).uppercased()
                        
                        self.usersInMemory.insert(id)
                        
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
            }
            self.filteredSectionMapping = self.sectionMapping
            self.filteredSection = self.sections
            self.filtered = self.users
            self.tableView.reloadData()
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
//    func loadRestUsers(){
//        userRef.observe(DataEventType.value, with: { (snapshot) in
//            // Get user value
//            let users = snapshot.value as? [String:[String:Any]]
//            
//            for (id, user) in users!{
//                if !self.usersInMemory.contains(id){
//                    self.users.append(user)
//                    self.usersInMemory.insert(id)
//                }
//            }
//            
//            self.users.sort { (nameOne, nameTwo) -> Bool in
//                var stringOfNameOne = String(describing: nameOne["username"])
//                var stringOfNameTwo = String(describing: nameTwo["username"])
//                
//                return stringOfNameOne.lowercased() < stringOfNameTwo.lowercased()
//            }
//            
//            self.tableView.reloadData()
//        })
//        
//    }
    
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
            let searchPredicate = NSPredicate(format: "username CONTAINS[C] %@", searchText)
            var filteredUser = [[String:Any]]()
            for section in sections {
                let users = self.users[section]
                let array = (users as! NSArray).filtered(using: searchPredicate)
                for val in array{
                    filteredUser.append(val as! [String : Any])
                }
            }
            
            filteredSection.removeAll()
            filtered.removeAll()
            filteredSectionMapping.removeAll()
            for user in filteredUser{
                if let username = user["username"] as? String{
                    let first = String(describing: username.characters.first!).uppercased()
                    
                    
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
        else{
            self.filteredSection = self.sections
            self.filteredSectionMapping = self.sectionMapping
            self.filtered = self.users
        }
        
        self.tableView.reloadData()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show_chat"{
            let VC = segue.destination as! ChatViewController
            let user = sender as? [String:Any]
            VC.user = user!
        }
    }
}
