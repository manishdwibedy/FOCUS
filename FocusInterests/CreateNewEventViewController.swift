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
   
class CreateNewEventViewController: UIViewController,UITextFieldDelegate,UITextViewDelegate, gotLocationDelegate{
    
    @IBOutlet weak var privatePublicSwitch: UISwitch!
    //@IBOutlet weak var interestListView: UIView!
    @IBOutlet var parentView: UIView!
    @IBOutlet weak var interestListLabel: UILabel!
    //@IBOutlet weak var interestNextButton: UIButton!
    @IBOutlet weak var interestLabelTopConstraintToSwitcher: NSLayoutConstraint!
    
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var choseFocusButton: UIButton!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var publicLabel: UILabel!
    @IBOutlet weak var privateLabel: UILabel!
    //@IBOutlet weak var searchBar: UISearchBar!
    
    let minuteComponent = ["01","02","03","04","05","06","07","08","09","10","11","12"]
    let secondComponent = ["00","05","10","15","20","25","30","35","40","45","50","55"]
    let ampm = ["AM", "PM"]
    var timerObject = [
        0: "",
        1: "",
        2: ""
    ]
    
//    these are called when a user has pressed "pin here" in either place or event details 
    var specifiedLocationFromPlaceOrEventDetail = false
    var specifiedLocation = ""
    
    var event: Event?
    var place: GMSPlace?
    var isSelectedLocation = false
    var selectedLocation: LocationSuggestion?
    var fullAddress = ""
    var hasNotChosenFocus = true
    let datePicker = UIDatePicker()
//    let timePicker = UIDatePicker()
    let timePicker = UIPickerView()
    let dateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    
    var focusList = Set<String>()
    
    // Interests
    var checkInterests = [Bool]()
    var filteredCheck = [Bool]()
    var interests = [String]()
    var filteredInterest = [String]()
    var interests_set = Set<String>()
    
    let validatedFields = true
    
    @IBOutlet weak var interestLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var guestListStackTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var canInviteFriendsLabel: UILabel!
    @IBOutlet weak var showGuestListLabel: UILabel!
    
    @IBOutlet weak var guestListBttn: UIButton!
    @IBOutlet weak var showGuestFriendsBttn: UIButton!
    
    // MARK: - IBOutlets
    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var eventDateTextField: UITextField!
    @IBOutlet weak var eventEndDateTextField: UITextField!
    @IBOutlet weak var eventTimeTextField: UITextField!
    @IBOutlet weak var eventEndTimeTextField: UITextField!
    @IBOutlet weak var eventPriceTextView: UITextField!
    @IBOutlet weak var eventDescriptionTextView: UITextView!
    
    
    //@IBOutlet weak var interestTableView: UITableView!
    @IBOutlet weak var publicOrPrivateSwitch: UISwitch!
    @IBOutlet weak var guestSettingsStackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    //@IBOutlet weak var interestTopConstraint: NSLayoutConstraint!
    
//    TOOLBARS
    
