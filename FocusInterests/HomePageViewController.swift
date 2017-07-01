//
//  HomePageViewController.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/5/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class HomePageViewController: UITabBarController {

    var showEvent = false
    var showPin = false
    var location: CLLocation? = nil
    var showTutorial = false
    var showTab = 0
    override func viewDidLoad() {
        super.viewDidLoad()

        let attributes = [
            NSFontAttributeName:UIFont(name: "American Typewriter", size: 15),
            NSForegroundColorAttributeName:UIColor.white
        ]

        UITabBarItem.appearance().setTitleTextAttributes(attributes, for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes(attributes, for: .selected)
        
        setupTabBarSeparators()
        
        self.selectedIndex = showTab
        
        var vc = self.viewControllers![0] as! MapViewController
        vc.showEvent = showEvent
        vc.showTutorial = showTutorial
        if let location = self.location{
            vc.currentLocation = location
        }
        
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
