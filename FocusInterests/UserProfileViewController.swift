//
//  UserProfileViewController.swift
//  FocusInterests
//
//  Created by Albert Pan on 5/17/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController {

	@IBOutlet var userScrollView: UIScrollView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		userScrollView.contentSize = CGSize(width: 375, height: 1600)
        // Do any additional setup after loading the view.
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
