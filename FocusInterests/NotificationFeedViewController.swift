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
        tableView.cellLayoutMarginsFollowReadableWidth = false
        
        segmentedControl.selectedSegmentIndex = self.selectedSegmentIndex
        
        let sortedViews = segmentedControl.subviews.sorted( by: { $0.frame.origin.x < $1.frame.origin.x } )
        sortedViews[0].tintColor = Constants.color.green
        sortedViews[0].backgroundColor = UIColor.white

        for index in 1..<3{
            sortedViews[index].tintColor = UIColor.white
            sortedViews[index].backgroundColor = UIColor.gray
        }
        
        
        AuthApi.clearNotifications()
        
        self.nofArray = Array(Set<FocusNotification>(self.nofArray))
        self.invArray = Array(Set<FocusNotification>(self.invArray))
        self.feedAray = Array(Set<FocusNotification>(self.feedAray))
        
        
        
        self.nofArray = self.nofArray.sorted(by: {
            $0.time! > $1.time!
        })
        
        self.invArray = self.invArray.sorted(by: {
            $0.time! > $1.time!
        })
        
        self.feedAray = self.feedAray.sorted(by: {
            $0.time! > $1.time!
        })
        
        tableView.reloadData()
        AuthApi.set(read: nofArray.count + invArray.count + feedAray.count)
        
        tableView.register(UINib(nibName: "NotificationFeedCellTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "NotifFeedCell")
        
        tableView.register(UINib(nibName: "FeedOneTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedOneCell")
        
        tableView.register(UINib(nibName: "FeedEventTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedTwoCell")
        
        tableView.register(UINib(nibName: "FeedPlaceTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedThreeCell")
        
        tableView.register(UINib(nibName: "FeedCommentTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedFourCell")
        
        tableView.register(UINib(nibName: "FeedPlaceImageTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedFiveCell")
        
        tableView.register(UINib(nibName: "FeedCreatedEventTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedSixCell")
        
        tableView.register(UINib(nibName: "notificationTabCell", bundle: Bundle.main), forCellReuseIdentifier: "NotifTabCell")
        
        segmentedControl.layer.borderWidth = 1
        segmentedControl.layer.borderColor = UIColor.white.cgColor
        segmentedControl.layer.cornerRadius = 6
        segmentedControl.clipsToBounds = true
        
        navBar.titleTextAttributes = Constants.navBar.attrs
        navBar.barTintColor = Constants.color.navy
        
        tableView.tableFooterView = UIView()
        
        self.view.backgroundColor = Constants.color.navy
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
            var rowHeight: CGFloat?
            if indexPath.row == 0{
                rowHeight = 165
            }else if indexPath.row == 1{
                rowHeight = 130
            }else if indexPath.row == 2{
                rowHeight = 120
            }else if indexPath.row == 3{
                rowHeight = 150
            }else if indexPath.row == 4{
                rowHeight = 220
            }else if indexPath.row == 5{
                rowHeight = 255
            }else{
                rowHeight = 80
            }
            return rowHeight!
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.selectedSegmentIndex == 0{
            return self.nofArray.count
        }else if self.selectedSegmentIndex == 1{
            return invArray.count
        }else if self.selectedSegmentIndex == 2{
            return 6
        }else
        {
        return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.selectedSegmentIndex == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "NotifTabCell", for: indexPath) as! notificationTabCell
            cell.setupCell(notif: nofArray[indexPath.row])
            cell.parentVC = self
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
            var cell: UITableViewCell?
            
            if indexPath.row == 0{
                cell = tableView.dequeueReusableCell(withIdentifier: "FeedOneCell", for: indexPath) as! FeedOneTableViewCell
            }else if indexPath.row == 1{
                cell = tableView.dequeueReusableCell(withIdentifier: "FeedTwoCell", for: indexPath) as! FeedEventTableViewCell
            }else if indexPath.row == 2{
                cell = tableView.dequeueReusableCell(withIdentifier: "FeedThreeCell", for: indexPath) as! FeedPlaceTableViewCell
            }else if indexPath.row == 3{
                cell = tableView.dequeueReusableCell(withIdentifier: "FeedFourCell", for: indexPath) as! FeedCommentTableViewCell
            }else if indexPath.row == 4{
                cell = tableView.dequeueReusableCell(withIdentifier: "FeedFiveCell", for: indexPath) as! FeedPlaceImageTableViewCell
            }else if indexPath.row == 5{
                cell = tableView.dequeueReusableCell(withIdentifier: "FeedSixCell", for: indexPath) as! FeedCreatedEventTableViewCell
            }
            return cell!
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if self.selectedSegmentIndex == 0{
            let notif = nofArray[indexPath.row]
            
            if let type = notif.item?.data["type"] as? String{
                if type == "event"{
                    let storyboard = UIStoryboard(name: "EventDetails", bundle: nil)
                    let controller = storyboard.instantiateViewController(withIdentifier: "eventDetailVC") as! EventDetailViewController
                    controller.event = notif.item?.data["event"] as? Event
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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let VC = storyboard.instantiateViewController(withIdentifier: "home") as? HomePageViewController
        
        self.present(VC!, animated: true, completion: nil)
    }

}
