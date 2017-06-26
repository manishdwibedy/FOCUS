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
    @IBOutlet weak var navBar: UINavigationBar!
    
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
        
        let sortedViews = segmentedControl.subviews.sorted( by: { $0.frame.origin.x < $1.frame.origin.x } )
        sortedViews[0].tintColor = Constants.color.green
        sortedViews[0].backgroundColor = UIColor.white

        for index in 1..<3{
            sortedViews[index].tintColor = UIColor.white
            sortedViews[index].backgroundColor = UIColor.gray
        }
        
        
        AuthApi.clearNotifications()
        
        FirebaseDownstream.shared.getUserNotifications(completion: {array in
            //self.multipleArray.insert(array!, at: SelectedIndex.INVITE.rawValue)
            self.invArray = array!
            print("got NOTI")
            print(array)
            
        }, gotNotif: {not in
            self.nofArray = not
            self.tableView.reloadData()
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
        
        tableView.register(UINib(nibName: "notificationTabCell", bundle: Bundle.main), forCellReuseIdentifier: "NotifTabCell")
        
        // Do any additional setup after loading the view.
        
        segmentedControl.layer.cornerRadius = 6
        segmentedControl.clipsToBounds = true
        
        self.view.backgroundColor = Constants.color.navy
        self.tableView.backgroundColor = Constants.color.navy
        
//        segmentedControl.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: UIControlState.selected)
//        segmentedControl.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: UIControlState.normal)
        
        let attrs = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "Avenir-Black", size: 18)!
        ]
        
        navBar.titleTextAttributes = attrs
//        
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
        if self.selectedSegmentIndex == 0{
            return 100
        }
        else if self.selectedSegmentIndex == 1{
            return 115.0
        }
        else{
            return 80
        }
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
        
        if self.selectedSegmentIndex == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "NotifTabCell", for: indexPath) as! notificationTabCell
            cell.setupCell(notif: nofArray[indexPath.row])
            return cell
        }else if self.selectedSegmentIndex == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "NotifFeedCell", for: indexPath) as! NotificationFeedCellTableViewCell
            cell.parentVC = self
            cell.isFeed = false
            cell.seeYouThereButton.isHidden = false
            cell.nextTimeButton.isHidden = false
            
            cell.setupCell(notif: invArray[indexPath.row])
             return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "NotifFeedCell", for: indexPath) as! NotificationFeedCellTableViewCell
            cell.parentVC = self
            cell.seeYouThereButton.isHidden = true
            cell.nextTimeButton.isHidden = true
            
            cell.isFeed = true
            cell.setupCell(notif: feedAray[indexPath.row])
            return cell
        }
        
        
    }
    
    @IBAction func indexChanged(_ sender: AnyObject) {
        
        let segmentedControl = sender as! UISegmentedControl
        
        self.selectedSegmentIndex = segmentedControl.selectedSegmentIndex
        
        tableView.reloadData()
        print("switch")
        
        let sortedViews = sender.subviews.sorted( by: { $0.frame.origin.x < $1.frame.origin.x } )
        
        for (index, view) in sortedViews.enumerated() {
            if index == sender.selectedSegmentIndex {
                view.tintColor = Constants.color.green
                view.backgroundColor = UIColor.white
            } else {
                view.tintColor = UIColor.white
                view.backgroundColor = UIColor.gray
            }
        }
        
        
        
    }
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
