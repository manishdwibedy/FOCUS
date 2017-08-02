//
//  InterestStackViewLabel.swift
//  FocusInterests
//
//  Created by Alex Jang on 7/13/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class InterestStackViewLabel: UIView{

    @IBOutlet weak var interestLabelImage: UIImageView!
    @IBOutlet weak var interestLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet var view: UIView!
    
    override init(frame : CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
    }
    
    func setupView(){
        Bundle.main.loadNibNamed("InterestStackViewLabel", owner: self, options: nil)
//        self.view.frame.size.width = self.frame.size.width
//        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(view)
        
        self.addButton.setImage(#imageLiteral(resourceName: "White_Plus_Sign"), for: .normal)
        self.addButton.setImage(#imageLiteral(resourceName: "Green_check_sign"), for: .selected)
        
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBAction func plusButtonPressed(_ sender: Any) {
        Constants.DB.user_interests.child(interestLabel.text!).childByAutoId().setValue(["UID": AuthApi.getFirebaseUid()])
        
        var user_interests = AuthApi.getInterests()!.components(separatedBy: ",")
        user_interests.append("\(interestLabel.text!)-1")
        Constants.DB.user.child(AuthApi.getFirebaseUid()!).updateChildValues(["interests": user_interests.joined(separator: ",")])
        
        AuthApi.set(interests: user_interests.joined(separator: ","))
        
        self.addButton.setImage(#imageLiteral(resourceName: "Green_check_sign"), for: .normal)
        self.addButton.isSelected = !self.addButton.isSelected
    }

}
