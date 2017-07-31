//
//  CreateEventOnMapViewController.swift
//  FocusInterests
//
//  Created by Alex Jang on 7/28/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class CreateEventOnMapViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UISearchBarDelegate{

    // change location stack
    @IBOutlet weak var currentLocationStack: UIStackView!
    @IBOutlet weak var searchLocationSearchBar: UISearchBar!
    @IBOutlet weak var currentLocationButton: UIButton!
    @IBOutlet weak var mainChangeLocationView: UIView!
    @IBOutlet weak var searchLocationTableView: UITableView!
    
    // add focus stack
    @IBOutlet weak var addFocusStack: UIStackView!
    @IBOutlet weak var addFocusDropdownButton: UIButton!
    @IBOutlet weak var addFocusButton: UIButton!
    @IBOutlet weak var addFocusTableView: UITableView!
    @IBOutlet weak var mainAddFocusView: UIView!
    
    // main stack
    @IBOutlet weak var mainStackView: UIView!
    @IBOutlet weak var mainStack: UIStackView!
    
    // user stack text view
    @IBOutlet weak var userStatusTextView: UITextView!
    
    // go to camera button
    @IBOutlet weak var cameraButton: UIButton!
    
    // set pin buttons
    @IBOutlet weak var pinButton: UIButton!
    @IBOutlet weak var pinImageButton: UIButton!
    
    // side stack
    @IBOutlet weak var lockButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var twitterButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        let searchBarPlaceholderlaceholderAttributes: [String : AnyObject] = [NSForegroundColorAttributeName: UIColor.lightGray, NSFontAttributeName: UIFont(name: "Avenir Book", size: 15)!]
        
        self.searchLocationSearchBar.delegate = self
        self.searchLocationSearchBar.layer.borderWidth = 1
        self.searchLocationSearchBar.layer.borderColor = UIColor.white.cgColor
        self.addFocusButton.setTitle("Add FOCUS", for: .normal)
        self.addFocusButton.setTitleColor(Constants.color.navy, for: .normal)
        self.addFocusButton.setTitle("Add FOCUS", for: .selected)
        self.addFocusButton.setTitleColor(Constants.color.navy, for: .selected)
        
        guard let textFieldInsideSearchBar = self.searchLocationSearchBar.value(forKey: "_searchField") as? UITextField else {
            return
        }
        
        self.searchLocationSearchBar.setValue("Cancel", forKey:"_cancelButtonText")
        
        let cancelButtonsInSearchBar: [String: AnyObject] = [NSForegroundColorAttributeName: UIColor.lightGray, NSFontAttributeName: UIFont(name: "Avenir-Black", size: 15)!]
        
        let attributedPlaceholder: NSAttributedString = NSAttributedString(string: "Change Location", attributes: searchBarPlaceholderlaceholderAttributes)
        
        textFieldInsideSearchBar.attributedPlaceholder = attributedPlaceholder
        textFieldInsideSearchBar.textAlignment = .left
        textFieldInsideSearchBar.textColor = UIColor.lightGray
        textFieldInsideSearchBar.tintColor = UIColor.lightGray
        textFieldInsideSearchBar.backgroundColor = UIColor.white
        
        let glassIconView = textFieldInsideSearchBar.leftView as! UIImageView
        glassIconView.frame = CGRect(x: 0, y: 0, width: 13, height: 18)
        glassIconView.image = #imageLiteral(resourceName: "Pin icon x1")
        
        glassIconView.tintColor = UIColor.red
        
        textFieldInsideSearchBar.clearButtonMode = .whileEditing
        let clearButton = textFieldInsideSearchBar.value(forKey: "clearButton") as! UIButton
        clearButton.setImage(clearButton.imageView?.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: .normal)
        clearButton.tintColor = UIColor.lightGray
        
        UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonsInSearchBar, for: .normal)
        
        self.mainStackView.layer.cornerRadius = 5.0
        self.mainAddFocusView.layer.cornerRadius = 5.0
        self.mainChangeLocationView.layer.cornerRadius = 5.0
        
        self.userStatusTextView.delegate = self
        self.userStatusTextView.tintColor = UIColor.lightGray
        
        self.addFocusTableView.delegate = self
        self.addFocusTableView.dataSource = self
        self.addFocusTableView.layer.cornerRadius = 5.0
        
        let interestCell = UINib(nibName: "SingleInterestTableViewCell", bundle: nil)
        self.addFocusTableView.register(interestCell, forCellReuseIdentifier: "singleInterestCell")
        self.addFocusStack.removeArrangedSubview(self.addFocusTableView)
        
        self.searchLocationTableView.delegate = self
        self.searchLocationTableView.dataSource = self
        self.searchLocationTableView.layer.cornerRadius = 5.0
        
        
        let currentLocationNib = UINib(nibName: "SingleInterestTableViewCell", bundle: nil)
        self.searchLocationTableView.register(currentLocationNib, forCellReuseIdentifier: "singleInterestCell")
        let searchPlaceCell = UINib(nibName: "SearchPlaceCell", bundle: nil)
        self.searchLocationTableView.register(searchPlaceCell, forCellReuseIdentifier: "SearchPlaceCell")
        self.currentLocationStack.removeArrangedSubview(self.searchLocationTableView)
        
        hideKeyboardWhenTappedAround()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func currentLocationPressed(){
        
    }

    @IBAction func lockPressed(_ sender: Any) {
        print("locked pressed")
    }
    
    @IBAction func facebookPressed(_ sender: Any) {
        print("facebook pressed")
    }
    
    @IBAction func twitterPressed(_ sender: Any) {
        print("twitter pressed")
    }
    
    @IBAction func pinPressed(_ sender: Any) {
        print("pin pressed")
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cameraPressed(_ sender: Any) {
        print("camera pressed")
    }
    
    @IBAction func addAFocus(_ sender: Any) {
        self.addFocusDropdownButton.isSelected = !self.addFocusDropdownButton.isSelected
        self.addFocusButton.isSelected = !self.addFocusButton.isSelected
        
        if self.addFocusDropdownButton.isSelected{
            self.addFocusStack.addArrangedSubview(self.addFocusTableView)
            self.view.bringSubview(toFront: self.addFocusStack)
        }else{
            self.addFocusStack.removeArrangedSubview(self.addFocusTableView)
            self.addFocusStack.sendSubview(toBack: self.addFocusStack)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 0{
            return 2
        }else{
            return Constants.interests.interests.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 0 {
            if indexPath.row == 0{
                let currentLocationCell = tableView.dequeueReusableCell(withIdentifier: "singleInterestCell", for: indexPath) as! SingleInterestTableViewCell
                currentLocationCell.interestLabel.text = "Current Location"
                currentLocationCell.interestImage.frame.size.height = 23
                currentLocationCell.interestImage.frame.size.width = 20
                currentLocationCell.interestImage.image = #imageLiteral(resourceName: "Pin icon x1")
                currentLocationCell.layoutIfNeeded()
                currentLocationCell.backgroundColor = UIColor.lightGray
                currentLocationCell.accessoryType = .checkmark
                return currentLocationCell
            }else{
                let searchPlace = tableView.dequeueReusableCell(withIdentifier: "SearchPlaceCell", for: indexPath) as! SearchPlaceCell
                searchPlace.backgroundColor = UIColor.lightGray
                return searchPlace
            }
            
        }else{
            let interestCell = tableView.dequeueReusableCell(withIdentifier: "singleInterestCell", for: indexPath) as! SingleInterestTableViewCell
            let interestName = Constants.interests.interests[indexPath.row]
            
            interestCell.interestLabel.text = interestName
            interestCell.interestImage.image = UIImage(named: "\(interestName) Green")
            return interestCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 0{
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }else if tableView.tag == 1{
            let interestCell = tableView.cellForRow(at: indexPath) as! SingleInterestTableViewCell
            
            interestCell.accessoryType = .checkmark
            interestCell.tintColor = Constants.color.green
    
            self.addFocusButton.setTitle(interestCell.interestLabel.text, for: .normal)
            self.addFocusButton.setTitle(interestCell.interestLabel.text, for: .selected)
            self.addFocusStack.removeArrangedSubview(self.addFocusTableView)
            self.addFocusStack.sendSubview(toBack: self.addFocusStack)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.tag == 1{
            guard let selectedCell = tableView.cellForRow(at: indexPath) else{
                return
            }
            selectedCell.accessoryType = .none
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.tag == 0{
            if indexPath.row == 0{
                return 40
            }else{
                return 110
            }
        }else{
            return 40
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell.isSelected{
            cell.accessoryType = .checkmark
        }else{
            cell.accessoryType = .none
        }
    }
    
    
//    MARK: Search Bar Delegate Methods

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.addFocusStack.removeArrangedSubview(self.addFocusTableView)
        self.addFocusStack.sendSubview(toBack: self.addFocusTableView)
        self.searchLocationSearchBar.setShowsCancelButton(true, animated: true)
        self.currentLocationStack.addArrangedSubview(self.searchLocationTableView)
        self.view.bringSubview(toFront: self.currentLocationStack)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchLocationSearchBar.text = ""
        self.searchLocationSearchBar.setShowsCancelButton(false, animated: true)
        self.currentLocationStack.endEditing(true)
        self.currentLocationStack.removeArrangedSubview(self.searchLocationTableView)
        self.view.sendSubview(toBack: self.currentLocationStack)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.searchLocationSearchBar.text = ""
        self.searchLocationSearchBar.setShowsCancelButton(false, animated: true)
        self.currentLocationStack.removeArrangedSubview(self.searchLocationTableView)
        self.view.sendSubview(toBack: self.currentLocationStack)
        self.view.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchLocationSearchBar.text = ""
        self.searchLocationSearchBar.setShowsCancelButton(false, animated: true)
        self.currentLocationStack.removeArrangedSubview(self.searchLocationTableView)
        self.view.sendSubview(toBack: self.currentLocationStack)
        self.view.endEditing(true)
    }
    
//    MARK: TextView delegate methods
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text != "" {
            textView.text = ""
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
