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
    @IBOutlet weak var tableHeader: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var people = [User]()
    var filtered = [User]()
    var location: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 6
        tableView.clipsToBounds = true
        
        
        let nib = UINib(nibName: "SearchPeopleTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "SearchPlaceCell")
        
        self.searchBar.delegate = self
        
        tableHeader.topCornersRounded(radius: 10)
        
        filtered = people
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let ref = Constants.DB.user
        _ = ref.queryLimited(toLast: 10).observeSingleEvent(of: .value, with: { snapshot in
            let users = snapshot.value as? [String : Any] ?? [:]
            
            for (_, user) in users{
                let info = user as? [String:Any]
                
                let user = User(username: info?["username"] as! String? , uuid: info?["firebaseUserId"] as! String?, userImage: nil, interests: nil)
                
                if user.uuid != AuthApi.getFirebaseUid() && user.uuid != nil{
                    self.people.append(user)
                }
            }
            self.filtered = self.people
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
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "SearchPlaceCell") as! SearchPeopleTableViewCell!
        
        let people = filtered[indexPath.row]
        cell?.username.text = people.username
        cell?.fullName.text = "Full Name"
        
        cell?.address.text = ""
        cell?.distance.text = ""
        
//        var addressComponents = event.fullAddress?.components(separatedBy: ",")
//        let streetAddress = addressComponents?[0]
//        
//        addressComponents?.remove(at: 0)
//        let city = addressComponents?.joined(separator: ", ")
//        
//        
//        cell?.address.text = "\(streetAddress!)\n\(city!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))"
//        cell?.address.textContainer.maximumNumberOfLines = 6
        cell?.ID = people.uuid!
        cell?.checkFollow()
        cell?.interest.text = "Category"
        //cell.checkForFollow(id: event.id!)
        let placeHolderImage = UIImage(named: "empty_event")
        
//        let reference = Constants.storage.event.child("\(event.id!).jpg")
//        
//        // Placeholder image
//        _ = UIImage(named: "empty_event")
//        
//        reference.downloadURL(completion: { (url, error) in
//            
//            if error != nil {
//                print(error?.localizedDescription ?? "")
//                return
//            }
//            
//            cell?.userImage?.sd_setImage(with: url, placeholderImage: placeHolderImage)
//            
//            cell?.userImage?.setShowActivityIndicator(true)
//            cell?.userImage?.setIndicatorStyle(.gray)
//            
//        })
        
        cell?.followButton.roundCorners(radius: 10)
        cell?.inviteButton.roundCorners(radius: 10)
        
        cell?.followButton.tag = indexPath.row
        cell?.followButton.addTarget(self, action: #selector(self.followUser), for: UIControlEvents.touchUpInside)
        
        cell?.inviteButton.tag = indexPath.row
        cell?.inviteButton.addTarget(self, action: #selector(self.inviteUser), for: UIControlEvents.touchUpInside)
        
        return cell!
    }
    
    func followUser(sender:UIButton){
        let buttonRow = sender.tag
        
        print("following user \(self.people[buttonRow].username) ")
    }
    
    func inviteUser(sender:UIButton){
        let buttonRow = sender.tag
        
        print("invite user \(self.people[buttonRow].username) ")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText.characters.count > 0){
            self.filtered.removeAll()
            
            let ref = Constants.DB.user
            _ = ref.queryOrdered(byChild: "username").queryStarting(atValue: searchText.lowercased()).queryEnding(atValue: searchText.lowercased()+"\u{f8ff}").observe(.value, with: { snapshot in
                let users = snapshot.value as? [String : Any] ?? [:]
                
                for (_, user) in users{
                    let info = user as? [String:Any]
                    
                    let user = User(username: info?["username"] as! String? , uuid: info?["firebaseUserId"] as! String?, userImage: nil, interests: nil)
                    
                    if user.uuid != AuthApi.getFirebaseUid(){
                        self.filtered.append(user)
                    }
                }
                self.tableView.reloadData()
            })
        }
        else{
            self.filtered = self.people
            self.tableView.reloadData()
        }
        
        
    }
    
    @IBAction func showCreateEvent(_ sender: UIButton) {
        
        let storyboard = UIStoryboard(name: "CreateEvent", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "createEvent")
        self.present(controller, animated: true, completion: nil)
        
        
    }
    
}

