//
//  CommentsViewController.swift
//  FocusInterests
//
//  Created by Alex Jang on 6/7/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import Crashlytics

class CommentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate{

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var addCommentView: UIView!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var commentsTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var addCommentsViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainStackHeight: NSLayoutConstraint!
    
    var data: NSDictionary!
    var commentData = [[String:Any]]()
    var eventComments = NSMutableArray()
    var type = ""
    let commentDF = DateFormatter()
    
    let screenSize = UIScreen.main.bounds
    var screenWidth: CGFloat = 0.0
    var screenHeight: CGFloat = 0.0
    
    let toolBar = UIToolbar()
    let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: #selector(CommentsViewController.cancelPressed))
    let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let commentsNib = UINib(nibName: "CommentsTableViewCell", bundle: nil)
        self.commentsTableView.register(commentsNib, forCellReuseIdentifier: "commentsCell")
        self.commentsTableView.tableFooterView = UIView()
        self.postButton.roundCorners(radius: 5.0)
        
        if type == "pin"{
            Constants.DB.pins.child(data["fromUID"] as! String).child("comments").queryOrdered(byChild: "date").observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? [String:Any]
                var info = [String:Any]()
                if value != nil
                {
                    for (key,_) in value!
                    {
                        info[key] = value?[key] as! [String:Any]
                    }
                    
                    let myArr = Array(info.keys)
                    let sortedKeys = myArr.sorted(by: {
                        let val1 = info[$0] as? [String: Any]
                        let val2 = info[$1] as? [String: Any]
                        
                        let date1 = val1!["date"] as! Double
                        let date2 = val2!["date"] as! Double
                        return date1 < date2
                    })
                    
                    for key in sortedKeys{
                        self.commentData.append(info[key] as! [String : Any])
                    }
                }
                self.commentsTableView.reloadData()
            })
        }
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
        
        self.addCommentView.frame.origin.y = self.screenSize.height - self.addCommentView.frame.size.height
//        self.scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: (self.view.frame.size.height - self.navBar.frame.height))
        
        self.commentTextView.delegate = self
        self.commentTextView.textContainer.maximumNumberOfLines = 0
        self.commentTextView.layer.borderWidth = 1.0
        self.commentTextView.layer.borderColor = UIColor.white.cgColor
        self.commentTextView.layer.cornerRadius = 5.0
        
        let placeholderAttributes: [String : AnyObject] = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "Avenir Book", size: 15)!
        ]
        let placeholderTextAttributes: NSAttributedString = NSAttributedString(string: "Add a comment", attributes: placeholderAttributes)
        self.commentTextView.attributedText = placeholderTextAttributes
        
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        toolBar.setItems([flexSpace, cancelButton], animated: false)
        toolBar.isUserInteractionEnabled = true
//        self.commentField.inputAccessoryView = toolBar
        
        hideKeyboardWhenTappedAround()
        
        navBar.titleTextAttributes = Constants.navBar.attrs
        
        commentDF.dateFormat = "hh:mm a MM/dd"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.commentsTableView.reloadData()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if type == "pin"{
            return commentData.count
        }
        else{
            return eventComments.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let commentCell = tableView.dequeueReusableCell(withIdentifier: "commentsCell", for: indexPath) as! CommentsTableViewCell
        if type == "pin"{
            let comment = commentData[indexPath.row]
            commentCell.dateLabel.text = commentDF.string(for: Date(timeIntervalSince1970: comment["date"] as! Double))
            commentCell.loadInfo(UID: comment["fromUID"] as! String, text: (commentData[indexPath.row]["comment"] as? String)!)
            return commentCell
        }else{
            if let comment = eventComments[indexPath.row] as? commentCellData{
                
                commentCell.loadInfo(UID: comment.from, text: comment.comment)
                commentCell.dateLabel.text = commentDF.string(from: comment.date)
                return commentCell
            }
            
        }
        return commentCell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    @IBAction func post(_ sender: Any) {
        
        if self.commentTextView.text == "" || self.commentTextView.text == "Add a comment"{
            self.postButton.isEnabled = false
        }else{
            self.postButton.isEnabled = true
            let time = NSDate().timeIntervalSince1970
            Constants.DB.pins.child(data["fromUID"] as! String).child("comments").childByAutoId().updateChildValues(["fromUID": AuthApi.getFirebaseUid()!, "comment": commentTextView.text!, "date": Double(time)])
            
            commentTextView.resignFirstResponder()
            
            self.commentData.append([
                "comment": commentTextView.text!,
                "date": Double(time),
                "fromUID": AuthApi.getFirebaseUid()!
                ])
            commentTextView.text = "Add a comment"
            self.commentsTableView.reloadData()
            
            sendNotification(to: data["fromUID"] as! String, title: "New Comment", body: "\(AuthApi.getUserName()!) commented on your Pin", actionType: "", type: "", item_id: "", item_name: "")
            
            Answers.logCustomEvent(withName: "Comment Pin",
                                   customAttributes: [
                                    "user": AuthApi.getFirebaseUid()!,
                                    "comment": commentTextView.text
                ])
        }
        
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    func keyboardWillShow(notification: NSNotification) {
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var tableContentInset:UIEdgeInsets = self.commentsTableView.contentInset
        tableContentInset.bottom = keyboardFrame.size.height
        self.commentsTableView.contentInset = tableContentInset
        
        //get indexpath
        let indexpath = IndexPath(row: 0, section: 0)
        self.commentsTableView.scrollToRow(at: indexpath, at: .top, animated: true)
        contentInset.bottom = keyboardFrame.size.height + 10
        self.scrollView.contentInset = contentInset
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        self.scrollView.contentInset = contentInset
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Add a comment"{
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if self.commentTextView.text == "" || self.commentTextView.text == "Add a comment"{
            self.postButton.isEnabled = false
        }else{
            self.postButton.isEnabled = true
            textView.resignFirstResponder()
        }
    }
    
    func cancelPressed(){
        self.commentTextView.endEditing(true)
    }
}
