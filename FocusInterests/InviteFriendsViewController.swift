//
//  InviteFriendsViewController.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/19/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth
import FacebookCore

class InviteFriendsViewController: UIViewController {

    let loginView = FBSDKLoginManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonClicked(_ sender: Any) {
        
        if AuthApi.getFacebookToken() != nil{
            self.getFacebookFriends()
        }
        else{
            loginView.logIn(withReadPermissions: ["public_profile", "email", "user_friends"], from: self) { (result, error) in
                if error != nil {
                    print(error?.localizedDescription)
                    self.showLoginFailedAlert(loginType: "Facebook")
                } else {
                    if let res = result {
                        if res.isCancelled {
                            return
                        }
                        if let tokenString = FBSDKAccessToken.current().tokenString {
                            let credential = FIRFacebookAuthProvider.credential(withAccessToken: tokenString)
                            FIRAuth.auth()?.currentUser?.link(with: credential) { (user, error) in
                                if error != nil {
                                    
                                    self.showLoginFailedAlert(loginType: "Facebook")
                                    return
                                }
                                AuthApi.set(facebookToken: tokenString)
                                self.getFacebookFriends()
                            }
                            
                        }
                    } else {
                        self.showLoginFailedAlert(loginType: "Facebook")
                    }
                }
            }
        }
        }

    func showLoginFailedAlert(loginType: String) {
        let alert = UIAlertController(title: "Login error", message: "There has been an error logging in with \(loginType). Please try again.", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .destructive, handler: nil)
        alert.view.tintColor = UIColor.primaryGreen()
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func getFacebookFriends(){
        let params = ["fields": "id, first_name, last_name, middle_name, name, email, picture", "limit": 1000] as [String : Any]
        let token = AccessToken(authenticationToken: AuthApi.getFacebookToken()!)

        let connection = GraphRequestConnection()
        connection.add(GraphRequest(graphPath: "me/taggable_friends", parameters: params, accessToken: token)) { httpResponse, result in
            switch result {
            case .success(let response):
                let friends = response.dictionaryValue?["data"] as! [[String : AnyObject]]

                let paging = response.dictionaryValue?["paging"] as! [String : AnyObject]
                _ = paging["next"] as! String

                for friend in friends{
                    print("\(String(describing: friend["first_name"]!)) \(String(describing: friend["last_name"]!) )")
                    print(String(describing: friend["id"]!))
                }
            case .failed(let error):
                print("Graph Request Failed: \(error)")
            }
        }
        connection.start()
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
