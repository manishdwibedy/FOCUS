//
//  InviteUserView.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/16/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

protocol inviteUsers {
    func inviteUser()
}
class InviteUserView: UIView {
    var delegate: inviteUsers?
    
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBAction func inviteUser(_ sender: Any) {
        delegate?.inviteUser()
    }
    func hello(){
        print("hey!!")
    }
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
}
