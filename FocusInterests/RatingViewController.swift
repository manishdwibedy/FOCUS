//
//  RatingViewController.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/17/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import Cosmos

class RatingViewController: UIViewController, UITextViewDelegate, UITableViewDataSource, Comments{

    @IBOutlet weak var rating: CosmosView!
    @IBOutlet weak var comment: UITextView!
    @IBOutlet weak var submitRatingButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    var placeVC: PlaceViewController? = nil
    
    var place: Place?
    var ratingID: String?
    var ratings = [PlaceRating]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        placeVC?.delegate = self

        // Do any additional setup after loading the view.
        rating.settings.fillMode = .half
        comment.textColor = UIColor.white
        comment.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RatingViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        
        rating.didFinishTouchingCosmos = { rating in
            self.submitRatingButton.isEnabled = true
        }
        
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if comment.textColor == UIColor.lightGray {
            comment.text = nil
            comment.textColor = UIColor.white
        }
    }

    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if comment.text.isEmpty {
            comment.text = "Please enter your comments here..."
            comment.textColor = UIColor.white
        }
        return true
    }
    
    
    @IBAction func ratingSubmitted(_ sender: UIButton) {
        let place = Constants.DB.places
        let comments = place.child((self.place?.id)!).child("comments")
        
        let comment = comments.childByAutoId()
        
        var commentText = ""
        
        if self.comment.textColor != UIColor.lightGray{
            commentText = self.comment.text
        }
        
        if let rating = self.ratingID{
            comments.child(rating).setValue([
                "rating": self.rating.rating,
                "comment": commentText,
                "date": Date().timeIntervalSince1970,
                "user": AuthApi.getFirebaseUid()!
                ])
        }
        else{
            comment.setValue([
                "rating": self.rating.rating,
                "comment": commentText,
                "date": Date().timeIntervalSince1970,
                "user": AuthApi.getFirebaseUid()!
                ])
            self.ratingID = comment.key
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ratings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("RatingViewCell", owner: self, options: nil)?.first as! RatingViewCell
        let comment = self.ratings[indexPath.row]
        
        if let user = comment.username{
            cell.userName.text = "By: \(user)"
        }
        else{
            cell.userName.text = "hello"
        }
        
        cell.rating.rating = comment.rating
        cell.comments.text = comment.comment
        cell.time.text = DateFormatter().timeSince(from: comment.date, numericDates: true)
        
        if let commentText = comment.comment{
            cell.comments.text = commentText
        }
        return cell
        
    }
    
    func gotComments(comments: [PlaceRating]) {
        self.ratings = comments
        self.tableView.reloadData()
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
