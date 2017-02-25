//
//  InterestsPickerViewController.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 2/23/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class InterestsPickerViewController: BaseViewController {
    
    @IBOutlet weak var button5: UIButton!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var fakeNavBarView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedController: UISegmentedControl!
    
    var fakeTabBar = [UIButton]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fakeTabBar = [button1, button2, button3, button4, button5]
        for button in fakeTabBar {
            button.setTitleColor(UIColor.white, for: .normal)
            button.setTitleColor(UIColor.darkGray, for: .selected)
        }
        
        fakeNavBarView.backgroundColor = UIColor.primaryGreen()
        submitButton.setTitleColor(UIColor.white, for: .normal)
        cancelButton.setTitleColor(UIColor.white, for: .normal)
    }

    @IBAction func didTapCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapSubmit(_ sender: Any) {
        print("will submit")
    }
    
    @IBAction func segmentChanged(_ sender: Any) {
    }
    
    @IBAction func button1Tapped(_ sender: Any) {
        print("button1tapped")
    }
    
    @IBAction func button2Tapped(_ sender: Any) {
        print("button2tapped")
    }
    
    @IBAction func button3Tapped(_ sender: Any) {
        print("button3tapped")
    }
    
    @IBAction func button4Tapped(_ sender: Any) {
        print("button4tapped")
    }
    
    @IBAction func button5Tapped(_ sender: Any) {
        print("button5tapped")
    }
    
}
