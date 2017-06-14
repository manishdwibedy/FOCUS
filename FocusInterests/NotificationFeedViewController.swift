//
//  NotificationFeedViewController.swift
//  FocusInterests
//
//  Created by Nicolas on 29/05/2017.
//  Copyright © 2017 singlefocusinc. All rights reserved.


//TODO: FIX COLOR WHEN SPECIFIC SEGMENT IS SELECTED

import UIKit

enum SelectedIndex: Int {
    case NOTIF = 0
    case INVITE = 1
    case FEED = 2
}

class NotificationFeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: CustomSegmentedControl!
    @IBOutlet weak var backButtonItem: UIBarButtonItem!
    
    var multipleArray = [[FocusNotification]]()
    var selectedSegmentIndex: Int = SelectedIndex.NOTIF.rawValue
    
    var nofArray = [FocusNotification]()
    var invArray = [FocusNotification]()
    var feedAray = [FocusNotification]()
    
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
        
        AuthApi.clearNotifications()
        
        FirebaseDownstream.shared.getUserNotifications(completion: {array in
            //self.multipleArray.insert(array!, at: SelectedIndex.INVITE.rawValue)
            self.invArray = array!
            print("done")
        }, gotNotif: {not in
            self.nofArray = not
        })
        
        getFeeds(gotPins: {pins in
            print("get pins")
            print(pins)
            for data in pins
            {
                self.feedAray.append(data)
            }
            //self.multipleArray.insert(pins, at: SelectedIndex.INVITE.rawValue)
            
        }, gotEvents: { events in
            print("get events")
            print(events)
            for data in events
            {
                self.feedAray.append(data)
            }
            
        }, gotInvitations: {invitations in
            for data in invitations
            {
                self.feedAray.append(data)
            }
            print("get iniventaion")
            print(invitations)
            //self.multipleArray.insert(invitations, at: SelectedIndex.INVITE.rawValue)
            
        })
        
         //self.setupDummyArray()
        
        tableView.register(UINib(nibName: "NotificationFeedCellTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "NotifFeedCell")
        
        // Do any additional setup after loading the view.
        
        segmentedControl.layer.cornerRadius = 6
        segmentedControl.clipsToBounds = true
        
        
    }
    
    func setupDummyArray() {
        
        let notifNotif = FocusNotification(type: NotificationType.Comment, sender: NotificationUser(username: "nicolas chr", uuid: "192103", imageURL: nil) , item: ItemOfInterest(itemName: "EventDummy", imageURL: ""), time: Date())
        
        let notifInvite = FocusNotification(type: NotificationType.Invite, sender: NotificationUser(username: "oliver", uuid: "192103", imageURL: nil) , item: ItemOfInterest(itemName:
            "EventDummy", imageURL: ""), time: Date())
        
        let notifFeed = FocusNotification(type: NotificationType.Going, sender: NotificationUser(username: "leo jardim", uuid: "", imageURL: nil) , item: ItemOfInterest(itemName: "EventDummy", imageURL: ""), time: Date())
        
        
        self.multipleArray.insert([notifNotif, notifNotif], at: SelectedIndex.NOTIF.rawValue)
        //self.multipleArray.insert([notifInvite, notifInvite, notifInvite], at: SelectedIndex.INVITE.rawValue)
        //self.multipleArray.insert([notifNotif, notifInvite, notifFeed], at: SelectedIndex.FEED.rawValue)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func leftButtonAction(_ sender: Any) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromTop
        self.view.window!.layer.add(transition, forKey: kCATransition)
        self.dismiss(animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 115.0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.selectedSegmentIndex == 0{
            return nofArray.count
        }else if self.selectedSegmentIndex == 1{
            return invArray.count
        }else if self.selectedSegmentIndex == 2{
            return feedAray.count
        }else
        {
        return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotifFeedCell", for: indexPath) as! NotificationFeedCellTableViewCell
        if self.selectedSegmentIndex == 0{
            cell.setupCell(notif: nofArray[indexPath.row])
        }else if self.selectedSegmentIndex == 1{
            cell.setupCell(notif: invArray[indexPath.row])
        }else if self.selectedSegmentIndex == 2{
            cell.setupCell(notif: feedAray[indexPath.row])
        }else
        {
            cell.setupCell(notif: nofArray[indexPath.row])
        }
        return cell
    }
    
    
    
    @IBAction func indexChanged(_ sender: AnyObject) {
        
        let segmentedControl = sender as! UISegmentedControl
        
        self.selectedSegmentIndex = segmentedControl.selectedSegmentIndex
        
        tableView.reloadData()
        print("switch")
        
        print(segmentedControl.selectedSegmentIndex)
        
    }
    

}
