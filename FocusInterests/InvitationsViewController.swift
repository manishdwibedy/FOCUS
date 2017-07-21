//
//  InvitationsViewController.swift
//  FocusInterests
//
//  Created by Alex Jang on 7/20/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import SDWebImage

class InvitationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var inviteTableView: UITableView!
    
    var invArray = [FocusNotification]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = Constants.color.navy
        self.navBar.titleTextAttributes = Constants.navBar.attrs
        self.navBar.barTintColor = Constants.color.navy
        self.inviteTableView.delegate = self
        self.inviteTableView.dataSource = self
        
        let inviteNib = UINib(nibName: "NotificationFeedCellTableViewCell", bundle: nil)
        self.inviteTableView.register(inviteNib, forCellReuseIdentifier: "inviteCell")
        
        self.inviteTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return invArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let inviteCell = tableView.dequeueReusableCell(withIdentifier: "inviteCell", for: indexPath) as! NotificationFeedCellTableViewCell
//        inviteCell.parentVC = self
        inviteCell.isFeed = false
        
        inviteCell.setupCell(notif: self.invArray[indexPath.row])
        
        
        //          MARK: Message button
        inviteCell.seeYouThereButton.roundCorners(radius: 5.0)
        
        //        MARK: Accepted button
        inviteCell.nextTimeButton.roundCorners(radius: 5.0)
        
        //        MARK: User Profile Image
        inviteCell.userProfilePic.layer.borderWidth = 1
        inviteCell.userProfilePic.layer.borderColor = Constants.color.green.cgColor
        inviteCell.userProfilePic.roundButton()
        
        //        MARK: Username Label
        //        inviteCell.userNameLabel.text = "arya invited you to the Rose Bowl"
        
        //        MARK: Location Image
        inviteCell.locationImage.layer.borderWidth = 1
        inviteCell.locationImage.layer.borderColor = Constants.color.lightBlue.cgColor
        inviteCell.locationImage.roundedImage()
        
        //        inviteCell.timeLabel.text = "31 min"
        
        return inviteCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
