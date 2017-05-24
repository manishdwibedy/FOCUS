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
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 6
        tableView.clipsToBounds = true
        
        let nib = UINib(nibName: "SearchEventTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "SearchPlaceCell")
        
        self.searchBar.delegate = self
        
        createEventButton.roundCorners(radius: 10)
        tableHeader.topCornersRounded(radius: 10)
        
        filtered = events
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.filtered = events
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtered.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "SearchPlaceCell") as! SearchEventTableViewCell!
        
        let event = filtered[indexPath.row]
        cell?.name.text = event.title
        
        var addressComponents = event.fullAddress?.components(separatedBy: ",")
        let streetAddress = addressComponents?[0]
        
        addressComponents?.remove(at: 0)
        let city = addressComponents?.joined(separator: ", ")
        
        
        cell?.address.text = "\(streetAddress!)\n\(city!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))"
        cell?.address.textContainer.maximumNumberOfLines = 6


        cell?.guestCount.text = "\(event.attendeeCount) guests"
        cell?.interest.text = "Category"
        cell?.price.text = "Price"
        //cell.checkForFollow(id: event.id!)
        let placeHolderImage = UIImage(named: "empty_event")
        
        let reference = Constants.storage.event.child("\(event.id!).jpg")
        
        // Placeholder image
        let placeholderImage = UIImage(named: "empty_event")
        
        reference.downloadURL(completion: { (url, error) in
            
            if error != nil {
                print(error?.localizedDescription ?? "")
                return
            }
        
            cell?.eventImage?.sd_setImage(with: url, placeholderImage: placeHolderImage)
            
            cell?.eventImage?.setShowActivityIndicator(true)
            cell?.eventImage?.setIndicatorStyle(.gray)
            
        })
        
        cell?.attendButton.roundCorners(radius: 10)
        cell?.inviteButton.roundCorners(radius: 10)
        
        cell?.attendButton.tag = indexPath.row
        cell?.attendButton.addTarget(self, action: #selector(self.attendEvent), for: UIControlEvents.touchUpInside)

        cell?.inviteButton.tag = indexPath.row
        cell?.inviteButton.addTarget(self, action: #selector(self.inviteUser), for: UIControlEvents.touchUpInside)
        
        return cell!
    }
    
    func attendEvent(sender:UIButton){
        let buttonRow = sender.tag

        print("attending event \(self.events[buttonRow].title) ")
    }
    
    func inviteUser(sender:UIButton){
        let buttonRow = sender.tag
        
        print("invite user to event \(self.events[buttonRow].title) ")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
                    let event = Event(title: (info?["title"])! as! String, description: (info?["description"])! as! String, fullAddress: (info?["fullAddress"])! as! String, shortAddress: (info?["shortAddress"])! as! String, latitude: (info?["latitude"])! as! String, longitude: (info?["longitude"])! as! String, date: (info?["date"])! as! String, creator: (info?["creator"])! as! String, id: id)
                    
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
