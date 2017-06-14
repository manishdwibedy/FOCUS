//
//  SelectedTimeTableViewCell.swift
//  FocusInterests
//
//  Created by Alex Jang on 6/6/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class SelectedTimeTableViewCell: UITableViewCell {

    var contactListArray = [String]() //will need to change this to CNContacts later
    @IBOutlet weak var selectedTime: UIButton!
    
    let datePicker = UIDatePicker()
    let timePicker = UIDatePicker()
    let dateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupBottomBorderForSelectedTimeButton()
        
        self.timePicker.datePickerMode = .time
        self.timePicker.minuteInterval = 5
        self.datePicker.datePickerMode = .date
        self.dateFormatter.dateFormat = "MMM d yyyy"
        self.timeFormatter.dateFormat = "h:mm a"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func timePressed(_ sender: Any) {
        
        datePicker.backgroundColor = UIColor.lightGray
        
        datePicker.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: datePicker.frame.height)
        
        self.addSubview(datePicker)
        
    }
    
    
    
    func setupBottomBorderForSelectedTimeButton(){
        let bottomBorder: CALayer = CALayer()
        bottomBorder.borderWidth = 1;
        bottomBorder.borderColor = UIColor(red: 122/255.0, green: 201/255.0, blue: 1/255.0, alpha: 1.0).cgColor
        
    }
}
