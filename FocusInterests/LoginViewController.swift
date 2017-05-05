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

class LoginViewController: UIViewController,GIDSignInUIDelegate, GIDSignInDelegate, FBSDKLoginButtonDelegate, UITextFieldDelegate {
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
        
        setUpTextFields()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        handle?.addStateDidChangeListener({ (auth, user) in
            if let u = user {
                print("user uid: \(u.uid)")
                self.showHomeVC()
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
                    self.showHomeVC()
                } else {
                    self.showLoginFailedAlert(loginType: "email")
                }
            }
        })
    }

    @IBAction func facebookLogin(_ sender: UIButton) {
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
                        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                            if let u = user {
                                let fireId = u.uid
                                self.addEmpty(userWith: fireId)
                                AuthApi.set(firebaseUid: fireId)
                                AuthApi.set(loggedIn: .Facebook)
                                AuthApi.set(facebookToken: FBSDKAccessToken.current().tokenString)
                                self.showHomeVC()
                            }
                            
                            self.checkForSignedUp()
                            if let error = error {
                                self.showLoginFailedAlert(loginType: "our server")
                                return
                            }
                        }
                    } else {
                        self.showLoginFailedAlert(loginType: "Facebook")
                    }
                    
                }
            }
        }
    }
    
    @IBAction func googleLogin(_ sender: UIButton) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    func setUpTextFields(){
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        self.emailTextField.setBottomBorder()
        self.passwordTextField.setBottomBorder()
    }
    
    func addEmpty(userWith Id: String) {
        let user = FocusUser(userName: nil, firebaseId: Id, imageString: nil, currentLocation: nil)
        FirebaseUpstream.sharedInstance.addToUsers(focusUser: user)
    }
    
    func promptToConfirm() {
        let alert = UIAlertController(title: "Confirmation sent", message: "Please check your email and click the link in message that will arrive momentarily", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel) { (action) in
            self.showHomeVC()
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showHomeVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        let vc = storyboard.instantiateViewController(withIdentifier: "OpeningTabBarController") as! CustomTabController

        present(vc, animated: true, completion: nil)
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
        guard let user = user else{
            return
        }
        
        print("my email: \(user.profile.email)")
        if let id = user.authentication.accessToken, let idToken = user.authentication.idToken {
            
            
            let credential = FIRGoogleAuthProvider.credential(withIDToken: idToken,
                                                              accessToken: id)
            FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
                if let u = user {
                    let fireId = u.uid
                    self.addEmpty(userWith: fireId)
                    AuthApi.set(firebaseUid: fireId)
                    AuthApi.set(loggedIn: .Google)
                    AuthApi.set(googleToken: id)
                    self.showHomeVC()
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
    // MARK: - Navigation
    
    @IBAction func unwindFromSignUP(sender: UIStoryboardSegue){}
    
    // MARK - TextField Delegate Methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
