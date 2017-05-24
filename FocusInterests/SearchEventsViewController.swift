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
        let nib = UINib(nibName: "SearchPlaceCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "SearchPlaceCell")
        
        self.searchBar.delegate = self
        
        createEventButton.roundCorners(radius: 10)
        tableHeader.topCornersRounded(radius: 10)
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
        
        let cell:SearchPlaceCell = self.tableView.dequeueReusableCell(withIdentifier: "SearchPlaceCell") as! SearchPlaceCell!
        let event = filtered[indexPath.row]
        cell.placeNameLabel.text = event.title
        
        var addressComponents = event.fullAddress?.components(separatedBy: ",")
        let streetAddress = addressComponents?[0]
        
        addressComponents?.remove(at: 0)
        let city = addressComponents?.joined(separator: ", ")
        
        
        cell.addressTextView.text = "\(streetAddress!)\n \(city!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))"
        cell.addressTextView.textContainer.maximumNumberOfLines = 6

        cell.ratingLabel.text = "\(event.attendeeCount) guests"
        cell.categoryLabel.text = "Category"
        cell.checkForFollow(id: event.id!)
        let placeHolderImage = UIImage(named: "empty_event")
        
        let reference = Constants.storage.event.child("\(event.id!).jpg")
        
        // Placeholder image
        let placeholderImage = UIImage(named: "empty_event")
        
        reference.downloadURL(completion: { (url, error) in
            
            if error != nil {
                print(error?.localizedDescription)
                return
            }
        
            cell.placeImage.sd_setImage(with: url, placeholderImage: placeHolderImage)
            
            cell.placeImage.setShowActivityIndicator(true)
            cell.placeImage.setIndicatorStyle(.gray)
            
        })
        cell.followButtonOut.setTitle("Attend", for: .normal)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText.characters.count > 0){
            self.filtered.removeAll()

        
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
