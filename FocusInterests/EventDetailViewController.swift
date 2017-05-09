//
//  EventDetailViewController.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 4/19/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import SDWebImage
import Firebase

class EventDetailViewController: UIViewController {
    @IBOutlet weak var likeCount: UILabel!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var hostInfoLabel: UITextView!
    @IBOutlet weak var descriptionLabel: UITextView!
    
    @IBOutlet weak var commentsView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var commentTextField: UITextField!
    var event: Event?
    @IBOutlet weak var image: UIImageView!
    let ref = FIRDatabase.database().reference()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Reference to an image file in Firebase Storage
        
        self.navigationItem.title = self.event?.title
        
        let reference = Constants.storage.event.child("\(event!.id!).jpg")
        
        // Placeholder image
        let placeholderImage = UIImage(named: "empty_event")
        
        reference.downloadURL(completion: { (url, error) in
            
            if error != nil {
                print(error?.localizedDescription)
                return
            }
            
            self.image.sd_setImage(with: url, placeholderImage: placeholderImage)
            self.image.setShowActivityIndicator(true)
            self.image.setIndicatorStyle(.gray)
            
        })
        image.contentMode = .scaleAspectFill
        commentTextField.layer.borderWidth = 1
        commentTextField.layer.cornerRadius = 5
        commentTextField.clipsToBounds = true
        commentTextField.layer.borderColor = UIColor.white.cgColor
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        
        eventTitleLabel.text = event?.title
        hostInfoLabel.text = (event?.fullAddress)! + "\n\n"
        hostInfoLabel.text = hostInfoLabel.text! + (event?.date)! + "\n"
        descriptionLabel.text = event?.description
        
        
        ref.child("users").child(AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if value != nil
            {
                let placeString = ("Add comment as " + (value?["username"] as! String))
                var placeHolder = NSMutableAttributedString()
                placeHolder = NSMutableAttributedString(string:placeString, attributes: [NSFontAttributeName:UIFont(name: "Helvetica", size: 15.0)!])
                placeHolder.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 255, green: 255, blue: 255, alpha: 0.8), range:NSRange(location:0,length:placeString.characters.count))
                self.commentTextField.attributedPlaceholder = placeHolder
                
            }
            
        })
        
        
        ref.child("events").child((event?.id)!).child("comments").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if value != nil
            {
                print(value!)
                
                for (key,_) in value!
                {
                    let dict = value?[key] as! NSDictionary
                    let comm = comment(frame: self.commentsView.frame,fromUID: dict["fromUID"] as! String, comment: dict["comment"] as! String)
                    self.commentsView.addSubview(comm.view)
                    //self.commentsView.frame.size = CGSize(width: self.commentsView.frame.width, height: comm.view.frame.height)
                    // self.commentTextField.frame.origin.y = self.commentsView.frame.origin.y + self.commentsView.frame.height + 10
                    //self.commentTextField.updateConstraints()
                    
                }
            }
            
        })
        
        
        
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func inviteEvent(_ sender: UIButton) {
    }
    
    @IBAction func likeEvent(_ sender: UIButton) {
        let eventRef = Constants.DB.event.child("\(event!.id!)")
        //        if eventRef.child("likes").exi
    }
    
    @IBAction func attendEvent(_ sender: UIButton) {
    }
    
    @IBAction func mapEvent(_ sender: Any) {
    }
    
    @IBAction func postComment(_ sender: Any) {
        ref.child("events").child((event?.id)!).child("comments").childByAutoId().updateChildValues(["fromUID":AuthApi.getFirebaseUid()!, "comment":commentTextField.text!])
    }
    
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            self.scrollView.frame.origin.y = -((keyboardHeight))
            
            
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
    
    
    class comment
    {
        let ref = FIRDatabase.database().reference()
        let view = UIView()
        let commentLabel = UILabel()
        let fromLabel = UILabel()
        init(frame:CGRect,fromUID:String, comment: String) {
            self.view.frame.size = CGSize(width: frame.width, height: 60)
            commentLabel.text = comment
            ref.child("users").child(fromUID).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                if value != nil
                {
                    self.fromLabel.text = value?["username"] as? String
                }
                
            })
            
            self.fromLabel.frame = CGRect(x: 0, y: 0, width: frame.width, height: self.view.frame.height/2)
            self.fromLabel.font = UIFont(name: "Helvetica-Light", size: 17)
            self.fromLabel.textAlignment = .left
            self.fromLabel.backgroundColor = UIColor.clear
            self.fromLabel.textColor = UIColor.white
            self.view.addSubview(self.fromLabel)
            
            self.commentLabel.frame = CGRect(x: 20, y: self.fromLabel.frame.height, width: frame.width, height: (self.view.frame.height/2))
            self.commentLabel.font = UIFont(name: "Helvetica-Light", size: 17)
            self.commentLabel.textAlignment = .left
            self.commentLabel.backgroundColor = UIColor.clear
            self.commentLabel.textColor = UIColor.white
            self.view.addSubview(self.commentLabel)
            
            let line = CAShapeLayer()
            let linePath = UIBezierPath()
            linePath.move(to: CGPoint(x: 0, y: self.view.frame.height))
            linePath.addLine(to: CGPoint(x: self.view.frame.width, y: self.view.frame.height))
            line.path = linePath.cgPath
            line.strokeColor = UIColor.white.cgColor
            line.lineWidth = 1
            line.lineJoin = kCALineJoinRound
            self.view.layer.addSublayer(line)
            
        }
        
    }
    
    
    
    
    
    
}
