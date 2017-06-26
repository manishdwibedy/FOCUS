//
//  PlaceViewController.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/15/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

protocol CommentsDelegate {
    func gotComments(comments: [PlaceRating])
}

protocol SuggestPlacesDelegate {
    func gotSuggestedPlaces(places: [Place])
}

class PlaceViewController: UIViewController {
    var commentsDelegate: CommentsDelegate?
    var suggestPlacesDelegate: SuggestPlacesDelegate?
    
    var place: Place?
    var rating = [PlaceRating]()
    var currentLocation: CLLocation?
    
    @IBOutlet weak var ratingView: UIView!
    @IBOutlet weak var pinView: UIView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var ratingBackground: UIView!
    @IBOutlet weak var navBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        ratingBackground.layer.cornerRadius = 5
        self.loadPlace(place: self.place!)
        
        hideKeyboardWhenTappedAround()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showRating(sender:)))
        
        ratingBackground.addGestureRecognizer(tapGesture)
        
        let attrs = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "Avenir-Black", size: 18)!
        ]
        
        navBar.titleTextAttributes = attrs
    }
    
    func showRating(sender: UITapGestureRecognizer) {
        let storyboard = UIStoryboard(name: "Reviews", bundle: nil)
        let VC = storyboard.instantiateViewController(withIdentifier: "reviews") as? ReviewsViewController
        VC?.place = place
        self.present(VC!, animated: true, completion: nil)
        
        

    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func valueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            UIView.animate(withDuration: 0.5, animations: {
                self.pinView.alpha = 1
                self.ratingView.alpha = 0
            })
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.pinView.alpha = 0
                self.ratingView.alpha = 1
            })
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pinInfo"{
            let pin = segue.destination as! PinViewController
            pin.placeVC = self
            pin.place = self.place
        }
        else if segue.identifier == "rating"{
            let rating = segue.destination as! RatingViewController
            rating.placeVC = self
            rating.place = self.place
            rating.ratings = self.rating
        }
    }
    
    func loadPlace(place: Place){
        navigationBar.topItem?.title = place.name
        ratingLabel.text = "\(place.rating)"
        
        imageView.sd_setImage(with: URL(string: (place.image_url)), placeholderImage: nil)
        self.getLatestComments()
        fetchSuggestedPlaces(token: AuthApi.getYelpToken()!)
        
    }
    func getLatestComments(){
        let place = Constants.DB.places
        let comments = place.child((self.place?.id)!).child("comments")
        
        comments.queryOrdered(byChild: "date").queryLimited(toLast: 5).observeSingleEvent(of: .value, with: {snapshot in
            
            if let comments = snapshot.value as? [String: [String: Any]]{
                for (_, comment) in comments.enumerated(){
                    print(comment.key)
                    let id = comment.value["user"] as! String
                    var commentText = comment.value["comment"] as! String
                    let rating = comment.value["rating"] as! Double
                    let date = comment.value["date"] as! Double
                    
                    if commentText.characters.count == 0{
                        commentText = "No comment was provided."
                    }
                    
                    let placeComment = PlaceRating(uid: id, date: Date(timeIntervalSince1970: date), rating: rating)
                    
                    Constants.DB.user.child(id).observeSingleEvent(of: .value, with: {snapshot in
                        let value = snapshot.value as! [String: Any]
                        let username = value["username"] as! String
                        placeComment.setUsername(username: username)
                        
                        self.commentsDelegate?.gotComments(comments: self.rating)
                    })
                    
                    
                    
                    if commentText.characters.count > 0{
                        placeComment.addComment(comment: commentText)
                    }
                    self.rating.append(placeComment)
                }
            }
            
            
        })
    }
    
    func fetchSuggestedPlaces(token: String){
        if let location = self.currentLocation{
            getNearbyPlaces(location: location)
        }
        else{
            let location = CLLocation(latitude: (self.place?.latitude)!, longitude: (self.place?.longitude)!)
            getNearbyPlaces(location: location)
        }
        
    }
    
    func getNearbyPlaces(location: CLLocation){
        let url = "https://api.yelp.com/v3/businesses/search"
        let categories = self.place?.categories.map { $0.alias }.joined(separator: ",")
        
        let parameters: [String: Any] = [
            "latitude" : Double(location.coordinate.latitude),
            "longitude" : Double(location.coordinate.longitude),
            "categories": categories!,
            "limit": 3
        ]
        
        let headers: HTTPHeaders = [
            "authorization": "Bearer \(AuthApi.getYelpToken()!)",
            "cache-contro": "no-cache"
        ]
        
        Alamofire.request(url, method: .get, parameters:parameters, headers: headers).responseJSON { response in
            var suggestedPlaces = [Place]()
            let json = JSON(data: response.data!)
            
            for (_, business) in json["businesses"].enumerated(){
                let id = business.1["id"].stringValue
                let name = business.1["name"].stringValue
                let image_url = business.1["image_url"].stringValue
                let isClosed = business.1["is_closed"].boolValue
                let reviewCount = business.1["review_count"].intValue
                let rating = business.1["rating"].floatValue
                let latitude = business.1["coordinates"]["latitude"].doubleValue
                let longitude = business.1["coordinates"]["longitude"].doubleValue
                let price = business.1["price"].stringValue
                let address_json = business.1["location"]["display_address"].arrayValue
                let phone = business.1["display_phone"].stringValue
                let distance = business.1["distance"].doubleValue
                let categories_json = business.1["categories"].arrayValue
                let url = business.1["url"].stringValue
                let plain_phone = business.1["phone"].stringValue
                
                var address = [String]()
                for raw_address in address_json{
                    address.append(raw_address.stringValue)
                }
                
                var categories = [Category]()
                for raw_category in categories_json as [JSON]{
                    let category = Category(name: raw_category["title"].stringValue, alias: raw_category["alias"].stringValue)
                    categories.append(category)
                }
                
                let place = Place(id: id, name: name, image_url: image_url, isClosed: isClosed, reviewCount: reviewCount, rating: rating, latitude: latitude, longitude: longitude, price: price, address: address, phone: phone, distance: distance, categories: categories, url: url, plainPhone: plain_phone)
                
                if !suggestedPlaces.contains(place){
                    suggestedPlaces.append(place)
                }
            }
            
            self.suggestPlacesDelegate?.gotSuggestedPlaces(places: suggestedPlaces)
        }
    }
    
    
    
    @IBAction func reviewButon(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Reviews", bundle: nil)
        let ivc = storyboard.instantiateViewController(withIdentifier: "Reviews") as! UINavigationController
        let reviewVC = ivc.viewControllers[0] as! ReviewsViewController
        reviewVC.place = self.place
        self.present(ivc, animated: true, completion: { _ in })
    }
    
    
    
    

}
