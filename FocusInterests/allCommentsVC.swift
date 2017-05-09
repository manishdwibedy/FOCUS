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
    
    @IBOutlet weak var scrollView: UIScrollView!
    var parentEvent: Event?
    let ref = FIRDatabase.database().reference()
    let commentList = NSMutableArray()

    override func viewDidLoad() {
        super.viewDidLoad()

        ref.child("events").child((parentEvent?.id)!).child("comments").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if value != nil
            {
                print(value!)
                
                for (key,_) in value!
                {
                    let dict = value?[key] as! NSDictionary
                    let comm = comment(frame: self.scrollView.frame,fromUID: dict["fromUID"] as! String, comment: dict["comment"] as! String, parent: self)
                    self.commentList.add(comm)
                    self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: comm.view.frame.origin.y + comm.view.frame.height + 25)
                    self.scrollView.addSubview(comm.view)
                    
                }
            }
            
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
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
