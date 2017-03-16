//
//  UserProfile1ViewController.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 3/15/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class UserProfile1ViewController: UIViewController {
    
    @IBOutlet weak var FakeToolBar: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomBar: UIToolbar!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.statusBarStyle = .lightContent

        FakeToolBar.backgroundColor = UIColor.primaryGreen()
        bottomBar.backgroundColor = UIColor.primaryGreen()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
