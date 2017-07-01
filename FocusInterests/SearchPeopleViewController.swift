//
//  SearchPeopleViewController.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/24/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import SDWebImage
import Alamofire
import CoreLocation
import SwiftyJSON

class SearchPeopleViewController: UIViewController, UITableViewDelegate,UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var navBar: UINavigationBar!
    
    var people = [User]()
    var filtered = [User]()
    var followers = [User]()
    var user_pins = [String:pinData]()
    var location: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let greenPinImage = UIImage(named: "pin")
//        greenPinImage!.imageScaled(to: CGSize(width: 10, height: 10))
//        let greenPinImageView = UIImageView(image: greenPinImage)
//        self.navigationItem.title =  greenPinImageView + " People"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 6
        tableView.clipsToBounds = true
        
        
        let nib = UINib(nibName: "SearchPeopleTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "SearchPlaceCell")
        
        self.searchBar.delegate = self
        
        //        search bar attributes
        let placeholderAttributes: [String : AnyObject] = [NSForegroundColorAttributeName: UIColor.white]
        let attributedPlaceholder: NSAttributedString = NSAttributedString(string: "Search", attributes: placeholderAttributes)
        
        //        search bar placeholder
        let textFieldInsideSearchBar = self.searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.backgroundColor = Constants.color.navy
        textFieldInsideSearchBar?.attributedPlaceholder = attributedPlaceholder
        textFieldInsideSearchBar?.textColor = UIColor.white
        
        //        search bar glass icon
        let glassIconView = textFieldInsideSearchBar?.leftView as! UIImageView
        glassIconView.image = glassIconView.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        glassIconView.tintColor = UIColor.white
        
        //        search bar clear button
        textFieldInsideSearchBar?.clearButtonMode = .whileEditing
        let clearButton = textFieldInsideSearchBar?.value(forKey: "clearButton") as! UIButton
        clearButton.setImage(clearButton.imageView?.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: .normal)
        clearButton.tintColor = UIColor.white
        
        UIBarButtonItem.appearance().setTitleTextAttributes(placeholderAttributes, for: .normal)
        
        self.moreButton.layer.borderColor = UIColor.white.cgColor
        self.moreButton.roundCorners(radius: 5.0)
        
        filtered = people
        hideKeyboardWhenTappedAround()
        
        
        let attrs = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "Avenir-Black", size: 18)!
        ]
        
        navBar.titleTextAttributes = attrs
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        let ref = Constants.DB.user
        
        ref.child(AuthApi.getFirebaseUid()!).child("following/people").observeSingleEvent(of: .value, with: {snapshot in
            if let value = snapshot.value as? [String:Any]{
                for (id, people) in value{
                    let followingCount = value.count
                    if let peopleData = people as? [String:Any]{
                        let UID = peopleData["UID"] as! String
                        ref.child(UID).observeSingleEvent(of: .value, with: { snapshot in
                            let user = snapshot.value as? [String:Any]
                            if let user = User.toUser(info: user!){
                                if user.uuid != AuthApi.getFirebaseUid(){
                                    Constants.DB.pins.child(user.uuid!).observeSingleEvent(of: .value, with: { (snapshot) in
                                        let value = snapshot.value as? NSDictionary
                                        if let value = value
                                        {
                                            if let pin = pinData.toPin(user: user, value: value){
                                                self.user_pins[user.uuid!] = pin
                                                user.hasPin = true
                                                
                                                let pinLocation = CLLocation(latitude: pin.coordinates.latitude, longitude: pin.coordinates.longitude)
                                                user.pinDistance = pinLocation.distance(from: AuthApi.getLocation()!)
                                            }
                                        }
                                        self.followers.append(user)
                                        
                                        self.followers.sort {
                                            if $0.hasPin && $1.hasPin{
                                                return $0.pinDistance < $1.pinDistance
                                            }
                                            return $0.hasPin && !$1.hasPin
                                        }
                                        
                                        if self.followers.count == followingCount{
                                            self.filtered = self.followers + self.filtered
                                            self.tableView.reloadData()
                                        }
                                        
                                    })
                                }
                            }
                        })
                    }
                }
            }
        })
        _ = ref.queryLimited(toLast: 10).observeSingleEvent(of: .value, with: { snapshot in
            let users = snapshot.value as? [String : Any] ?? [:]
            
            let count = users.count
            self.people.removeAll()
            for (_, user) in users{
                let info = user as? [String:Any]
                
                let userCount = users.count
                if let info = info{
                    if let user = User.toUser(info: info){
                        if user.uuid != AuthApi.getFirebaseUid(){
                            Constants.DB.pins.child(user.uuid!).observeSingleEvent(of: .value, with: { (snapshot) in
                                let value = snapshot.value as? NSDictionary
                                if let value = value
                                {
                                    if let pin = pinData.toPin(user: user, value: value){
                                        self.user_pins[user.uuid!] = pin
                                        user.hasPin = true
                                        
                                        let pinLocation = CLLocation(latitude: pin.coordinates.latitude, longitude: pin.coordinates.longitude)
                                        user.pinDistance = pinLocation.distance(from: AuthApi.getLocation()!)
                                    }
                                }
                                self.people.append(user)
                                
                                self.people.sort {
                                    if $0.hasPin && $1.hasPin{
                                        return $0.pinDistance < $1.pinDistance
                                    }
                                    return $0.hasPin && !$1.hasPin
                                }
                                
                                self.filtered = self.followers + self.people
                                self.tableView.reloadData()
                            })
                        }
                    }
                }
            }
            
        })
        
        let cancelButtonAttributes: [String: AnyObject] = [NSForegroundColorAttributeName: UIColor.white]
        
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(cancelButtonAttributes, for: .normal)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtered.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "SearchPlaceCell") as! SearchPeopleTableViewCell!
        cell?.parentVC = self
        
        let people = filtered[indexPath.row]
        if(people.username == "" || people.username == nil){
            cell?.username.text = "No username"
        }else{
            cell?.username.text = people.username
        }
        
        
        cell?.fullName.text = people.fullname
        let pin = user_pins[people.uuid!]
        
        
        if people.hasPin{
            cell?.pinAvailable = true
            cell?.shortBackground.isHidden = true
            var address = pin?.locationAddress
            address = address?.replacingOccurrences(of: ";;", with: "\n")
            cell?.whiteBorder.isHidden = false
            cell?.address.text = pin?.pinMessage
            addGreenDot(label: (cell?.interest)!, content: (pin?.focus)!)
            let pinLocation = CLLocation(latitude: (pin?.coordinates.latitude)!, longitude: (pin?.coordinates.longitude)!)
            cell?.distance.text = getDistance(fromLocation: pinLocation, toLocation: AuthApi.getLocation()!)
            cell?.cellContentView.backgroundColor = UIColor(red: 97/255.0, green: 115/255.0, blue: 129/255.0, alpha: 1.0)
        }
        else{
            cell?.whiteBorder.isHidden = true
            cell?.address.text = ""
            cell?.distance.text = ""
            
//            cell?.cellHeight.constant = 70
            cell?.interest.text = ""
            cell?.cellContentView.backgroundColor = .clear
            cell?.shortBackground.isHidden = false
            
        }
    
        cell?.ID = people.uuid!
        //cell.checkForFollow(id: event.id!)
        
        let placeHolderImage = UIImage(named: "empty_event")

        cell?.checkFollow()
        
        return cell!
    }
    
    
    func followUser(sender:UIButton){
        let time = NSDate().timeIntervalSince1970
        
        let buttonRow = sender.tag
        
        
        if sender.isSelected == false {
            sender.isSelected = true
            sender.layer.borderColor = UIColor.white.cgColor
            sender.layer.borderWidth = 1
            sender.backgroundColor = UIColor(red: 149/255.0, green: 166/255.0, blue: 181/255.0, alpha: 1.0)
            sender.tintColor = UIColor(red: 149/255.0, green: 166/255.0, blue: 181/255.0, alpha: 1.0)
            
        } else if sender.isSelected == true{
            
            
            
        }

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "SearchPlaceCell") as! SearchPeopleTableViewCell!
        cell?.parentVC = self
        
        let people = filtered[indexPath.row]
        
        let VC = UIStoryboard(name: "UserProfile", bundle: nil).instantiateViewController(withIdentifier: "Home") as! UserProfileViewController
        
        VC.otherUser = true
        VC.userID = people.uuid!
        VC.previous = .people
        dropfromTop(view: self.view)
        
        self.present(VC, animated:true, completion:nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "SearchPlaceCell") as! SearchPeopleTableViewCell!
        
        let people = filtered[indexPath.row]
        if people.hasPin{
            return 110
        }
        else{
            
//            cell.content
//            cell?.cellContentViewHeightConstraint.constant = 60.0
////            cell?.subviews[0].subviews[0].frame.size.height = 70.0
//            cell?.distanceCategoryStack.arrangedSubviews[0].removeFromSuperview()
//            cell?.distanceCategoryStack.spacing = 0
//            cell?.addressStack.arrangedSubviews[0].removeFromSuperview()
//            
//            cell?.cellContentView.clipsToBounds = true
//            cell?.cellContentView.allCornersRounded(radius: 6.0)
//            
//            cell?.cellContentView.layoutIfNeeded()
//            
//            print(cell?.cellContentView.frame.height)
            return 75
        }
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText.characters.count > 0){
            self.filtered.removeAll()
            
            let ref = Constants.DB.user
            _ = ref.queryOrdered(byChild: "username").queryStarting(atValue: searchText.lowercased()).queryEnding(atValue: searchText.lowercased()+"\u{f8ff}").observeSingleEvent(of: .value, with: { snapshot in
                let users = snapshot.value as? [String : Any] ?? [:]
                
                let count = users.count
                for (_, user) in users{
                    if let info = user as? [String:Any]{
                        if let user = User.toUser(info: info){
                            if user.uuid != AuthApi.getFirebaseUid(){
                                Constants.DB.pins.child(user.uuid!).observeSingleEvent(of: .value, with: { (snapshot) in
                                    let value = snapshot.value as? NSDictionary
                                    if let value = value
                                    {
                                        if let pin = pinData.toPin(user: user, value: value){
                                            self.user_pins[user.uuid!] = pin
                                            user.hasPin = true
                                            
                                            let pinLocation = CLLocation(latitude: pin.coordinates.latitude, longitude: pin.coordinates.longitude)
                                            user.pinDistance = pinLocation.distance(from: AuthApi.getLocation()!)
                                        }
                                    }
                                    self.filtered.append(user)
                                    
                                    self.filtered.sort {
                                        if $0.hasPin && $1.hasPin{
                                            return $0.pinDistance < $1.pinDistance
                                        }
                                        return $0.hasPin && !$1.hasPin
                                    }
                                    
                                    self.tableView.reloadData()
                                })
                            }
                        }
                    }
                }
                
            })
        }
        else{
            self.filtered = self.people
            self.tableView.reloadData()
        }
        
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.text = ""
        self.searchBar.setShowsCancelButton(false, animated: true)
        self.filtered = self.people
        self.tableView.reloadData()
        searchBar.resignFirstResponder()
    }
    
    @IBAction func showCreateEvent(_ sender: UIButton) {
        
        let storyboard = UIStoryboard(name: "CreateEvent", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "createEvent")
        self.present(controller, animated: true, completion: nil)
        
        
    }
    
}

