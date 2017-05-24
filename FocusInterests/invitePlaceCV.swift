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
    var inviteUIDList = [String]()
    var parentCell: SearchPlaceCell!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "inviteCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "inviteCell")

        Constants.DB.user.child(AuthApi.getFirebaseUid()!).child("following").child("people").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if value != nil
            {
                for (key,_) in value!
                {
                    let newData = inviteData()
                    newData.UID = (value?[key] as! NSDictionary)["UID"] as! String
                    self.inviteCellData.append(newData)
                }
            }
            self.tableView.reloadData()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func backButton(_ sender: Any) {
        self.inviteUIDList.removeAll()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func inviteButton(_ sender: Any) {
        
        
         let time = NSDate().timeIntervalSince1970
         for UID in inviteUIDList
             {
             Constants.DB.following_place.child(parentCell.placeID).child("invitations").childByAutoId().updateChildValues(["toUID":UID, "fromUID":AuthApi.getFirebaseUid()!,"time": Double(time)])
             
             Constants.DB.user.child(UID).child("invitations").child("places").childByAutoId().updateChildValues(["placeID":parentCell.placeID, "time":time,"fromUID":AuthApi.getFirebaseUid()!])
        }
        
        self.dismiss(animated: true, completion: nil)
        
 
    }
    
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inviteCellData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:inviteCell = self.tableView.dequeueReusableCell(withIdentifier: "inviteCell") as! inviteCell!
        cell.data = inviteCellData[indexPath.row]
        cell.parent = self
        cell.load()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
        
    }

}
