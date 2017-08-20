//
//  NotificationFeedViewController.swift
//  FocusInterests
//
//  Created by Nicolas on 29/05/2017.
//  Copyright © 2017 singlefocusinc. All rights reserved.


//TODO: FIX COLOR WHEN SPECIFIC SEGMENT IS SELECTED

import UIKit
import Crashlytics
import DataCache

enum SelectedIndex: Int {
    case NOTIF = 0
    case INVITE = 1
    case FEED = 2
}

class NotificationFeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var noNotificationsLabel: UILabel!
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
        tableView.cellLayoutMarginsFollowReadableWidth = false
        
        
        AuthApi.clearNotifications()
        
        self.nofArray = (DataCache.instance.readObject(forKey: "notifications") as? [FocusNotification])!
        if self.nofArray.isEmpty && self.invArray.isEmpty && self.feedAray.isEmpty{
            self.noNotificationsLabel.isHidden = false
            self.tableView.isHidden = true
        }else{
            self.noNotificationsLabel.isHidden = true
            self.tableView.isHidden = false
            
            var unique = [FocusNotification]()
            
            for nof in self.nofArray{
                if !unique.contains(nof){
                    unique.append(nof)
                }
            }
            
            for nof in self.invArray{
                if !unique.contains(nof){
                    unique.append(nof)
                }
            }
            
            self.nofArray = unique.sorted(by: {
                $0.time! > $1.time!
            })
            
            
            tableView.reloadData()
            AuthApi.set(read: nofArray.count + invArray.count)
            
            
            tableView.register(UINib(nibName: "NotificationFeedCellTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "NotifFeedCell")
            
            tableView.register(UINib(nibName: "notificationTabCell", bundle: Bundle.main), forCellReuseIdentifier: "NotifTabCell")
            
        }
        
        navBar.titleTextAttributes = Constants.navBar.attrs
        navBar.barTintColor = Constants.color.navy
        
        tableView.tableFooterView = UIView()
        
        self.view.backgroundColor = Constants.color.navy
    }
    
    var gameTimer: Timer!

    override func viewDidAppear(_ animated: Bool) {
        
        Answers.logCustomEvent(withName: "Screen",
                               customAttributes: [
                                "Name": "Notifications"
            ])
        
        gameTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(getNotifications), userInfo: nil, repeats: true)


    }
    
    func getNotifications(){
        AuthApi.clearNotifications()
        AuthApi.set(unread: 0)
        
        NotificationUtil.getNotificationCount(avoidMissing: true, gotNotification: {notif in
            for notification in Array(Set<FocusNotification>(notif)){
                if !self.nofArray.contains(notification){
                    self.nofArray.append(notification)
                }
            }
            
            self.nofArray = self.nofArray.sorted(by: {
                $0.time! > $1.time!
            })
            
            DataCache.instance.write(object: self.nofArray as NSCoding, forKey: "notifications")
            AuthApi.set(read: self.nofArray.count)
            self.tableView.reloadData()
        }, gotInvites: {invites in
            for notification in Array(Set<FocusNotification>(invites)){
                if !self.nofArray.contains(notification){
                    self.nofArray.append(notification)
                }
            }
            
            self.nofArray = self.nofArray.sorted(by: {
                $0.time! > $1.time!
            })
            AuthApi.set(read: self.nofArray.count)
            DataCache.instance.write(object: self.nofArray as NSCoding, forKey: "notifications")
            self.tableView.reloadData()
        } , gotFeed: {feed in
            
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        gameTimer.invalidate()
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
//        return 100
//        if self.selectedSegmentIndex == 0{
//        }
//        else if self.selectedSegmentIndex == 1{
//            return 115.0
//        }
//        else{
//            var rowHeight: CGFloat?
//            if indexPath.row == 0{
//                rowHeight = 165
//            }else if indexPath.row == 1{
//                rowHeight = 130
//            }else if indexPath.row == 2{
//                rowHeight = 120
//            }else if indexPath.row == 3{
//                rowHeight = 150
//            }else if indexPath.row == 4{
//                rowHeight = 220
//            }else if indexPath.row == 5{
//                rowHeight = 255
//            }else{
//                rowHeight = 80
//            }
//            return rowHeight!
//        }
        
        return 100
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.nofArray.count
//        if self.selectedSegmentIndex == 0{
//        }else if self.selectedSegmentIndex == 1{
//            return invArray.count
//        }else if self.selectedSegmentIndex == 2{
//            return 6
//        }else
//        {
//        return 0
//        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let notification = self.nofArray[indexPath.row]
        
        if notification.notif_type == .invite{
            let cell = tableView.dequeueReusableCell(withIdentifier: "NotifFeedCell", for: indexPath) as! NotificationFeedCellTableViewCell
            cell.userProfilePic.roundButton()
            cell.nextTimeButton.allCornersRounded(radius: 5.0)
            cell.seeYouThereButton.allCornersRounded(radius: 5.0)
            cell.locationImage.roundedImage()
            
            cell.setupCell(notif: nofArray[indexPath.row])
            cell.parentVC = self
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "NotifTabCell", for: indexPath) as! notificationTabCell
            cell.setupCell(notif: nofArray[indexPath.row])
            cell.parentVC = self
            return cell

        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let notif = nofArray[indexPath.row]
        
        if let type = notif.item?.data["type"] as? String{
            if type == "event"{
                let storyboard = UIStoryboard(name: "EventDetails", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "eventDetailVC") as! EventDetailViewController
                controller.event = notif.item?.data["event"] as? Event
                self.present(controller, animated: true, completion: nil)
            }
            else if type == "place"{
                let storyboard = UIStoryboard(name: "PlaceDetails", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "home") as! PlaceViewController
                controller.place = notif.item?.data["place"] as! Place
                self.present(controller, animated: true, completion: nil)
            }
            else{
                let storyboard = UIStoryboard(name: "Pin", bundle: nil)
                let ivc = storyboard.instantiateViewController(withIdentifier: "PinLookViewController") as! PinLookViewController
                ivc.data = notif.item?.data["pin"] as! pinData
                self.present(ivc, animated: true, completion: { _ in })
            }
        }
        
        print(notif)
    
    }
    
    @IBAction func indexChanged(_ sender: AnyObject) {
        
//        let segmentedControl = sender as! UISegmentedControl
        
//        self.selectedSegmentIndex = segmentedControl.selectedSegmentIndex
        
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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let VC = storyboard.instantiateViewController(withIdentifier: "home") as? HomePageViewController
        
        self.present(VC!, animated: true, completion: nil)
    }

}
