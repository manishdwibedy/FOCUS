//
//  PhotoInputView.swift
//  FocusInterests
//
//  Created by Christopher Gilardi on 6/28/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation
import UIKit

class PhotoInputView : UIView {
    
    @IBOutlet var view: UIView!
    
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var cameraRollButton: UIButton!
    
    override init(frame : CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit(){
        Bundle.main.loadNibNamed("PhotoInputView", owner: self, options: nil)
        self.addSubview(self.view)
        print(self.view.frame.size)
        print(self.frame.size)
        self.view.frame.size = CGSize(width: self.frame.width, height: self.frame.height)
        self.view.layoutIfNeeded()
        
        self.layer.cornerRadius = 15
        self.clipsToBounds = true
        
        styleButtons()
    }
    
    private func styleButtons() {
        takePhotoButton.layer.cornerRadius = 10
        cameraRollButton.layer.cornerRadius = 10
    }
    
    @IBAction func cameraRollButtonPressed(_ sender: UIButton) {
    }
    
    
    
}
