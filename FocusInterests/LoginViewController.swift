//
//  LoginViewController.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/3/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import FirebaseAuth
import GoogleSignIn

enum LoginTypes: String {
    case Email = "email"
    case Facebook = "facebook"
    case Google = "google"
}

class LoginViewController: UIViewController,GIDSignInUIDelegate, GIDSignInDelegate, FBSDKLoginButtonDelegate {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    let handle = FIRAuth.auth()
    let loginView = FBSDKLoginManager()
    let defaults = UserDefaults.standard
    var delegate: LoginDelegate?
    let appD = UIApplication.shared.delegate as! AppDelegate
    var user: FIRUser?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        loginView.loginBehavior = .web
    }
    
    override func viewWillAppear(_ animated: Bool) {
        handle?.addStateDidChangeListener({ (auth, user) in
            if let u = user {
                print("user uid: \(u.uid)")
            }
        })
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        handle?.removeStateDidChangeListener(handle!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func emailLogin(_ sender: UIButton) {
        
        guard let email = self.emailTextField.text else{
            print("empty email")
            return
        }
        
    
        guard let password = self.passwordTextField.text else{
            print("empty password")
            return
        }
        
        AuthApi.setPassword(password: password)
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                self.showLoginFailedAlert(loginType: "email")
                print("there has been an error with email login: \(error?.localizedDescription)")
            } else {
                if user != nil {
                    if let id = user?.uid {
                        AuthApi.set(firebaseUid: id)
                    }
                    self.emailTextField.text = ""
                    self.passwordTextField.text = ""
                    self.defaults.set(user?.uid, forKey: "firebaseEmailLogin")
                    self.presentOwnUserProfile()
                } else {
                    self.showLoginFailedAlert(loginType: "email")
                }
            }
        })
    }

    @IBAction func facebookLogin(_ sender: UIButton) {
    }
    
    @IBAction func googleLogin(_ sender: UIButton) {
    }
    
    
    func addEmpty(userWith Id: String) {
        let user = FocusUser(userName: nil, firebaseId: Id, imageString: nil, currentLocation: nil)
        FirebaseUpstream.sharedInstance.addToUsers(focusUser: user)
    }
    
    func promptToConfirm() {
        let alert = UIAlertController(title: "Confirmation sent", message: "Please check your email and click the link in message that will arrive momentarily", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel) { (action) in
            self.presentOwnUserProfile()
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func presentOwnUserProfile() {
        let destination = UserProfile1ViewController(nibName: "UserProfile1ViewController", bundle: nil)
        present(destination, animated: true, completion: nil)
    }
    
    func showLoginFailedAlert(loginType: String) {
        let alert = UIAlertController(title: "Login error", message: "There has been an error logging in with \(loginType). Please try again.", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .destructive, handler: nil)
        alert.view.tintColor = UIColor.primaryGreen()
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func checkForSignedUp() {
        if let uid = AuthApi.getFirebaseUid() {
            print("User logged in with id: \(uid)")
        }
    }
    

    
    // FaceBook Delegates
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        print("didlogin")
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("didlogout")
    }

    
    // GIDSignInDelegate
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        print("my email: \(user.profile.email)")
        if let id = user.authentication.accessToken, let idToken = user.authentication.idToken {
            AuthApi.set(googleToken: id)
            
            let credential = FIRGoogleAuthProvider.credential(withIDToken: idToken,
                                                              accessToken: id)
            FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
                if let u = user {
                    let fireId = u.uid
                    self.addEmpty(userWith: fireId)
                    AuthApi.set(firebaseUid: fireId)
                    AuthApi.set(loggedIn: .Google)
                    self.presentOwnUserProfile()
                } else {
                    self.showLoginFailedAlert(loginType: "our server")
                }
            })
        } else {
            self.showLoginFailedAlert(loginType: "Google")
        }
        self.defaults.set("google", forKey: "Login")
        checkForSignedUp()
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
