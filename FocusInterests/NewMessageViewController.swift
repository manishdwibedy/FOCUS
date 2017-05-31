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

    let userRef = Constants.DB.user
    var users = [[String: Any]]()
    var usersInMemory: Set<String> = []
    var filtered = [[String: Any]]()
    var searching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        self.setupSearchBar()
        
        self.usersInMemory.insert(AuthApi.getFirebaseUid()!)
        loadInitialTable()
        loadRestUsers()
        
        
        let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height))
        backgroundView.backgroundColor = UIColor(hexString: "445464")
        tableView.backgroundView = backgroundView
        
        self.tableView.separatorColor = UIColor.white
        self.tableView.separatorInset = UIEdgeInsets.zero

        self.navigationController?.navigationBar.tintColor = UIColor.white

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
        textFieldInsideSearchBar?.backgroundColor = UIColor.lightGray
        search.delegate = self
        self.navigationItem.titleView = search
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching{
            return self.filtered.count
        }
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.textColor = UIColor.white

        
        if !searching{
            cell.textLabel?.text = self.users[indexPath.row]["username"] as! String?
        }
        else{
            cell.textLabel?.text = self.filtered[indexPath.row]["username"] as! String?
        }
        
//        cell.preservesSuperviewLayoutMargins = false
//        cell.separatorInset = UIEdgeInsets.zero
//        cell.layoutMargins = UIEdgeInsets.zero

        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "show_chat", sender: indexPath.row)
    }
    
    func loadInitialTable(){
        self.userRef.queryLimited(toLast: 10).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let users = snapshot.value as? [String:[String:Any]]
            
            for (id, user) in users!{
                if !self.usersInMemory.contains(id){
                    self.users.append(user)
                    self.usersInMemory.insert(id)
                }
            }
            self.tableView.reloadData()
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func loadRestUsers(){
        
        userRef.observe(DataEventType.value, with: { (snapshot) in
            // Get user value
            let users = snapshot.value as? [String:[String:Any]]
            
            for (id, user) in users!{
                if !self.usersInMemory.contains(id){
                    self.users.append(user)
                    self.usersInMemory.insert(id)
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
            let searchPredicate = NSPredicate(format: "username CONTAINS[C] %@", searchText)
            self.filtered = (self.users as NSArray).filtered(using: searchPredicate) as! [[String : Any]]
        }
        else{
            self.filtered = self.users
        }
        
        self.tableView.reloadData()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show_chat"{
            let VC = segue.destination as! ChatViewController
            searching = false
            let user: [String:Any]
            if searching{
                user = self.filtered[sender as! Int]
            }
            else{
                user = self.users[sender as! Int]
            }
            VC.user = user
        }
    }
}
