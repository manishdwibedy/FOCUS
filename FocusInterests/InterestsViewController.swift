//
//  InterestsViewController.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/19/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import FacebookCore
import FBSDKCoreKit
import SpriteKit
import SCLAlertView

var interest_status = [Interest]()
var interest_mapping = [String: Int]()



let sidePadding: CGFloat = 20.0
let numberOfItemsPerRow: CGFloat = 3.0
let hieghtAdjustment: CGFloat = 20.0
class InterestsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{

    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    var interests = [Interest]()
    let backgroundColor = UIColor.init(red: 22/255, green: 42/255, blue: 64/255, alpha: 1)
    var filtered = [Interest]()
    var searching = false
    
    var interestCells = [InterstCollectionViewCell]()
    
    var needsReturn = false
    var parentReturnVC: PinScreenViewController!
    var isNewUser = false
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var focus_string = ["Meet up", "Coffee", "Chill", "Celebration", "Food", "Drinks", "Business", "Learn", "Entertainment", "Arts", "Music", "Beauty", "Shopping", "Fitness", "Sports", "Outdoors", "Views", "Causes", "Community", "Travel", "Networking"]
    var focus = [Interest]()
    
    var old_interests = Set<String>()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        collectionView.delegate = self
        collectionView.dataSource = self
        let commentsNib = UINib(nibName: "InterstCollectionViewCell", bundle: nil)
        self.collectionView.register(commentsNib, forCellWithReuseIdentifier: "interestCell")
        
        if AuthApi.isNewUser(){
            saveButton.title = "Done"
        }
        
        let screenRect = UIScreen.main.bounds
        let screenWidth = screenRect.size.width
        let cellWidth = screenWidth/3.0
        
        
        let width = ((collectionView.frame.width) - sidePadding)/numberOfItemsPerRow
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: width)
        
        self.old_interests = Set(getUserInterests().components(separatedBy: ",").map { $0 })
        
        var selected_interests = [String:InterestStatus]()
        if let interests = AuthApi.getInterests(){
            let selected = interests.components(separatedBy: ",")
            
            var final_interest = [String]()
            for interest in selected{
                if interest.characters.count > 0{
                    let parts = interest.components(separatedBy: "-")
                    if parts.count == 2{
                        let interest_name = interest.components(separatedBy: "-")[0]
                        let status = interest.components(separatedBy: "-")[1]
                        
                        if status == "1"{
                            selected_interests[interest_name] = .like
                        }
                        else{
                            selected_interests[interest_name] = .love
                        }
                        
                    }
                    
                }
                
            }
        }
        
        for interest in focus_string{
            if let selected = selected_interests[interest]{
                let interest = Interest(name: interest, category: nil, image: nil, imageString: nil)
                interest.addStatus(status: selected)
                focus.append(interest)
            }
            else{
                focus.append(Interest(name: interest, category: nil, image: nil, imageString: nil))
            }
            
        }
        
        
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return focus.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "interestCell", for: indexPath) as! InterstCollectionViewCell
        
        let interest = focus[indexPath.row]
        switch(interest.status){
            case .normal:
                cell.backgroundColor = UIColor.clear
                cell.label.textColor = UIColor.white
                let imageName = "\(interest.name!) Blue"
                cell.image.image = UIImage(named: imageName)
                
                cell.view.layer.borderColor = UIColor(red: 22/255, green: 44/255, blue: 69/255, alpha: 1.0).cgColor
                cell.view.layer.borderWidth = 5
            case .like:
                cell.backgroundColor = UIColor(red: 22/255, green: 44/255, blue: 69/255, alpha: 1)
                cell.label.textColor = UIColor.white
                
                let imageName = "\(interest.name!) Green"
                cell.image.image = UIImage(named: imageName)
                
            case .love:
                cell.backgroundColor = UIColor.white
                cell.label.textColor = UIColor.black
                let imageName = "\(interest.name!) Green"
                cell.image.image = UIImage(named: imageName)
            default:
                break
        }
        
//        let imageName = "\(focus[indexPath.row].name!) Blue"
//        cell.image.image = UIImage(named: imageName)
        cell.label.text = focus[indexPath.row].name
        
        cell.parentVC = self
        cell.index = indexPath.row
        cell.indexPath = indexPath
//        interestCells.append(cell)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let screenRect = UIScreen.main.bounds
        let width = screenRect.size.width
        let cellWidth = width/3.0
        
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveInterests(_ sender: UIBarButtonItem) {
     
        var selected = [String]()
        var new_interests = Set<String>()
        for cell in self.focus
        {
            if cell.status == .like{
                selected.append("\(cell.name!)-1")
                new_interests.insert(cell.name!)
            }
            else if cell.status == .love{
                selected.append("\(cell.name!)-2")
                new_interests.insert(cell.name!)
            }
        }
        
        print(old_interests)
        print(new_interests)
        
        var add = new_interests
        var  remove = old_interests
        add.subtract(old_interests)
        remove.subtract(new_interests)

        
        if add.count > 0{
            for interest in add{
                Constants.DB.user_interests.child(interest).childByAutoId().setValue(["UID": AuthApi.getFirebaseUid()])
            }
        }

        if remove.count > 0{
            for interest in remove{
                
                if interest.characters.count > 0{
                    // remove interest
                    Constants.DB.user_interests.child(interest).queryOrdered(byChild: "UID").queryEqual(toValue: AuthApi.getFirebaseUid()!).observeSingleEvent(of: .value, with: { (snapshot) in
                        let value = snapshot.value as? NSDictionary
                        if value != nil {
                            for (key,_) in value!
                            {
                                print(key)
                                Constants.DB.user_interests.child(interest).child(key as! String).removeValue()
                            }
                            
                            
                            
                        }
                    })
                }
                
            }
        }
        
        let interests = selected.joined(separator: ",")
        
        Constants.DB.user.child(AuthApi.getFirebaseUid()!).updateChildValues(["interests": interests])
        AuthApi.set(interests: interests)
        
        if isNewUser{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "home") as! HomePageViewController

            present(vc, animated: true, completion: nil)
        }
        else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    func returnValue(FOCUS:String){
        parentReturnVC.interest = FOCUS
        parentReturnVC.focusLabel.text = FOCUS
        self.dismiss(animated: true, completion: nil)
    }
    
   
}



    
    
    
   
