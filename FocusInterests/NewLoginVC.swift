//
//  NewLoginVC.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 3/5/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation
import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import FirebaseAuth
import GoogleSignIn
//
//enum LoginTypes: String {
//    case Email = "email"
//    case Facebook = "facebook"
//    case Google = "google"
//}

class NewLoginVC: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate, FBSDKLoginButtonDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var segmentedC: UISegmentedControl!
    @IBOutlet weak var faceBookButton: UIButton!
    @IBOutlet weak var googleLoginButton: GIDSignInButton!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var emailMovementConstraint: NSLayoutConstraint!
    @IBOutlet weak var emailPwordButton: UIButton!
    @IBOutlet weak var submitEmailButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    let handle = FIRAuth.auth()
    let loginView = FBSDKLoginManager()
    let defaults = UserDefaults.standard
    var email: String?
    var password: String?
    var signUp = false
    var delegate: LoginDelegate?
    let appD = UIApplication.shared.delegate as! AppDelegate
    var user: FIRUser?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.isHidden = true
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        emailTextField.tag = 0
        passwordTextField.tag = 1
        
        self.delegate = appD
        
        emailView.backgroundColor = UIColor.primaryGreen()
        
        let attr = [NSForegroundColorAttributeName: UIColor.appBlue()]
        let attr2 = [NSForegroundColorAttributeName: UIColor.primaryGreen()]
        let attrStr = NSAttributedString(string: "Submit", attributes: attr2)
        submitEmailButton.backgroundColor = UIColor.veryLightGrey()
        submitEmailButton.setAttributedTitle(attrStr, for: .normal)
        
        let icon = UIImage(named: "facebook")
        let tinted = icon?.withRenderingMode(.alwaysTemplate)
        
        let fbImage = UIImageView(frame: CGRect(x: 5, y: 5, width: 30, height: 30))
        fbImage.image = tinted!
        fbImage.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        fbImage.tintColor = UIColor.appBlue()
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        loginView.loginBehavior = .web
        let coloredTitle = NSAttributedString(string: "Login with Facebook", attributes: attr)
        faceBookButton.setAttributedTitle(coloredTitle, for: .normal)
        faceBookButton.layer.cornerRadius = 2
        faceBookButton.layer.borderColor = UIColor.lightGray.cgColor
        faceBookButton.layer.borderWidth = 0.7
        faceBookButton.layer.shadowOpacity = 0.7
        faceBookButton.layer.shadowColor = UIColor.darkGray.cgColor
        faceBookButton.layer.shadowRadius = 3
        faceBookButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        faceBookButton.addSubview(fbImage)
        print("This user is logged in: \(FBSDKAccessToken.current())")
        
        emailPwordButton.backgroundColor = UIColor.primaryGreen()
        emailPwordButton.layer.cornerRadius = 2
        segmentedC.tintColor = UIColor.white
        if FIRAuth.auth()?.currentUser == nil {
            signUp = true
            segmentedC.selectedSegmentIndex = 1
            emailTextField.placeholder = "Enter a valid email."
            passwordTextField.placeholder = "Select a password."
        } else {
            signUp = false
            segmentedC.selectedSegmentIndex = 0
            emailTextField.placeholder = "Enter your email."
            passwordTextField.placeholder = "Enter you password."
        }
    }
    
    func addEmpty(userWith Id: String) {
        let user = FocusUser(userName: nil, firebaseId: Id, imageString: nil, currentLocation: nil)
        FirebaseUpstream.sharedInstance.addToUsers(focusUser: user)
    }
    
    func checkForSignedUp() {
        if let uid = AuthApi.getFirebaseUid() {
            print("User logged in with id: \(uid)")
        }
    }
    
    func setUIForLogged() {
        faceBookButton.isEnabled = false
        self.faceBookButton.alpha = 0.2
        googleLoginButton.isEnabled = false
        emailPwordButton.isEnabled = false
        emailPwordButton.alpha = 0.2

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
    
    @IBAction func emailPwordTapped(_ sender: Any) {
        UIView.animate(withDuration: 0.7, animations: {
            self.emailMovementConstraint.constant = -20
            self.view.layoutIfNeeded()
            self.view.bringSubview(toFront: self.emailView)
        }, completion: nil)
    }
    
    @IBAction func segValChanged(_ sender: Any) {
        if segmentedC.selectedSegmentIndex == 0 {
            signUp = false
        } else {
            signUp = true
        }
    }
    
    @IBAction func submitEmailTapped(_ sender: Any) {
        if emailTextField.text != "" && passwordTextField.text != "" {
            self.email = emailTextField.text
            self.password = passwordTextField.text                      
        }
        guard let eml = self.email, let pwrd = self.password else {
            return
        }
        
        AuthApi.setPassword(password: pwrd)
        
        if signUp {
            FIRAuth.auth()?.createUser(withEmail: eml, password: pwrd, completion: { (user, error) in
                if error != nil {
                    self.showLoginFailedAlert(loginType: "email & password")
                    print("and here is the error: \(error?.localizedDescription)")
                } else {
                    if user != nil {
                        self.user = user
                        self.addEmpty(userWith: user!.uid)
                        FIRAuth.auth()?.currentUser?.sendEmailVerification(completion: { (error) in
                            if error != nil {
                                self.showLoginFailedAlert(loginType: "email")
                                print("there has been an error with email login: \(error?.localizedDescription)")
                            } else {
                                AuthApi.setEmailConfirmationSent()
                                if let id = user?.uid {
                                    AuthApi.set(firebaseUid: id)
                                }
                                UIView.animate(withDuration: 0.8, animations: {
                                    self.emailMovementConstraint.constant = 700
                                    self.view.layoutIfNeeded()
                                }) { (t) in
                                    if t {
                                        self.emailTextField.text = ""
                                        self.passwordTextField.text = ""
                                    }
                                }
                                self.defaults.set(user!.uid, forKey: "firebaseEmailLogin")
                                AuthApi.set(loggedIn: LoginTypes.Email)
                                self.showActivityIndicator()
                                self.promptToConfirm()
                                if (user?.isEmailVerified)! {
                                    print("Email verified")
                                }
                            }
                        })
                    } else {
                        self.showLoginFailedAlert(loginType: "email")
                    }
                }
            })
        } else {
            FIRAuth.auth()?.signIn(withEmail: eml, password: pwrd, completion: { (user, error) in
                if error != nil {
                    self.showLoginFailedAlert(loginType: "email")
                    print("there has been an error with email login: \(error?.localizedDescription)")
                } else {
                    if user != nil {
                        if let id = user?.uid {
                            AuthApi.set(firebaseUid: id)
                        }
                        UIView.animate(withDuration: 0.8, animations: {
                            self.emailMovementConstraint.constant = 700
                            self.view.layoutIfNeeded()
                        }) { (t) in
                            if t {
                                self.emailTextField.text = ""
                                self.passwordTextField.text = ""
                            }
                        }
                        self.defaults.set(user?.uid, forKey: "firebaseEmailLogin")
                        self.presentOwnUserProfile()
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.isHidden = true
                    } else {
                        self.showLoginFailedAlert(loginType: "email")
                    }
                }
            })
        }
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
    
    @IBAction func cancelEmailTapped(_ sender: Any) {
        UIView.animate(withDuration: 0.8, animations: {
            self.emailMovementConstraint.constant = 700
            self.view.layoutIfNeeded()
        }) { (t) in
            if t {
                self.emailTextField.text = ""
                self.passwordTextField.text = ""
            }
        }
    }
    
    // FaceBook Delegates
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        print("didlogin")
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("didlogout")
        faceBookButton.isEnabled = true
        googleLoginButton.isEnabled = true
    }
    
    func showActivityIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.backgroundColor = UIColor.black
        activityIndicator.layer.cornerRadius = 5
        activityIndicator.clipsToBounds = true
        activityIndicator.color = UIColor.white
        activityIndicator.startAnimating()
    }
    
    @IBAction func faceBookLoginClicked(_ sender: Any) {
       
        showActivityIndicator()
        loginView.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
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
                                self.activityIndicator.stopAnimating()
                                self.activityIndicator.isHidden = true
                                self.presentOwnUserProfile()
                                
                            }
                            
                            self.checkForSignedUp()
                            if error != nil {
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
    
    // GIDSignInDelegate
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        showActivityIndicator()
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
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
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
    
    func showLoginFailedAlert(loginType: String) {
        let alert = UIAlertController(title: "Login error", message: "There has been an error logging in with \(loginType). Please try again.", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .destructive, handler: nil)
        alert.view.tintColor = UIColor.primaryGreen()
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    // textField delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.tag == 0 {
            self.email = textField.text!
        }
        if textField.tag == 1 {
            self.password = textField.text!
        }
        return true
    }
}
