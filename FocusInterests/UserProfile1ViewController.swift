//
//  UserProfile1ViewController.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 3/15/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

protocol UserProfileCell {
    func configureFor(user: FocusUser)
}

enum ReuseIdentifiers: String {
    case UserImage = "UserPhotoCell"
    case UserDescription = "UserDescriptionCell"
    case FollowCell = "FollowCell"
    case SocialGroupCell = "SocialCrowdCell"
    case DisplayInterestCell = "DisplayInterestsCell"
    case SelectedInterestCell = "SelectedInterestCell"
}

protocol EditDelegate {
    func makeEditable(currentString: String)
    func makeStatic()
}

protocol DescriptionDelegate {
    func update(description: String)
}

protocol CellImageDelegate {
    func set(image: UIImage)
}

class UserProfile1ViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate, InterestPickerDelegate {
    
    @IBOutlet weak var interestsViewWidthConstraints: NSLayoutConstraint!
    @IBOutlet weak var interestViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var interestsViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var interestsView: UIView!
    @IBOutlet weak var UserNameLabel: UILabel!
    @IBOutlet weak var textViewContainer: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewTrailing: NSLayoutConstraint!
    @IBOutlet weak var textViewLeading: NSLayoutConstraint!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var FakeToolBar: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomBar: UIView!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var usernameTopConstraint: NSLayoutConstraint!
    var inEditMode = false
    var editDelegate: EditDelegate?
    var imageEditDelegate: EditDelegate?
    var cellImageDelegate: CellImageDelegate?
    let pickerController = UIImagePickerController()
    var profileImageUrl: String?
    var descriptionDelegate: DescriptionDelegate?
    var user: FocusUser?
    var descript = "I am a fake user. But I'm interested in whether or not the words in this string will wrap for a means of line-break and stretch the cell's height."
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginDelegate = appD
        tableView.delegate = self
        userNameTextField.delegate = self
        
        UIApplication.shared.statusBarStyle = .lightContent

        FakeToolBar.backgroundColor = UIColor.primaryGreen()
        bottomBar.backgroundColor = UIColor.primaryGreen()
        // Cell registration
        let imageCellNib = UINib(nibName: ReuseIdentifiers.UserImage.rawValue, bundle: nil)
        tableView.register(imageCellNib, forCellReuseIdentifier: ReuseIdentifiers.UserImage.rawValue)
        let descriptionCellNib = UINib(nibName: ReuseIdentifiers.UserDescription.rawValue, bundle: nil)
        tableView.register(descriptionCellNib, forCellReuseIdentifier: ReuseIdentifiers.UserDescription.rawValue)
        let followNib = UINib(nibName: ReuseIdentifiers.FollowCell.rawValue, bundle: nil)
        tableView.register(followNib, forCellReuseIdentifier: ReuseIdentifiers.FollowCell.rawValue)
        let socialNib = UINib(nibName: ReuseIdentifiers.SocialGroupCell.rawValue, bundle: nil)
        tableView.register(socialNib, forCellReuseIdentifier: ReuseIdentifiers.SocialGroupCell.rawValue)
        let interestsNib = UINib(nibName: ReuseIdentifiers.DisplayInterestCell.rawValue, bundle: nil)
        tableView.register(interestsNib, forCellReuseIdentifier: ReuseIdentifiers.DisplayInterestCell.rawValue)
        
        usernameTopConstraint.constant = -60
        userNameTextField.autocapitalizationType = .words
        userNameTextField.clearButtonMode = .whileEditing
        
        // So cells can stretch if needed
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
        
        animateInterestViewIn()
        
        // Configure textViewContainer
        textViewContainer.layer.cornerRadius = 10
        textViewContainer.backgroundColor = UIColor.primaryGreen()
        textViewContainer.layer.borderColor = UIColor.white.cgColor
        textViewContainer.layer.borderWidth = 2
        textViewContainer.clipsToBounds = true
        textView.layer.cornerRadius = 10
        textView.layer.borderWidth = 2
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.clipsToBounds = true
        textViewLeading.constant = 408
        textViewTrailing.constant = 392
        