    var nextButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(CreateNewEventViewController.keyboardNextButton))
    var previousButton = UIBarButtonItem(title: "Previous", style: .plain, target: self, action: #selector(CreateNewEventViewController.keyboardPreviousButton))
    var flexibleSpaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    var fixedSpaceButton = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
    
    
    var dateDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(CreateNewEventViewController.startDateSelected))
    var endDateDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(CreateNewEventViewController.endDateSelected))
    var startTimeDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(CreateNewEventViewController.startTimeSelected))
    var endTimeDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(CreateNewEventViewController.endTimeSelected))
    var priceDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(CreateNewEventViewController.priceSelected))
    var locationDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(CreateNewEventViewController.locationSelected))
    var textViewDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(CreateNewEventViewController.textViewFinished))
    
    // start and end time
    var startDate: Date? = nil
    var endDate: Date? = nil
    var startTime: Date? = nil
    var endTime: Date? = nil
    var delegate: showMarkerDelegate?
    
    lazy var dateToolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.sizeToFit()
        
        toolbar.setItems([self.flexibleSpaceButton, self.dateDoneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        return toolbar
    }()
    
    lazy var endDateToolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.sizeToFit()
        
        toolbar.setItems([self.flexibleSpaceButton, self.endDateDoneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        return toolbar
    }()
    
    lazy var startTimeToolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.sizeToFit()

        toolbar.setItems([self.flexibleSpaceButton, self.startTimeDoneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        return toolbar
    }()
    
    lazy var endTimeToolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.sizeToFit()
        
        toolbar.setItems([self.flexibleSpaceButton, self.endTimeDoneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        return toolbar
    }()
    
    lazy var priceToolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.sizeToFit()
        
        toolbar.setItems([self.flexibleSpaceButton, self.priceDoneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        return toolbar
    }()
    
    lazy var googleLocationToolBar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.sizeToFit()
        
        toolbar.setItems([self.flexibleSpaceButton, self.locationDoneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        return toolbar
    }()
    
    lazy var textViewToolbar: UIToolbar = {
        var toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.sizeToFit()
        
        toolbar.setItems([self.flexibleSpaceButton, self.textViewDoneButton], animated: false)
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
        self.privatePublicSwitch.isOn = false
        self.privatePublicSwitch.tintColor = UIColor(red: 122/255.0, green: 201/255.0, blue: 1/255.0, alpha: 1.0)
        self.privatePublicSwitch.layer.cornerRadius = 16
        self.privatePublicSwitch.backgroundColor = UIColor(red: 122/255.0, green: 201/255.0, blue: 1/255.0, alpha: 1.0)
        self.privatePublicSwitch.onTintColor = UIColor(red: 122/255.0, green: 201/255.0, blue: 1/255.0, alpha: 1.0)
        
        formatTextFields()
        setTextFieldDelegates()

        self.timePicker.delegate = self
        self.timePicker.dataSource = self
        
        self.timerObject[0] = self.minuteComponent[0]
        self.timerObject[1] = self.secondComponent[0]
        self.timerObject[2] = self.ampm[0]
        
        self.timePicker.selectRow(0, inComponent: 0, animated: false)
        self.timePicker.selectRow(0, inComponent: 1, animated: false)
        self.timePicker.selectRow(0, inComponent: 2, animated: false)
        self.timeFormatter.dateFormat = "hh:mm a"
        let startTimeVal = "\(String(describing: self.timerObject[0]!)):\(String(describing: self.timerObject[1]!)) \(String(describing: self.timerObject[2]!))"
        let startingTime = timeFormatter.date(from: startTimeVal)
        self.startTime = startingTime!
        
        let date = Date()
        self.datePicker.minimumDate = date

        self.datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: +100, to: Date())
        self.datePicker.datePickerMode = .date
        self.dateFormatter.dateFormat = "MMM d"
       
        var tapGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CreateNewEventViewController.choseFocusAction(_:)))
        tapGesture.numberOfTapsRequired = 1
        
//        THIS is to not allow user to change place if they're creating a pin from event or place details
        if self.specifiedLocationFromPlaceOrEventDetail && self.specifiedLocation != ""{
            self.locationTextField.isUserInteractionEnabled = false
            self.locationTextField.text = self.specifiedLocation
        }else{
            self.locationTextField.isUserInteractionEnabled = true
        }
        
        eventDescriptionTextView.delegate = self
        eventDescriptionTextView.text = "Description"
        eventDescriptionTextView.textColor = .white
        
        datePicker.minuteInterval = 15
        //timePicker.minuteInterval = 15
        
        datePicker.addTarget(self, action: #selector(CreateNewEventViewController.datePickerChanged), for: .valueChanged)
        
        choseFocusButton.layer.cornerRadius = 15
        choseFocusButton.clipsToBounds = true
        choseFocusButton.layer.borderColor =  UIColor.white.cgColor
        choseFocusButton.layer.borderWidth = 1
        
        for _ in 0..<Constants.interests.interests.count{
            checkInterests.append(false)
            filteredCheck.append(false)
        }
        
        self.filteredInterest = Constants.interests.interests
        self.interests = self.filteredInterest
        
        hideKeyboardWhenTappedAround()
        
        let attrs = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "Avenir-Black", size: 18)!
        ]
        
        navBar.titleTextAttributes = attrs
        navBar.barTintColor = Constants.color.navy
        
        self.guestSettingsStackView.isHidden = true
        self.view.backgroundColor = Constants.color.navy
        UIApplication.shared.statusBarStyle = .default
    }
    
    @IBAction func choseFocusAction(_ sender: Any) {
        
        //var lastCaption = ""

        
        //lastCaption = pinTextView.text
        let focusWindow = InterestsViewController(nibName:"InterestsViewController", bundle:nil)
        focusWindow.pinInterest = true
        self.present(focusWindow, animated: true, completion:{
            focusWindow.saveButton.isEnabled = false
            focusWindow.saveButton.title = ""
            focusWindow.shouldOnlyReturn = true
            focusWindow.needsReturn = true
            focusWindow.parentCreateEvent = self
        })
        
        focusWindow.onClose = { (finished, set) in
            print("Finished")
            print("Self focus list => \(set)")
            
            self.interests_set = set
            
            var str = ""
            
            for value in set {
                str += "\(value) | "
            }
            
            self.choseFocusButton.setTitle(str, for: .normal)
            self.choseFocusButton.setTitle(str, for: .selected)
            self.hasNotChosenFocus = false
            self.eventNameTextField.becomeFirstResponder()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let cached = Event.fetchEvent() {
            self.event = cached
            choseFocusButton.setTitle(cached.category!, for: .normal)
            eventNameTextField.text = cached.title
            eventDescriptionTextView.text = cached.eventDescription! 
            locationTextField.text = cached.shortAddress
            
            let dateTime = cached.date?.components(separatedBy: ",")
            eventDateTextField.text = dateTime?[0]
            eventTimeTextField.text = dateTime?[1]
            eventEndTimeTextField.text = cached.endTime
            
            if let price = cached.price{
                eventPriceTextView.text = String(describing: price)    
            }
            
            
            let interests = cached.category?.components(separatedBy: ",")
            
            for (index, interest) in Constants.interests.interests.enumerated(){
                if (interests?.contains(interest))!{
                    checkInterests[index] = true
                }
            }
        }
        registerKeyboardNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        let _ = [eventNameTextField, locationTextField, eventDateTextField, eventEndDateTextField, eventTimeTextField, eventEndTimeTextField, eventPriceTextView].map{$0.delegate = self}
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
        sender.isOn = !sender.isOn
        if sender.isOn {
            self.privateLabel.textColor = UIColor(red: 122/255.0, green: 201/255.0, blue: 1/255.0, alpha: 1.0)
            self.publicLabel.textColor = UIColor.white
            
//            self.guestListStackTopConstraint.constant += 28
            
//            self.scrollViewHeight.constant += 71
            guestSettingsStackView.isHidden = false
            //interestTopConstraint.constant = 100
            
        } else /* the switch is set to public */ {
            self.privateLabel.textColor = UIColor.white
            self.publicLabel.textColor = UIColor(red: 122/255.0, green: 201/255.0, blue: 1/255.0, alpha: 1.0)
            
            guestSettingsStackView.isHidden = true
//            self.guestListStackTopConstraint.constant -= 28
            
//            self.scrollViewHeight.constant -= 71
            //interestTopConstraint.constant = 0
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! EventIconViewController
        destination.delegate = self.delegate
        
        
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
                guard AuthApi.getFirebaseUid() != nil else { return }
                
                if choseFocusButton.titleLabel?.text == "Choose FOCUS"{
                    presentNotification(title: "Choose an interest", message: "Please choose atleast one interest for this event.")
                    return
                }
                
                self.event?.title = eventNameTextField.text
                self.event?.eventDescription = validDescrip
                self.event?.date = dateString
                self.event?.category = interests.joined(separator: ";")
                
                
            }
            else{
                if !self.isSelectedLocation{
                    presentNotification(title: "Choose a location", message: "Please choose a location for this event.")
                }
                let locality = selectedLocation?.address
                
                
                guard let name = eventNameTextField.text, !name.isEmpty else{
                    presentNotification(title: "Choose a name", message: "Please choose a name for this event.")
                    return
                }
                
                _ = eventDescriptionTextView.text ?? ""
                
                guard let validDate = eventDateTextField.text, !validDate.isEmpty,
                    let validTime = eventTimeTextField.text, !validTime.isEmpty else {
                        presentNotification(title: "Choose a date and time.", message: "Please choose a date and time for this event.")
                        return
                }
                let dateString = "\(validDate), \(validTime)"
                guard let creator = AuthApi.getFirebaseUid() else { return }
                
                //let interests = zip(checkInterests,Constants.interests.interests ).filter { $0.0 }.map { $1 }
                
                let interests = self.interests_set
                
                if choseFocusButton.titleLabel?.text == "Choose FOCUS"{
                    presentNotification(title: "Choose an interest", message: "Please choose atleast one interest for this event.")
                    return
                }
                
                let endTime = eventEndTimeTextField.text
                
                
                self.event = Event(title: name, description: "", fullAddress: selectedLocation?.address, shortAddress: selectedLocation?.name, latitude: String(describing: selectedLocation!.lat), longitude: String(describing: selectedLocation!.long), date: dateString, creator: creator, category: choseFocusButton.titleLabel?.text, privateEvent: publicOrPrivateSwitch.isOn)
                
                let price = eventPriceTextView.text
                if (price?.characters.count)! > 0{
                    self.event?.setPrice(price: Double(price!)!)    
                }
                
                self.event?.setEndTime(endTime: endTime!)
            }
            
            Event.cacheEvent(event: self.event!)
            destination.event = self.event
            
            
            let _ = [eventNameTextField, eventDateTextField, eventEndDateTextField,eventTimeTextField, locationTextField, eventEndTimeTextField, eventPriceTextView].map{$0.text = nil}
        }
    }
    
    private func presentNotification(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .destructive, handler: nil)
        alert.view.tintColor = Constants.color.green
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func showGuestListBttn(_ sender: UIButton) {
        if self.guestListBttn.isSelected == false {
            self.guestListBttn.setImage(UIImage(named: "Green.png"), for: .selected)
            self.guestListBttn.isSelected = true
        } else {
            self.guestListBttn.setImage(UIImage(named: "Interest_blank.png"), for: .normal)
            self.guestListBttn.isSelected = false
        }
    }
    
    @IBAction func allowForInvitingFriendsBttn(_ sender: UIButton) {
        if self.showGuestFriendsBttn.isSelected == true {
            self.showGuestFriendsBttn.setBackgroundImage(UIImage(named: "Interest_blank"), for: .normal)
            self.showGuestFriendsBttn.isSelected = false
        } else {
            self.showGuestFriendsBttn.layer.borderWidth = 0.0
            self.showGuestFriendsBttn.setBackgroundImage(UIImage(named: "Green.png"), for: .normal)
            self.showGuestFriendsBttn.isSelected = true
        }
    }
    
    @IBAction func addEventLocation(_ sender: UITextField) {
        let chooseLocationVC = ChooseLocationViewController(nibName: "ChooseLocationViewController", bundle: nil)
        chooseLocationVC.delegate = self
        
        self.present(chooseLocationVC, animated: true, completion: nil)
    }
    
    @IBAction func addEventDate(_ sender: UITextField) {
//        showDatePicker()
        self.eventDateTextField.inputView = self.timePicker
//        self.eventDateTextField.inputAccessoryView = self.dateToolbar
    }
    
    @IBAction func addEventTime(_ sender: UITextField) {
//        showStartTimePicker()
        self.eventTimeTextField.inputView = self.timePicker
//        self.eventTimeTextField.inputAccessoryView = self.startTimeToolbar
        
    }
    
    @IBAction func addEventEndTime(_ sender: UITextField) {
//        showEndTimePicker()
        self.eventEndTimeTextField.inputView = self.timePicker
//        self.eventEndTimeTextField.inputAccessoryView = self.endTimeToolbar
        self.eventPriceTextView.becomeFirstResponder()
    }
    
    @IBAction func addPrice(_ sender: UITextField) {
//        self.eventPriceTextView.inputAccessoryView = self.priceToolbar
    }
    
    func datePickerChanged(){
        if self.eventDateTextField.isFirstResponder{
            self.datePicker.setDate(self.datePicker.date, animated: true)
        }else if self.eventEndDateTextField.isFirstResponder{
            self.datePicker.setDate(self.datePicker.date, animated: true)
        }
    }
    
    func startDateSelected(){
        
        if let endDate = self.endDate{
            let startYear = Calendar.current.component(.year, from: self.datePicker.date)
            let startMonth = Calendar.current.component(.month, from: self.datePicker.date)
            let startDay = Calendar.current.component(.day, from: self.datePicker.date)
            
            let endYear = Calendar.current.component(.year, from: endDate)
            let endMonth = Calendar.current.component(.month, from: endDate)
            let endDay = Calendar.current.component(.day, from: endDate)
            
            if startMonth == endMonth && startDay >= endDay{
                showError(message: "Please enter an end date on or after the start date")
            }else if startMonth > endMonth{
                showError(message: "Please enter an end date on or after the start date")
            }
            
            self.startDate = self.datePicker.date
            self.eventDateTextField.text = "\(self.dateFormatter.string(from: self.datePicker.date))"
            self.view.endEditing(true)
            self.eventEndDateTextField.becomeFirstResponder()
        }else{
            self.startDate = self.datePicker.date
            self.eventDateTextField.text = "\(self.dateFormatter.string(from: self.datePicker.date))"
            self.view.endEditing(true)
            self.eventEndDateTextField.becomeFirstResponder()
        }
    }
    
    func endDateSelected(){
        
        if let startingDate = self.startDate{
//            let startDate = self.dateFormatter.date(from: startingDate)
            print("startDate: \(startingDate)")
            let startYear = Calendar.current.component(.year, from: startingDate)
            let startMonth = Calendar.current.component(.month, from: startingDate)
            let startDay = Calendar.current.component(.day, from: startingDate)

            let endYear = Calendar.current.component(.year, from: self.datePicker.date)
            let endMonth = Calendar.current.component(.month, from: self.datePicker.date)
            let endDay = Calendar.current.component(.day, from: self.datePicker.date)
            
            if startYear == endYear{
                if startMonth < endMonth{
                    self.endDate = self.datePicker.date
                    self.eventEndDateTextField.text = "\(self.dateFormatter.string(from: self.datePicker.date))"
                    self.view.endEditing(true)
                    self.eventTimeTextField.becomeFirstResponder()
                }else if startMonth == endMonth && startDay <= endDay{
                    self.endDate = self.datePicker.date
                    self.eventEndDateTextField.text = "\(self.dateFormatter.string(from: self.datePicker.date))"
                    self.view.endEditing(true)
                    self.eventTimeTextField.becomeFirstResponder()
                }else if startMonth == endMonth && startDay > endDay{
                    showError(message: "Please enter an end date on or after the start date")
                    self.view.endEditing(true)
                    self.eventEndDateTextField.becomeFirstResponder()
                    
                }else if startMonth > endMonth{
                    showError(message: "Please enter an end date on or after the start date")
                    self.view.endEditing(true)
                    self.eventEndDateTextField.becomeFirstResponder()
                }
            }else if startYear < endYear{
                self.endDate = self.datePicker.date
                self.eventEndDateTextField.text = "\(self.dateFormatter.string(from: self.datePicker.date))"
                self.view.endEditing(true)
                self.eventTimeTextField.becomeFirstResponder()
            }
        }else{
            showError(message: "Please enter an end date on or after the start date")
            self.view.endEditing(true)
        }
    }
    
    func startTimeSelected(){
        if let startTimeVal = self.startTime{
            if let startDate = self.startDate{
                var current = Date()
                
                let gregorianCalendar = Calendar(identifier: .gregorian)
                var dateSelected = gregorianCalendar.dateComponents([.year, .month, .day], from: startDate)
                var timeSelected = gregorianCalendar.dateComponents([.hour, .minute], from: startTimeVal)
                
                dateSelected.hour = timeSelected.hour
                dateSelected.minute = timeSelected.minute
                let date = gregorianCalendar.date(from: dateSelected)!
           
                if date < current{
                    showError(message: "Please enter a valid time")
                    return
                }
                else{
                    self.eventTimeTextField.text = timeFormatter.string(from: startTimeVal)
                }
            }
            else{
                showError(message: "Please choose the start date")
            }
            
        }
        self.eventEndTimeTextField.becomeFirstResponder()
    }
    
    func endTimeSelected(){
        let endDate = timeFormatter.date(from: "\(String(describing: self.timerObject[0]!)):\(String(describing: self.timerObject[1]!)) \(String(describing: self.timerObject[2]!))")
        print("endDate: \(endDate)")
        self.endTime = endDate!
        
        if let endTimeVal = self.endTime{
            if let endDate = self.endDate{
                
                let gregorianCalendar = Calendar(identifier: .gregorian)
                var dateSelected = gregorianCalendar.dateComponents([.year, .month, .day], from: endDate)
                var timeSelected = gregorianCalendar.dateComponents([.hour, .minute], from: endTimeVal)
                
                dateSelected.hour = timeSelected.hour
                dateSelected.minute = timeSelected.minute
                let date = gregorianCalendar.date(from: dateSelected)!
           
                
                if let startTimeVal = self.startTime{
                    if let startDate = self.startTime{
                        if date > self.startTime! {
                            self.eventEndTimeTextField.text = "\(self.timeFormatter.string(from: self.endTime!))"
                            self.scrollView.setContentOffset(CGPoint(x: 0, y: self.scrollView.contentOffset.y-10), animated: true)
                            self.eventPriceTextView.becomeFirstResponder()
                            self.view.endEditing(true)
                        }else{
                            self.view.endEditing(true)
                            showError(message: "Please enter an end time after the start time")
                        }
                        
                    }
                    else{
                        showError(message: "Please choose the start date")
                    }
                }
            }
            else{
                showError(message: "Please choose the end date")
            }
            
        }

        
        
    }
    
    func priceSelected(){
        print(self.eventPriceTextView.text ?? "")
        self.view.endEditing(true)
        self.eventDescriptionTextView.becomeFirstResponder()
    }
    
    func locationSelected(){
        self.view.endEditing(true)
        self.eventDateTextField.becomeFirstResponder()
    }
    
    func textViewFinished(){
        self.eventDescriptionTextView.resignFirstResponder()
        self.eventDescriptionTextView.endEditing(true)
    }
    
    func formatTextFields(){
        let _ = [eventNameTextField, locationTextField, eventDateTextField, eventEndDateTextField,eventTimeTextField, eventEndTimeTextField, eventDescriptionTextView, eventPriceTextView].map{
            self.addRoundBorder(view: $0)
        }
        
        eventDateTextField.attributedPlaceholder = formatPlaceholder(placeholder: "Start Date")
        eventEndDateTextField.attributedPlaceholder = formatPlaceholder(placeholder: "End Date")
        locationTextField.attributedPlaceholder = formatPlaceholder(placeholder: "Location")
        eventTimeTextField.attributedPlaceholder = formatPlaceholder(placeholder: "Start Time")
        eventNameTextField.attributedPlaceholder = formatPlaceholder(placeholder: "Event Name")
        eventEndTimeTextField.attributedPlaceholder = formatPlaceholder(placeholder: "End Time (if applicable)")
        eventPriceTextView.attributedPlaceholder = formatPlaceholder(placeholder: "Price (if applicable)")

    }
    
    func formatPlaceholder(placeholder text: String) -> NSAttributedString {
        let newString = NSAttributedString(string: text, attributes: [NSForegroundColorAttributeName: UIColor.white])
        return newString
    }
    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return filteredInterest.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = interestTableView.dequeueReusableCell(withIdentifier: "selectedInterest", for: indexPath) as! InterestTableViewCell
//        
//        cell.selectedInterestLabel.text = filteredInterest[indexPath.row]
//        
//        if checkInterests[indexPath.row]{
//            cell.checkedInterest.image = UIImage(named: "Green.png")
//        }
//        else{
//            cell.checkedInterest.image = UIImage(named: "Interest_blank")
//        }
//        
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        
//        //interestListView.isHidden = false
//        
//        let cell = interestTableView.dequeueReusableCell(withIdentifier: "selectedInterest", for: indexPath) as! InterestTableViewCell
//        tableView.deselectRow(at: indexPath, animated: false)
//        
//        checkInterests[indexPath.row] = !checkInterests[indexPath.row]
//        
//        if interestListLabel.text == "" || interestListLabel.text == nil{
//            self.interestListLabel.text =  filteredInterest[indexPath.row]
//        } else {
//            self.interestListLabel.text =  self.interestListLabel.text! + ", \(filteredInterest[indexPath.row])"
//        }
//        
//        if checkInterests[indexPath.row]{
//            cell.checkedInterest.image = UIImage(named: "Green.png")
//        }
//        else{
//            cell.checkedInterest.image = UIImage(named: "Interest_blank")
//        }
//        interestTableView.reloadData()
//    }
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        Event.clearCache()
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = mainStoryboard.instantiateViewController(withIdentifier: "home") as! HomePageViewController
        vc.selectedIndex = 3
        self.present(vc, animated: true, completion: nil)
        
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
    
    func createGMSViewController() -> GMSAutocompleteViewController{
        let autoCompleteController = GMSAutocompleteViewController()
        
        let filter = GMSAutocompleteFilter()
        filter.country = "US"
        
        autoCompleteController.autocompleteFilter = filter
        
        autoCompleteController.delegate = self
        
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().barTintColor = UIColor(red: 20/255.0, green: 40/255.0, blue: 64/255.0, alpha: 1.0)
        UINavigationBar.appearance().tintColor = UIColor.white
        
        //        search bar attributes
        let placeholderAttributes: [String : AnyObject] = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "Avenir Book", size: 17)!
        ]
        
        let placeholderTextAttributes: NSAttributedString = NSAttributedString(string: "Search", attributes: placeholderAttributes)
        
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = placeholderAttributes
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).attributedPlaceholder = placeholderTextAttributes
        
        autoCompleteController.primaryTextColor = UIColor.white
        autoCompleteController.primaryTextHighlightColor = Constants.color.green
        autoCompleteController.secondaryTextColor = UIColor.white
        autoCompleteController.tableCellBackgroundColor = UIColor(red: 20/255.0, green: 40/255.0, blue: 64/255.0, alpha: 1.0)
        autoCompleteController.tableCellSeparatorColor = UIColor.white
        
        return autoCompleteController
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        self.place = place
        
        var first = [String]()
        var second = [String]()
        
        var isPlace = true
        //locality;admin area level 1; postal code
        for a in place.addressComponents!{
            if a.type == "street_number"{
                first.append(a.name)
                isPlace = false
            }
            if a.type == "route"{
                first.append(a.name)
                isPlace = false
            }
            
            if a.type == "locality"{
                if isPlace{
                    first.append(a.name)
                }
                else{
                    second.append(a.name)
                }
            }
            if a.type == "administrative_area_level_1"{
                if isPlace{
                    first.append(a.name)
                }
                else{
                    second.append(a.name)
                }
            }
            if a.type == "postal_code"{
                if isPlace{
                    first.append(a.name)
                }
                else{
                    second.append(a.name)
                }
            }
            if a.type == "premise"{
                first.append(a.name)
                break
            }
        }
        
        if isPlace{
            second = first
            self.locationTextField.text = place.name
            
            self.fullAddress = "\(place.name);;\(second.joined(separator: ", "))"
        }
        else{
            self.locationTextField.text = first.joined(separator: " ")
            self.fullAddress = "\(first.joined(separator: " "));;\(second.joined(separator: " "))"
        }
        
        self.eventDateTextField.becomeFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // to do: handle error
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
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
    
