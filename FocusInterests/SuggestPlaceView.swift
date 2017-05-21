//
//  SuggestPlaceView.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/17/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class SuggestPlaceView: UIView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet var view: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        load()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        load()
    }
    
    func load() {
        Bundle.main.loadNibNamed("SuggestPlaceView", owner: self, options: nil)
        
        self.view.addSubview(name)
        self.view.addSubview(imageView)
        self.addSubview(self.view)
    }

}
