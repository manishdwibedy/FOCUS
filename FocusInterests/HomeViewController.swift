//
//  ViewController.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 2/19/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var items = [ItemOfInterest]()

    override func viewDidLoad() {
        super.viewDidLoad()
        segmentedControl.backgroundColor = UIColor.primaryGreen()
        segmentedControl.tintColor = UIColor.white
        segmentedControl.setImage(UIImage(named: "users"), forSegmentAt: 0)
        segmentedControl.setImage(UIImage(named: "businessIcon"), forSegmentAt: 1)
        segmentedControl.setImage(UIImage(named: "location"), forSegmentAt: 2)
        
        let cellNib = UINib(nibName: "HomViewControllerCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "HomeCell")
        
        let item1 = ItemOfInterest(itemName: "Barre Burger Bar", features: [Constants.dummyItemsOfInterest.feature2, Constants.dummyItemsOfInterest.feature4, Constants.dummyItemsOfInterest.feature6], mainImage: UIImage(named: "Shroom"), distance: "8.5 mi")
        let item2 = ItemOfInterest(itemName: "Jill's Pottery Studio", features: [Constants.dummyItemsOfInterest.feature5, Constants.dummyItemsOfInterest.feature1], mainImage: UIImage(named: "lady"), distance: "3.9 mi")
        let item3 = ItemOfInterest(itemName: "The Fireworks Store", features: [Constants.dummyItemsOfInterest.feature3, Constants.dummyItemsOfInterest.feature4, Constants.dummyItemsOfInterest.feature5], mainImage: UIImage(named: "tinyB"), distance: "0.5 mi")
        let item4 = ItemOfInterest(itemName: "Downtown Ducati", features: [Constants.dummyItemsOfInterest.feature3, Constants.dummyItemsOfInterest.feature1], mainImage: UIImage(named: "Humes"), distance: "8.4 mi")
        
        items = [item1, item2, item3, item4]
        
        let nav = self.tabBarController as! CustomTabController
        nav.setBarColor()
        self.title = "HOME"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func segmentedControlChanged(_ sender: Any) {
    }

    // TableView Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCell") as? HomViewControllerCell
        cell?.configure(itemOfInterest: items[indexPath.row])
        return cell!
    }
    
    // TableView Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

