//
//  EventDetailViewController.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 4/19/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import SDWebImage

class EventDetailViewController: UIViewController {
    @IBOutlet weak var likeCount: UILabel!
    
    var event: Event?
    
    @IBOutlet weak var image: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Reference to an image file in Firebase Storage
        
        self.navigationItem.title = self.event?.title
        
        let reference = Constants.storage.event.child("\(event!.id!).jpg")
        
        // Placeholder image
        let placeholderImage = UIImage(named: "empty_event")
        
        reference.downloadURL(completion: { (url, error) in
            
            if error != nil {
                print(error?.localizedDescription)
                return
            }
            
            self.image.sd_setImage(with: url, placeholderImage: placeholderImage)
            self.image.setShowActivityIndicator(true)
            self.image.setIndicatorStyle(.gray)
            
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func inviteEvent(_ sender: UIButton) {
    }
    
    @IBAction func likeEvent(_ sender: UIButton) {
        let eventRef = Constants.DB.event.child("\(event!.id!)")
//        if eventRef.child("likes").exi
    }

    @IBAction func attendEvent(_ sender: UIButton) {
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