//    MARK: Date Picker Functions
    
    
//    MARK: TEXT FIELD DELEGATE FUNCTIONS
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.eventNameTextField{
            if self.specifiedLocationFromPlaceOrEventDetail {
                self.eventNameTextField.resignFirstResponder()
                self.eventDateTextField.becomeFirstResponder()
            }else{
                let chooseLocationVC = ChooseLocationViewController(nibName: "ChooseLocationViewController", bundle: nil)
                chooseLocationVC.delegate = self
                
                self.present(chooseLocationVC, animated: true, completion: nil)
            }
        }
        return true
    }
    
    func gotSelectedLocation(location: LocationSuggestion) {
        self.isSelectedLocation = true
        self.selectedLocation = location
//        self.location = CLLocation(latitude: location.lat, longitude: location.long)
        self.locationTextField.text = location.name
        self.view.endEditing(true)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if self.choseFocusButton.isFirstResponder{
            self.eventNameTextField.becomeFirstResponder()
        }else if textField == self.eventDateTextField {
            eventDateTextField.inputAccessoryView = self.dateToolbar
            eventDateTextField.inputView = self.datePicker
        }else if textField == self.eventEndDateTextField{
            eventEndDateTextField.inputAccessoryView = self.endDateToolbar
            eventEndDateTextField.inputView = self.datePicker
        }else if textField == self.eventTimeTextField {
            self.eventTimeTextField.inputAccessoryView = self.startTimeToolbar
            self.eventTimeTextField.inputView = self.timePicker
        }else if textField == self.eventEndTimeTextField {
            self.eventEndTimeTextField.inputAccessoryView = self.endTimeToolbar
            self.eventEndTimeTextField.inputView = self.timePicker
        } else if textField == self.locationTextField {
            let chooseLocationVC = ChooseLocationViewController(nibName: "ChooseLocationViewController", bundle: nil)
            chooseLocationVC.delegate = self
            
            self.present(chooseLocationVC, animated: true, completion: nil)
        } else if textField == self.eventPriceTextView {
            self.eventPriceTextView.inputAccessoryView = self.priceToolbar
        }
        
        return true
    }
    
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        textField.becomeFirstResponder()
//    }
    
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
        if (textView.text == ""){
            textView.text = "Description"
        }
        textView.resignFirstResponder()
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.eventDescriptionTextView.inputAccessoryView = self.textViewToolbar
        return true
    }
    
    func keyboardNextButton(){
        if self.eventNameTextField.isFirstResponder{
            print("locationbecome first  ")
            self.eventNameTextField.resignFirstResponder()
            self.locationTextField.becomeFirstResponder()
        } else if self.locationTextField.isFirstResponder {
            self.locationTextField.resignFirstResponder()
            self.eventTimeTextField.becomeFirstResponder()
        }else if self.eventDateTextField.isFirstResponder {
            print("event Time become first  ")
            self.eventTimeTextField.becomeFirstResponder()
            self.eventDateTextField.text = "\(self.dateFormatter.string(from: self.datePicker.date))"
            self.eventDateTextField.resignFirstResponder()
//            self.eventDateTextField.endEditing(true)
        } else if self.eventTimeTextField.isFirstResponder {
            print("locationbecome first  ")
            self.eventEndTimeTextField.becomeFirstResponder()
//            self.eventTimeTextField.text = "\(self.timeFormatter.string(from: self.timePicker.date))"
//            self.startTime = self.timePicker.date
            self.eventTimeTextField.resignFirstResponder()
        } else if self.eventEndTimeTextField.isFirstResponder {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 100), animated: true)
