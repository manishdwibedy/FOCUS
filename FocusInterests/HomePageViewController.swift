//
//  HomePageViewController.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/5/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class HomePageViewController: UITabBarController, UIPopoverPresentationControllerDelegate{

    var willShowEvent = false
    var showEvent: Event? = nil
    var willShowPin = false
    var showPin: pinData? = nil
    var willShowPlace = false
    var showPlace: Place? = nil
    
    var location: CLLocation? = nil
    var showTutorial = false
    var showTab = 0
    override func viewDidLoad() {
        super.viewDidLoad()

        let attributes = [
            NSFontAttributeName:UIFont(name: "Avenir-Black", size: 15),
            NSForegroundColorAttributeName:UIColor.white
        ]

        let selected = [
            NSFontAttributeName:UIFont(name: "Avenir-Black", size: 15),
            NSForegroundColorAttributeName: Constants.color.green
        ]

        UITabBarItem.appearance().setTitleTextAttributes(attributes, for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes(selected , for: .selected)
        
        setupTabBarSeparators()
        
        self.selectedIndex = showTab
        
        let vc = self.viewControllers![0] as! MapViewController
        vc.willShowEvent = willShowEvent
        vc.showEvent = showEvent
        
        vc.willShowPin = willShowPin
        vc.showPin = showPin
        
        vc.willShowPlace = willShowPlace
        vc.showPlace = showPlace
        
        if let location = self.location{
            vc.currentLocation = location
        }
        
        vc.showTutorial = showTutorial
        self.setStatusBarStyle(UIStatusBarStyle.default)
        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupTabBarSeparators() {
        let itemWidth = floor(self.tabBar.frame.size.width / CGFloat(self.tabBar.items!.count))
        
        // this is the separator width.  0.5px matches the line at the top of the tab bar
        let separatorWidth: CGFloat = 0.5
        
        // iterate through the items in the Tab Bar, except the last one
        for i in 0...(self.tabBar.items!.count - 2) {
            // make a new separator at the end of each tab bar item
            let separator = UIView(frame: CGRect(x: itemWidth * CGFloat(i + 1) - CGFloat(separatorWidth / 2), y: 0.2 * self.tabBar.frame.size.height, width: CGFloat(separatorWidth), height: self.tabBar.frame.size.height * 0.6))
            
            // set the color to light gray (default line color for tab bar)
            separator.backgroundColor = UIColor.white
            
            self.tabBar.addSubview(separator)
        }
    }
    
//    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
//        if item.tag == 2{
////            let menuViewController: ActivityPopoverViewController = storyboard.instantiateViewControllerWithIdentifier("ActivityPopoverViewController") as! ActivityPopoverViewController
////            menuViewController.modalPresentationStyle = .Popover
////            menuViewController.view.frame = newRect
////            menuViewController.preferredContentSize = CGSizeMake(150, 150)
////            
////            if let popoverMenuViewController = menuViewController.popoverPresentationController {
////                popoverMenuViewController.permittedArrowDirections = .Down
////                popoverMenuViewController.delegate = menuViewController
////                popoverMenuViewController.sourceRect = newRect
////                popoverMenuViewController.sourceView = self.menuTabBar
////                
////                presentViewController(menuViewController, animated: true, completion: nil)
////                
////            }
//            
//            let tabBarItemWidth = Int(tabBar.frame.size.width) / (tabBar.items?.count)!
//            let x = tabBarItemWidth * 2
//            let newRect = CGRect(x: x, y: 0, width: tabBarItemWidth, height: Int(tabBar.frame.size.height))
//            print(newRect)
//            
//            let popController = UIStoryboard(name: "CreateEventOnMapViewController", bundle: nil).instantiateViewController(withIdentifier: "CreateEventOnMapViewController")
//            
//            // set the presentation style
//            popController.modalPresentationStyle = .popover
//            
//            popController.preferredContentSize = CGSize(width: popController.childViewControllers[0].view.frame.size.width, height: popController.childViewControllers[0].view.frame.size.height)
//            
//            if let  popoverPinViewController = popController.popoverPresentationController{
//                
//                popController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
//                popController.popoverPresentationController?.delegate = self
//                popController.popoverPresentationController?.sourceRect = newRect
//                popController.popoverPresentationController?.sourceView = tabBar
//                self.present(popController, animated: true, completion: nil)
//            }
//
//        }
//    }
    
    //    MARK: this is for popover for notifications
    
//    func showPopOver(_ sender: UIButton){
//        let popController = UIStoryboard(name: "FollowersRequest", bundle: nil).instantiateViewController(withIdentifier: "FollowersRequest")
//        
//        // set the presentation style
//        popController.modalPresentationStyle = UIModalPresentationStyle.popover
//        
//        popController.preferredContentSize = CGSize(width: 200, height: 60)
//        
//        // set up the popover presentation controller
//        popController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
//        popController.popoverPresentationController?.delegate = self
//        popController.popoverPresentationController?.sourceView = sender as UIView // button
//        popController.popoverPresentationController?.sourceRect = sender.bounds
//        self.present(popController, animated: true, completion: nil)
//    }
//    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
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
