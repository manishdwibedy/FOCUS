//
//  MapNavigationView.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/5/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class MapNavigationView: UIView {

    @IBOutlet var view: MapNavigationView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit(){
        Bundle.main.loadNibNamed("MapNavigationView", owner: self, options: nil)
        self.addSubview(self.view)
    }
    @IBAction func profileButtonPressed(_ sender: UIButton) {
        print("profile")
    }
    
    @IBAction func messagesButtonPressed(_ sender: UIButton) {
        print("message")
    }
    
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        print("search")
    }
    
    @IBAction func notificationsButtonPressed(_ sender: UIButton) {
        print("notifications")
    }

}
