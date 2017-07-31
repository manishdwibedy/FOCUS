//
//  CreateEventContainerViewController.swift
//  FocusInterests
//
//  Created by Alex Jang on 7/28/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class CreateEventContainerViewController: UIViewController, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var tabBar: UITabBarItem!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }

}
