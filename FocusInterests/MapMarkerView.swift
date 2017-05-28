//
//  MapMarkerView.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/27/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import BadgeSwift

class MapMarkerView: UIView {
    @IBOutlet var view: UIView!

    @IBOutlet weak var markerImage: UIImageView!
    @IBOutlet weak var markerBadge: BadgeSwift!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit(){
        Bundle.main.loadNibNamed("MapMarkerView", owner: self, options: nil)
        self.addSubview(self.view)
        
        self.view.addSubview(markerImage)
        self.view.addSubview(markerBadge)
        
//        userImage.layer.cornerRadius = userImage.frame.width/2
//        userImage.clipsToBounds = true
//        
//        view.layer.borderColor = UIColor.white.cgColor
//        view.layer.borderWidth = 0.7
//        view.layer.cornerRadius = 6
//        view.clipsToBounds = true
        
    }

}
