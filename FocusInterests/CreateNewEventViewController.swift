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

class CreateNewEventViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var publicLabel: UILabel!
    @IBOutlet weak var privateLabel: UILabel!
    
    var event: Event?
    var place: GMSPlace?
    let datePicker = UIDatePicker()
    let timePicker = UIDatePicker()
    let dateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    var checkInterests = [Bool]()
    let validatedFields = true
    
    @IBOutlet weak var canInviteFriendsLabel: UILabel!
    @IBOutlet weak var showGuestListLabel: UILabel!
    
    @IBOutlet weak var guestListBttn: UIButton!
    @IBOutlet weak var showGuestFriendsBttn: UIButton!
    
    // MARK: - IBOutlets
    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var eventDateTextField: UITextField!
    @IBOutlet weak var eventTimeTextField: UITextField!
    @IBOutlet weak var eventDescriptionTextView: UITextView!
    @IBOutlet weak var interestTableView: UITableView!
    @IBOutlet weak var publicOrPrivateSwitch: UISwitch!
    @IBOutlet weak var guestSettingsStackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var interestTopConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        interestTableView.dataSource = self
        interestTableView.delegate = self
        formatTextFields()
        setTextFieldDelegates()
        self.interestTableView.delaysContentTouches = false
        self.timePicker.datePickerMode = .time
        self.datePicker.datePickerMode = .date
        self.dateFormatter.dateFormat = "MMM d yyyy"
        self.timeFormatter.dateFormat = "h:mm a"
        
        eventDescriptionTextView.delegate = self
        eventDescriptionTextView.text = "Description"
        eventDescriptionTextView.textColor = .white
        
        let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: self.interestTableView.bounds.size.width, height: self.interestTableView.bounds.size.height))
        backgroundView.backgroundColor = UIColor.lightGray
        interestTableView.backgroundView = backgroundView
        
        
        
        for _ in 0..<Constants.interests.interest_list.count{
            checkInterests.append(false)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let cached = Event.fetchEvent() {
            self.event = cached
            eventNameTextField.text = cached.title
            eventDescriptionTextView.text = cached.eventDescription! ?? ""
            locationTextField.text = cached.fullAddress
            
            let dateTime = cached.date?.components(separatedBy: ",")
            eventDateTextField.text = dateTime?[0]
            eventTimeTextField.text = dateTime?[0]
            
            let interests = cached.category?.components(separatedBy: ",")
            
            for (index, interest) in Constants.interests.interest_list.enumerated(){
                if (interests?.contains(interest.name!))!{
                    checkInterests[index] = true
                }
            }
            interestTableView.reloadData()
            Event.clearCache()
        }
    }
    
    func setTextFieldDelegates(){
        let _ = [eventNameTextField, locationTextField, eventDateTextField, eventTimeTextField].map{$0.delegate = self}
    }
    
    @IBAction func PrivOrPubSwtchChanged(_ sender: UISwitch) {
        if sender.isOn {
            self.privateLabel.textColor = UIColor.primaryGreen()
            self.publicLabel.textColor = UIColor.white
            
            guestSettingsStackView.isHidden = false
            interestTopConstraint.constant = 16
            
        } else /* the switch is set to public */ {
            self.privateLabel.textColor = UIColor.white
            self.publicLabel.textColor = UIColor.primaryGreen()
            
            guestSettingsStackView.isHidden = true
            interestTopConstraint.constant = -70
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chooseIcon" && validatedFields {
            if self.event != nil{
                guard let name = eventNameTextField.text, !name.isEmpty else{
                    presentNotification(title: "Choose a name", message: "Please choose a name for this event.")
                    return
                }
                
                let validDescrip = eventDescriptionTextView.text ?? ""
                
                guard let validDate = eventDateTextField.text, !validDate.isEmpty,
                    let validTime = eventTimeTextField.text, !validTime.isEmpty else {
                        presentNotification(title: "Choose a date and time.", message: "Please choose a date and time for this event.")
                        return
                }
                let dateString = "\(validDate), \(validTime)"
                guard let creator = AuthApi.getFirebaseUid() else { return }
                
                let interests = zip(checkInterests,Constants.interests.interest_list ).filter { $0.0 }.map { $1.name! }
                
                guard !interests.isEmpty else{
                    presentNotification(title: "Choose a interest", message: "Please choose atleast one interest for this event.")
                    return
                }
                self.event?.title = eventNameTextField.text
                self.event?.eventDescription = validDescrip
                self.event?.date = dateString
                self.event?.category = interests.joined(separator: ";")
                
                
            }
            else{
                guard let validPlace = self.place else {
                    presentNotification(title: "Choose a location", message: "Please choose a location for this event.")
                    return
                }
                let locality = validPlace.addressComponents?[0].name
                let street = validPlace.addressComponents?[1].name
                let shortAddress = "\(locality!), \(street!)"
                
                
                guard let name = eventNameTextField.text, !name.isEmpty else{
                    presentNotification(title: "Choose a name", message: "Please choose a name for this event.")
                    return
                }
                
                let validDescrip = eventDescriptionTextView.text ?? ""
                
                guard let validDate = eventDateTextField.text, !validDate.isEmpty,
                    let validTime = eventTimeTextField.text, !validTime.isEmpty else {
                        presentNotification(title: "Choose a date and time.", message: "Please choose a date and time for this event.")
                        return
                }
                let dateString = "\(validDate), \(validTime)"
                guard let creator = AuthApi.getFirebaseUid() else { return }
                
                let interests = zip(checkInterests,Constants.interests.interest_list ).filter { $0.0 }.map { $1.name! }
                
                guard !interests.isEmpty else{
                    presentNotification(title: "Choose a interest", message: "Please choose atleast one interest for this event.")
                    return
                }
                
                
                self.event = Event(title: name, description: "", fullAddress: validPlace.formattedAddress!, shortAddress: shortAddress, latitude: validPlace.coordinate.latitude.debugDescription, longitude: validPlace.coordinate.longitude.debugDescription, date: dateString, creator: creator, category: interests.joined(separator: ";"))
            
            }
            
            Event.cacheEvent(event: self.event!)
            let destination = segue.destination as! EventIconViewController
            destination.event = self.event
            
            
            let _ = [eventNameTextField, eventDateTextField, eventTimeTextField, locationTextField].map{$0.text = nil}
        }
    }
    
    private func presentNotification(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .destructive, handler: nil)
        alert.view.tintColor = UIColor.primaryGreen()
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func showGuestListBttn(_ sender: UIButton) {
        if self.guestListBttn.isSelected == false {
            self.guestListBttn.isSelected = true
            self.guestListBttn.setBackgroundImage(UIImage(named: "Interest_filled"), for: .selected)
        } else {
            self.guestListBttn.isSelected = false
            self.guestListBttn.setBackgroundImage(UIImage(named: "Interest_blank"), for: .normal)
        }
    }
    
    @IBAction func allowForInvitingFriendsBttn(_ sender: UIButton) {
        if self.showGuestFriendsBttn.isSelected == true {
            self.showGuestFriendsBttn.isSelected = false
            self.showGuestFriendsBttn.setBackgroundImage(UIImage(named: "Interest_blank"), for: .normal)
        } else {
            self.showGuestFriendsBttn.isSelected = true
            self.showGuestFriendsBttn.setBackgroundImage(UIImage(named: "Interest_filled"), for: .normal)
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
        let _ = [eventNameTextField, locationTextField, eventDateTextField, eventTimeTextField, eventDescriptionTextView].map{
            self.addRoundBorder(view: $0)
        }
        
        eventDateTextField.attributedPlaceholder = formatPlaceholder(placeholder: "Date")
        locationTextField.attributedPlaceholder = formatPlaceholder(placeholder: "Location")
        eventTimeTextField.attributedPlaceholder = formatPlaceholder(placeholder: "Time")
        eventNameTextField.attributedPlaceholder = formatPlaceholder(placeholder: "Event Name")
        
        eventDateTextField.setRightIcon(iconString: "Calendar-50")
        locationTextField.setRightIcon(iconString: "location")
        eventTimeTextField.setRightIcon(iconString: "Clock-25")
    }
    
    func formatPlaceholder(placeholder text: String) -> NSAttributedString {
        let newString = NSAttributedString(string: text, attributes: [NSForegroundColorAttributeName: UIColor.white])
        return newString
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return checkInterests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = interestTableView.dequeueReusableCell(withIdentifier: "selectedInterest", for: indexPath) as! InterestTableViewCell
        
        cell.selectedInterestLabel.text = Constants.interests.interest_list[indexPath.row].name
        
        if checkInterests[indexPath.row]{
            cell.checkedInterest.image = UIImage(named: "Interest_Filled")
        }
        else{
            cell.checkedInterest.image = UIImage(named: "Interest_blank")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = interestTableView.dequeueReusableCell(withIdentifier: "selectedInterest", for: indexPath) as! InterestTableViewCell
        tableView.deselectRow(at: indexPath, animated: false)
        
        checkInterests[indexPath.row] = !checkInterests[indexPath.row]
        if checkInterests[indexPath.row]{
            cell.checkedInterest.image = UIImage(named: "Interest_Filled")
        }
        else{
            cell.checkedInterest.image = UIImage(named: "Interest_blank")
        }
        interestTableView.reloadData()
    }
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        Event.clearCache()
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    @IBAction func unwindFromCreateEventIcon(sender: UIStoryboardSegue){}
    
    func addRoundBorder(view: Any){
        if let textField = view as? UITextField{
            textField.setRoundedBorder()
        }
        else if let textView = view as? UITextView{
            textView.layer.borderColor = UIColor.white.cgColor
            textView.layer.borderWidth = 1.0
            textView.layer.cornerRadius = 15.00
        }
    }
    
    @IBAction func chooseIcon(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "chooseIcon", sender: nil)
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

extension CreateNewEventViewController {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        if (textView.text == "Description")
        {
            textView.text = ""
        }
        textView.becomeFirstResponder() //Optional
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        if (textView.text == "")
        {
            textView.text = "Description"
        }
        textView.resignFirstResponder()
    }
    
}







