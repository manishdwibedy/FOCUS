//
//  FollowingViewController.swift
//  FocusInterests
//
//  Created by Alex Jang on 6/5/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class FollowersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var inviteContactsButton: UIButton!
    @IBOutlet weak var inviteFbFriendsButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.inviteContactsButton.roundCorners(radius: 9.0)
        self.inviteFbFriendsButton.roundCorners(radius: 9.0)
        
        let nib = UINib(nibName: "FollowProfileCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "FollowProfileCell")
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
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        print("you are loading cell now")
        let followersCell = tableView.dequeueReusableCell(withIdentifier: "FollowProfileCell", for: indexPath) as! FollowProfileCell
        
        return followersCell
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
