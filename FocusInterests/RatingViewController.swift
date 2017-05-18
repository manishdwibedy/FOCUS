//
//  RatingViewController.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/17/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import Cosmos

class RatingViewController: UIViewController, UITextViewDelegate{

    @IBOutlet weak var rating: CosmosView!
    @IBOutlet weak var comment: UITextView!
    var place: Place?
    @IBOutlet weak var submitRatingButton: UIButton!
    var ratingID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        rating.settings.fillMode = .half
        comment.textColor = UIColor.lightGray
        comment.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RatingViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        
        rating.didFinishTouchingCosmos = { rating in
            self.submitRatingButton.isEnabled = true
        }
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
            comment.textColor = UIColor.black
        }
    }

    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if comment.text.isEmpty {
            comment.text = "Please enter your comments here..."
            comment.textColor = UIColor.lightGray
        }
        return true
    }
    
    
    @IBAction func ratingSubmitted(_ sender: UIButton) {
        let place = Constants.DB.places
        let comments = place.child((self.place?.id)!).child("comments")
        
        let comment = comments.childByAutoId()
        
        if let rating = self.ratingID{
            comments.child(rating).setValue([
                "rating": self.rating.rating,
                "comment": self.comment.text,
                "date": Date().timeIntervalSince1970,
                "user": AuthApi.getFirebaseUid()!
                ])
        }
        else{
            comment.setValue([
                "rating": self.rating.rating,
                "comment": self.comment.text,
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
