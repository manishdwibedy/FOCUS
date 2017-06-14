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
    
    var people = [User]()
    var filtered = [User]()
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
        self.moreButton.layer.borderColor = UIColor.white.cgColor
        self.moreButton.roundCorners(radius: 5.0)
        
        filtered = people
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let ref = Constants.DB.user
        _ = ref.queryLimited(toLast: 10).observeSingleEvent(of: .value, with: { snapshot in
            let users = snapshot.value as? [String : Any] ?? [:]
            
            for (_, user) in users{
                let info = user as? [String:Any]
                
                let user = User(username: info?["username"] as! String? , uuid: info?["firebaseUserId"] as! String?, userImage: nil, interests: nil, image_string: nil)
                
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
        cell?.parentVC = self
        
        let people = filtered[indexPath.row]
        if(people.username == "" || people.username == nil){
            cell?.username.text = "No username"
        }else{
            cell?.username.text = people.username
        }
        
        cell?.fullName.text = "Full Name"
        
        cell?.address.text = "1234 Grand Ave.\nPasadena, CA 91101"
        cell?.distance.text = "2.1m"
        
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
            print("now unfollowing user")
            print("UNFOLLOW ID")
            //           Constants.DB.user.child(AuthApi.getFirebaseUid()!).child("following").child("people").queryOrdered(byChild: "UID").queryEqual(toValue: ID).observeSingleEvent(of: .value, with: { (snapshot) in
            //                let value = snapshot.value as? [String:Any]
            //
            //                for (id, _) in value!{
            //                    Constants.DB.user.child(AuthApi.getFirebaseUid()!).child("following/people/\(id)").removeValue()
            //                }
            //
            //                })
            //            Constants.DB.user.child(self.ID).child("followers").child("people").queryOrdered(byChild: "UID").queryEqual(toValue: AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: { (snapshot) in
            //                let value = snapshot.value as? [String:Any]
            //
            //                for (id, _) in value!{
            //                    Constants.DB.user.child(self.ID).child("followers/people/\(id)").removeValue()
            //
            //                }
            //
            //            })
            
            //            follow button appearance
            
            //            alert controller view
            
            let unfollowAlertController = UIAlertController(title: "\n\n\n\n\n\n", message: "Are you sure you want to unfollow \(self.people[buttonRow].username!)", preferredStyle: .actionSheet)
            
            let margin:CGFloat = 10.0
            let rect = CGRect(x: margin, y: margin, width: unfollowAlertController.view.bounds.size.width - margin * 4.0, height: CGFloat(120))
            let customView = UIView(frame: rect)
            
            customView.backgroundColor = .green
            let imgViewTitle = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            imgViewTitle.image = self.people[buttonRow].userImage
            customView.addSubview(imgViewTitle)
            unfollowAlertController.view.addSubview(customView)
//            let imgViewTitle = UIImageView(frame: CGRect(x: 10, y: 10, width: 30, height: 30))
//            imgViewTitle.image = self.people[buttonRow].userImage
            
//            unfollowAlertController.view.addSubview(imgViewTitle)
            
            let unfollowAction = UIAlertAction(title: "Unfollow", style: .destructive) { action in
                print("unfollow has been tapped")
                print("now following user is followUserAction")
                
//                unfollow button view
                
                sender.isSelected = false
                sender.backgroundColor = UIColor(red: 31/255.0, green: 50/255.0, blue: 73/255.0, alpha: 1.0)
                sender.tintColor = UIColor(red: 31/255.0, green: 50/255.0, blue: 73/255.0, alpha: 1.0)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
                print("cancel has been tapped")
            }
            
            unfollowAlertController.addAction(unfollowAction)
            unfollowAlertController.addAction(cancelAction)
            self.present(unfollowAlertController, animated: true, completion: nil)
        }

    }
    
    func inviteUser(sender:UIButton){
        let buttonRow = sender.tag
        
        print("invite user \(self.people[buttonRow].username) ")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText.characters.count > 0){
            self.filtered.removeAll()
            
            let ref = Constants.DB.user
            _ = ref.queryOrdered(byChild: "username").queryStarting(atValue: searchText.lowercased()).queryEnding(atValue: searchText.lowercased()+"\u{f8ff}").observe(.value, with: { snapshot in
                let users = snapshot.value as? [String : Any] ?? [:]
                
                for (_, user) in users{
                    let info = user as? [String:Any]
                    
                    let user = User(username: info?["username"] as! String? , uuid: info?["firebaseUserId"] as! String?, userImage: nil, interests: nil, image_string: nil)
                    
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

