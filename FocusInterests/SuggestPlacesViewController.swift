//
//  SuggestPlacesViewController.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/23/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import ChameleonFramework
import CoreLocation

class SuggestPlacesViewController: UIViewController, UITableViewDataSource {

    @IBOutlet var statusBarView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var moreButton: UIButton!
    
    var currentLocation: CLLocation?
    var place: Place?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundView.backgroundColor = UIColor(hexString: "192D43")
        moreButton.roundCorners(radius: 10)
        
        hideKeyboardWhenTappedAround()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("SuggestPlaceTableViewCell", owner: self, options: nil)?.first as! SuggestPlaceTableViewCell
        
        return cell
    }
    

}
