//
//  attendeeVC.swift
//  FocusInterests
//
//  Created by Andrew Simpson on 5/15/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import Firebase
class attendeeVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var navTitle: UINavigationItem!
    @IBOutlet weak var navBackOut: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var attendingLabel: UILabel!
    
    var parentEvent: Event?
    var parentVC: EventDetailViewController?
    var attendeeList = NSMutableArray()
    let ref = Database.database().reference()
    var guestList: [String:[String:String]]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clear
        tableView.backgroundView?.backgroundColor = UIColor.clear
        let nib = UINib(nibName: "FollowProfileCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "FollowProfileCell")
        
        navTitle.title = parentEvent?.title
        
        self.attendingLabel.text = "\((guestList?.count)!) Attending"
        
        let fullRef = ref.child("events").child((parentEvent?.id)!).child("attendingList")
        
        for (key,_) in guestList!
        {
            let newData = followProfileCellData()
            newData.uid = (guestList?[key] as! NSDictionary)["UID"] as! String
            self.attendeeList.add(newData)
        }
    
        hideKeyboardWhenTappedAround()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
   
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attendeeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:FollowProfileCell = self.tableView.dequeueReusableCell(withIdentifier: "FollowProfileCell") as! FollowProfileCell!
        cell.data = attendeeList[indexPath.row] as! followProfileCellData
        cell.loadData()
        cell.parentVC = self
        cell.profileImage.roundedImage()
        if cell.data.uid == AuthApi.getFirebaseUid()
        {
            cell.followOut.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
        
    }
    
    @IBAction func navBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
   

}
