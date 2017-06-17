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
    let user_interests = AuthApi.getInterests()?.components(separatedBy: ",")
    
    var interestCells = [InterstCollectionViewCell]()
    
//    var imageArrayBlue = ["Arts Blue","Beauty Blue","Business Blue","Causes Blue","Celebration Blue","Chill Blue","Coffee Blue","Community Blue","Drinks Blue","Entertainment Blue","Fitness Blue","Food Blue","Learn Blue","Meet up Blue","Music Blue","Networking Blue","Outdoors Blue","Shopping Blue","Sports Blue","Travel Blue","Views Blue"]
//    
//    var imageArrayGreen = ["Arts Green","Beauty Green","Business Green","Causes Green","Celebration Green","Chill Green","Coffee Green","Community Green","Drinks Green","Entertainment Green","Fitness Green","Food Green","Learn Green","Meet up Green","Music Green","Networking Green","Outdoors Green","Shopping Green","Sports Green","Travel Green","Views Green"]
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var focus_string = ["Meet up", "Coffee", "Chill", "Celebration", "Food", "Drinks", "Business", "Learn", "Entertainment", "Arts", "Music", "Beauty", "Shopping", "Fitness", "Sports", "Outdoors", "Views", "Causes", "Community", "Travel", "Networking"]
    var focus = [Interest]()
    
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
        
        for interest in focus_string{
            focus.append(Interest(name: interest, category: nil, image: nil, imageString: nil))
        }
        
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return focus.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "interestCell", for: indexPath) as! InterstCollectionViewCell
        let imageName = "\(focus[indexPath.row].name!) Blue"
        cell.image.image = UIImage(named: imageName)
        cell.label.text = focus[indexPath.row].name
        cell.parentVC = self
        cell.index = indexPath.row
        cell.indexPath = indexPath
        interestCells.append(cell)
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
//        let selected_interests = interest_status.filter( { return $0.status != .normal } )
//        let interest_string = selected_interests.map(){ $0.name! }.joined(separator: ",")
//        
//        var interests = ""
//        if AuthApi.isNewUser(){
//            if selected_interests.count == 0{
//                SCLAlertView().showError("Invalid Interests", subTitle: "Please choose atleast one interest.")
//                return
//            }
//            interests = interest_string
//        }
//        else{
//            let earlier_interests = AuthApi.getInterests()!
//            interests = "\(earlier_interests),\(interest_string)"
//        }
//
        
    var interestAll = ""
    for cell in interestCells
    {
        if cell.liked == true || cell.loved == true
        {
            interestAll = interestAll + cell.label.text!+","
        }

    }
        
    Constants.DB.user.child(AuthApi.getFirebaseUid()!).updateChildValues(["interests":interestAll])
    AuthApi.set(interests: interestAll)
        
    if AuthApi.isNewUser(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        let vc = storyboard.instantiateViewController(withIdentifier: "home") as! HomePageViewController

        present(vc, animated: true, completion: nil)
    }
    else{
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
  }
    
   
}



    
    
    
   
