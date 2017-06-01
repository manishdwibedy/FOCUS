//
//  UserProfileViewController.swift
//  FocusInterests
//
//  Created by Albert Pan on 5/17/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import SDWebImage

class UserProfileViewController: UIViewController {

	@IBOutlet var userScrollView: UIScrollView!
    
    // User data
	@IBOutlet var userName: UILabel!
	@IBOutlet var descriptionText: UITextView!
	@IBOutlet var userLocationImage: UIImageView!
	@IBOutlet var userLocationLabel: UILabel!
	@IBOutlet var userLikesLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    
    
    // user pin info
    
    @IBOutlet weak var pinImage: UIImageView!
    @IBOutlet weak var pinLabel: UILabel!
    @IBOutlet weak var pinCategoryLabel: UILabel!
    @IBOutlet weak var pinLikesLabel: UILabel!
    @IBOutlet weak var pinAddress1Label: UILabel!
    @IBOutlet weak var pinAddress2Label: UILabel!
    @IBOutlet weak var pinDescription: UILabel!
    @IBOutlet weak var updatePinButton: UIButton!
    
    // user interests
    @IBOutlet weak var interestStackView: UIStackView!
    
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
        
        self.displayUserData()
        updatePinButton.roundCorners(radius: 10)
    }
    
    func displayUserData() {
        FirebaseDownstream.shared.getCurrentUser {[unowned self] (dictionnary) in
            if dictionnary != nil {
                print(dictionnary!)
                let username_str = dictionnary!["username"] as! String
                let description_str = dictionnary!["description"] as! String
                let image_string = dictionnary!["image_string"] as! String
                let fullname = dictionnary!["fullname"] as! String
                
                self.userName.text = username_str
                self.descriptionText.text = description_str
                self.fullNameLabel.text = fullname
                
                self.userImage.sd_setImage(with: URL(string: image_string), placeholderImage: UIImage(named: "empty_event"))
                
            }

        }
        
        let interests = AuthApi.getInterests()?.components(separatedBy: ",")
        
        for view in interestStackView.arrangedSubviews{
            interestStackView.removeArrangedSubview(view)
        }
        
        for (index, interest) in (interests?.enumerated())!{
            let textLabel = UILabel()
            
            textLabel.textColor = .white
            textLabel.text  = interest
            textLabel.textAlignment = .left
            
            
            if index == 0{
                textLabel.text = textLabel.text! + " ●"
                
                let primaryFocus = NSMutableAttributedString(string: textLabel.text!)
                primaryFocus.addAttribute(NSForegroundColorAttributeName, value: UIColor.green, range: NSRange(location:(textLabel.text?.characters.count)! - 1,length:1))
                textLabel.attributedText = primaryFocus
            }
            
            interestStackView.addArrangedSubview(textLabel)
            interestStackView.translatesAutoresizingMaskIntoConstraints = false;
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.displayUserData()

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
