//
//  SendInvitationsViewController.swift
//  FocusInterests
//
//  Created by Amber Spadafora on 5/16/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import FirebaseStorage

class SendInvitationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var inviteFromContactsBttn: UIButton!
    @IBOutlet weak var createEventBttn: UIButton!
    @IBOutlet weak var friendsTableView: UITableView!
    var event: Event?
    var image: Data?
    var selectedFriend = [Bool]()

    override func viewDidLoad() {
        super.viewDidLoad()
        formatNavBar()
        formatSubViews()
        self.friendsTableView.delegate = self
        self.friendsTableView.dataSource = self
        
        for _ in 0...3{
            selectedFriend.append(false)
        }
    }
    
    
    @IBAction func inviteFromContacts(_ sender: UIButton) {
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
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = friendsTableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! InviteFriendTableViewCell
        
        cell.friendIconImageView.layer.cornerRadius = 50.0
        cell.friendIconImageView.clipsToBounds = true
        
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
