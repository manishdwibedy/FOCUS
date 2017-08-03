//
//  HomePageViewController.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/5/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import AMPopTip

class HomePageViewController: UITabBarController, UITabBarControllerDelegate,UIPopoverPresentationControllerDelegate{

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
        
        self.delegate = self
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
            print(vc.willShowPin)
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
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        print(viewController)
        if viewController is CreateEventContainerViewController{
            print("shouldn\'t select")
            let tabBarItemWidth = Int(tabBar.frame.size.width) / (tabBar.items?.count)!
            let x = tabBarItemWidth * 2
            let newRect = CGRect(x: x, y: 0, width: tabBarItemWidth, height: Int(tabBar.frame.size.height))
            print(newRect)
            
            let popController = UIStoryboard(name: "CreateEventOnMapViewController", bundle: nil).instantiateViewController(withIdentifier: "CreateEventOnMapViewController") as! CreateEventOnMapViewController
                
                popController.modalPresentationStyle = UIModalPresentationStyle.popover
                
                popController.preferredContentSize = CGSize(width: 345, height: 354)
                
                // set up the popover presentation controller
                popController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
                popController.popoverPresentationController?.delegate = self
                popController.popoverPresentationController?.sourceView = self.tabBar
                popController.popoverPresentationController?.sourceRect = newRect
                tabBarController.present(popController, animated: true, completion: nil)
                return false

        }
        return true
    }

    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        if AuthApi.isNewToPage(index: item.tag){
            let popTip = PopTip()
            if let view = item.value(forKey: "view") as? UIView{
                var text = ""
                switch(item.tag){
                case 0:
                    text = "Map"
                case 1:
                    text = "People"
                case 2:
                    text = "Create Pin"
                case 3:
                    text = "Explore"
                case 4:
                    text = "Feed"
                default :
                    break
                }
                
                popTip.show(text: text, direction: .up, maxWidth: 200, in: view, from: view.frame, duration: 3)
                popTip.entranceAnimation = .scale;
                popTip.actionAnimation = .bounce(20)
                popTip.shouldDismissOnTap = true
            }
            AuthApi.setIsNewToPage(index: item.tag)

        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createEventPopover" {
            let popoverViewController = segue.destination as! CreateEventOnMapViewController
            popoverViewController.modalPresentationStyle = .popover
            popoverViewController.popoverPresentationController!.delegate = self
        }
    }
 

}
