//
//  FollowersRequestViewController.swift
//  FocusInterests
//
//  Created by Alex Jang on 7/18/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class FollowersRequestViewController: UIViewController {

    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var ifAcceptedLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.acceptButton.roundCorners(radius: 5.0)
        self.declineButton.roundCorners(radius: 5.0)
        self.ifAcceptedLabel.isHidden = true
        print("parent view controller: \(self.presentingViewController)")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func acceptedOrDeclineButtonClicked(_ sender: UIButton) {
        if sender.currentTitle == "Accept"{
            self.ifAcceptedLabel.isHidden = false
            self.buttonStackView.isHidden = true
            self.ifAcceptedLabel.text = "username is now following you"
        }else if sender.currentTitle == "Decline"{
            self.ifAcceptedLabel.isHidden = false
            self.buttonStackView.isHidden = true
            self.ifAcceptedLabel.text = "you have declined username"
        }
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
