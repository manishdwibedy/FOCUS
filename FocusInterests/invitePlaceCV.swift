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
                    newData.UID = (value?[key] as! NSDictionary)["firebaseUserId"] as! String
                    self.inviteCellData.append(newData)
                }
            }
            
            for _ in 0..<self.inviteCellData.count{
                self.selected.append(false)
            }
            self.tableView.reloadData()
        })
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
            if type == "place"{
                Constants.DB.places.child(id).child("invitations").childByAutoId().updateChildValues(["toUID":UID, "fromUID":AuthApi.getFirebaseUid()!,"time": Double(time)])
            }
            else{
                Constants.DB.event.child(id).child("invitations").childByAutoId().updateChildValues(["toUID":UID, "fromUID":AuthApi.getFirebaseUid()!,"time": Double(time)])
            }
            
             Constants.DB.user.child(UID).child("invitations").child(self.type).childByAutoId().updateChildValues(["ID":id, "time":time,"fromUID":AuthApi.getFirebaseUid()!])
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