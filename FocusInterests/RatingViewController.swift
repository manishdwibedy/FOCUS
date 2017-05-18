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
        
    @IBOutlet weak var ratingSubmitted: UIButton!
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
