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
import GeoFire
import SCLAlertView
   
class CreateNewEventViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate, UISearchBarDelegate{
    
    @IBOutlet weak var interestListView: UIView!
    @IBOutlet var parentView: UIView!
    @IBOutlet weak var interestListLabel: UILabel!
    @IBOutlet weak var interestNextButton: UIButton!
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var publicLabel: UILabel!
    @IBOutlet weak var privateLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var event: Event?
    var place: GMSPlace?
    let datePicker = UIDatePicker()
    let timePicker = UIDatePicker()
    let dateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    
    // Interests
    var checkInterests = [Bool]()
    var filteredCheck = [Bool]()
    var interests = [String]()
    var filteredInterest = [String]()
    
    let validatedFields = true
    
    @IBOutlet weak var canInviteFriendsLabel: UILabel!
    @IBOutlet weak var showGuestListLabel: UILabel!
    
    @IBOutlet weak var guestListBttn: UIButton!
    @IBOutlet weak var showGuestFriendsBttn: UIButton!
    
    @IBOutlet weak var interestTableBottom: NSLayoutConstraint!
    // MARK: - IBOutlets
    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var eventDateTextField: UITextField!
    @IBOutlet weak var eventTimeTextField: UITextField!
    @IBOutlet weak var eventEndTimeTextField: UITextField!
    @IBOutlet weak var eventPriceTextView: UITextField!
    @IBOutlet weak var eventDescriptionTextView: UITextView!
    
    
    @IBOutlet weak var interestTableView: UITableView!
    @IBOutlet weak var publicOrPrivateSwitch: UISwitch!
    @IBOutlet weak var guestSettingsStackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var interestTopConstraint: NSLayoutConstraint!
    
//    TOOLBARS
    
