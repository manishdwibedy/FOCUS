//
//  NotificationsViewController.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 2/19/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class NotificationsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var notifications: [Notification]?

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        
        super.viewDidLoad()

        let cellNib = UINib(nibName: "NotificationsCellTableViewCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: Constants.tableCellReuseIDs.notificationCellId)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let nots = notifications {
            return nots.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.tableCellReuseIDs.notificationCellId) as? NotificationsCellTableViewCell
        cell!.configure(notification: (notifications?[indexPath.row])!)
        return cell!
    }
    
}
