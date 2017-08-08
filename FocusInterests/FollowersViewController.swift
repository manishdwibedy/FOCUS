//
//  FollowingViewController.swift
//  FocusInterests
//
//  Created by Alex Jang on 6/5/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import Contacts

class FollowersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    @IBOutlet weak var navBar: UINavigationBar!
    var windowTitle = "Followers"
    var followers = [followProfileCellData]()
    var following = [followProfileCellData]()
    let store = CNContactStore()
    var ID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = Constants.color.navy
        self.navBar.barTintColor = Constants.color.navy
        
        navBar.topItem?.title = self.windowTitle
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navBar.titleTextAttributes = Constants.navBar.attrs
        
        let nib = UINib(nibName: "FollowProfileCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "FollowProfileCell")
        
        tableView.tableFooterView = UIView()
        
        
        
        Constants.DB.user.child(ID).observeSingleEvent(of: .value, with: {snapshot in
            if let value = snapshot.value as? [String:Any]{
                if let followers = value["followers"] as? [String:Any]{
                    if let people = followers["people"] as? [String:[String:Any]]{
                        let count = people.count
                        
                        for (id, value) in people{
                            print("")
                            
                            let data = followProfileCellData()
                            data.uid = (value["UID"] as? String)!
                            
                            self.followers.append(data)
                            
                            if self.windowTitle == "Followers" && self.followers.count == count{
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
                
                if let following = value["following"] as? [String:Any]{
                    if let people = following["people"] as? [String:[String:Any]]{
                        let count = people.count
                        
                        for (id, value) in people{
                            print("")
                            
                            let data = followProfileCellData()
                            data.uid = (value["UID"] as? String)!
                            self.following.append(data)
                            
                            if self.windowTitle == "Following" && self.following.count == count{
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if windowTitle == "Followers"{
            return followers.count
        }
        else{
            return following.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        print("you are loading cell now")
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowProfileCell", for: indexPath) as! FollowProfileCell
        
        var user: followProfileCellData? = nil
        if windowTitle == "Followers"{
            user = self.followers[indexPath.row]
        }
        else{
            user = self.following[indexPath.row]
        }

        cell.data = user as! followProfileCellData
        cell.loadData()
        cell.following = self
        cell.profileImage.roundedImage()
        if cell.data.uid == AuthApi.getFirebaseUid()
        {
            cell.followOut.isHidden = true
        }
        
        Constants.DB.user.child((user?.uid)!).observeSingleEvent(of: .value, with: {snapshot in
        
            if let value = snapshot.value as? [String:Any]{
                 cell.data.username = (value["username"] as? String)!
            }
        })
//        followersCell.fullnameLabel.text = user?.fullname
//        followersCell.usernameLabel.text = user?.username
//        followersCell.profileImage.roundedImage()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var user: followProfileCellData? = nil
        if windowTitle == "Followers"{
            user = self.followers[indexPath.row]
        }
        else{
            user = self.following[indexPath.row]
        }
        
        let VC = UIStoryboard(name: "UserProfile", bundle: nil).instantiateViewController(withIdentifier: "OtherUser") as! OtherUserProfileViewController
        
        VC.otherUser = true
        VC.userID = (user?.uid)!
        dropfromTop(view: self.view)
        
        self.present(VC, animated:true, completion:nil)

    }
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
   
}