        pullUser()
    }
    
    func pullUser() {
        self.user = FocusUser()
        FirebaseDownstream.shared.getCurrentUser { (dict) in
            if let dct = dict {
                let modDict: [String : AnyObject] = dct as! [String : AnyObject]
                if let uName = modDict["username"] as? String {
                    self.user?.setUsername(username: uName)
                    self.UserNameLabel.text = uName
                }
                if let descr = modDict["description"] as? String {
                    self.user?.setDescription(description: descr)
                    self.descript = descr
                    self.descriptionDelegate?.update(description: descr)
                }
                if let imString = modDict["image_string"] as? String {
                    self.user?.setImageString(imageString: imString)
                }
                
                
                
                self.tableView.reloadData()
                /*
                if let loc = modDict["current_location"] as? String {
                    self.user?.setCurrentLocation(location: <#T##CLLocationCoordinate2D#>)
                }
                 */
            }
        }
    }
    
    func presentIntPicker() {
        let vc = InterestListViewController(nibName: "InterestListViewController", bundle: nil)
        vc.user = self.user
        present(vc, animated: true, completion: nil)
    }
    
    func add(interests: [Interest]) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // IBActions
    @IBAction func editTapped(_ sender: Any) {
        animate(constraint: textViewLeading, finishingConstant: 408.0)
        animate(constraint: textViewTrailing, finishingConstant: 392.0)
        animate(constraint: usernameTopConstraint, finishingConstant: -60.0)
        if inEditMode {
            
            inEditMode = false
            editDelegate?.makeStatic()
            imageEditDelegate?.makeStatic()
            editButton.setTitle("Edit", for: .normal)
            UserNameLabel.layer.borderColor = UIColor.primaryGreen().cgColor
            UserNameLabel.gestureRecognizers = []
            user!.firebaseId = AuthApi.getFirebaseUid()
            FirebaseUpstream.sharedInstance.addToUsers(focusUser: user!)
        } else {
            inEditMode = true
            if let str = user?.description {
                editDelegate?.makeEditable(currentString: str)
            } else {
                editDelegate?.makeEditable(currentString: "No Description yet.")
            }
            if let imStr = user?.imageString {
                imageEditDelegate?.makeEditable(currentString: imStr)
            } else {
                imageEditDelegate?.makeEditable(currentString: "")
            }
            editButton.setTitle("Done", for: .normal)
            UserNameLabel.isUserInteractionEnabled = true
            let tapGr = UITapGestureRecognizer(target: self, action: #selector(UserProfile1ViewController.animateUsernameText))
            UserNameLabel.addGestureRecognizer(tapGr)
            UserNameLabel.layer.cornerRadius = 5
            UserNameLabel.clipsToBounds = true
            UserNameLabel.layer.borderWidth = 1
            UserNameLabel.layer.borderColor = UIColor.white.cgColor
        }
    }
    
    @IBAction func cancelDescription(_ sender: Any) {
        animate(constraint: textViewLeading, finishingConstant: 408.0)
        animate(constraint: textViewTrailing, finishingConstant: 392.0)
    }
    @IBAction func saveDescription(_ sender: Any) {
        descript = textView.text
        descriptionDelegate?.update(description: textView.text)
        textView.resignFirstResponder()
        animate(constraint: textViewLeading, finishingConstant: 408.0)
        animate(constraint: textViewTrailing, finishingConstant: 392.0)
        
        var des = textView.text
        if textView.text == "" {
            des = descript
        }
        user!.setDescription(description: des!)
        tableView.reloadData()
    }
    
    // Helpers
    func animateUsernameText() {
        animate(constraint: usernameTopConstraint, finishingConstant: 19)
        userNameTextField.becomeFirstResponder()
    }
    
    // Tableviewdatasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 1
        case 3:
            return 1
            
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifiers.UserImage.rawValue) as? UserPhotoCell
            self.imageEditDelegate = cell!
            self.cellImageDelegate = cell!
            if let imStr = user?.imageString {
                cell?.userImage.download(urlString: imStr, completion: { (imag) in
                    if let im = imag {
                        self.cellImageDelegate?.set(image: im)
                    }
                })
            }
            return cell!
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifiers.UserDescription.rawValue) as? UserDescriptionCell
            self.editDelegate = cell!
            self.descriptionDelegate = cell!
            cell?.descriptionLabel.text = descript
            return cell!
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifiers.SocialGroupCell.rawValue) as? SocialCrowdCell
            cell?.configureFor(followers: Constants.FollowArrays.followers, followed: Constants.FollowArrays.followings)
            return cell!
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifiers.DisplayInterestCell.rawValue) as? DisplayInterestsCell
            if let u = self.user {
                cell?.configureFor(user: u)
            }
            return cell!
        default:
            return UITableViewCell()
        }
    }

    func animate(constraint: NSLayoutConstraint, finishingConstant: CGFloat) {
        UIView.animate(withDuration: 0.6, animations: {
            constraint.constant = finishingConstant
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 0:
            user?.setUsername(username: userNameTextField.text!)
            userNameTextField.resignFirstResponder()
            if userNameTextField.text != "" {
                UserNameLabel.text = userNameTextField.text
            }
            animate(constraint: usernameTopConstraint, finishingConstant: -60)
            showPickerActionSheet()
        case 1:
            animate(constraint: textViewLeading, finishingConstant: 8.0)
            animate(constraint: textViewTrailing, finishingConstant: 8.0)
            user?.setUsername(username: userNameTextField.text!)
            if userNameTextField.text != "" {
                UserNameLabel.text = userNameTextField.text
            }
            animate(constraint: usernameTopConstraint, finishingConstant: -60)
            userNameTextField.resignFirstResponder()
            textView.becomeFirstResponder()
        case 2:
            let vc = SocialGroupViewController(nibName: "SocialGroupViewController", bundle: nil)
            vc.followers = Constants.FollowArrays.followers
            vc.following = Constants.FollowArrays.followings
            vc.username = (self.user?.userName)!
            present(vc, animated: true, completion: nil)
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 2:
            return 50
        case 3:
            return 50
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let blank = UIView()
        blank.frame.size.height = 0
        let center = ((UIScreen.main.bounds.size.width / 2) + 5)
        switch section {
        case 2:
            let hView = UIView()
            hView.backgroundColor = UIColor.primaryGreen()
            let followers = UILabel(frame: CGRect(x: 10, y: 10, width: 100, height: 30))
            followers.text = "Followers"
            followers.textAlignment = .center
            followers.textColor = UIColor.white
            followers.font = UIFont(name: "Futura", size: 22)
            hView.addSubview(followers)
            let following = UILabel(frame: CGRect(x: center, y: 10, width: 100, height: 30))
            following.textColor = UIColor.white
            following.text = "Following"
            following.font = UIFont(name: "Futura", size: 22)
            following.textAlignment = .center
            hView.addSubview(following)
            return hView
        case 3:
            let hView = UIView()
            hView.backgroundColor = UIColor.primaryGreen()
            let label = UILabel(frame: CGRect(x: 10, y: 10, width: 130, height: 30))
            label.text = "My Interests"
            label.textAlignment = .center
            label.textColor = UIColor.white
            label.font = UIFont(name: "Futura", size: 22)
            hView.addSubview(label)
            let button = UIButton(frame: CGRect(x: self.view.frame.width - 60, y: 5, width: 40, height: 40))
            let plus = UIImage(named: "plus")
            let renderPlus = plus?.withRenderingMode(.alwaysTemplate)
            button.setImage(renderPlus!, for: .normal)
            button.tintColor = UIColor.white
            button.addTarget(self, action: #selector(UserProfile1ViewController.presentIntPicker), for: .touchUpInside)
            hView.addSubview(button)
            return hView
        default:
            return blank
        }
    }
    
    // TextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        animate(constraint: usernameTopConstraint, finishingConstant: -60.0)
        if textField.text != "" {
            UserNameLabel.text = textField.text
            user?.setUsername(username: textField.text!)
        }
        userNameTextField.text = ""
        return true
    }
    
    // TextView delegate
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }
}
