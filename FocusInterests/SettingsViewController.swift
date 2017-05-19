//
//  SettingsViewController.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 2/20/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase

protocol LogoutDelegate {
    func logout()
}

class SettingsViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, GIDSignInDelegate {

    @IBOutlet weak var statusBarFillView: UIView!
    @IBOutlet weak var tableView: UITableView!
    let backgroundColor = UIColor.init(red: 22/255, green: 42/255, blue: 64/255, alpha: 1)
    
    var fBManager: FBSDKLoginManager?
    var googleHandle: GIDSignIn?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        googleHandle = GIDSignIn()
        googleHandle?.delegate = self
        fBManager = FBSDKLoginManager()
        logoutDelegate = appD
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        let switchNib = UINib(nibName: "SwitchCell", bundle: nil)
        tableView.register(switchNib, forCellReuseIdentifier: "SwitchCell")
        statusBarFillView.backgroundColor = UIColor.primaryGreen()
        
        tableView.tableFooterView = UIView()
        tableView.reloadData()
        
        let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height))
        backgroundView.backgroundColor = self.backgroundColor
        self.tableView.backgroundView = backgroundView

    }
    
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: true)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    // TableView datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constants.settings.cellTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 4 {
            let swCell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell") as? SwitchCell
            swCell?.backgroundColor = self.backgroundColor
            swCell?.titleLabel.text = Constants.settings.cellTitles[indexPath.row]
            return swCell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
            cell?.textLabel?.text = Constants.settings.cellTitles[indexPath.row]
            cell?.backgroundColor = self.backgroundColor
            
            if indexPath.row == Constants.settings.cellTitles.count - 1{
                cell?.textLabel?.textColor = UIColor.red
            }
            else{
                cell?.textLabel?.textColor = UIColor.white
            }
            
            cell?.accessoryType = .disclosureIndicator
            return cell!
        }
    }
    
    // TableView delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row{
            case 0:
                let selectInterests = InterestsViewController(nibName: "InterestsViewController", bundle: nil)
                self.present(selectInterests, animated: true, completion: nil)
            case 4:
                let swCell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell") as? SwitchCell
                if (swCell?.cellSwitch.isOn)!{
                    swCell?.cellSwitch.setOn(false, animated: true)
                }
                else{
                    swCell?.cellSwitch.setOn(false, animated: true)
                }
            case Constants.settings.cellTitles.count - 1:
                fBManager!.logOut()
                FBSDKAccessToken.setCurrent(nil)
                FBSDKProfile.setCurrent(nil)
                AuthApi.setDefaultsForLogout()
                defaults.set("notLoggedIn", forKey: "Login")
                GIDSignIn.sharedInstance().signOut()
                googleHandle!.signOut()
                try! FIRAuth.auth()!.signOut()
                self.logoutDelegate?.logout()
            default: break
        }        
    }
    
    // required google function
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
    }
}