//            if timePicker.date > self.startTime!{
//                self.eventPriceTextView.becomeFirstResponder()
//                self.eventEndTimeTextField.text = "\(self.timeFormatter.string(from: self.timePicker.date))"
//                self.endTime = timePicker.date
//            }
//            else{
//                SCLAlertView().showError("Invalid end time", subTitle: "Please enter end time after start time.")
//            }
            self.eventPriceTextView.becomeFirstResponder()
            self.eventEndTimeTextField.resignFirstResponder()
            
        } else if self.eventPriceTextView.isFirstResponder{
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 100), animated: true)
            self.eventDescriptionTextView.becomeFirstResponder()
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 200), animated: true)
        } else if self.eventDescriptionTextView.isFirstResponder {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: self.scrollView.contentInset.bottom), animated: true)
            //self.searchBar.becomeFirstResponder()
        }
    }
    
    func keyboardPreviousButton(){
//        if self.searchBar.isFirstResponder {
//            self.scrollView.setContentOffset(CGPoint(x: 0, y: self.scrollView.contentOffset.y-20), animated: true)
//            self.eventDescriptionTextView.becomeFirstResponder()
//        } else
        
            if self.eventDescriptionTextView.isFirstResponder {
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
   
extension CreateNewEventViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var componentAmt = 0
        if component == 0 || component == 1{
            componentAmt = 12
        }else if component == 2{
            componentAmt = 2
        }
        return componentAmt
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var componentString = ""
        if component == 0{
            componentString = self.minuteComponent[row]
        }else if component == 1{
            componentString = self.secondComponent[row]
        }else if component == 2{
            componentString = self.ampm[row]
        }
        return componentString
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if component == 0{
            print("changed hour component")
            self.timerObject[0] = self.minuteComponent[row]
        }else if component == 1{
            print("changed minute component")
            self.timerObject[1] = self.secondComponent[row]
        }else if component == 2{
            print("changed am pm component")
            self.timerObject[2] = self.ampm[row]
        }
        
        print(self.timerObject)
        
//        let timeFull = "\(String(format: "%02d", self.timerObject[0]!)):\(String(format: "%02d", self.timerObject[1]!))"
        let timeString = "\(String(describing: self.timerObject[0]!)):\(String(describing: self.timerObject[1]!)) \(String(describing: self.timerObject[2]!))"
        print("timeString: \(timeString)")

        if eventTimeTextField.isFirstResponder{
            let startingTime = timeFormatter.date(from: timeString)
            self.startTime = startingTime!
        }
        
        self.timePicker.selectRow(row, inComponent: component, animated: true)
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 60
    }
}
