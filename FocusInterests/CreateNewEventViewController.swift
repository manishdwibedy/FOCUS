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
        formatTextFields()
    }
    
    
    @IBAction func addEventLocation(_ sender: UITextField) {
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        present(autoCompleteController, animated: true, completion: nil)
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
        switch section {
        case 0 :
            return 3
        case 1:
            return 3
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = interestTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! InterestTableViewCell
            return cell
            
        case 1:
            let cell = interestTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! InterestTableViewCell
            return cell
            
        default:
            let cell = interestTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! InterestTableViewCell
            
            return cell
        }
        
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







