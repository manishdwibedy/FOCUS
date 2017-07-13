//
//  FollowYourFriendsView.swift
//  FocusInterests
//
//  Created by Alex Jang on 7/12/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import SDWebImage

class FollowYourFriendsView: UIView, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var followTableView: UITableView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var followButton: UIButton!
    
    var users = [FollowNewUser]()
    override init(frame : CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
    }
    
    let manager = SDWebImageManager.shared()
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
        
        self.followTableView.reloadData()

        manager?.setValue("Bearer \(AuthApi.getGoogleToken()!)", forKey: "authorization")
        manager?.setValue("3.0", forKey: "GData-Version")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }else{
            return self.users.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if indexPath.section == 0 {
            let allFriendsCell = self.followTableView.dequeueReusableCell(withIdentifier: "followAllFriendsCell", for: indexPath) as! FollowAllYourFriendsTableViewCell
            cell = allFriendsCell
        }else if indexPath.section == 1{
            let specificFriendsCell = self.followTableView.dequeueReusableCell(withIdentifier: "followSpecificFriendCell", for: indexPath) as! FollowYourSpecificFriendTableViewCell
            
            let user = self.users[indexPath.row]
            specificFriendsCell.usernameLabel.text = user.email
            specificFriendsCell.fullnameLabel.text = user.fullname
            
            
            manager?.downloadImage(with: URL(string: user.image), options: .continueInBackground, progress: {
                (receivedSize :Int, ExpectedSize :Int) in
                
            }, completed: {
                (image : UIImage?, error : Error?, cacheType : SDImageCacheType, finished : Bool, url : URL?) in
                
                if image != nil && finished{
                    specificFriendsCell.usernameImage.image = image
                    self.followTableView.reloadData()
                }
            })
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
    
    @IBAction func closeButton(_ sender: Any) {
        self.contentView.isHidden = true
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
