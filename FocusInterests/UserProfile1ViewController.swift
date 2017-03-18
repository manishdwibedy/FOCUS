//
//  UserProfile1ViewController.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 3/15/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

enum ReuseIdentifiers: String {
    case UserImage = "UserImageCell"
}

class UserProfile1ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var FakeToolBar: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomBar: UIToolbar!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        
        UIApplication.shared.statusBarStyle = .lightContent

        FakeToolBar.backgroundColor = UIColor.primaryGreen()
        bottomBar.backgroundColor = UIColor.primaryGreen()
        let imageCellNib = UINib(nibName: "UserPhotoCell", bundle: nil)
        tableView.register(imageCellNib, forCellReuseIdentifier: ReuseIdentifiers.UserImage.rawValue)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Tableviewdatasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifiers.UserImage.rawValue) as? UserPhotoCell
            return cell!
        }
        return UITableViewCell()
    }
}
