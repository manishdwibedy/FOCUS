//
//  FollowingViewController.swift
//  FocusInterests
//
//  Created by Alex Jang on 6/5/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class FollowingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var backButon: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        tableView.delegate = self
        tableView.dataSource = self
        
        self.backButon.tintColor = UIColor.white
        let nib = UINib(nibName: "FollowingTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "FollowingTableViewCell")
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let followingCell = self.tableView.dequeueReusableCell(withIdentifier: "FollowingTableViewCell") as! FollowingTableViewCell
        
        followingCell.usernameLabel.text = "User Name"
        followingCell.fullNameLabel.text = "Full Name"
        
        return followingCell
    }
    
    @IBAction func backAction(_ sender: Any) {
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
