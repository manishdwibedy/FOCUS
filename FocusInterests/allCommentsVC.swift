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
        
        ref.child("events").child((parentEvent?.id)!).child("comments").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if value != nil
            {
                print(value!)
                
                for (key,_) in value!
                {
                    let dict = value?[key] as! NSDictionary
                    let comm = commentView()
                    comm.addData(image: UIImage(), fromUID: dict["fromUID"] as! String, commment: dict["comment"] as! String)
                    self.commentsCList.add(dict["comment"] as! String)
                    /*
                    self.tableView.beginUpdates()
                    self.tableView.insertRows(at: [IndexPath(row: self.commentsList.count-1, section: 0)], with: .automatic)
                    self.tableView.endUpdates()
                    */
                    
                }
            }
            self.tableView.reloadData()
            let oldLastCellIndexPath = NSIndexPath(row: self.commentsCList.count-1, section: 0)
            self.tableView.scrollToRow(at: oldLastCellIndexPath as IndexPath, at: .bottom, animated: true)

        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentsCList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell:commentCell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! commentCell!
        
        cell.commentLabel.text = commentsCList[indexPath.row] as! String
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        commentTextField.resignFirstResponder()
        parentVC?.scrollView.frame.origin.y = 0
        UIView.animate(withDuration: 0.2,delay: 0.0,options: UIViewAnimationOptions.curveEaseIn,
                       animations: { () -> Void in
                        self.parentVC?.blur.alpha = 0
                        
        }, completion: { (finished) -> Void in
            self.parentVC?.blur.removeFromSuperview()
        })
    }
    
    
    @IBAction func post(_ sender: Any) {
        ref.child("events").child((parentEvent?.id)!).child("comments").childByAutoId().updateChildValues(["fromUID":AuthApi.getFirebaseUid()!, "comment":commentTextField.text!])
        commentsCList.add(commentTextField.text!)
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
    
    
    


}
