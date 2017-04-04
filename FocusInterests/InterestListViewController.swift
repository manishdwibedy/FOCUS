//
//  InterestListViewController.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 4/3/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

protocol InterestPickerDelegate {
    func add(interests: [Interest])
}

class InterestListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    
    var delegate: InterestPickerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func confirmInterests(_ sender: Any) {
        
    }
    
    // TableViewDatasource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    // TableViewDelegate
}
