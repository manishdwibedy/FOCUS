//
//  SocialGroupViewController.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 3/27/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class SocialGroupViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var fakeBar: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var followers = [FocusUser]()
    var following = [FocusUser]()
    var username = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fakeBar.backgroundColor = UIColor.primaryGreen()
        tableView.delegate = self
        tableView.dataSource = self
        let cellNib = UINib(nibName: ReuseIdentifiers.FollowCell.rawValue, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: ReuseIdentifiers.FollowCell.rawValue)
        titleLabel.text = username
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func didTapBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // TableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return followers.count
        case 1:
            return following.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifiers.FollowCell.rawValue) as? FollowCell
        switch indexPath.section {
        case 0:
            cell?.configureFor(user: followers[indexPath.row])
        case 1:
            cell?.configureFor(user: following[indexPath.row])
        default:
            print("default")
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let blank = UIView()
        switch section {
        case 0:
            let hView = UIView()
            hView.backgroundColor = UIColor.primaryGreen()
            let followers = UILabel(frame: CGRect(x: tableView.center.x - 50, y: 10, width: 100, height: 30))
            followers.text = "Followers"
            followers.textAlignment = .center
            followers.textColor = UIColor.white
            followers.font = UIFont(name: "Futura", size: 22)
            hView.addSubview(followers)
            return hView
        case 1:
            let hView = UIView()
            hView.backgroundColor = UIColor.primaryGreen()
            let following = UILabel(frame: CGRect(x: tableView.center.x - 50, y: 10, width: 100, height: 30))
            following.text = "Following"
            following.textAlignment = .center
            following.textColor = UIColor.white
            following.font = UIFont(name: "Futura", size: 22)
            hView.addSubview(following)
            return hView
        default:
            return blank
        }

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
