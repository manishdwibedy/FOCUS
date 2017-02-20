//
//  MapViewController.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 2/19/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation
import UIKit

class MapViewController: UIViewController {
    @IBOutlet weak var toolbar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        toolbar.barTintColor = UIColor.primaryGreen()
    }
}
