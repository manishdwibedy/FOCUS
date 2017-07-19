//
//  MapSettingTwoViewController.swift
//  FocusInterests
//
//  Created by Alex Jang on 7/18/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class MapSettingsTwoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var eventsTableView: UITableView!
    @IBOutlet weak var placesTableView: UITableView!
    @IBOutlet weak var peopleTableView: UITableView!
    @IBOutlet weak var peopleTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var placeTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var eventTableViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var peopleDropDownButton: UIButton!
    @IBOutlet weak var peopleLabelButton: UIButton!
    @IBOutlet weak var peopleImageButton: UIButton!
    
    @IBOutlet weak var placesDropdownButton: UIButton!
    @IBOutlet weak var placesImageButton: UIButton!
    @IBOutlet weak var placesLabelButton: UIButton!
    
    @IBOutlet weak var eventsDropDownButton: UIButton!
    @IBOutlet weak var eventsLabelButton: UIButton!
    @IBOutlet weak var eventsImageButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.peopleTableView.isHidden = true
        self.placesTableView.isHidden = true
        self.eventsTableView.isHidden = true
        
        // Do any additional setup after loading the view.
        let allOptionsNib = UINib(nibName: "AllOptionTableViewCell", bundle: nil)
        let followingNib = UINib(nibName: "FollowingOptionTableViewCell", bundle: nil)
        
        self.eventsTableView.register(allOptionsNib, forCellReuseIdentifier: "allOptionCell")
        self.eventsTableView.register(followingNib, forCellReuseIdentifier: "followingOptionCell")
        self.placesTableView.register(allOptionsNib, forCellReuseIdentifier: "allOptionCell")
        self.placesTableView.register(followingNib, forCellReuseIdentifier: "followingOptionCell")
        self.peopleTableView.register(allOptionsNib, forCellReuseIdentifier: "allOptionCell")
        self.peopleTableView.register(followingNib, forCellReuseIdentifier: "followingOptionCell")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        if indexPath.row == 0{
            let allCell = tableView.dequeueReusableCell(withIdentifier: "allOptionCell", for: indexPath) as! AllOptionTableViewCell
            cell = allCell
        }else if indexPath.row == 1{
            let followingCell = tableView.dequeueReusableCell(withIdentifier: "followingOptionCell", for: indexPath) as! FollowingOptionTableViewCell
            cell = followingCell
        }
        
        return cell
    }

    @IBAction func showTable(_ sender: UIButton) {
        switch sender.tag{
        case 0, 1, 2:
            UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseInOut, animations: {
//                self.placesTableView.isHidden = true
//                self.eventsTableView.isHidden = true
                if self.peopleTableView.isHidden{
                    
                    if !self.placesTableView.isHidden{
                        self.placesTableView.isHidden = true
                    }
                    
                    if !self.eventsTableView.isHidden{
                        self.eventsTableView.isHidden = true
                    }
                    
                    self.peopleTableView.isHidden = false
                    self.peopleTableViewHeight.constant = 100
                }else{
                    self.peopleTableView.isHidden = true
                }
            }, completion: nil)
            break
        case 3, 4, 5:
            UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseInOut, animations: {
                if self.placesTableView.isHidden{
                    if !self.peopleTableView.isHidden{
                        self.peopleTableView.isHidden = true
                    }
                    
                    if !self.eventsTableView.isHidden{
                        self.eventsTableView.isHidden = true
                    }
                    
                    self.placesTableView.isHidden = false
                    self.placeTableViewHeight.constant = 100
                }else{
                    self.placesTableView.isHidden = true
                }
            }, completion: nil)
            break
        case 6, 7, 8:
            UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseInOut, animations: {
                if self.eventsTableView.isHidden{
                    if !self.placesTableView.isHidden{
                        self.placesTableView.isHidden = true
                    }
                    
                    if !self.peopleTableView.isHidden{
                        self.peopleTableView.isHidden = true
                    }
                    self.eventsTableView.isHidden = false
                    self.eventTableViewHeight.constant = 100
                }else{
                    self.eventsTableView.isHidden = true
                }
            }, completion: nil)
            break
        default:
            break
        }
    }
    
    @IBAction func closePressed(_ sender: Any) {
        if let parent = self.parent{
            parent.view.isHidden = true
        }
    }
    
    @IBAction func donePressed(_ sender: Any) {
        if let parent = self.parent{
            parent.view.isHidden = true
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

}
