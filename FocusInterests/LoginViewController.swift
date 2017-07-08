//
//  LoginViewController.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/3/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import AVFoundation
import FBSDKLoginKit
import FBSDKCoreKit
import FirebaseAuth
import GoogleSignIn
import SCLAlertView
import FirebaseMessaging
import Foundation
import CoreData
import SDWebImage

enum LoginTypes: String {
    case Email = "email"
    case Facebook = "facebook"
    case Google = "google"
}

class LoginViewController: UIViewController,GIDSignInUIDelegate, GIDSignInDelegate, FBSDKLoginButtonDelegate, UITextFieldDelegate, XMLParserDelegate {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var facebookLoginButton: UIButton!
    @IBOutlet weak var googleLoginButton: UIButton!
    @IBOutlet weak var regularSignInButton: UIButton!
    @IBOutlet weak var orView: UIView!
    
    let handle = Auth.auth()
    let loginView = FBSDKLoginManager()
    let defaults = UserDefaults.standard
    var delegate: LoginDelegate?
    let appD = UIApplication.shared.delegate as! AppDelegate
    var user: User?

    private var xmlParser : XMLParser? = nil
    private var accessToken : String?
    private var networkController : NetworkController!
    private var parsingBuffer : String = ""
    private var parsingAttributes = [String : String]()
    private var context: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().scopes = ["https://www.googleapis.com/auth/contacts.readonly"]
        GIDSignIn.sharedInstance().clientID = "633889221608-7mbafaqf9mmjqp1vbr1urq28utnthg2r.apps.googleusercontent.com"

        loginView.loginBehavior = .web
        
