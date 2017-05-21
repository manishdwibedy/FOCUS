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
       
        self.view.addSubview(userName)
        self.view.addSubview(image)
        self.view.addSubview(inviteButton)
        self.addSubview(self.view)
    }
    
    @IBAction func invite(_ sender: UIButton) {
        print("he")
        delegate?.inviteUser(name: self.userName.text!)
    }    
}
