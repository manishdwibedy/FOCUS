//
//  PushNotificationsTableViewController.swift
//  FocusInterests
//
//  Created by Alex Jang on 7/14/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class PushNotificationsTableViewController: UITableViewController{

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 5
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        if section != 5{
//            return 2
//        }else{
//            return 3
//        }
//    }
//
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.cellForRow(at: indexPath) as! UITableViewCell
//
//        return cell
//    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 30
        }
        return 30
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = UIColor.lightGray
        header.textLabel?.font = UIFont(name: "Avenir-Black", size: 14)
        header.textLabel?.frame = header.frame
        header.backgroundView?.backgroundColor = Constants.color.navy
        header.textLabel?.textAlignment = .left
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0:
            if indexPath.row == 0{
                checkForAccessoryView(indexPath: indexPath)
                print("select in section \(indexPath.section) at row \(indexPath.row)")
                
            }else if indexPath.row == 1{
                checkForAccessoryView(indexPath: indexPath)
                print("select in section \(indexPath.section) at row \(indexPath.row)")
            }
            break
        case 1:
            if indexPath.row == 0{
                checkForAccessoryView(indexPath: indexPath)
                print("select in section \(indexPath.section) at row \(indexPath.row)")
            }else if indexPath.row == 1{
                checkForAccessoryView(indexPath: indexPath)
                print("select in section \(indexPath.section) at row \(indexPath.row)")
            }
            break
        case 2:
            if indexPath.row == 0{
                checkForAccessoryView(indexPath: indexPath)
                print("select in section \(indexPath.section) at row \(indexPath.row)")
            }else if indexPath.row == 1{
                checkForAccessoryView(indexPath: indexPath)
                print("select in section \(indexPath.section) at row \(indexPath.row)")
            }
            break
        case 3:
            if indexPath.row == 0{
                checkForAccessoryView(indexPath: indexPath)
                print("select in section \(indexPath.section) at row \(indexPath.row)")
            }else if indexPath.row == 1{
                checkForAccessoryView(indexPath: indexPath)
                print("select in section \(indexPath.section) at row \(indexPath.row)")
            }
            break
        case 4:
            if indexPath.row == 0{
                checkForAccessoryView(indexPath: indexPath)
                print("select in section \(indexPath.section) at row \(indexPath.row)")
            }else if indexPath.row == 1{
                checkForAccessoryView(indexPath: indexPath)
                print("select in section \(indexPath.section) at row \(indexPath.row)")
            }else if indexPath.row == 2{
                checkForAccessoryView(indexPath: indexPath)
                print("select in section \(indexPath.section) at row \(indexPath.row)")
            }
            break
        case 5:
            if indexPath.row == 0{
                checkForAccessoryView(indexPath: indexPath)
                print("select in section \(indexPath.section) at row \(indexPath.row)")
            }else if indexPath.row == 1{
                checkForAccessoryView(indexPath: indexPath)
                print("select in section \(indexPath.section) at row \(indexPath.row)")
            }else if indexPath.row == 2{
                checkForAccessoryView(indexPath: indexPath)
                print("select in section \(indexPath.section) at row \(indexPath.row)")
            }
            break
        default:
            break
        }
    }
    
    func checkForAccessoryView(indexPath: IndexPath){
        
        if indexPath.section == 0 || indexPath.section == 1 || indexPath.section == 2 || indexPath.section == 3{
            if indexPath.row == 0{
                if self.tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark{
                    self.tableView.cellForRow(at: indexPath)?.accessoryType = .none
                    self.tableView.cellForRow(at: IndexPath(row: 1, section: indexPath.section))?.accessoryType = .checkmark
                }else{
                    self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                    self.tableView.cellForRow(at: IndexPath(row: 1, section: indexPath.section))?.accessoryType = .none
                }
            }else{
                if self.tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark{
                    self.tableView.cellForRow(at: indexPath)?.accessoryType = .none
                    self.tableView.cellForRow(at: IndexPath(row: 0, section: indexPath.section))?.accessoryType = .checkmark
                }else{
                    self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                    self.tableView.cellForRow(at: IndexPath(row: 0, section: indexPath.section))?.accessoryType = .none
                }
            }
        }else if indexPath.section == 4 || indexPath.section == 5{
            if indexPath.row == 0{
                if self.tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark{
                    self.tableView.cellForRow(at: indexPath)?.accessoryType = .none
                }else{
                    self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                    self.tableView.cellForRow(at: IndexPath(row: 1, section: indexPath.section))?.accessoryType = .none
                    self.tableView.cellForRow(at: IndexPath(row: 2, section: indexPath.section))?.accessoryType = .none
                }
            }else if indexPath.row == 1{
                if self.tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark{
                    self.tableView.cellForRow(at: indexPath)?.accessoryType = .none
                }else{
                    self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                    self.tableView.cellForRow(at: IndexPath(row: 0, section: indexPath.section))?.accessoryType = .none
                    self.tableView.cellForRow(at: IndexPath(row: 2, section: indexPath.section))?.accessoryType = .none
                }
            }else if indexPath.row == 2{
                if self.tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark{
                    self.tableView.cellForRow(at: indexPath)?.accessoryType = .none
                }else{
                    self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                    self.tableView.cellForRow(at: IndexPath(row: 0, section: indexPath.section))?.accessoryType = .none
                    self.tableView.cellForRow(at: IndexPath(row: 1, section: indexPath.section))?.accessoryType = .none
                }
            }
        }
    }

}
