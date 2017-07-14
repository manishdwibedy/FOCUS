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
        
        self.addButton.setImage(UIImage(named: "plus.png"), for: .normal)
        self.addButton.setImage(UIImage(named: "GreenCheck.png"), for: .selected)
        
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
