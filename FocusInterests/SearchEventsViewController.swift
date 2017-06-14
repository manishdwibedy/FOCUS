//
//  SearchEventsViewController.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/23/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import SDWebImage
import Alamofire
import CoreLocation
import SwiftyJSON
import FirebaseDatabase

class SearchEventsViewController: UIViewController, UITableViewDelegate,UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var navTitle: UINavigationItem!
    
    @IBOutlet weak var tableHeader: UIView!
    @IBOutlet weak var createEventButton: UIButton!
    var events = [Event]()
    var filtered = [Event]()
    var location: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView.clipsToBounds = true
        
        let nib = UINib(nibName: "SearchEventTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
        
        
        
        self.searchBar.delegate = self
        
        self.searchBar.isTranslucent = true
        self.searchBar.backgroundImage = UIImage()
        self.searchBar.tintColor = UIColor.white
        self.searchBar.barTintColor = UIColor.white
        self.searchBar.backgroundColor = UIColor(red: 31/255.0, green: 50/255.0, blue: 73/255.0, alpha: 1.0)
        self.searchBar.layer.cornerRadius = 6
        self.searchBar.clipsToBounds = true
        self.searchBar.layer.borderWidth = 2
        self.searchBar.layer.borderColor = UIColor(red: 119/255.0, green: 197/255.0, blue: 53/255.0, alpha: 1.0).cgColor
        
        
        createEventButton.roundCorners(radius: 10)
        
        filtered = events
        
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.location = AuthApi.getLocation()
        
        Constants.DB.event.observe(DataEventType.value, with: { (snapshot) in
            let events = snapshot.value as? [String : Any] ?? [:]
            
            for (id, event) in events{
                let info = event as? [String:Any]
                let event = Event(title: (info?["title"])! as! String, description: (info?["description"])! as! String, fullAddress: (info?["fullAddress"])! as! String, shortAddress: (info?["shortAddress"])! as! String, latitude: (info?["latitude"])! as! String, longitude: (info?["longitude"])! as! String, date: (info?["date"])! as! String, creator: (info?["creator"])! as! String, id: id, category: info?["interest"] as? String)
                
                if let attending = info?["attendingList"] as? [String:Any]{
                    event.setAttendessCount(count: attending.count)
                }
                
                self.events.append(event)
                
            }
            self.filtered = self.events
            self.tableView.reloadData()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtered.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! SearchEventTableViewCell!
        
        let event = filtered[indexPath.row]
        cell?.name.text = event.title
        
        var addressComponents = event.fullAddress?.components(separatedBy: ",")
        let streetAddress = addressComponents?[0]
        
        addressComponents?.remove(at: 0)
        let city = addressComponents?.joined(separator: ", ")
        
        
        cell?.address.text = "\(streetAddress!)\n\(city!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))"
        cell?.address.textContainer.maximumNumberOfLines = 6

        let eventLocation = CLLocation(latitude: Double(event.latitude!)!, longitude: Double(event.longitude!)!)
        cell?.distance.text = getDistance(fromLocation: self.location!, toLocation: eventLocation,addBracket: false)

        cell?.guestCount.text = "\(event.attendeeCount) guests"
        cell?.interest.text = "Category"
        cell?.price.text = "Price"
        //cell.checkForFollow(id: event.id!)
        let placeHolderImage = UIImage(named: "empty_event")
        
        if let category = event.category?.components(separatedBy: ";")[0]{
            cell?.interest.text = "\(category)"
        }
        else{
            cell?.interest.text = "N.A."
        }
        
        if let price = event.price{
            if price == 0{
                cell?.price.text = "Free"
            }
            else{
                cell?.price.text = "\(price)"
            }
            
        }
        
        let reference = Constants.storage.event.child("\(event.id!).jpg")
        
        // Placeholder image
        _ = UIImage(named: "empty_event")
        
        reference.downloadURL(completion: { (url, error) in
            
            if error != nil {
                print(error?.localizedDescription ?? "")
                return
            }
        
            cell?.eventImage?.sd_setImage(with: url, placeholderImage: placeHolderImage)
            
            cell?.eventImage?.setShowActivityIndicator(true)
            cell?.eventImage?.setIndicatorStyle(.gray)
            
        })
        
//        MARK: THESE WERE COMMENTED OUT SINCE ATTENDING BUTTON WAS REMOVED
//        attending
//        Constants.DB.event.child((event.id)!).child("attendingList").queryOrdered(byChild: "UID").queryEqual(toValue: AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: { (snapshot) in
//            let value = snapshot.value as? NSDictionary
//            if value != nil
//            {
//                cell?.attendButton.backgroundColor = UIColor.clear
//                cell?.attendButton.setTitle("Unattend", for: UIControlState.normal)
//            }
//            
//        })
        
        cell?.inviteButton.roundCorners(radius: 10)
        cell?.inviteButton.layer.shadowOpacity = 1.0
        cell?.inviteButton.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        cell?.inviteButton.layer.masksToBounds = false
        cell?.inviteButton.layer.shadowColor = UIColor.black.cgColor
        cell?.inviteButton.layer.shadowRadius = 10.0
        
        cell?.inviteButton.tag = indexPath.row
        cell?.inviteButton.addTarget(self, action: #selector(self.inviteUser), for: UIControlEvents.touchUpInside)
        
        return cell!
    }
    
    
    
    func attendEvent(sender:UIButton){
        let buttonRow = sender.tag
        let event = self.events[buttonRow]
        
        if sender.title(for: .normal) == "Attend"{
            print("attending event \(event.title) ")
            
            Constants.DB.event.child((event.id)!).child("attendingList").childByAutoId().updateChildValues(["UID":AuthApi.getFirebaseUid()!])
            
            
            Constants.DB.event.child((event.id)!).child("attendingAmount").observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                if value != nil
                {
                    let attendingAmount = value?["amount"] as! Int
                    Constants.DB.event.child((event.id)!).child("attendingAmount").updateChildValues(["amount":attendingAmount + 1])
                }
            })
            
            sender.backgroundColor = UIColor.clear
            sender.setTitle("Unattend", for: .normal)
        }
        else{
            Constants.DB.event.child((event.id)!).child("attendingList").queryOrdered(byChild: "UID").queryEqual(toValue: AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? [String:Any]
                
                for (id,_) in value!{
                    Constants.DB.event.child("\(event.id!)/attendingList/\(id)").removeValue()
                }
                
            })
            
            Constants.DB.event.child((event.id)!).child("attendingAmount").observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                if value != nil
                {
                    let attendingAmount = value?["amount"] as! Int
                    Constants.DB.event.child((event.id)!).child("attendingAmount").updateChildValues(["amount":attendingAmount - 1])
                }
            })
            sender.backgroundColor = UIColor(red: 31/255.0, green: 50/255.0, blue: 73/255.0, alpha: 1.0)
            sender.setTitle("Attend", for: .normal)
        }
        
    }
    
    func inviteUser(sender:UIButton){
        let buttonRow = sender.tag
        
        let event = self.events[buttonRow]
        print("invite user to event \(event.title) ")
        
        let storyboard = UIStoryboard(name: "Invites", bundle: nil)
        let ivc = storyboard.instantiateViewController(withIdentifier: "home") as! InviteViewController
        ivc.type = "event"
        ivc.id = event.id!
        ivc.event = event
        self.present(ivc, animated: true, completion: { _ in })
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event = self.events[indexPath.row]
        let storyboard = UIStoryboard(name: "EventDetails", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "eventDetailVC") as! EventDetailViewController
        controller.event = event
        self.present(controller, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText.characters.count > 0){
            self.filtered.removeAll()

            let ref = Constants.DB.event
            let query = ref.queryOrdered(byChild: "title").queryStarting(atValue: searchText.lowercased()).queryEnding(atValue: searchText.lowercased()+"\u{f8ff}").observe(.value, with: { snapshot in
                let events = snapshot.value as? [String : Any] ?? [:]
                
                for (id, event) in events{
                    let info = event as? [String:Any]
                    let event = Event(title: (info?["title"])! as! String, description: (info?["description"])! as! String, fullAddress: (info?["fullAddress"])! as! String, shortAddress: (info?["shortAddress"])! as! String, latitude: (info?["latitude"])! as! String, longitude: (info?["longitude"])! as! String, date: (info?["date"])! as! String, creator: (info?["creator"])! as! String, id: id, category: info?["interest"] as? String)
                    
                    if let attending = info?["attendingList"] as? [String:Any]{
                        event.setAttendessCount(count: attending.count)
                    }
                    
                    self.filtered.append(event)
                }
                self.tableView.reloadData()
            })
        }
        else{
            self.filtered = self.events
            self.tableView.reloadData()
        }
        
        
    }
    
    @IBAction func showCreateEvent(_ sender: UIButton) {
        
        let storyboard = UIStoryboard(name: "CreateEvent", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "createEvent")
        self.present(controller, animated: true, completion: nil)

        
    }

}
