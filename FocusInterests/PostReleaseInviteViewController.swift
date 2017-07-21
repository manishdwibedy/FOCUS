//
//  PostReleaseInviteViewController.swift
//  FocusInterests
//
//  Created by Alex Jang on 7/20/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import SDWebImage

class PostReleaseInviteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var inviteTableView: UITableView!
    
    var nofArray = [FocusNotification]()
    var invArray = [FocusNotification]()
    var feedAray = [FocusNotification]()
//    NotificationFeedCellTableViewCell
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = Constants.color.navy
        self.navBar.titleTextAttributes = Constants.navBar.attrs
        self.navBar.barTintColor = Constants.color.navy
        self.inviteTableView.delegate = self
        self.inviteTableView.dataSource = self
        
        let inviteNib = UINib(nibName: "NotificationFeedCellTableViewCell", bundle: nil)
        self.inviteTableView.register(inviteNib, forCellReuseIdentifier: "inviteCell")
        
        self.inviteTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //            return invArray.count
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let inviteCell = tableView.dequeueReusableCell(withIdentifier: "inviteCell", for: indexPath) as! NotificationFeedCellTableViewCell
        inviteCell.parentVC = self
        inviteCell.isFeed = false
//        inviteCell.seeYouThereButton.isHidden = false
//        inviteCell.nextTimeButton.isHidden = false
//
//        inviteCell.nofArray = self.nofArray
//        inviteCell.invArray = self.invArray
//        inviteCell.feedAray = self.feedAray
        
//        TODO: Error here
        inviteCell.setupCell(notif: FocusNotification(type: NotificationType.Invite, sender: NotificationUser(username: AuthApi.getUserName(), uuid: AuthApi.getFirebaseUid(), imageURL: AuthApi.getUserImage()), item: ItemOfInterest(itemName: "philz-coffee-cupertino", imageURL: "https://s3-media3.fl.yelpcdn.com/bphoto/Nuy5AjMNoD3r6hasmCofbg/o.jpg", type: "place"), time: Date())
        )

//        FocusNotification(type: NotificationType.Invite, sender: NotificationUser(username: AuthApi.getUserName(), uuid: AuthApi.getFirebaseUid(), imageURL: AuthApi.getUserImage()), item: ItemOfInterest(itemName: "philz-coffee-cupertino", imageURL: "https://s3-media3.fl.yelpcdn.com/bphoto/Nuy5AjMNoD3r6hasmCofbg/o.jpg", type: "place"), time: Date())
        
        if let url = URL(string: "https://s3-media3.fl.yelpcdn.com/bphoto/Nuy5AjMNoD3r6hasmCofbg/o.jpg"){
            SDWebImageManager.shared().downloadImage(with: url, options: .continueInBackground, progress: {
                (receivedSize :Int, ExpectedSize :Int) in
                
            }, completed: {
                (image : UIImage?, error : Error?, cacheType : SDImageCacheType, finished : Bool, url : URL?) in
                
                if image != nil && finished{
                    inviteCell.locationImage.image = crop(image: image!, width: 50, height: 50)
                }
            })
            
        }
        
//          MARK: Message button
        inviteCell.seeYouThereButton.roundCorners(radius: 5.0)
        
//        MARK: Accepted button
        inviteCell.nextTimeButton.roundCorners(radius: 5.0)
        
//        MARK: User Profile Image
        inviteCell.userProfilePic.layer.borderWidth = 1
        inviteCell.userProfilePic.layer.borderColor = Constants.color.green.cgColor
        inviteCell.userProfilePic.roundButton()
        
//        MARK: Username Label
//        inviteCell.userNameLabel.text = "arya invited you to the Rose Bowl"
        
//        MARK: Location Image
        inviteCell.locationImage.layer.borderWidth = 1
        inviteCell.locationImage.layer.borderColor = Constants.color.lightBlue.cgColor
        inviteCell.locationImage.roundedImage()
        
//        inviteCell.timeLabel.text = "31 min"
        
        return inviteCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
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
