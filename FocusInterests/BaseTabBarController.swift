//
//  BaseTabBarController.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 2/19/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation
import UIKit

class CustomTabController: UITabBarController {
    
    func setBarColor() {
        self.tabBar.isTranslucent = false
        self.tabBar.backgroundImage = UIImage(named: "greenTabBar")
        self.tabBar.tintColor = UIColor.white
        
    }
}
