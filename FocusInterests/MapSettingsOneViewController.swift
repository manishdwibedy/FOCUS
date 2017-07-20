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
        self.target(forAction: #selector(MapViewSettingsOne.openOptions(_:)), withSender: self)
        self.searchFocusView.target(forAction: #selector(MapViewSettingsOne.openOptions(_:)), withSender: self)
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
        var allInterestsCell: SelectAllInterestsTableViewCell?
        var singleInterestCell: SingleInterestTableViewCell?
        
        if indexPath.row == 0 {
            allInterestsCell = tableView.dequeueReusableCell(withIdentifier: "selectAllInterestsCell", for: indexPath) as! SelectAllInterestsTableViewCell
        }else{
            singleInterestCell = tableView.dequeueReusableCell(withIdentifier: "singleInterestCell", for: indexPath) as! SingleInterestTableViewCell
        }
        
        if indexPath.row == 0{
            
            allInterestsCell!.showAllButton.setTitle("Show All Interests", for: .normal)
            allInterestsCell!.showAllButton.setTitleColor(Constants.color.navy, for: .normal)
            
            allInterestsCell!.showAllButton.setTitle("Show All Interests", for: .selected)
            allInterestsCell!.showAllButton.setTitleColor(Constants.color.navy, for: .selected)
            
            
            print(tableView.numberOfRows(inSection: 0))
            
            for interestCellIndex in 1...tableView.numberOfRows(inSection: 0){
                
                interestCell.checkMarkButton.isHidden = true
                interestCell.checkMarkButton.isSelected = false
                interestCell.interestLabel.isSelected = false
                interestCell.interestButtonImage.isSelected = false
            }
            
            cell = allInterestsCell!
            
        }else{
            
            singleInterestCell!.interestLabel.setTitle(self.interests[indexPath.row-1], for: .normal)
            singleInterestCell!.interestLabel.setTitleColor(UIColor.white, for: .normal)
            
            singleInterestCell!.interestLabel.setTitle(self.interests[indexPath.row-1], for: .selected)
            singleInterestCell!.interestLabel.setTitleColor(UIColor.white, for: .selected)
            
            cell = singleInterestCell
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0{
            let showAllCell = tableView.cellForRow(at: indexPath) as! SelectAllInterestsTableViewCell
            showAllCell.checkMarkButton.isHidden = false
            showAllCell.checkMarkButton.isSelected = true
            showAllCell.showAllButton.isSelected = true
            
            print(tableView.numberOfRows(inSection: 0))
            
            for interestCellIndex in 1...tableView.numberOfRows(inSection: 0){
                
//                var interestCell = tableView.cellForRow(at: IndexPath(row: interestCellIndex, section: 0)) as! SingleInterestTableViewCell
//                interestCell.checkMarkButton.isHidden = true
//                interestCell.checkMarkButton.isSelected = false
//                interestCell.interestLabel.isSelected = false
//                interestCell.interestButtonImage.isSelected = false
            }
            
        }else{
            print(tableView.indexPathsForVisibleRows)
            let selectAllCells = self.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as! SelectAllInterestsTableViewCell
                print("showAllCell does exist")
            if selectAllCells.checkMarkButton.isSelected && selectAllCells.showAllButton.isSelected{
                    selectAllCells.checkMarkButton.isHidden = true
                    selectAllCells.checkMarkButton.isSelected = false
                    selectAllCells.showAllButton.isSelected = false
            }

            
            let interestCell = tableView.cellForRow(at: indexPath) as! SingleInterestTableViewCell
            
            if interestCell.checkMarkButton.isSelected && interestCell.interestLabel.isSelected && interestCell.interestButtonImage.isSelected{
                interestCell.checkMarkButton.isHidden = true
                interestCell.checkMarkButton.isSelected = false
                interestCell.interestLabel.isSelected = false
                interestCell.interestButtonImage.isSelected = false
            }else{
                interestCell.checkMarkButton.isHidden = false
                interestCell.checkMarkButton.isSelected = true
                interestCell.interestLabel.isSelected = true
                interestCell.interestButtonImage.isSelected = true
            }
        }
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
