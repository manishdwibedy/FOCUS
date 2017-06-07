//
//  NewUserPopupViewController.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/25/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import DottedProgressBar

protocol switchPinTabDelegate{
    func changeTab()
}

class NewUserPopupViewController: UIViewController {
    
    var delegate: switchPinTabDelegate?
    
    let info = [
        ["", "What if you could have an all-in-one view of the people, places and events YOU are about?", "Well, now YOU can", "addUser", UIColor.lightGray, UIColor.black, UIColor.black, UIFont.systemFont(ofSize: 15),UIFont.boldSystemFont(ofSize: 10)],
        
        ["People", "People", "People are shown on your map when they Pin their location and FOCUS. You can choose to view activities and places you'll both like.", "people", UIColor.lightGray, UIColor.black, UIColor.black, UIFont.boldSystemFont(ofSize: 20),UIFont.systemFont(ofSize: 15)],
        
        ["place_icon", "Places", "You now have a personalized Mpa of all the places that you FOCUS on. Rather than having to search for individual places you like, they'll always be up on your Map.", "place", UIColor.lightGray, UIColor.black, UIColor.black, UIFont.boldSystemFont(ofSize: 20),UIFont.systemFont(ofSize: 15)],
        
        ["Event", "Places", "You now have a personalized Map of all the places that you FOCUS on. Rather than having to search for individual places you like, they'll always be up on your Map.", "place", UIColor.lightGray, UIColor.black, UIColor.black, UIFont.boldSystemFont(ofSize: 20),UIFont.systemFont(ofSize: 15)],
        
        ["place_icon", "Pin", "Create your first Pin now and connect with others who have a similar FOCUS!", "place", UIColor.lightGray, UIColor.black, UIColor.black, UIFont.boldSystemFont(ofSize: 20),UIFont.systemFont(ofSize: 15)]
    ]
    
    var index = 0
    var arrowImage: UIImageView?
    
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var titleImage: UIImageView!
    @IBOutlet weak var descriptionText: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var skipLabel: UILabel!
    
    @IBOutlet weak var progress: UIView!
    var progressBar: DottedProgressBar?
    
    
    @IBOutlet weak var titleTop: NSLayoutConstraint!
    
    @IBOutlet weak var descriptionTop: NSLayoutConstraint!
    @IBOutlet weak var buttonTop: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadValue()
        
        self.progressBar = DottedProgressBar()
        
        //appearance
        self.progressBar?.progressAppearance = DottedProgressBar.DottedProgressAppearance(
            dotRadius: 8.0,
            dotsColor: UIColor.orange.withAlphaComponent(0.4),
            dotsProgressColor: UIColor.red,
            backColor: UIColor.clear
        )
        self.skipLabel.alpha = 0
        
        self.progress.addSubview(progressBar!)
        
        self.progressBar?.frame = CGRect(x: 0, y: 0, width: 100, height: 30)
        
        //set number of steps and current progress
        self.progressBar?.setNumberOfDots(info.count, animated: false)
        self.progressBar?.setProgress(1, animated: false)
        
        self.nextButton.roundCorners(radius: 10)
        self.progressBar?.progressChangeAnimationDuration = 0.1
        self.progressBar?.pauseBetweenConsecutiveAnimations = 0.1
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.skip))
        tapGesture.numberOfTapsRequired = 1
        skipLabel.isUserInteractionEnabled =  true
        skipLabel.addGestureRecognizer(tapGesture)

    }

    func skip(gr:UITapGestureRecognizer){
        self.arrowImage?.alpha = 0
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func nextButtonClicked(_ sender: UIButton) {
        
        
        if index == info.count - 1{
            self.arrowImage?.alpha = 0
            self.dismiss(animated: true, completion: nil)
            delegate?.changeTab()
            
        }
        else{
            index += 1
            loadValue()
        }
        self.progressBar?.setProgress(index+1, animated: true)
    }
    
    func loadValue(){
        if index == 0{
            titleTop.constant = -50
            buttonTop.constant = 50
            self.titleText.font = UIFont(name: "Avenir-Book", size: 15)
        }
        else{
            titleTop.constant = 20
            buttonTop.constant = 20
            descriptionTop.constant = 0
            
            self.titleText.font = UIFont(name: "Avenir-Black", size: 15)
            self.descriptionText.font = UIFont(name: "Avenir-Book", size: 15)
            
        }
        
        if index == info.count - 1 {
            self.arrowImage?.alpha = 1
            self.skipLabel.alpha = 1
            self.nextButton.setTitle("Create Pin", for: .normal)
        }
        self.titleImage.image = UIImage(named: self.info[index][0] as! String)
        self.titleText.text = self.info[index][1] as! String
        self.descriptionText.text = self.info[index][2] as! String
    }
}
