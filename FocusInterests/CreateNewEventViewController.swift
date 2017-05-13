//
//  CreateNewEventViewController.swift
//  FocusInterests
//
//  Created by Amber Spadafora on 5/8/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import GooglePlaces
import FirebaseDatabase

class CreateNewEventViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var event: Event?
    var place: GMSPlace?
    let datePicker = UIDatePicker()
    let timePicker = UIDatePicker()
    let dateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    @IBOutlet weak var guestListBttn: UIButton!
    @IBOutlet weak var showGuestFriendsBttn: UIButton!
    
    
    
    // MARK: - IBOutlets
    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var eventDateTextField: UITextField!
    @IBOutlet weak var eventTimeTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    @IBOutlet weak var interestTableView: UITableView!
    
    @IBOutlet weak var publicOrPrivateSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        interestTableView.dataSource = self
        interestTableView.delegate = self
        formatTextFields()
        self.timePicker.datePickerMode = .time
        self.datePicker.datePickerMode = .date
        self.dateFormatter.dateFormat = "MMM d yyyy"
        self.timeFormatter.dateFormat = "h:mm a"
    }
    
    
    @IBAction func showGuestListBttn(_ sender: UIButton) {
        if self.guestListBttn.isSelected == false {
            self.guestListBttn.isSelected = true
            self.guestListBttn.setBackgroundImage(UIImage(named: "Check Box Selected"), for: .selected)
        } else {
            self.guestListBttn.isSelected = false
            self.guestListBttn.setBackgroundImage(UIImage(named: "Check Box Deselected"), for: .normal)
        }
        
    }
    
    @IBAction func allowForInvitingFriendsBttn(_ sender: UIButton) {
        if self.showGuestFriendsBttn.isSelected == true {
            self.showGuestFriendsBttn.isSelected = false
            self.showGuestFriendsBttn.setBackgroundImage(UIImage(named: "Check Box Deselected"), for: .normal)
        } else {
            self.showGuestFriendsBttn.isSelected = true
            self.showGuestFriendsBttn.setBackgroundImage(UIImage(named: "Check Box Selected"), for: .normal)
        }
        
    }
    
    
    @IBAction func addEventLocation(_ sender: UITextField) {
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        present(autoCompleteController, animated: true, completion: nil)
    }
    
    
    
    
    @IBAction func addEventDate(_ sender: UITextField) {
        showDatePicker()
    }
    
    @IBAction func addEventTime(_ sender: UITextField) {
        showTimePicker()
    }
    
    @IBAction func createPin(_ sender: UIButton) {
        guard let validPlace = self.place else { return }
        let locality = validPlace.addressComponents?[0].name
        let street = validPlace.addressComponents?[1].name
        let shortAddress = "\(locality!), \(street!)"
        
        guard let validLocation = self.place else { return }
        guard let validName = eventNameTextField.text else { return }
        guard let validDescrip = descriptionTextField.text else { return }
        
        guard let validDate = eventDateTextField.text else { return }
        guard let validTime = eventTimeTextField.text else { return }
        let dateString = validDate + validTime
        
        guard let creator = AuthApi.getFirebaseUid() else { return }
        
        self.event = Event(title: validName, description: validDescrip, fullAddress: validLocation.formattedAddress!, shortAddress: shortAddress, latitude: validPlace.coordinate.latitude.debugDescription, longitude: validPlace.coordinate.longitude.debugDescription, date: dateString, creator: creator)
    }
    
    func showDatePicker(){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(dateSelected))
        toolbar.setItems([done], animated: false)
        eventDateTextField.inputAccessoryView = toolbar
        eventDateTextField.inputView = datePicker
    }
    
    func showTimePicker(){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(timeSelected))
        toolbar.setItems([done], animated: false)
        eventTimeTextField.inputAccessoryView = toolbar
        eventTimeTextField.inputView = timePicker
    }
    
    func dateSelected(){
        self.eventDateTextField.text = "\(self.dateFormatter.string(from: self.datePicker.date))"
        self.view.endEditing(true)
    }
    
    func timeSelected(){
        self.eventTimeTextField.text = "\(self.timeFormatter.string(from: self.timePicker.date))"
        self.view.endEditing(true)
    }
    
    func formatTextFields(){
        let _ = [eventNameTextField, locationTextField, eventDateTextField, eventTimeTextField, descriptionTextField].map{$0.setRoundedBorder()}
        
        eventDateTextField.attributedPlaceholder = formatPlaceholder(placeholder: "Date")
        locationTextField.attributedPlaceholder = formatPlaceholder(placeholder: "Location")
        eventTimeTextField.attributedPlaceholder = formatPlaceholder(placeholder: "Time")
        eventNameTextField.attributedPlaceholder = formatPlaceholder(placeholder: "Event Name")
        descriptionTextField.attributedPlaceholder = formatPlaceholder(placeholder: "Description")
        
        eventDateTextField.setRightIcon(iconString: "Calendar-50")
        locationTextField.setRightIcon(iconString: "location")
        eventTimeTextField.setRightIcon(iconString: "Clock-25")
    }
    
    func formatPlaceholder(placeholder text: String) -> NSAttributedString {
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
        let cell = interestTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! InterestTableViewCell
        return cell
    }
}

extension CreateNewEventViewController: GMSAutocompleteViewControllerDelegate {
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        self.place = place
        self.locationTextField.text = place.formattedAddress!
        
        print("Place name: \(place.name)")
        
        print("Place address: \(place.formattedAddress)")
        
        print("Place attributions: \(place.attributions)")
        
        dismiss(animated: true, completion: nil)
    }
    
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // to do: handle error
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    
}







