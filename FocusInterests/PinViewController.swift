//
//  PinViewController.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/16/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class PinViewController: UIViewController, InviteUsers, UITableViewDataSource, UITextViewDelegate{
    var place: Place?
    
    @IBOutlet weak var postReviewSeciontButton: UIButton!
    @IBOutlet weak var moreCategoriesSectionButton: UIButton!
    @IBOutlet weak var morePinSectionButton: UIButton!
    @IBOutlet weak var moreOtherLikesButton: UIButton!
    
    @IBOutlet weak var reviewsView: UIView!
    @IBOutlet weak var reviewsTextView: UITextView!
    
    // basic info screen
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var reviewButton: UIButton!
    
    // categories
    
    @IBOutlet weak var categoryBackground: UIView!
    @IBOutlet weak var categoriesStackView: UIStackView!
    
    
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var cityStateLabel: UILabel!
    @IBOutlet weak var streetAddress: UILabel!
    @IBOutlet weak var hoursStackView: UIStackView!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var inviteUserStackView: UIStackView!
    @IBOutlet weak var infoScreenHeight: NSLayoutConstraint!
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
//    @IBOutlet weak var suggestPlacesStackView: UIStackView!
    @IBOutlet weak var peopleAlsoLikedTableView: UITableView!
    
    @IBOutlet weak var writeReviewView: UITextView!
    @IBOutlet weak var starRatingView: UIView!
    @IBOutlet weak var pinView: UIView!
    @IBOutlet weak var inviteView: UIView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var categoryView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var placeVC: PlaceViewController? = nil
    var ratingID: String?
    var rating: Int? = nil
    
    
    @IBOutlet weak var webButton: UIButton!
    @IBOutlet weak var uberButton: UIButton!
    @IBOutlet weak var googleMapButton: UIButton!
    
    @IBOutlet weak var categoryTop: NSLayoutConstraint!
    
    //rating
    @IBOutlet weak var ratingView: UIView!
    
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var button5: UIButton!
    
    var data = [NSDictionary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pinPlaceReviewNib = UINib(nibName: "PinPlaceReviewTableViewCell", bundle: nil)
        self.table.register(pinPlaceReviewNib, forCellReuseIdentifier: "pinPlaceReviewCell")
        
        let nib = UINib(nibName: "SearchPlaceCell", bundle: nil)
        self.peopleAlsoLikedTableView.register(nib, forCellReuseIdentifier: "SearchPlaceCell")
        
//        placeVC?.suggestPlacesDelegate = self
        loadInfoScreen(place: self.place!)
        
        hideKeyboardWhenTappedAround()
        
        var address = ""
        for str in (place?.address)!
        {
            address = address + " " + str
            
        }
        Constants.DB.pins.queryOrdered(byChild: "formattedAddress").queryEqual(toValue: address).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if value != nil
            {
                for (key,_) in value!
                {
                    self.data.append(value?[key] as! NSDictionary)
                }
            }
            self.table.reloadData()
            
        })
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.callPlace))
        phoneLabel.isUserInteractionEnabled = true
        phoneLabel.addGestureRecognizer(tap)
        
        reviewsView.alpha = 0
        categoryTop.constant = 100
        
        button1.addTarget(self, action: #selector(selectedRating), for: .touchUpInside)
        button2.addTarget(self, action: #selector(selectedRating), for: .touchUpInside)
        button3.addTarget(self, action: #selector(selectedRating), for: .touchUpInside)
        button4.addTarget(self, action: #selector(selectedRating), for: .touchUpInside)
        button5.addTarget(self, action: #selector(selectedRating), for: .touchUpInside)

    }
    
    func callPlace(sender:UITapGestureRecognizer) {
        guard let number = URL(string: "tel://" + (place?.plainPhone)!) else { return }
        UIApplication.shared.open(number)
    }
    
    func loadInfoScreen(place: Place){
        // Do any additional setup after loading the view.
        
        placeNameLabel.text = place.name
        if place.price.characters.count == 0{
            costLabel.text = "N.A."
        }
        else{
            costLabel.text = place.price
        }
        
        distanceLabel.text = "2 mi"
        followButton.roundCorners(radius: 10)
        reviewButton.roundCorners(radius: 10)
        
        postReviewSeciontButton.layer.borderWidth = 1
        moreCategoriesSectionButton.layer.borderWidth = 1
        morePinSectionButton.layer.borderWidth = 1
        moreOtherLikesButton.layer.borderWidth = 1
        
        postReviewSeciontButton.layer.borderColor = UIColor.white.cgColor
        moreCategoriesSectionButton.layer.borderColor = UIColor.white.cgColor
        morePinSectionButton.layer.borderColor = UIColor.white.cgColor
        moreOtherLikesButton.layer.borderColor = UIColor.white.cgColor
        
        postReviewSeciontButton.roundCorners(radius: 5)
        moreCategoriesSectionButton.roundCorners(radius: 5)
        morePinSectionButton.roundCorners(radius: 5)
        moreOtherLikesButton.roundCorners(radius: 5)
        
        
        starRatingView.topCornersRounded(radius: 10)
        writeReviewView.bottomCornersRounded(radius: 10)
        
        for view in categoriesStackView.subviews{
            view.removeFromSuperview()
        }
        
        for (index, category) in (place.categories.enumerated()){
            let textLabel = UILabel()
            
            textLabel.textColor = .white
            textLabel.text  = getInterest(yelpCategory: category.alias)
            textLabel.textAlignment = .left
            
            
            if index == 0{
                textLabel.text = textLabel.text! + " ●"
                
                let primaryFocus = NSMutableAttributedString(string: textLabel.text!)
                primaryFocus.addAttribute(NSForegroundColorAttributeName, value: UIColor.green, range: NSRange(location:(textLabel.text?.characters.count)! - 1,length:1))
                textLabel.attributedText = primaryFocus
                
                
                
            }
            
            categoriesStackView.addArrangedSubview(textLabel)
            categoriesStackView.translatesAutoresizingMaskIntoConstraints = false;
        }
        streetAddress.text = place.address[0]
        if place
            .address.count == 2{
            cityStateLabel.text = place.address[1]
        }
        else{
            cityStateLabel.text = ""
        }
        
        phoneLabel.text = place.phone
        
        if let open_hours = place.hours{
            let hours = getOpenHours(open_hours)
            infoScreenHeight.constant += CGFloat(25 * hours.count)
            viewHeight.constant += CGFloat(25 * hours.count)
            
            for (_, hour) in (hours.enumerated()){
                let textLabel = UILabel()
                
                textLabel.text  = hour
                textLabel.textAlignment = .left
                textLabel.textColor = .white
                
                hoursStackView.addArrangedSubview(textLabel)
                hoursStackView.translatesAutoresizingMaskIntoConstraints = false;
            }
        }
        
        let invite = ["user1", "user2", "user3"]
        
        for (index, user) in invite.enumerated(){
            let view = inviteUserStackView.arrangedSubviews[index] as! InviteUserView
            view.userName.text = user
            view.userName.textColor = .white
            view.delegate = self
            
            view.image.image = UIImage(named: "UserPhoto")
        }
        
        webButton.setImage(UIImage(named: "Community Green"), for: .normal)
        webButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        
        uberButton.setImage(UIImage(named: "uber"), for: .normal)
        uberButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        
        googleMapButton.setImage(UIImage(named: "Large_Apple_Maps.png"), for: .normal)
        googleMapButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
    }

    // function which is triggered when handleTap is called
    func handleTap(_ sender: UITapGestureRecognizer) {
        let view = sender.view as! SuggestPlaceView
        print("Tapped \(view.name.text)")
        placeVC?.loadPlace(place: view.place!)
        self.loadInfoScreen(place: view.place!)
        
        self.scrollView.setContentOffset(CGPoint(x: 0,y: -self.scrollView.contentInset.top), animated: true)

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView.tag == 0){
            return 2
        }else{
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        var cell = UITableViewCell()
        if (tableView.tag == 0){
            let pinCell = self.table.dequeueReusableCell(withIdentifier: "pinPlaceReviewCell", for: indexPath) as! PinPlaceReviewTableViewCell
            //        let pinCell = Bundle.main.loadNibNamed("PinPlaceReviewTableViewCell", owner: self, options: nil)?.first as! PinPlaceReviewTableViewCell
            
            //        cell.data = data[indexPath.row]
            pinCell.usernameLabel.text = "username"
            pinCell.categoryLabel.text = "category" //add image after category here
            pinCell.timeOfPinLabel.text = "31min"
            pinCell.commentsTextView.text = "Comments"
            //        pinCell.commentsTextView.text = data[indexPath.row]["pin"] as! String
            
            //        cell.loadLikes()
            //        cell.parentVC = self
            
            /*
             Constants.DB.user.child(data[indexPath.row]["fromUID"] as! String).observeSingleEvent(of: .value, with: { (snapshot) in
             let value = snapshot.value as? NSDictionary
             if value != nil
             {
             pinCell.usernameLabel.text = value?["username"] as? String
             
             }
             
             })
             */
            return pinCell
        }else{
            
            let otherPlacesCell = self.peopleAlsoLikedTableView.dequeueReusableCell(withIdentifier: "SearchPlaceCell", for: indexPath) as! SearchPlaceCell
            otherPlacesCell.placeCellView.backgroundColor = UIColor.clear
            otherPlacesCell.layer.backgroundColor = UIColor.clear.cgColor
            otherPlacesCell.placeNameLabel.text = "place name"
            otherPlacesCell.ratingLabel.text = "4.3"
            otherPlacesCell.categoryLabel.text = "Mexican"
            otherPlacesCell.distanceLabel.text = "4.3 mi"
            
            return otherPlacesCell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(tableView.tag == 0){
            return 70
        }else{
            return 105
        }
    }
    
    func inviteUser(name: String) {
        print("clicked \(name)")
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func gotSuggestedPlaces(places: [Place]) {
//        for (index, place) in places.enumerated(){
//            let view = suggestPlacesStackView.arrangedSubviews[index] as! SuggestPlaceView
//            view.place = place
//            view.name.text = place.name
//            view.name.textColor = .white
//            view.imageView.sd_setImage(with: URL(string: place.image_url), placeholderImage: UIImage(named: "addUser"))
//            view.imageView.roundedImage()
//            
//            view.isUserInteractionEnabled = true
//            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
//            view.addGestureRecognizer(tap)
//            
//        }
//    }
//    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    @IBAction func openWebSite(_ sender: Any) {
        UIApplication.shared.openURL(NSURL(string: (place?.url)!)! as URL)

    }
    
    @IBAction func openUber(_ sender: Any) {
        let lat = place?.latitude as! Double
        let long = place?.longitude as! Double
        var address = place?.address[0] as! String
        address = address.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        let url_string = "uber://?client_id=1Z-d5Wq4PQoVsSJFyMOVdm1nExWzrpqI&action=setPickup&pickup=my_location&dropoff[latitude]=\(lat)&dropoff[longitude]=\(long)&dropoff[nickname]=\(address)&product_id=a1111c8c-c720-46c3-8534-2fcdd730040d"
        
        //let url  = URL(string: url_string.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)
        let url = URL(string: url_string)
        if UIApplication.shared.canOpenURL(url!) == true
        {
            UIApplication.shared.openURL(url!)
        }
        
    }
    
    @IBAction func openGoogleMaps(_ sender: Any) {
        let lat = place?.latitude as! Double
        let long = place?.longitude as! Double
        
        
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            UIApplication.shared.openURL(URL(string:
                "comgooglemaps://?daddr=\(lat),\(long)&directionsmode=driving")!)
        } else {
            print("Can't use comgooglemaps://");
        }
    }
    
    @IBAction func pin(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Pin", bundle: nil)
        let ivc = storyboard.instantiateViewController(withIdentifier: "Home") as! PinScreenViewController
        ivc.pinType = "place"
        for str in (place?.address)!
        {
         ivc.formmatedAddress = ivc.formmatedAddress + " " + str
        
        }
        ivc.coordinates.latitude = (place?.latitude)!
        ivc.coordinates.longitude = (place?.longitude)!
        ivc.locationName = (place?.name)!
        self.present(ivc, animated: true, completion: { _ in })
        
    }
    
    @IBAction func morePins(_ sender: Any) {
        let storyboard = UIStoryboard(name: "PlaceDetails", bundle: nil)
        let ivc = storyboard.instantiateViewController(withIdentifier: "pinList") as! PlaceAllPinsViewController
        for str in (place?.address)!
        {
            ivc.placeID = ivc.placeID + " " + str
            
        }
        self.present(ivc, animated: true, completion: { _ in })
    }
    
    // MARK: TEXT VIEW DELEGATE METHODS
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.reviewsTextView.text = ""
    }
    
    @IBAction func showReview(_ sender: Any) {
        if reviewsView.alpha == 1{
            reviewsView.alpha = 0
            categoryTop.constant = 100
        }
        else{
            reviewsView.alpha = 1
            categoryTop.constant = 215
        }
        
    }
    
    @IBAction func selectedRating(sender: UIButton){
        self.rating = sender.tag
        for select in 1...sender.tag{
            let button = ratingView.viewWithTag(select) as! UIButton
            button.setImage(#imageLiteral(resourceName: "Star"), for: .normal)
        }
        
        if sender.tag < 5{
            for unselected in sender.tag + 1...5{
                let button = ratingView.viewWithTag(unselected) as! UIButton
                button.setImage(#imageLiteral(resourceName: "Unstar.png"), for: .normal)
            }    
        }
        
    }
    
    @IBAction func postComment(_ sender: Any) {
        let place = Constants.DB.places
        let comments = place.child((self.place?.id)!).child("comments")
        
        let comment = comments.childByAutoId()
        
        if let rating = self.ratingID{
            comments.child(rating).setValue([
                "rating": self.rating,
                "comment": reviewsTextView.text,
                "date": Date().timeIntervalSince1970,
                "user": AuthApi.getFirebaseUid()!
                ])
        }
        else{
            comment.setValue([
                "rating": self.rating,
                "comment": reviewsTextView.text,
                "date": Date().timeIntervalSince1970,
                "user": AuthApi.getFirebaseUid()!
                ])
            self.ratingID = comment.key
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
