//
//  CreateEventOnMapViewController.swift
//  FocusInterests
//
//  Created by Alex Jang on 7/28/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class CreateEventOnMapViewController: UIViewController {

    // change location stack
    @IBOutlet weak var searchLocationSearchBar: UISearchBar!
    @IBOutlet weak var currentLocationButton: UIButton!
    
    // add focus stack
    @IBOutlet weak var addFocusDropdownButton: UIButton!
    @IBOutlet weak var addFocusButton: UIButton!
    
    // main stack
    
    // user stack text view
    @IBOutlet weak var userStatusTextView: UITextView!
    
    // go to camera button
    @IBOutlet weak var cameraButton: UIImageView!
    
    // set pin buttons
    @IBOutlet weak var pinButton: UIButton!
    @IBOutlet weak var pinImageButton: UIButton!
    
    // side stack
    @IBOutlet weak var lockButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var twitterButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

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
