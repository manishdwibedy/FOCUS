//
//  allCommentsVC.swift
//  FocusInterests
//
//  Created by Andrew Simpson on 5/9/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import Firebase

class allCommentsVC: UIViewController {
    
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    var parentEvent: Event?
    var parentVC: EventDetailViewController?
    let ref = FIRDatabase.database().reference()
    let commentList = NSMutableArray()

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                    self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: comm.frame.origin.y + comm.view.frame.height + 25)
                    self.scrollView.addSubview(comm)
                    print(comm.frame)
                    if self.commentList.count != 0
                    {
                        let last = self.commentList[self.commentList.count-1] as! commentView
                        comm.frame.origin.y = last.frame.origin.y + last.view.frame.height + 10
                    }
                    print(comm.frame)
                    self.commentList.add(comm)
                    
                }
            }
            
        })
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
        commentTextField.resignFirstResponder()
        commentTextField.text = ""
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            self.scrollView.frame.origin.y = -((keyboardHeight))
            
            
        }
    }
    
    
    class comment
    {
        
        let view = UIView()
        let commentLabel = UILabel()
        let fromLabel = UILabel()
        let ref = FIRDatabase.database().reference()
        init(frame:CGRect,fromUID:String, comment: String, parent: allCommentsVC) {
            self.view.frame.size = CGSize(width: frame.width, height: 60)
            if parent.commentList.count != 0
            {
                let last = parent.commentList[parent.commentList.count-1] as! comment
                self.view.frame.origin.y = last.view.frame.origin.y + last.view.frame.height + 5
            }
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
            linePath.move(to: CGPoint(x: 10, y: self.view.frame.height))
            linePath.addLine(to: CGPoint(x: self.view.frame.width-20, y: self.view.frame.height))
            line.path = linePath.cgPath
            line.strokeColor = UIColor.white.cgColor
            line.lineWidth = 1
            line.lineJoin = kCALineJoinRound
            self.view.layer.addSublayer(line)
            
        }
    }


}
