//
//  NotificationFeedViewController.swift
//  FocusInterests
//
//  Created by Nicolas on 29/05/2017.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class NotificationFeedViewController: UIViewController {

    @IBAction func indexChanged(_ sender: AnyObject) {
        
        let segmentedControl = sender as! UISegmentedControl
        
        print(segmentedControl.selectedSegmentIndex)
        
    }
    
    
    @IBOutlet weak var segmentedControl: CustomSegmentedControl!
    @IBOutlet weak var backButtonItem: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        segmentedControl.selectedSegmentIndex = 0

        backButtonItem.title = "Back"
        backButtonItem.tintColor = UIColor.veryLightGrey()
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: "#182C43")
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.title = "Notifications"
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func leftButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
