//
//  SettingsViewController.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 2/20/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var statusBarFillView: UIView!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        statusBarFillView.backgroundColor = UIColor.primaryGreen()
        toolBar.backgroundColor = UIColor.primaryGreen()
        tableView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: true)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    // TableView datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 11
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        return cell!
    }
    
    // TableView delegate
    
}
