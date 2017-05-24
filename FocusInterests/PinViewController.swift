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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        placeVC?.suggestPlacesDelegate = self
        loadInfoScreen(place: self.place!)
        
    }
    
    func loadInfoScreen(place: Place){
        // Do any additional setup after loading the view.
        
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
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = Bundle.main.loadNibNamed("PinTableViewCell", owner: self, options: nil)?.first as! PinTableViewCell
        cell.username.text = "hello"
        cell.comment.text = "asasasasa"
        cell.focus.text = "dummy"
        cell.time.text = "Just now"
        cell.userImage.image = UIImage(named: "addUser")
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
