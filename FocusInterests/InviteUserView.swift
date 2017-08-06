//
//  InviteUserView.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/16/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

protocol InviteUsers {
    func inviteUser(name: String)
}
class InviteUserView: UIView {
    var delegate: InviteUsers?
    
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet var view: InviteUserView!

    var user: User? = nil
    var parentVC: PinViewController? = nil
    var placeVC: PlaceViewController? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        load()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        load()
    }
    
    func load() {
        Bundle.main.loadNibNamed("InviteUserView", owner: self, options: nil)
        self.image.roundedImage()
        self.inviteButton.roundCorners(radius: 5.0)
        self.view.addSubview(userName)
        self.view.addSubview(image)
        self.view.addSubview(inviteButton)
        
        var tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.showProfile(sender:)))
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)
        
        self.addSubview(self.view)
    }
    
    @IBAction func invite(_ sender: UIButton) {
        print("sent user invite")
        delegate?.inviteUser(name: self.userName.text!)
    }
    
    func showProfile(sender: UITapGestureRecognizer)
    {
        let VC = UIStoryboard(name: "UserProfile", bundle: nil).instantiateViewController(withIdentifier: "OtherUser") as! OtherUserProfileViewController
        
        VC.otherUser = true
        VC.userID = (user?.uuid)!
        
        placeVC?.present(VC, animated: true, completion: nil)
        dropfromTop(view: self.view)
    }
}