        self.regularSignInButton.roundCorners(radius: 9.0)
        self.facebookLoginButton.roundCorners(radius: 27.5)
        self.googleLoginButton.roundCorners(radius: 27.5)
        setUpTextFields()
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        handle.addStateDidChangeListener({ (auth, user) in
//            if let u = user {
//                print("user uid: \(u.uid)")
//                self.showHomeVC()
//            }
//        })
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        handle.removeStateDidChangeListener(handle)
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func emailLogin(_ sender: UIButton) {
        
        if (self.emailTextField.text?.isEmpty)!{
            showLoginFailedAlert(loginType: "missing_email")
            return
        }
        
        var isNumber = false
        if (self.emailTextField.text!.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) != nil){
            isNumber = true
        }
        if isNumber || (self.passwordTextField.text?.isEmpty)!{
            showLoginFailedAlert(loginType: "missing_password")
            return
        }
        
        if let email = self.emailTextField.text, let password = self.passwordTextField.text{
            AuthApi.setPassword(password: password)
            
            if isValidEmail(text: email){
                Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                    if error != nil {
                        self.showLoginFailedAlert(loginType: "email")
                        print("there has been an error with email login: \(String(describing: error?.localizedDescription))")
                    } else {
                        if user != nil {
                            if let id = user?.uid {
                                AuthApi.set(firebaseUid: id)
                                AuthApi.set(loggedIn: .Email)
                            }
                            
                            Constants.DB.user.child("\(AuthApi.getFirebaseUid()!)/email").setValue(email)
                            
                            self.emailTextField.text = ""
                            self.passwordTextField.text = ""
                            self.defaults.set(user?.uid, forKey: "firebaseEmailLogin")
                            AuthApi.set(userEmail: email)
                            self.showHomeVC()
                            
                            
                        } else {
                            self.showLoginFailedAlert(loginType: "email")
                        }
                    }
                })
            }
            else if isNumber{
                //Auth.auth().signIn(with: <#T##AuthCredential#>, completion: <#T##AuthResultCallback?##AuthResultCallback?##(User?, Error?) -> Void#>)
            }
            else{
                let ref = Constants.DB.user_mapping
                ref.child(email).observeSingleEvent(of: .value, with: { snapshot in
                    let user = snapshot.value as? String
                    
                    if let userEmail = user{
                        Auth.auth().signIn(withEmail: userEmail, password: password, completion: { (user, error) in
                            if error != nil {
                                self.showLoginFailedAlert(loginType: "email")
                                print("there has been an error with email login: \(String(describing: error?.localizedDescription))")
                            } else {
                                if user != nil {
                                    if let id = user?.uid {
                                        AuthApi.set(firebaseUid: id)
                                        AuthApi.set(loggedIn: .Email)
                                    }
                                    
                                    Constants.DB.user.child("\(AuthApi.getFirebaseUid()!)/email").setValue(email)
                                    
                                    let token = Messaging.messaging().fcmToken
                                    Constants.DB.user.child("\(AuthApi.getFirebaseUid()!)/token").setValue(token)
                                    AuthApi.set(FCMToken: token)
                                    Constants.DB.user.child("\(AuthApi.getFirebaseUid()!)/firebaseUserId").setValue(AuthApi.getFirebaseUid()!)
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
                    else{
                        self.showLoginFailedAlert(loginType: "email")
                    }
                    
                })
                
            }
        }
    }

    @IBAction func facebookLogin(_ sender: UIButton) {
        loginView.loginBehavior = .native
        loginView.logIn(withReadPermissions: ["public_profile", "email", "user_friends"], from: self) { (result, error) in
            if error != nil {
                print(error?.localizedDescription ?? "")
                self.showLoginFailedAlert(loginType: "Facebook")
            } else {
                if let res = result {
                    if res.isCancelled {
                        return
                    }
                    if let tokenString = FBSDKAccessToken.current().tokenString {
                        
                        let credential = FacebookAuthProvider.credential(withAccessToken: tokenString)
                        Auth.auth().signIn(with: credential) { (user, error) in
                            if let u = user {
                                let fireId = u.uid
//                                self.addEmpty(userWith: fireId)
                                AuthApi.set(firebaseUid: fireId)
                                AuthApi.set(loggedIn: .Facebook)
                                AuthApi.set(facebookToken: FBSDKAccessToken.current().tokenString)
                                
                                
                                let graphRequest:FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id, first_name, last_name ,email, picture.type(large)"])
                                graphRequest.start(completionHandler: { (connection, result, error) -> Void in
                                    
                                    if ((error) != nil)
                                    {
                                        print("Error: \(error)")
                                    }
                                    else{
                                        self.getFacebookData(uuid: fireId, result: result ?? "")
                                    }
                                    AuthApi.set(userEmail: user?.email)
                                    Share.getFacebookFriends()
                                    self.showHomeVC()
                                })

                                
                                
                            }
                            
                            self.checkForSignedUp()
                            if let error = error{
                                showLoginError(error)
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
        
        self.emailTextField.attributedPlaceholder = NSAttributedString(string: "Username, Email or Phone Number", attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
        self.passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
        
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
        
        if getUserInterests().characters.count == 0{
            let interestsVC = InterestsViewController(nibName: "InterestsViewController", bundle: nil)
            interestsVC.isNewUser = true
            self.present(interestsVC, animated: true, completion: nil)
        }
        else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "home") as! HomePageViewController
            present(vc, animated: true, completion: nil)
        }
        
        
    }
    
    func showLoginFailedAlert(loginType: String) {
        var alert: UIAlertController? = nil
        
        if loginType == "missing_email"{
            alert = UIAlertController(title: "Login error", message: "Please enter a valid email/username", preferredStyle: .alert)
        }
        else if loginType == "missing_password"{
            alert = UIAlertController(title: "Login error", message: "Please enter a valid password", preferredStyle: .alert)
        }
        else{
             alert = UIAlertController(title: "Login error", message: "There has been an error logging in with \(loginType). Please try again.", preferredStyle: .alert)
        }
        let action = UIAlertAction(title: "Ok", style: .destructive, handler: nil)
        alert?.view.tintColor = UIColor.primaryGreen()
        alert?.addAction(action)
        self.present(alert!, animated: true, completion: nil)
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
        guard let googleUser = user else{
            return
        }
        let accessToken = user.authentication.accessToken
        
        let formattedToken: String = String(format: "Bearer %@", user.authentication.accessToken)
        let manager = SDWebImageManager.shared().imageDownloader
        manager!.setValue(formattedToken, forHTTPHeaderField: "Authorization")
        manager!.setValue("3.0", forHTTPHeaderField: "GData-Version")
        
        self.networkController = NetworkController(accessToken: accessToken!)
        loadContacts()
        
        print("my email: \(googleUser.profile.email)")
        if let id = googleUser.authentication.accessToken, let idToken = googleUser.authentication.idToken {
            
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                              accessToken: id)
            Auth.auth().signIn(with: credential, completion: { (user, error) in
                if let u = user {
                    let fireId = u.uid
                    
//                    self.addEmpty(userWith: fireId)
                    AuthApi.set(firebaseUid: fireId)
                    AuthApi.set(loggedIn: .Google)
                    AuthApi.set(googleToken: id)
                    
                    let userRef = Constants.DB.user.child(fireId).observeSingleEvent(of: .value, with: {(snapshot) in
                    
                        let info = snapshot.value as? [String:Any]
                        
                        if let fullname = info?["fullname"] as? String{
                            if fullname.isEmpty{
                                Constants.DB.user.child("\(fireId)/fullname").setValue(googleUser.profile.name)
                            }
                            
                        }
                        else{
                            Constants.DB.user.child("\(fireId)/fullname").setValue(googleUser.profile.name)
                        }
                        
                        if let image_string = info?["image_string"] as? String{
                            if image_string.isEmpty{
                                Constants.DB.user.child("\(fireId)/image_string").setValue(googleUser.profile.imageURL(withDimension: 375).absoluteString)
                                AuthApi.set(userImage: googleUser.profile.imageURL(withDimension: 375).absoluteString)
                            }
                            AuthApi.set(userImage: image_string)
                        }
                        else{
                            Constants.DB.user.child("\(fireId)/image_string").setValue(googleUser.profile.imageURL(withDimension: 375).absoluteString)
                            AuthApi.set(userImage: googleUser.profile.imageURL(withDimension: 375).absoluteString)
                        }
                        
                        if let interests = info?["interests"] as? String{
                            AuthApi.set(interests: interests)
                        }
                        else{
                            AuthApi.set(interests: "")
                        }
                        
                        if let username = info?["username"] as? String{
                            AuthApi.set(username: username)
                        }
                        else{
                            AuthApi.set(username: "")
                        }
                        let token = Messaging.messaging().fcmToken
                        Constants.DB.user.child("\(fireId)/token").setValue(token)
                        AuthApi.set(FCMToken: token)
                        
                        Constants.DB.user.child("\(fireId)/firebaseUserId").setValue(AuthApi.getFirebaseUid()!)
                        AuthApi.set(userEmail: googleUser.profile.email)
                        self.showHomeVC()
                        
                    })
                    
                } else {
                    if let error = error{
                        showLoginError(error)
                        return
                    }
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
    
    func getFacebookData(uuid fireId: String,result: Any)
    {
        let data:[String:AnyObject] = result as! [String : AnyObject]
        
        let facebook_id = data["id"] as? String
        let first_name = data["first_name"] as? String
        let last_name = data["last_name"] as? String
        
        let facebook_image_string = (data["picture"]?["data"] as! [String:Any])["url"] as? String
        let username = data["email"] as? String
        
        let userRef = Constants.DB.user.child(fireId).observeSingleEvent(of: .value, with: {(snapshot) in
            
            let info = snapshot.value as? [String:Any]
            
            if let fullname = info?["fullname"] as? String{
                if fullname.isEmpty{
                    Constants.DB.user.child("\(fireId)/fullname").setValue("\(first_name!) \(last_name!)")
                }
                
            }
            else{
                Constants.DB.user.child("\(fireId)/fullname").setValue("\(first_name!) \(last_name!)")
            }
            
            if let image_string = info?["image_string"] as? String{
                if image_string.isEmpty{
                    Constants.DB.user.child("\(fireId)/image_string").setValue(facebook_image_string)
                    AuthApi.set(userImage: facebook_image_string)
                }
                AuthApi.set(userImage: image_string)
            }
            else{
                Constants.DB.user.child("\(fireId)/image_string").setValue(facebook_image_string)
                AuthApi.set(userImage: facebook_image_string)
            }
            
            if let username = info?["username"] as? String{
                AuthApi.set(username: username)
            }
            
            let token = Messaging.messaging().fcmToken
            Constants.DB.user.child("\(fireId)/firebaseUserId").setValue(fireId)
            Constants.DB.user.child("\(fireId)/token").setValue(token)
            AuthApi.set(FCMToken: token)
            
            
            
        })
    }
    
    public func loadContacts() {
        let contactsURL : NSURL = NSURL(string: "https://www.google.com/m8/feeds/contacts/default/thin?max-results=10000")!
        
        
        self.networkController.sendRequestToURL(url: contactsURL, completion: { (data, response, error) -> () in
            print(response?.statusCode)
            if (response?.statusCode == 200 && error == nil) {
                
                DispatchQueue.global(qos: .background).async {
                    let delegate = UIApplication.shared.delegate as! AppDelegate
                    self.context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                    self.context.parent = delegate.persistentContainer.viewContext
                    
                    //self.parseContactsFromData(data: data!)
                }
                
            } else {
            }
        })
    }
    
    private func parseContactsFromData(data : NSData) {
        self.parsingBuffer = ""
        self.xmlParser = XMLParser.init(data: data as Data)
        self.xmlParser?.delegate = self
        self.xmlParser?.parse()
    }
    
    // XML Parser delegate methods
    func parserDidStartDocument(_ parser: XMLParser) {
        let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        do {
            try self.context.save()
        } catch let error as NSError {
            NSLog("Unresolved error: %@, %@", error, error.userInfo)
        }
        let delegate = UIApplication.shared.delegate as! AppDelegate
        
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        self.parsingBuffer = ""
        self.parsingAttributes = attributeDict
        
        if elementName == "entry" {
            
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        self.parsingBuffer += string
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
    }
    
}

class NetworkController : NSObject {
    
    private var session : URLSession
    private var accessToken : String? = nil
    
    
    //MARK: - Setup & Teardown
    
    
    override init() {
        let sessionConfiguration : URLSessionConfiguration = URLSessionConfiguration.ephemeral
        self.session = URLSession.init(configuration: sessionConfiguration)
    }
    
    
    init(accessToken: String) {
        let sessionConfiguration : URLSessionConfiguration = URLSessionConfiguration.ephemeral
        let formattedToken : NSString = NSString(format: "Bearer %@", accessToken)
        sessionConfiguration.httpAdditionalHeaders = ["Authorization" : formattedToken, "GData-Version" : "3.0"]
        self.accessToken = accessToken
        self.session = URLSession.init(configuration: sessionConfiguration)
    }
    
    
    //MARK: - Public Instance Methods
    
    
    public func sendRequestToURL(url : NSURL, completion: @escaping (NSData?, HTTPURLResponse?, NSError?) -> ()) {
        let dataTask : URLSessionDataTask = (self.session.dataTask(with: url as URL, completionHandler:{(data, response, error) -> Void in
            let httpResponse : HTTPURLResponse =  response as! HTTPURLResponse
            DispatchQueue.main.async(execute: { () -> Void in
                completion(data as NSData?, httpResponse, error as NSError?)
            })
        }))
        
        dataTask.resume()
    }
    
    
}

