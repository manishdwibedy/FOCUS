//
//  PushNotificationsViewController.swift
//  FocusInterests
//
//  Created by Alex Jang on 7/14/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class PushNotificationsViewController: UIViewController{

    @IBOutlet weak var navBar: UINavigationBar!
//    @IBOutlet weak var pushNotificationsTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let attrs = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "Avenir-Black", size: 18)!
        ]
        
        self.navBar.titleTextAttributes = attrs
        self.navBar.barTintColor = Constants.color.navy
        self.view.backgroundColor = Constants.color.navy
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func backButtonPushed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
