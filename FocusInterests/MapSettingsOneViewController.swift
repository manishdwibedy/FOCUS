//
//  MapSettingsOneViewController.swift
//  FocusInterests
//
//  Created by Alex Jang on 7/18/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class MapSettingsOneViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var interestTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var stackViewHeight: NSLayoutConstraint!
    @IBOutlet weak var searchByFocusButton: UIButton!
    @IBOutlet weak var interestTableView: UITableView!
    @IBOutlet weak var mapSettingStackView: UIStackView!
    @IBOutlet weak var searchFocusView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.interestTableView.register(UINib(nibName: "SelectAllInterestsTableViewCell", bundle: nil), forCellReuseIdentifier: "selectAllInterestsCell")
        
        self.interestTableView.register(UINib(nibName: "SingleInterestTableViewCell", bundle: nil), forCellReuseIdentifier: "singleInterestCell")
        self.interestTableView.isHidden = true
        //        self.stackViewHeight.constant -= self.interestTableViewHeight.constant
        self.interestTableViewHeight.constant = 0
        self.target(forAction: #selector(MapViewSettingsOne.openOptions(_:)), withSender: self)
        self.searchFocusView.target(forAction: #selector(MapViewSettingsOne.openOptions(_:)), withSender: self)
        searchFocusView.allCornersRounded(radius: 7.0)
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 12
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        if indexPath.row == 0{
            let allInterestsCell = tableView.dequeueReusableCell(withIdentifier: "selectAllInterestsCell", for: indexPath) as! SelectAllInterestsTableViewCell
            cell = allInterestsCell
        }else{
            let singleInterestCell = tableView.dequeueReusableCell(withIdentifier: "singleInterestCell", for: indexPath) as! SingleInterestTableViewCell
            cell = singleInterestCell
        }
        
        return cell
    }
    
    @IBAction func openOptions(_ sender: Any) {
        UIView.animate(withDuration: 2.0, delay: 0.0, options: .curveEaseInOut, animations: {
            if self.interestTableView.isHidden {
                self.interestTableView.isHidden = false
                self.interestTableViewHeight.constant = 225
                //                self.stackViewHeight.constant += self.interestTableViewHeight.constant
                
            }else{
                self.interestTableView.isHidden = true
                //                self.stackViewHeight.constant -= self.interestTableView.frame.size.height
                //                self.interestTableViewHeight.constant = 0
                
            }
        }, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
