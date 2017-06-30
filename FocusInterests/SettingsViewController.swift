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
import GoogleSignIn

protocol LogoutDelegate {
    func logout()
}

class SettingsViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, GIDSignInDelegate {

    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var statusBarFillView: UIView!
    @IBOutlet weak var tableView: UITableView!
    let backgroundColor = UIColor.init(red: 22/255, green: 42/255, blue: 64/255, alpha: 1)
    
    var fBManager: FBSDKLoginManager?
    var googleHandle: GIDSignIn?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("")
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
        
        let attrs = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "Avenir-Black", size: 18)!
        ]
        
        navBar.titleTextAttributes = attrs
        
        let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height))
        backgroundView.backgroundColor = self.backgroundColor
        self.tableView.backgroundView = backgroundView

    }
    
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    // TableView datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constants.settings.cellTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 2{
            let swCell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell") as? SwitchCell
            swCell?.backgroundColor = self.backgroundColor
            swCell?.titleLabel.text = Constants.settings.cellTitles[indexPath.row]
            return swCell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
            cell?.textLabel?.text = Constants.settings.cellTitles[indexPath.row]
            cell?.backgroundColor = self.backgroundColor
            
            cell?.textLabel?.font = UIFont(name: "Avenir-Book", size: 18)!
            cell?.textLabel?.textColor = UIColor.white
            
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
            case 1:
                let storyboard = UIStoryboard(name: "Settings", bundle: nil)
                let VC = storyboard.instantiateViewController(withIdentifier: "Change_username_password") as? ChangeUsernamePasswordViewController
                self.present(VC!, animated: true, completion: nil)
            case 2:
                let swCell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell") as? SwitchCell
                if (swCell?.cellSwitch.isOn)!{
                    swCell?.cellSwitch.setOn(false, animated: true)
                }
                else{
                    swCell?.cellSwitch.setOn(false, animated: true)
                }
            case 3:
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let VC = storyboard.instantiateViewController(withIdentifier: "home") as? HomePageViewController
                VC?.showTutorial = true
                
                self.present(VC!, animated: true, completion: nil)
            case 4:
                let storyboard = UIStoryboard(name: "Settings", bundle: nil)
                let VC = storyboard.instantiateViewController(withIdentifier: "Feedback") as? FeedbackViewController
                self.present(VC!, animated: true, completion: nil)
            case 5:
                let storyboard = UIStoryboard(name: "Settings", bundle: nil)
                let VC = storyboard.instantiateViewController(withIdentifier: "License") as? LicenseViewController
                self.present(VC!, animated: true, completion: nil)
            case 6:
                let storyboard = UIStoryboard(name: "Settings", bundle: nil)
                let VC = storyboard.instantiateViewController(withIdentifier: "Terms") as? TermsViewController
                self.present(VC!, animated: true, completion: nil)
            case 7:
                let storyboard = UIStoryboard(name: "Settings", bundle: nil)
                let VC = storyboard.instantiateViewController(withIdentifier: "Privacy") as? PrivacyViewController
                self.present(VC!, animated: true, completion: nil)
            case Constants.settings.cellTitles.count - 1:
                
                let alertController = UIAlertController(title: "Logout?", message: nil, preferredStyle: .actionSheet)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                
                let OKAction = UIAlertAction(title: "Logout", style: .destructive) { action in
                    self.fBManager!.logOut()
                    FBSDKAccessToken.setCurrent(nil)
                    FBSDKProfile.setCurrent(nil)
                    AuthApi.setDefaultsForLogout()
                    UserDefaults.standard.set("notLoggedIn", forKey: "Login")
                    GIDSignIn.sharedInstance().signOut()
                    self.googleHandle!.signOut()
                    try! Auth.auth().signOut()
                    self.logoutDelegate?.logout()
                }
                alertController.addAction(OKAction)
                
                self.present(alertController, animated: true)
                
            
            default: break
        }        
    }
    
    // required google function
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
    }
}
