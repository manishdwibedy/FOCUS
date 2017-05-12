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

class EventDetailViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var likeCount: UILabel!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var hostNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UITextView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UITextView!
    @IBOutlet weak var navBarView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var commentTextField: UITextField!
    var event: Event?
    @IBOutlet weak var image: UIImageView!
    let ref = FIRDatabase.database().reference()
    var blur: UIVisualEffectView!
    let commentsCList = NSMutableArray()
    override func viewDidLoad() {
        super.viewDidLoad()
        // add nav bar
        let bar = MapNavigationView()
        self.navBarView.addSubview(bar)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let nib = UINib(nibName: "commentCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
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
        image.clipsToBounds = true
        commentTextField.layer.borderWidth = 1
        commentTextField.layer.cornerRadius = 5
        commentTextField.clipsToBounds = true
        commentTextField.layer.borderColor = UIColor.white.cgColor
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillHide, object: nil)
        
        eventTitleLabel.text = event?.title
        timeLabel.text = event?.date
        addressLabel.text = event?.fullAddress
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
        
        let fullRef = ref.child("events").child((event?.id)!).child("comments")
        fullRef.queryOrdered(byChild: "date").queryLimited(toFirst: 1).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if value != nil
            {
                print(value!)
                
                for (key,_) in value!
                {
                    let dict = value?[key] as! NSDictionary
                    let data = commentCellData(from: dict["fromUID"] as! String, comment: dict["comment"] as! String, commentFirePath: fullRef.child(String(describing: key)), likeCount: (dict["like"] as! NSDictionary)["num"] as! Int)
                    self.commentsCList.add(data)
                    
                    
                    
                }
            }
            
            self.tableView.reloadData()
            if self.commentsCList.count != 0
            {
                let oldLastCellIndexPath = NSIndexPath(row: self.commentsCList.count-1, section: 0)
                self.tableView.scrollToRow(at: oldLastCellIndexPath as IndexPath, at: .bottom, animated: true)
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
        let unixDate = NSDate().timeIntervalSince1970
        let fullRef = ref.child("events").child((event?.id)!).child("comments").childByAutoId()
        fullRef.updateChildValues(["fromUID":AuthApi.getFirebaseUid()!, "comment":commentTextField.text!, "like":["num":0], "date": NSNumber(value: Double(unixDate))])
        
        let data = commentCellData(from: AuthApi.getFirebaseUid()!, comment: commentTextField.text!, commentFirePath: fullRef, likeCount: 0)
        self.commentsCList.removeObject(at: 0)
        self.commentsCList.add(data)
        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath(row: commentsCList.count-1, section: 0)], with: .automatic)
        tableView.endUpdates()
        commentTextField.resignFirstResponder()
        commentTextField.text = ""
        self.scrollView.frame.origin.y = 0
        self.view.frame.origin.y = 0
        let oldLastCellIndexPath = NSIndexPath(row: commentsCList.count-1, section: 0)
        self.tableView.scrollToRow(at: oldLastCellIndexPath as IndexPath, at: .bottom, animated: true)
    }
    
    
    @IBAction func moreComments(_ sender: Any) {
        scrollView.contentOffset = CGPoint(x: 0, y: 0)
        let storyboard = UIStoryboard(name: "EventDetails", bundle: nil)
        let ivc = storyboard.instantiateViewController(withIdentifier: "allComments") as! allCommentsVC
        ivc.parentVC = self
        ivc.parentEvent = event
        self.present(ivc, animated: true, completion: { _ in })
        
        
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
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
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentsCList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:commentCell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! commentCell!
        cell.data = (commentsCList[indexPath.row] as! commentCellData)
        cell.commentLabel.text = (commentsCList[indexPath.row] as! commentCellData).comment
        cell.likeCount.text = String((commentsCList[indexPath.row] as! commentCellData).likeCount)
        cell.checkForLike()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
        
    }
    
    
    
    
    
    
}
