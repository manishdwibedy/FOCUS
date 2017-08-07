//
//  ChooseLocationViewController.swift
//  FocusInterests
//
//  Created by Alex Jang on 8/7/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class ChooseLocationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate{

    @IBOutlet weak var locationTableView: UITableView!
    @IBOutlet weak var locationSearchBar: UISearchBar!
    @IBOutlet weak var navBar: UINavigationBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = Constants.color.navy
        
        self.locationTableView.rowHeight = UITableViewAutomaticDimension
        self.locationTableView.estimatedRowHeight = 70.0
        
        self.locationSearchBar.delegate = self
        // search bar attributes
        let placeholderAttributes: [String : AnyObject] = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "Avenir Book", size: 15)!]
        let cancelButtonsInSearchBar: [String: AnyObject] = [NSFontAttributeName: UIFont(name: "Avenir-Black", size: 15)!]
        
        //        MARK: Event Search Bar
        self.locationSearchBar.backgroundImage = UIImage()
        self.locationSearchBar.tintColor = UIColor.white
        self.locationSearchBar.barTintColor = UIColor.white
        
        self.locationSearchBar.clipsToBounds = true
        
        self.locationSearchBar.setValue("Cancel", forKey:"_cancelButtonText")
        
        if let textFieldInsideSearchBar = self.locationSearchBar.value(forKey: "_searchField") as? UITextField{
            let attributedPlaceholder: NSAttributedString = NSAttributedString(string: "Search", attributes: placeholderAttributes)
            
            textFieldInsideSearchBar.attributedPlaceholder = attributedPlaceholder
            textFieldInsideSearchBar.textColor = UIColor.white
            textFieldInsideSearchBar.backgroundColor = UIColor(red: 38/255.0, green: 83/255.0, blue: 126/255.0, alpha: 1.0)
            
            let glassIconView = textFieldInsideSearchBar.leftView as! UIImageView
            glassIconView.image = glassIconView.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            glassIconView.tintColor = UIColor.white
            
            textFieldInsideSearchBar.clearButtonMode = .whileEditing
            let clearButton = textFieldInsideSearchBar.value(forKey: "clearButton") as! UIButton
            clearButton.setImage(clearButton.imageView?.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: .normal)
            clearButton.tintColor = UIColor.white
        }
        
        UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonsInSearchBar, for: .normal)
        self.navBar.barTintColor = Constants.color.navy
        self.navBar.titleTextAttributes = Constants.navBar.attrs
        
        self.locationTableView.delegate = self
        self.locationTableView.dataSource = self
        
        self.locationTableView.register(UINib(nibName: "ChooseLocationTableViewCell", bundle: nil), forCellReuseIdentifier: "chooseLocationCell")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let locationCell = tableView.dequeueReusableCell(withIdentifier: "chooseLocationCell", for: indexPath) as! ChooseLocationTableViewCell
        
        if indexPath.row == 0{
            locationCell.currentLocationLabel.isHidden = false
            locationCell.locationNameLabel.isHidden = true
            locationCell.locationAddressLabel.isHidden = true
            locationCell.locationDistanceLabel.isHidden = true
        }else{
            locationCell.currentLocationLabel.isHidden = true
            locationCell.locationNameLabel.isHidden = false
            locationCell.locationAddressLabel.isHidden = false
            locationCell.locationDistanceLabel.isHidden = false
        }
        
        return locationCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            return 50
        }else{
            return 65
        }
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.endEditing(true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
