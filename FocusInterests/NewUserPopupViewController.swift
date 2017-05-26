//
//  NewUserPopupViewController.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/25/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class NewUserPopupViewController: UIViewController {
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadValue()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func nextButtonClicked(_ sender: UIButton) {
        if index == info.count - 1{
            self.arrowImage?.alpha = 0
            self.dismiss(animated: true, completion: nil)
        }
        else{
            index += 1
            loadValue()
        }
    }
    
    func loadValue(){
        if index == info.count - 1 {
            self.arrowImage?.alpha = 1
            self.nextButton.setTitle("Done", for: .normal)
        }
        self.titleImage.image = UIImage(named: self.info[index][0] as! String)
        self.titleText.text = self.info[index][1] as! String
        self.descriptionText.text = self.info[index][2] as! String
    }
}
