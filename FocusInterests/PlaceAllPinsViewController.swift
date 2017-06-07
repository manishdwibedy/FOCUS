//
//  PlaceAllPinsViewController.swift
//  FocusInterests
//
//  Created by Andrew Simpson on 6/6/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class PlaceAllPinsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var data = [NSDictionary]()
    var placeID = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        Constants.DB.pins.queryOrdered(byChild: "formattedAddress").queryEqual(toValue: placeID).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if value != nil
            {
                for (key,_) in value!
                {
                    self.data.append(value?[key] as! NSDictionary)
                }
            }
            self.tableView.reloadData()
        })

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = Bundle.main.loadNibNamed("PinTableViewCell", owner: self, options: nil)?.first as! PinTableViewCell
        cell.data = data[indexPath.row]
        cell.comment.text = data[indexPath.row]["pin"] as! String
        cell.loadLikes()
        //cell.focus.text = ""
        //cell.time.text = ""
        Constants.DB.user.child(data[indexPath.row]["fromUID"] as! String).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if value != nil
            {
                cell.username.text = value?["username"] as? String
                
            }
            
        })
        cell.parentVC = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    

    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

}
