//
//  NotificationFeedViewController.swift
//  FocusInterests
//
//  Created by Nicolas on 29/05/2017.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

enum SelectedIndex: Int {
    case NOTIF = 0
    case INVITE = 1
    case FEED = 2
}

class NotificationFeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBAction func indexChanged(_ sender: AnyObject) {
        
        let segmentedControl = sender as! UISegmentedControl
        
        self.selectedSegmentIndex = segmentedControl.selectedSegmentIndex
        
        tableView.reloadData()
        
        print(segmentedControl.selectedSegmentIndex)
        
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: CustomSegmentedControl!
    @IBOutlet weak var backButtonItem: UIBarButtonItem!
    
    var multipleArray = [[FocusNotification]]()
    var selectedSegmentIndex: Int = SelectedIndex.NOTIF.rawValue
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        segmentedControl.selectedSegmentIndex = self.selectedSegmentIndex

        backButtonItem.title = "Back"
        backButtonItem.tintColor = UIColor.veryLightGrey()
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: "#182C43")
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.title = "Notifications"
        
        self.setupDummyArray()
        
        tableView.register(UINib(nibName: "NotificationFeedCellTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "NotifFeedCell")
        
        // Do any additional setup after loading the view.
    }
    
    func setupDummyArray() {
        
        let notifNotif = FocusNotification(type: NotificationType.Comment, sender: User(username: "nicolas chr", uuid: "192103", userImage: nil, interests: nil) , item: ItemOfInterest(itemName: "EventDummy", imageurl: ""), time: Date())
        
        let notifInvite = FocusNotification(type: NotificationType.Invite, sender: User(username: "oliver", uuid: "192103", userImage: nil, interests: nil) , item: ItemOfInterest(itemName: "EventDummy", imageurl: ""), time: Date())
        
        let notifFeed = FocusNotification(type: NotificationType.Going, sender: User(username: "leo jardim", uuid: "192103", userImage: nil, interests: nil) , item: ItemOfInterest(itemName: "EventDummy", imageurl: ""), time: Date())
        
        
        self.multipleArray.insert([notifNotif, notifNotif], at: SelectedIndex.NOTIF.rawValue)
        self.multipleArray.insert([notifInvite, notifInvite, notifInvite], at: SelectedIndex.INVITE.rawValue)
        self.multipleArray.insert([notifNotif, notifInvite, notifFeed], at: SelectedIndex.FEED.rawValue)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func leftButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return multipleArray[selectedSegmentIndex].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotifFeedCell", for: indexPath) as! NotificationFeedCellTableViewCell
        
        cell.setupCell(notif: multipleArray[selectedSegmentIndex][indexPath.row] as! FocusNotification)
        
        return cell
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
