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
        if indexPath.row == 0{
            
            let allInterestsCell = tableView.dequeueReusableCell(withIdentifier: "selectAllInterestsCell", for: indexPath) as! SelectAllInterestsTableViewCell
            allInterestsCell.showAllLabel.text = "Show All Interests"
            allInterestsCell.showAllLabel.textColor = Constants.color.navy
            allInterestsCell.tintColor = Constants.color.green
            return allInterestsCell
            
        }else{
            let singleInterestCell = tableView.dequeueReusableCell(withIdentifier: "singleInterestCell", for: indexPath) as! SingleInterestTableViewCell
            
            let interest = "\(self.interests[indexPath.row-1]) Green"
            
            singleInterestCell.interestImage.image = UIImage(named: interest)
            singleInterestCell.interestLabel.text = self.interests[indexPath.row-1]
            singleInterestCell.tintColor = Constants.color.green
            print("interest cell isselected at \(indexPath.row): \(singleInterestCell.isSelected)")
            
            return singleInterestCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        guard let selectedCell = tableView.cellForRow(at: indexPath) else{
            return
        }

        guard let indexPathForSelectedRows = tableView.indexPathsForSelectedRows?.sorted() else {
            print("no index path")
            return
        }
        let amountOfSelectedRows = indexPathForSelectedRows.count
        
        if indexPath.row == 0{
            print("selected cell at 0")

            // set the accessory type for show all cell
            selectedCell.accessoryType = .checkmark
            
            // check if how many selected rows there are
            // if there's only one then skip
            // else
            if amountOfSelectedRows <= 1{
                print("do not need to deselectcells")
            }else{
                for cellIndex in 1...indexPathForSelectedRows.count-1{
                    tableView.deselectRow(at: IndexPath(row: indexPathForSelectedRows[cellIndex][1], section: 0), animated: false)
                }
                
                for visibleCellsIndex in 1...tableView.visibleCells.count-1{
                    if tableView.visibleCells[visibleCellsIndex].accessoryType == .checkmark{
                        tableView.visibleCells[visibleCellsIndex].accessoryType = .none
                    }
                }
            }
        }else{
            tableView.deselectRow(at: IndexPath(row: 0, section: 0), animated: false)
            let zeroIndex = tableView.indexPathsForVisibleRows?.sorted()[0][0]
            if zeroIndex == 0 {
                tableView.visibleCells.first?.accessoryType = .none
            }
            
            selectedCell.accessoryType = .checkmark
            print("selected cell not at 0")
        }

        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let selectedCell = tableView.cellForRow(at: indexPath) else{
            return
        }
        selectedCell.accessoryType = .none
    }
    

    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell.isSelected{
            cell.accessoryType = .checkmark
        }else{
            cell.accessoryType = .none
        }
    }
    
    @IBAction func openOptions(_ sender: Any) {
        UIView.animate(withDuration: 0.8, delay: 0.0, options: .curveEaseInOut, animations: {
            if self.interestTableView.isHidden {
                self.interestTableView.isHidden = false
                self.interestTableViewHeight.constant = 225
                
            }else{
                self.interestTableView.isHidden = true
            }
        }, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        print("Closing")
        
        guard let mapView = self.parent?.parent as? MapViewController else{
            return
        }
        
        mapView.settingGearButton.isHidden = false
        mapView.mapViewSettings.isHidden = true
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
