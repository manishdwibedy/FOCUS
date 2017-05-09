//
//  CreateNewEventViewController.swift
//  FocusInterests
//
//  Created by Amber Spadafora on 5/8/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class CreateNewEventViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - IBOutlets
    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var eventDateTextField: UITextField!
    @IBOutlet weak var eventTimeTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    @IBOutlet weak var interestTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        interestTableView.dataSource = self
        interestTableView.delegate = self
        interestTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        formatTextFields()
    }
    
    func formatTextFields(){
        let _ = [eventNameTextField, locationTextField, eventDateTextField, eventTimeTextField, descriptionTextField].map{$0.setRoundedBorder()}
        
        eventDateTextField.attributedPlaceholder = formatAttributedPlaceholder(placeholder: "Date")
        locationTextField.attributedPlaceholder = formatAttributedPlaceholder(placeholder: "Location")
        eventTimeTextField.attributedPlaceholder = formatAttributedPlaceholder(placeholder: "Time")
        eventNameTextField.attributedPlaceholder = formatAttributedPlaceholder(placeholder: "Event Name")
        descriptionTextField.attributedPlaceholder = formatAttributedPlaceholder(placeholder: "Description")
        
        
        locationTextField.rightViewMode = UITextFieldViewMode.always
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        let image = UIImage(named: "location")
        imageView.image = image
        imageView.contentMode = .center
        if let size = imageView.image?.size {
            imageView.frame = CGRect(x: 0.0, y: 0.0, width: size.width + 10.0, height: size.height)
        }
        locationTextField.rightView = imageView
        
    }
    
    func formatAttributedPlaceholder(placeholder text: String) -> NSAttributedString {
        let newString = NSAttributedString(string: text, attributes: [NSForegroundColorAttributeName: UIColor.white])
        return newString
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = interestTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        return cell
    }

}