    var nextButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(CreateNewEventViewController.keyboardNextButton))
    var previousButton = UIBarButtonItem(title: "Previous", style: .plain, target: self, action: #selector(CreateNewEventViewController.keyboardPreviousButton))
    var flexibleSpaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    var fixedSpaceButton = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
//    var dateDoneButon = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(CreateNewEventViewController.dateSelected))
    var startTimeDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(CreateNewEventViewController.startTimeSelected))
    var endTimeDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(CreateNewEventViewController.endTimeSelected))
    var priceDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(CreateNewEventViewController.priceSelected))
    
    
    // start and end time
    var startTime: Date? = nil
    var endTime: Date? = nil
    
    lazy var dateToolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.sizeToFit()
        
        toolbar.setItems([self.fixedSpaceButton, self.previousButton, self.fixedSpaceButton, self.nextButton, self.flexibleSpaceButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        return toolbar
    }()
    
    lazy var startTimeToolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.sizeToFit()
        
        toolbar.setItems([self.fixedSpaceButton, self.previousButton, self.fixedSpaceButton, self.nextButton, self.flexibleSpaceButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        return toolbar
    }()
    
    lazy var endTimeToolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.sizeToFit()
        
        toolbar.setItems([self.fixedSpaceButton, self.previousButton, self.fixedSpaceButton, self.nextButton, self.flexibleSpaceButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        return toolbar
    }()
    
    lazy var priceToolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.sizeToFit()
        
        toolbar.setItems([self.fixedSpaceButton, self.previousButton, self.fixedSpaceButton, self.nextButton, self.flexibleSpaceButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        return toolbar
    }()
    
    //this toolbar is for the name, price, and description textfields
    lazy var nextPrevToolbar: UIToolbar = {
        var toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.sizeToFit()
        
        toolbar.setItems([self.fixedSpaceButton, self.previousButton, self.fixedSpaceButton, self.nextButton, self.flexibleSpaceButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        return toolbar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.interestTableView.dataSource = self
        self.interestTableView.delegate = self
        self.searchBar.delegate = self
        self.searchBar.tintColor = UIColor.white
        self.searchBar.returnKeyType = .done
        
        var textFieldInsideSearchBar = self.searchBar.value(forKey: "searchField") as? UITextField
        
        textFieldInsideSearchBar?.textColor = UIColor.white
        
        formatTextFields()
        setTextFieldDelegates()
        self.interestTableView.delaysContentTouches = false
        self.timePicker.datePickerMode = .time
        self.timePicker.minuteInterval = 5
        self.datePicker.datePickerMode = .date
        self.dateFormatter.dateFormat = "MMM d yyyy"
        self.timeFormatter.dateFormat = "h:mm a"
        
        eventNameTextField.delegate = self
        
        eventDescriptionTextView.delegate = self
        eventDescriptionTextView.text = "Description"
        eventDescriptionTextView.textColor = .white
        
        let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: self.interestTableView.bounds.size.width, height: self.interestTableView.bounds.size.height))
        backgroundView.backgroundColor = UIColor.clear
        interestTableView.backgroundView = backgroundView
        
        for _ in 0..<Constants.interests.interests.count{
            checkInterests.append(false)
            filteredCheck.append(false)
        }
        
        self.filteredInterest = Constants.interests.interests
        self.interests = self.filteredInterest
        self.interestNextButton.roundCorners(radius: 5.0)
        
        self.interestListView.isHidden = true
        hideKeyboardWhenTappedAround()
        
        let attrs = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "Avenir-Black", size: 18)!
        ]
        
        navBar.titleTextAttributes = attrs
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let cached = Event.fetchEvent() {
            self.event = cached
            eventNameTextField.text = cached.title
            eventDescriptionTextView.text = cached.eventDescription! ?? ""
            locationTextField.text = cached.fullAddress
            
            let dateTime = cached.date?.components(separatedBy: ",")
            eventDateTextField.text = dateTime?[0]
            eventTimeTextField.text = dateTime?[1]
            eventEndTimeTextField.text = cached.endTime
            eventPriceTextView.text = String(describing: cached.price)
            
            let interests = cached.category?.components(separatedBy: ",")
            
            for (index, interest) in Constants.interests.interests.enumerated(){
                if (interests?.contains(interest))!{
                    checkInterests[index] = true
                }
            }
            interestTableView.reloadData()
            Event.clearCache()
        }
        registerKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterKeyboardNotifications()

    }
    
    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardDidShow(notification:)),
                                               name: NSNotification.Name.UIKeyboardDidShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillHide(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
    }
    
    func unregisterKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setTextFieldDelegates(){
        let _ = [eventNameTextField, locationTextField, eventDateTextField, eventTimeTextField, eventEndTimeTextField, eventPriceTextView].map{$0.delegate = self}
    }
    
    func keyboardDidShow(notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardInfo = userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue
        let keyboardSize = keyboardInfo.cgRectValue.size
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height + 200, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    
    @IBAction func PrivOrPubSwtchChanged(_ sender: UISwitch) {
        if sender.isOn {
            self.privateLabel.textColor = UIColor.primaryGreen()
            self.publicLabel.textColor = UIColor.white
            
            guestSettingsStackView.isHidden = false
            interestTopConstraint.constant = 125
            
        } else /* the switch is set to public */ {
            self.privateLabel.textColor = UIColor.white
            self.publicLabel.textColor = UIColor.primaryGreen()
            
            guestSettingsStackView.isHidden = true
            interestTopConstraint.constant = 50
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
                
                let interests = zip(checkInterests,Constants.interests.interests ).filter { $0.0 }.map { $1 }
                
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
                
                let interests = zip(checkInterests,Constants.interests.interests ).filter { $0.0 }.map { $1 }
                
                guard !interests.isEmpty else{
                    presentNotification(title: "Choose a interest", message: "Please choose atleast one interest for this event.")
                    return
                }
                
                let endTime = eventEndTimeTextField.text
                
                
                
                self.event = Event(title: name, description: "", fullAddress: validPlace.formattedAddress!, shortAddress: shortAddress, latitude: validPlace.coordinate.latitude.debugDescription, longitude: validPlace.coordinate.longitude.debugDescription, date: dateString, creator: creator, category: interests.joined(separator: ";"))
                
                let price = eventPriceTextView.text
                if (price?.characters.count)! > 0{
                    self.event?.setPrice(price: Double(price!)!)    
                }
                
                self.event?.setEndTime(endTime: endTime!)
            }
            
            Event.cacheEvent(event: self.event!)
            let destination = segue.destination as! EventIconViewController
            destination.event = self.event
            
            
            let _ = [eventNameTextField, eventDateTextField, eventTimeTextField, locationTextField, eventEndTimeTextField, eventPriceTextView].map{$0.text = nil}
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
            self.guestListBttn.setImage(UIImage(named: "Interest_Filled.png"), for: .selected)
            self.guestListBttn.isSelected = true
        } else {
            self.guestListBttn.setImage(UIImage(named: "Interest_blank.png"), for: .normal)
            self.guestListBttn.isSelected = false
        }
    }
    
    @IBAction func allowForInvitingFriendsBttn(_ sender: UIButton) {
        if self.showGuestFriendsBttn.isSelected == true {
            self.showGuestFriendsBttn.isSelected = false
            self.showGuestFriendsBttn.setBackgroundImage(UIImage(named: "Interest_blank"), for: .normal)
        } else {
            self.showGuestFriendsBttn.isSelected = true
            self.showGuestFriendsBttn.setBackgroundImage(UIImage(named: "Interest_Filled"), for: .normal)
        }
    }
    
    @IBAction func addEventLocation(_ sender: UITextField) {
        let autoCompleteController = GMSAutocompleteViewController()
        
        let filter = GMSAutocompleteFilter()
        filter.country = "US"
        
        autoCompleteController.autocompleteFilter = filter

        
        autoCompleteController.delegate = self
        present(autoCompleteController, animated: true, completion: nil)
    }
    
    @IBAction func addEventDate(_ sender: UITextField) {
//        showDatePicker()
        self.eventDateTextField.inputAccessoryView = self.dateToolbar
        self.eventDateTextField.inputView = datePicker
    }
    
    @IBAction func addEventTime(_ sender: UITextField) {
//        showStartTimePicker()
        self.eventTimeTextField.inputAccessoryView = self.startTimeToolbar
        self.eventTimeTextField.inputView = self.timePicker
    }
    
    @IBAction func addEventEndTime(_ sender: UITextField) {
//        showEndTimePicker()
        self.eventEndTimeTextField.inputAccessoryView = self.endTimeToolbar
        self.eventEndTimeTextField.inputView = self.timePicker
    }
    
    @IBAction func addPrice(_ sender: UITextField) {
        self.eventPriceTextView.inputAccessoryView = self.priceToolbar
    }
    
    func dateSelected(){
        self.eventDateTextField.text = "\(self.dateFormatter.string(from: self.datePicker.date))"
        self.view.endEditing(true)
        self.eventTimeTextField.becomeFirstResponder()
    }
    
    func startTimeSelected(){
        self.eventTimeTextField.text = "\(self.timeFormatter.string(from: self.timePicker.date))"
        self.view.endEditing(true)
        self.eventEndTimeTextField.becomeFirstResponder()
    }
    
    func endTimeSelected(){
        self.eventEndTimeTextField.text = "\(self.timeFormatter.string(from: self.timePicker.date))"
        self.view.endEditing(true)
        self.eventPriceTextView.becomeFirstResponder()
    }
    
    func priceSelected(){
        print(self.eventPriceTextView.text)
        self.view.endEditing(true)
        self.eventDescriptionTextView.becomeFirstResponder()
    }
    
    func formatTextFields(){
        let _ = [eventNameTextField, locationTextField, eventDateTextField, eventTimeTextField, eventEndTimeTextField, eventDescriptionTextView, eventPriceTextView].map{
            self.addRoundBorder(view: $0)
        }
        
        eventDateTextField.attributedPlaceholder = formatPlaceholder(placeholder: "Date")
        locationTextField.attributedPlaceholder = formatPlaceholder(placeholder: "Location")
        eventTimeTextField.attributedPlaceholder = formatPlaceholder(placeholder: "Start Time")
        eventNameTextField.attributedPlaceholder = formatPlaceholder(placeholder: "Event Name")
        eventEndTimeTextField.attributedPlaceholder = formatPlaceholder(placeholder: "End Time (if applicable)")
        eventPriceTextView.attributedPlaceholder = formatPlaceholder(placeholder: "Price (if applicable)")

//        eventDateTextField.setRightIcon(iconString: "Calendar-50")
//        locationTextField.setRightIcon(iconString: "location")
//        eventTimeTextField.setRightIcon(iconString: "Clock-25")
//        eventEndTimeTextField.setRightIcon(iconString: "Clock-25")
//        eventPriceTextView.setRightIcon(iconString: "price")
        
    }
    
    func formatPlaceholder(placeholder text: String) -> NSAttributedString {
        let newString = NSAttributedString(string: text, attributes: [NSForegroundColorAttributeName: UIColor.white])
        return newString
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredInterest.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = interestTableView.dequeueReusableCell(withIdentifier: "selectedInterest", for: indexPath) as! InterestTableViewCell
        
        cell.selectedInterestLabel.text = filteredInterest[indexPath.row]
        
        if checkInterests[indexPath.row]{
            cell.checkedInterest.image = UIImage(named: "Green.png")
        }
        else{
            cell.checkedInterest.image = UIImage(named: "Interest_blank")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        interestListView.isHidden = false
        
        let cell = interestTableView.dequeueReusableCell(withIdentifier: "selectedInterest", for: indexPath) as! InterestTableViewCell
        tableView.deselectRow(at: indexPath, animated: false)
        
        checkInterests[indexPath.row] = !checkInterests[indexPath.row]
        
        if interestListLabel.text == "" || interestListLabel.text == nil{
            self.interestListLabel.text =  filteredInterest[indexPath.row]
        } else {
            self.interestListLabel.text =  self.interestListLabel.text! + ", \(filteredInterest[indexPath.row])"
        }
        
        if checkInterests[indexPath.row]{
            cell.checkedInterest.image = UIImage(named: "Green.png")
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
    
    @IBAction func interestNextPressed(_ sender: Any) {
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
        
        self.eventDateTextField.becomeFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // to do: handle error
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        if self.eventNameTextField.isFirstResponder {
            self.eventNameTextField.becomeFirstResponder()
        }
        
        if self.eventDateTextField.isFirstResponder {
            self.eventDateTextField.becomeFirstResponder()
        }

        dismiss(animated: true, completion: nil)
    }
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        viewController.autocompleteFilter?.country = "US"
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        viewController.autocompleteFilter?.country = "US"
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

extension CreateNewEventViewController {
    
//    MARK: TEXT FIELD DELEGATE FUNCTIONS
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.eventDateTextField {
            eventDateTextField.inputAccessoryView = self.dateToolbar
            eventDateTextField.inputView = self.datePicker
        }
        else if textField == self.eventTimeTextField {
            self.eventTimeTextField.inputAccessoryView = self.startTimeToolbar
            self.eventTimeTextField.inputView = self.timePicker
        }
        else if textField == self.eventEndTimeTextField {
            self.eventEndTimeTextField.inputAccessoryView = self.endTimeToolbar
            self.eventEndTimeTextField.inputView = self.timePicker
        } else if textField == self.locationTextField {
//            eventDateTextField.inputAccessoryView = self.datePicker
            
            let autoCompleteController = GMSAutocompleteViewController()
            autoCompleteController.delegate = self
            present(autoCompleteController, animated: true, completion: nil)
        } else if textField == self.eventPriceTextView {
            self.eventPriceTextView.inputAccessoryView = self.priceToolbar
        } else {
            self.eventNameTextField.inputAccessoryView = self.nextPrevToolbar
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    //    MARK: TEXT VIEW DELEGATE FUNCTIONS
    
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
    
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
//        TODO: sometimes the tool bar works and sometimes it doesn't. need to figure out why
        self.eventDescriptionTextView.inputAccessoryView = self.nextPrevToolbar
        return true
    }
    
//    MARK: SEARCH BAR DELEGATE FUNCTIONS
    
//    TODO: need to increase height of view controller in order to compensate for scroll view moving up

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchBar.returnKeyType = .done
        
        if searchText.characters.count > 0{
            self.filteredInterest = self.interests.filter { $0.contains(searchText) }
            self.interestTableView.reloadData()
        }
        else{
            self.filteredInterest = self.interests
            self.interestTableView.reloadData()
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
    }
    
    func searchForInterest(interest: String){
//        filteredCandies = candies.filter { candy in
//            return candy.name.lowercaseString.containsString(searchText.lowercaseString)
//        }
    }
    
    func keyboardNextButton(){
        if self.eventNameTextField.isFirstResponder{
            self.locationTextField.becomeFirstResponder()
        } else if self.eventDateTextField.isFirstResponder {
            self.eventTimeTextField.becomeFirstResponder()
            self.eventDateTextField.text = "\(self.dateFormatter.string(from: self.datePicker.date))"
        } else if self.eventTimeTextField.isFirstResponder {
            self.eventEndTimeTextField.becomeFirstResponder()
            self.eventTimeTextField.text = "\(self.timeFormatter.string(from: self.timePicker.date))"
            self.startTime = self.timePicker.date
        } else if self.eventEndTimeTextField.isFirstResponder {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 100), animated: true)
            
            if timePicker.date > self.startTime!{
                self.eventPriceTextView.becomeFirstResponder()
                self.eventEndTimeTextField.text = "\(self.timeFormatter.string(from: self.timePicker.date))"
                self.endTime = timePicker.date
            }
            else{
                SCLAlertView().showError("Invalid end time", subTitle: "Please enter end time after start time.")
            }
        } else if self.eventPriceTextView.isFirstResponder{
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 100), animated: true)
            self.eventDescriptionTextView.becomeFirstResponder()
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 200), animated: true)
        } else if self.eventDescriptionTextView.isFirstResponder {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: self.scrollView.contentInset.bottom), animated: true)
            self.searchBar.becomeFirstResponder()
        }
    }
    
    func keyboardPreviousButton(){
        if self.searchBar.isFirstResponder {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: self.scrollView.contentOffset.y-20), animated: true)
            self.eventDescriptionTextView.becomeFirstResponder()
        } else if self.eventDescriptionTextView.isFirstResponder {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: self.scrollView.contentOffset.y-10), animated: true)
            self.eventPriceTextView.becomeFirstResponder()
        } else if self.eventPriceTextView.isFirstResponder {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: self.scrollView.contentOffset.y-10), animated: true)
            self.eventEndTimeTextField.becomeFirstResponder()
        } else if self.eventEndTimeTextField.isFirstResponder {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: self.scrollView.contentOffset.y-10), animated: true)
            self.eventTimeTextField.becomeFirstResponder()
        } else if self.eventTimeTextField.isFirstResponder {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: self.scrollView.contentOffset.y-10), animated: true)
            self.eventDateTextField.becomeFirstResponder()
        } else if self.eventDateTextField.isFirstResponder {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: self.scrollView.contentInset.top), animated: true)
            self.locationTextField.becomeFirstResponder()
            self.eventNameTextField.becomeFirstResponder()
        }
        
    }
}







