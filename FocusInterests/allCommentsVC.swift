//
//  allCommentsVC.swift
//  FocusInterests
//
//  Created by Andrew Simpson on 5/9/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import Firebase

class allCommentsVC: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var commentTextField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    var parentEvent: Event?
    var parentVC: EventDetailViewController?
    let ref = FIRDatabase.database().reference()
    let commentList = NSMutableArray()
    let commentsCList = NSMutableArray()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "commentCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
        
        commentTextField.layer.borderWidth = 1
        commentTextField.layer.cornerRadius = 5
        commentTextField.clipsToBounds = true
        commentTextField.layer.borderColor = UIColor.white.cgColor
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillHide, object: nil)
        
        let fullRef = ref.child("events").child((parentEvent?.id)!).child("comments")
        fullRef.queryOrdered(byChild: "date").queryLimited(toFirst: 10).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if value != nil
            {
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
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        commentTextField.resignFirstResponder()
        parentVC?.scrollView.frame.origin.y = 0
        
    }
    
    
    @IBAction func post(_ sender: Any) {
        let unixDate = NSDate().timeIntervalSince1970
        let fullRef = ref.child("events").child((parentEvent?.id)!).child("comments").childByAutoId()
        fullRef.updateChildValues(["fromUID":AuthApi.getFirebaseUid()!, "comment":commentTextField.text!, "like":["num":0], "date": NSNumber(value: Double(unixDate))])
    
        let data = commentCellData(from: AuthApi.getFirebaseUid()!, comment: commentTextField.text!, commentFirePath: fullRef, likeCount: 0)
        self.commentsCList.add(data)
        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath(row: commentsCList.count-1, section: 0)], with: .automatic)
        tableView.endUpdates()
        commentTextField.resignFirstResponder()
        commentTextField.text = ""
        parentVC?.scrollView.frame.origin.y = 0
        self.view.frame.origin.y = 0
        let oldLastCellIndexPath = NSIndexPath(row: commentsCList.count-1, section: 0)
        self.tableView.scrollToRow(at: oldLastCellIndexPath as IndexPath, at: .bottom, animated: true)
        
        
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            self.view.frame.origin.y = -keyboardHeight
                       
            
        }
    }
    
    
    @IBAction func back(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    


}
