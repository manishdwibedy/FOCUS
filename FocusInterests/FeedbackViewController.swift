//
//  FeedbackViewController.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/27/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class FeedbackViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textView.textColor = UIColor.gray
        textView.text = "Please enter your feedback here..."
        textView.roundCorners(radius: 10)
        textView.delegate = self
        
        sendButton.roundCorners(radius: 10)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendFeedback(_ sender: Any) {
        if !textView.text.isEmpty{
            let time = NSDate().timeIntervalSince1970
            Constants.DB.feedback.childByAutoId().updateChildValues(["fromUID": AuthApi.getFirebaseUid()!, "time": Double(time), "feedback": textView.text])
        }
    }

    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.gray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if textView.text.isEmpty {
            textView.text = "Please enter your feedback here..."
            textView.textColor = UIColor.gray
        }
        return true
    }

}
