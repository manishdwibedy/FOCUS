//
//  InterestsViewController.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/19/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class InterestsViewController: UIViewController, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var interests = [Interest]()
    let backgroundColor = UIColor.init(red: 22/255, green: 42/255, blue: 64/255, alpha: 1)
    var filtered = [Interest]()
    var searching = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        searchBar.delegate = self
        
        let interestCell = UINib(nibName: "InterestViewCell", bundle: nil)
        tableView.register(interestCell, forCellReuseIdentifier: "cell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "label")
        
        let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height))
        backgroundView.backgroundColor = self.backgroundColor
        self.tableView.backgroundView = backgroundView
        self.tableView.tableFooterView = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.backgroundColor = UIColor.darkGray
        
        for view in searchBar.subviews.last!.subviews {
            if view.isKind(of: NSClassFromString("UISearchBarBackground")!)
            {
                view.removeFromSuperview()
            }
        }
        
        for i in 1...10{
            let interest = Interest(name: "Interest \(i)", category: nil, image: nil, imageString: nil)
            interests.append(interest)
            filtered.append(interest)
        }
        
        tableView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searching{
            return self.filtered.count
        }
        return self.filtered.count + 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !searching && indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! InterestViewCell
            cell.interestName.text = "All My interests"
            cell.interestName.font = .boldSystemFont(ofSize: 16.0)
            cell.interestName.textColor = UIColor.white
            cell.backgroundColor = self.backgroundColor
            return cell
        }
        else if !searching && indexPath.row == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "label", for: indexPath)
            cell.textLabel?.text = "Clear All"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 12)
            cell.textLabel?.textColor = UIColor.white
            cell.backgroundColor = self.backgroundColor
            return cell
        }
        else if !searching && indexPath.row == 2{
            let cell = tableView.dequeueReusableCell(withIdentifier: "label", for: indexPath)
            cell.textLabel?.text = "Top"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 12)
            cell.textLabel?.textColor = UIColor.green
            cell.backgroundColor = self.backgroundColor
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! InterestViewCell
            if searching{
                cell.interestName.text = self.filtered[indexPath.row].name
            }
            else{
                cell.interestName.text = self.filtered[indexPath.row - 3].name
            }
            
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
            cell.interestName.textColor = UIColor.white
            cell.backgroundColor = self.backgroundColor
            return cell
        }
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searching = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.searching = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searching = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searching = false;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count > 0{
            self.filtered = self.interests.filter { ($0.name?.contains(searchText))! }
            self.searching = true
        }
        else{
            self.searching = false;
            self.filtered = self.interests
        }
        
        self.tableView.reloadData()
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
