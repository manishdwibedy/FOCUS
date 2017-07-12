//
//  FollowYourFriendsView.swift
//  FocusInterests
//
//  Created by Alex Jang on 7/12/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class FollowYourFriendsView: UIView, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var followTableView: UITableView!
//    @IBOutlet var contentView: UIView!
    @IBOutlet weak var followButton: UIButton!
    
    override init(frame : CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
    }
    
    func setupView(){
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        addSubview(view)

        self.followButton.roundCorners(radius: 6.0)
        
        self.followTableView.dataSource = self
        self.followTableView.delegate = self
        
        let followSpecificFriendsNib = UINib(nibName: "FollowYourSpecificFriendTableViewCell", bundle: nil)
        let followAllFriendsNib = UINib(nibName: "FollowAllYourFriendsTableViewCell", bundle: nil)
        
        self.followTableView.register(followSpecificFriendsNib, forCellReuseIdentifier: "followSpecificFriendCell")
        self.followTableView.register(followAllFriendsNib, forCellReuseIdentifier: "followAllFriendsCell")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }else{
            return 6
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if indexPath.section == 0 {
            let allFriendsCell = self.followTableView.dequeueReusableCell(withIdentifier: "followAllFriendsCell", for: indexPath) as! FollowAllYourFriendsTableViewCell
            cell = allFriendsCell
        }else if indexPath.section == 1{
            let specificFriendsCell = self.followTableView.dequeueReusableCell(withIdentifier: "followSpecificFriendCell", for: indexPath) as! FollowYourSpecificFriendTableViewCell
            specificFriendsCell.usernameLabel.text = "Username"
            specificFriendsCell.fullnameLabel.text = "Firstname Lastname"
            cell = specificFriendsCell
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            return 40
        }else{
            return 55
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
