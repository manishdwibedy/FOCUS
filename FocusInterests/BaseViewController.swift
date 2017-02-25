//
//  BaseViewController.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 2/25/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation
import UIKit

class BaseViewController: UIViewController {
    
    let defaults = UserDefaults.standard
    
    func presentOneOptionAlert(title: String, message: String, presenter: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        alert.view.tintColor = UIColor.primaryGreen()
        presenter.present(alert, animated: true, completion: nil)
    }
}
