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
	@IBOutlet var userName: UILabel!
	@IBOutlet var descriptionText: UITextView!
	@IBOutlet var userLocationImage: UIImageView!
	@IBOutlet var userLocationLabel: UILabel!
	@IBOutlet var userLikesLabel: UILabel!
	
	// Haven't added:
	// User FOCUS button
	// Location Description (would this be location description?)
	// Location FOCUS button (what would this be for?)
	// Collection view See more... button
	// (and also any of the ones after)
	
	// Back button
	@IBAction func backButton(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
	
	// Message button
	@IBAction func messageButton(_ sender: Any) {
	}
	
	// Follow button
	@IBAction func followButton(_ sender: Any) {
	}
	
	// Edit Description button
	@IBAction func editDescription(_ sender: Any) {
	}
	
	// See all... activity button
	@IBAction func activityAllButton(_ sender: Any) {
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		userScrollView.contentSize = CGSize(width: 375, height: 1600)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func settingsButtonTapped(_ sender: UIBarButtonItem) {
        let vc = SettingsViewController(nibName: "SettingsViewController", bundle: nil)
        self.present(vc, animated: true, completion: nil)
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
