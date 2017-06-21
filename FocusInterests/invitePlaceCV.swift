//
//  invitePlaceCV.swift
//  FocusInterests
//
//  Created by Andrew Simpson on 5/22/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class invitePlaceCV: UIViewController, UITableViewDelegate,UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    var inviteCellData = [inviteData]()

    var parentCell: SearchPlaceCell!
    var type = ""
    var id = ""
    var place: Place?
    var event: Event?
    
    var selected = [Bool]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "inviteCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "inviteCell")

        Constants.DB.user.queryLimited(toFirst: 10).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if value != nil
            {
                for (key,_) in value!
                {
                    let newData = inviteData()
                    if let UID = (value?[key] as! NSDictionary)["firebaseUserId"] as? String{
                        newData.UID = UID
                        self.inviteCellData.append(newData)
                    }
                }
            }
            
            for _ in 0..<self.inviteCellData.count{
                self.selected.append(false)
            }
            self.tableView.reloadData()
        })
        
        hideKeyboardWhenTappedAround()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func inviteButton(_ sender: Any) {
        
        
         let time = NSDate().timeIntervalSince1970
        
        let inviteUIDList = zip(selected,self.inviteCellData ).filter { $0.0 }.map { $1.UID }
        
        
         for UID in inviteUIDList{
            var name = ""
            if type == "place"{
                name = (place?.name)!
                Constants.DB.user.child(AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: { snapshot in 
                    let user = snapshot.value as? [String : Any] ?? [:]
                    
                    let fullname = user["fullname"] as? String
                    sendNotification(to: UID, title: "\(String(describing: fullname)) invited you to \(String(describing: self.place?.name))", body: "", actionType: "", type: "", item_id: "", item_name: (self.place?.name)!)
                })
            Constants.DB.places.child(id).child("invitations").childByAutoId().updateChildValues(["toUID":UID, "fromUID":AuthApi.getFirebaseUid()!,"time": Double(time)])
            }
            else{
                name = (event?.title)!
                Constants.DB.user.child(AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: { snapshot in
                    let user = snapshot.value as? [String : Any] ?? [:]
                    
                    let fullname = user["fullname"] as? String
                    sendNotification(to: UID, title: "\(String(describing: fullname)) invited you to \(String(describing: self.place?.name))", body: "", actionType: "", type: "", item_id: "", item_name: "")
                })
            Constants.DB.event.child(id).child("invitations").childByAutoId().updateChildValues(["toUID":UID, "fromUID":AuthApi.getFirebaseUid()!,"time": Double(time)])
            }
            
             Constants.DB.user.child(UID).child("invitations").child(self.type).childByAutoId().updateChildValues(["ID":id, "time":time,"fromUID":AuthApi.getFirebaseUid()!])
            
            Constants.DB.user.child(AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: { snapshot in
                
                let user = snapshot.value as? [String : Any] ?? [:]
                
                let username = user["username"] as? String
                
                sendNotification(to: UID, title: "Invitations", body: "\(username!) invited you to \(name)", actionType: "", type: "", item_id: "", item_name: "")
                
            })

            
            
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inviteCellData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:inviteCell = self.tableView.dequeueReusableCell(withIdentifier: "inviteCell") as! inviteCell!
        cell.data = inviteCellData[indexPath.row]
        
        if self.selected[indexPath.row]{
            cell.selectedUserImage.image = UIImage(named: "Interest_Filled")
            
        }
        else{
            cell.selectedUserImage.image = UIImage(named: "Interest_blank")
        }
        
        cell.parent = self
        cell.load()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell:inviteCell = self.tableView.dequeueReusableCell(withIdentifier: "inviteCell") as! inviteCell!
        tableView.deselectRow(at: indexPath, animated: false)
        
        self.selected[indexPath.row] = !self.selected[indexPath.row]
        
        if self.selected[indexPath.row]{
            cell.selectedUserImage.image = UIImage(named: "Interest_Filled")
            
        }
        else{
            cell.selectedUserImage.image = UIImage(named: "Interest_blank")
        }
        
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
        
    }

}
