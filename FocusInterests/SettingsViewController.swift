//
//  SettingsViewController.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 2/20/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import FBSDKLoginKit

protocol LogoutDelegate {
    func logout()
}

class SettingsViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, GIDSignInDelegate {

    @IBOutlet weak var statusBarFillView: UIView!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dismissButton: UIBarButtonItem!
    
    var delegate: LogoutDelegate?
    let appD = UIApplication.shared.delegate
    var fBManager: FBSDKLoginManager?
    var googleHandle: GIDSignIn?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        googleHandle = GIDSignIn()
        googleHandle?.delegate = self
        fBManager = FBSDKLoginManager()
        delegate = appD as! LogoutDelegate?
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        let switchNib = UINib(nibName: "SwitchCell", bundle: nil)
        tableView.register(switchNib, forCellReuseIdentifier: "SwitchCell")
        statusBarFillView.backgroundColor = UIColor.primaryGreen()
        toolBar.barTintColor = UIColor.primaryGreen()
        let attr = [NSForegroundColorAttributeName:UIColor.white]
        dismissButton.setTitleTextAttributes(attr, for: .normal)
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: true)
        
    }
    @IBAction func didTapDismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    // TableView datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constants.settings.cellTitles.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == Constants.settings.cellTitles.count {
            let swCell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell") as? SwitchCell
            swCell?.titleLabel.text = "Privacy"
            return swCell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
            cell?.textLabel?.text = Constants.settings.cellTitles[indexPath.row]
            cell?.accessoryType = .disclosureIndicator
            return cell!
        }
    }
    
    // TableView delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            let chooseVC = InterestsPickerViewController(nibName: "InterestsPickerViewController", bundle: nil)
            self.present(chooseVC, animated: true, completion: nil)
        }
        if indexPath.row == 6 {fBManager!.logOut()
            FBSDKAccessToken.setCurrent(nil)
            FBSDKProfile.setCurrent(nil)
            AuthApi.setDefaultsForLogout()
            defaults.set("notLoggedIn", forKey: "Login")
            GIDSignIn.sharedInstance().signOut()
            do {
                try googleHandle!.signOut()
            } catch let error as NSError {
                print("error logging out of firebase: \(error.localizedDescription)")
            }
            self.delegate?.logout()
        }
    }
    
    // required google function
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
    }
}
