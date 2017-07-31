//
//  InvitePopoverView.swift
//  FocusInterests
//
//  Created by Alex Jang on 7/28/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class InvitePopoverView: UIView {

    @IBOutlet weak var chooseDateButton: UIButton!
    @IBOutlet weak var chooseTimeButton: UIButton!
    
    let datePicker = UIDatePicker()
    let timePicker = UIDatePicker()
    let dateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBAction func timeButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func dateButtonPressed(_ sender: Any) {
        
    }

    @IBAction func donePressed(_ sender: Any) {
    }
}
