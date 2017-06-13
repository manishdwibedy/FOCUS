//
//  ReviewsViewController.swift
//  FocusInterests
//
//  Created by Alex Jang on 6/7/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class ReviewsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var interestLabel: UILabel!
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var reviewsTableView: UITableView!
    var place: Place!
    var data = [NSDictionary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let reviewCellNib = UINib(nibName: "ReviewsTableViewCell", bundle: nil)
        self.reviewsTableView.register(reviewCellNib, forCellReuseIdentifier: "reviewsCell")
        
        Constants.DB.places.child(place.id).child("comments").observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? NSDictionary {
                for (key, _) in value{
                    self.data.append(value[key] as! NSDictionary)
                }
                
            }
            self.reviewsTableView.reloadData()
        })
        
        interestLabel.text = place.categories[0].name
        placeNameLabel.text = place.name
        self.reviewsTableView.tableFooterView = UIView()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reviewsCell = self.reviewsTableView.dequeueReusableCell(withIdentifier: "reviewsCell", for: indexPath) as! ReviewsTableViewCell
        reviewsCell.commentsLabel.text = data[indexPath.row]["comment"] as? String
        reviewsCell.getUsernae(UID: data[indexPath.row]["user"] as! String)
        reviewsCell.showStarts(num: data[indexPath.row]["rating"] as! Int)
        return reviewsCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
