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
        
        tableView.tableFooterView = UIView()
        tableView.reloadData()
        
        let attrs = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "Avenir-Black", size: 18)!
        ]
        
        self.view.backgroundColor = Constants.color.navy
        self.navBar.barTintColor = Constants.color.navy
        self.navBar.titleTextAttributes = attrs
        
        let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height))
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
        
        if AuthApi.getLoginType() == .Facebook || AuthApi.getLoginType() == LoginTypes.Google{
            return Constants.settings.cellTitles.count - 1
        }
        return Constants.settings.cellTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if AuthApi.getLoginType() == .Facebook || AuthApi.getLoginType() == LoginTypes.Google{
            var row = indexPath.row
            
            if row >= 1{
                row += 1
            }
            if row == 2{
                let swCell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell") as? SwitchCell
                swCell?.backgroundColor = UIColor(red: 25/255.0, green: 53/255.0, blue: 81/255.0, alpha: 1.0)
                swCell?.titleLabel.text = Constants.settings.cellTitles[row]
                Constants.DB.user.child(AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: {snapshot in
                    if let data = snapshot.value as? [String:Any]{
                        if let privateProfile = data["private"] as? Bool{
                            print("statement \(privateProfile)")
                            if privateProfile{
                                swCell?.accessoryType = .checkmark
                            }else{
                                swCell?.accessoryType = .none
                            }
                        }
                        else{
                            print("didn't find state")
                            swCell?.accessoryType = .none
                        }
                    }
                })
                return swCell!
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
                cell?.textLabel?.text = Constants.settings.cellTitles[row]
                cell?.backgroundColor = UIColor(red: 25/255.0, green: 53/255.0, blue: 81/255.0, alpha: 1.0)
                
                cell?.textLabel?.font = UIFont(name: "Avenir-Book", size: 18)!
                cell?.textLabel?.textColor = UIColor.white
                
                cell?.accessoryType = .disclosureIndicator
                return cell!
            }
        }
        else{
            if indexPath.row == 2{
                let swCell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell") as? SwitchCell
                swCell?.backgroundColor = UIColor(red: 25/255.0, green: 53/255.0, blue: 81/255.0, alpha: 1.0)
                swCell?.titleLabel.text = Constants.settings.cellTitles[indexPath.row]
                Constants.DB.user.child(AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: {snapshot in
                    if let data = snapshot.value as? [String:Any]{
                        if let privateProfile = data["private"] as? Bool{
                            print("statement \(privateProfile)")
                            swCell?.tintColor = Constants.color.green
                            if privateProfile{
                                swCell?.accessoryType = .checkmark
                            }else{
                                swCell?.accessoryType = .none
                            }
                        }
                        else{
                            swCell?.accessoryType = .none
                        }
                    }
                })
                return swCell!
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
                cell?.textLabel?.text = Constants.settings.cellTitles[indexPath.row]
                cell?.backgroundColor = UIColor(red: 25/255.0, green: 53/255.0, blue: 81/255.0, alpha: 1.0)
                
                cell?.textLabel?.font = UIFont(name: "Avenir-Book", size: 18)!
                cell?.textLabel?.textColor = UIColor.white
                
                cell?.accessoryType = .disclosureIndicator
                return cell!
            }
        }
        
    }
    
    // TableView delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var row = indexPath.row
        if AuthApi.getLoginType() == .Facebook || AuthApi.getLoginType() == LoginTypes.Google{
            if row > 0{
                row += 1
            }
            
        }
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch row{
            case 0:
                let selectInterests = InterestsViewController(nibName: "InterestsViewController", bundle: nil)
                self.present(selectInterests, animated: true, completion: nil)
            case 1:
                let storyboard = UIStoryboard(name: "Settings", bundle: nil)
                let VC = storyboard.instantiateViewController(withIdentifier: "Change_username_password") as? ChangeUsernamePasswordViewController
                self.present(VC!, animated: true, completion: nil)
            case 2:
                let swCell = tableView.cellForRow(at: indexPath) as! SwitchCell
                if swCell.accessoryType == .checkmark {
                    swCell.accessoryType = .none
                    Constants.DB.user.child(AuthApi.getFirebaseUid()!).updateChildValues(["private": false])
                }else if swCell.accessoryType == .none{
                    swCell.accessoryType = .checkmark
                    Constants.DB.user.child(AuthApi.getFirebaseUid()!).updateChildValues(["private": true])
                }
            break
            case 3:
                let pushNotificationViewController = UIStoryboard(name: "PushNotifications", bundle: nil).instantiateViewController(withIdentifier: "PushNotifications") as? PushNotificationsViewController
                self.present(pushNotificationViewController!, animated: true, completion: nil)
            case 4:
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let VC = storyboard.instantiateViewController(withIdentifier: "home") as? HomePageViewController
                VC?.showTutorial = true
                
                self.present(VC!, animated: true, completion: nil)
            
            case 5:
                let storyboard = UIStoryboard(name: "Settings", bundle: nil)
                let VC = storyboard.instantiateViewController(withIdentifier: "Feedback") as? FeedbackViewController
                self.present(VC!, animated: true, completion: nil)
            case 6:
                let storyboard = UIStoryboard(name: "Settings", bundle: nil)
                let VC = storyboard.instantiateViewController(withIdentifier: "License") as? LicenseViewController
                self.present(VC!, animated: true, completion: nil)
            case 7:
                let storyboard = UIStoryboard(name: "Settings", bundle: nil)
                let VC = storyboard.instantiateViewController(withIdentifier: "Terms") as? TermsViewController
                self.present(VC!, animated: true, completion: nil)
            case 8:
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
