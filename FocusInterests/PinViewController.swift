//
//  PinViewController.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/16/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class PinViewController: UIViewController, InviteUsers, UITableViewDataSource, SuggestPlacesDelegate {
    var place: Place?
    
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
    @IBOutlet weak var suggestPlacesStackView: UIStackView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    var placeVC: PlaceViewController? = nil
    
    
    @IBOutlet weak var webButton: UIButton!
    @IBOutlet weak var uberButton: UIButton!
    @IBOutlet weak var googleMapButton: UIButton!
    
    var data = [NSDictionary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        placeVC?.suggestPlacesDelegate = self
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
        
        
        categoryBackground.addTopBorderWithColor(color: UIColor.white, width: 1)
        categoryBackground.addBottomBorderWithColor(color: UIColor.white, width: 1)
        
        for view in categoriesStackView.subviews{
            view.removeFromSuperview()
        }
        
        for (index, category) in (place.categories.enumerated()){
            let textLabel = UILabel()
            
            textLabel.textColor = .white
            textLabel.text  = category.name
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
            
            view.image.image = UIImage(named: "addUser")
        }
        
        webButton.setImage(UIImage(named: "web"), for: .normal)
        webButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        
        uberButton.setImage(UIImage(named: "uber"), for: .normal)
        uberButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        
        googleMapButton.setImage(UIImage(named: "maps"), for: .normal)
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
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = Bundle.main.loadNibNamed("PinTableViewCell", owner: self, options: nil)?.first as! PinTableViewCell
        cell.data = data[indexPath.row]
        cell.comment.text = data[indexPath.row]["pin"] as! String
        cell.loadLikes()
        cell.parentVC = self
        Constants.DB.user.child(data[indexPath.row]["fromUID"] as! String).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if value != nil
            {
                cell.username.text = value?["username"] as? String
                
            }
            
        })
        return cell
    }
    
    func inviteUser(name: String) {
        print("clicked \(name)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func gotSuggestedPlaces(places: [Place]) {
        for (index, place) in places.enumerated(){
            let view = suggestPlacesStackView.arrangedSubviews[index] as! SuggestPlaceView
            view.place = place
            view.name.text = place.name
            view.name.textColor = .white
            view.imageView.sd_setImage(with: URL(string: place.image_url), placeholderImage: UIImage(named: "addUser"))
            view.imageView.roundedImage()
            
            view.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            view.addGestureRecognizer(tap)
            
        }
    }
    
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
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
