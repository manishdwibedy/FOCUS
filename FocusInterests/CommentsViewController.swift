//
//  CommentsViewController.swift
//  FocusInterests
//
//  Created by Alex Jang on 6/7/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import Crashlytics

class CommentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate{

    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var addCommentView: UIView!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var navBar: UINavigationBar!
    
    var data: NSDictionary!
    var commentData = [[String:Any]]()
    
    let toolBar = UIToolbar()
    let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: #selector(CommentsViewController.cancelPressed))
    let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let commentsNib = UINib(nibName: "CommentsTableViewCell", bundle: nil)
        self.commentsTableView.register(commentsNib, forCellReuseIdentifier: "commentsCell")
        
        self.postButton.roundCorners(radius: 5.0)
        
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillHide, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: .UIKeyboardDidShow, object: nil)
        
        commentsTableView.tableFooterView = UIView()
        commentsTableView.backgroundColor = Constants.color.navy
        
        commentField.delegate = self
        
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        toolBar.setItems([flexSpace, cancelButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        self.commentField.inputAccessoryView = toolBar
        
        hideKeyboardWhenTappedAround()
        
        navBar.titleTextAttributes = Constants.navBar.attrs
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let followersCell = tableView.dequeueReusableCell(withIdentifier: "commentsCell", for: indexPath) as! CommentsTableViewCell
        
        let comment = commentData[indexPath.row]
        let date = DateFormatter()
        date.dateFormat = "hh:mm a MM/dd"
        followersCell.dateLabel.text = date.string(for: Date(timeIntervalSince1970: comment["date"] as! Double))
        followersCell.loadInfo(UID: comment["fromUID"] as! String, text: (commentData[indexPath.row]["comment"] as? String)!)
        return followersCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
     }
    
    
    @IBAction func post(_ sender: Any) {
        let time = NSDate().timeIntervalSince1970
        Constants.DB.pins.child(data["fromUID"] as! String).child("comments").childByAutoId().updateChildValues(["fromUID": AuthApi.getFirebaseUid()!, "comment": commentField.text!, "date": Double(time)])
        
        commentField.resignFirstResponder()
        
        self.commentData.append([
            "comment": commentField.text!,
            "date": Double(time),
            "fromUID": AuthApi.getFirebaseUid()!
            ])
        commentField.text = ""
        self.commentsTableView.reloadData()
        
        Answers.logCustomEvent(withName: "Comment Pin",
                               customAttributes: [
                                "user": AuthApi.getFirebaseUid()!,
                                "comment": commentField.text
            ])
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            self.addCommentView.frame.origin.y = self.view.frame.height - self.addCommentView.frame.height - 10 - keyboardHeight
            
            self.commentsTableView.frame.size = CGSize(width: self.commentsTableView.frame.width, height: self.addCommentView.frame.origin.y - self.commentsTableView.frame.origin.y-10)
            
        }
    }
    
    func keyboardDidShow(notification: NSNotification) {
        let oldLastCellIndexPath = NSIndexPath(row: commentData.count-1, section: 0)
        if commentData.count != 0
        {
            self.commentsTableView.scrollToRow(at: oldLastCellIndexPath as IndexPath, at: .bottom, animated: true)
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        let time = NSDate().timeIntervalSince1970
        Constants.DB.pins.child(data["fromUID"] as! String).child("comments").childByAutoId().updateChildValues(["fromUID": AuthApi.getFirebaseUid()!, "comment": commentField.text!, "date": Double(time)])
        commentField.text = ""

        textField.resignFirstResponder()
        return true
    }
    
    func cancelPressed(){
        self.commentField.endEditing(true)
    }
}
