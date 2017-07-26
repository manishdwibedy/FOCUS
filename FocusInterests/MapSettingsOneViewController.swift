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
    
    let interests = Constants.interests.interests
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.interestTableView.dataSource = self
        self.interestTableView.delegate = self
        
        self.searchFocusView.layer.cornerRadius = 7.0
        
        self.interestTableView.register(UINib(nibName: "SelectAllInterestsTableViewCell", bundle: nil), forCellReuseIdentifier: "selectAllInterestsCell")
        
        self.interestTableView.register(UINib(nibName: "SingleInterestTableViewCell", bundle: nil), forCellReuseIdentifier: "singleInterestCell")
        self.interestTableView.isHidden = true
        self.interestTableViewHeight.constant = 0
        self.target(forAction: #selector(MapSettingsOneViewController.openOptions(_:)), withSender: self)
        self.searchFocusView.target(forAction: #selector(MapSettingsOneViewController.openOptions(_:)), withSender: self)
//        searchFocusView.allCornersRounded(radius: 7.0)
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(interests.count)
        return interests.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cell indexpath: \(indexPath.row)")
        var cell = UITableViewCell()
        
        if indexPath.row == 0{
            
            let allInterestsCell = tableView.dequeueReusableCell(withIdentifier: "selectAllInterestsCell", for: indexPath) as! SelectAllInterestsTableViewCell
            allInterestsCell.showAllButton.setTitle("Show All Interests", for: .normal)
            allInterestsCell.showAllButton.setTitleColor(Constants.color.navy, for: .normal)
            
            allInterestsCell.showAllButton.setTitle("Show All Interests", for: .selected)
            allInterestsCell.showAllButton.setTitleColor(Constants.color.navy, for: .selected)
            
            allInterestsCell.accessoryType = .checkmark
            allInterestsCell.showAllButton.isSelected = true
            
            cell = allInterestsCell
            
        }else{
            let singleInterestCell = tableView.dequeueReusableCell(withIdentifier: "singleInterestCell", for: indexPath) as! SingleInterestTableViewCell
            
            let interest = "\(self.interests[indexPath.row-1]) Green"
            
            singleInterestCell.interestImage.image = UIImage(named: interest)
            singleInterestCell.interestLabel.setTitle(self.interests[indexPath.row-1], for: .normal)
            singleInterestCell.interestLabel.setTitleColor(UIColor.white, for: .normal)
            
            singleInterestCell.interestLabel.setTitle(self.interests[indexPath.row-1], for: .selected)
            singleInterestCell.interestLabel.setTitleColor(UIColor.white, for: .selected)
            
            singleInterestCell.accessoryType = .none
            singleInterestCell.interestLabel.isSelected = false
            
            cell = singleInterestCell
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row > 0{
            
            //TODO: works when within range of cell. but not once leaving range
            let selectAllCell = self.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as! SelectAllInterestsTableViewCell
            if selectAllCell.accessoryType == .checkmark{
                selectAllCell.accessoryType = .none
            }
            selectAllCell.showAllButton.isSelected = false
            
            let singleInterestCell = tableView.cellForRow(at: indexPath) as! SingleInterestTableViewCell
            singleInterestCell.accessoryType = .checkmark
            singleInterestCell.interestLabel.isSelected = true
            print("cell at \(indexPath.row) selected")
        }else{
            /*let allCell = tableView.cellForRow(at: indexPath) as! SelectAllInterestsTableViewCell
            allCell.accessoryType = .checkmark
            allCell.showAllButton.isSelected = true
            
            for index in 1...tableView.numberOfRows(inSection: 0){
                let singleInterestCell = self.tableView(tableView, cellForRowAt: IndexPath(row: index, section: 0)) as! SingleInterestTableViewCell
                singleInterestCell.accessoryType = .none
                singleInterestCell.interestLabel.isSelected = false
                singleInterestCell.interestButtonImage.isSelected = false
            }
            
            print("cell at 0 selected")*/
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
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
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        print("Closing")
        self.parent?.view.isHidden = true
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
