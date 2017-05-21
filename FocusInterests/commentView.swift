//
//  commentView.swift
//  FocusInterests
//
//  Created by Andrew Simpson on 5/10/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import Firebase

class commentView: UIView {
    @IBOutlet var view: UIView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var commentTextView: UITextView!
    let ref = FIRDatabase.database().reference()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit(){
        Bundle.main.loadNibNamed("commentView", owner: self, options: nil)
        self.addSubview(self.view)
        
        userImage.layer.cornerRadius = userImage.frame.width/2
        userImage.clipsToBounds = true
        
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 0.7
        view.layer.cornerRadius = 6
        view.clipsToBounds = true
        
    }
    
    func addData(image:UIImage, fromUID: String, commment: String)
    {
        //userImage.image = image
        ref.child("users").child(fromUID).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if value != nil
            {
                self.commentTextView.text = (value?["username"] as? String)! + "\t" + commment
            }
            
        })
    }


    

}
