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
            
            //Now you can start downloading the image or any file from the storage using URLSession.
            self.image.sd_setImage(with: url, placeholderImage: placeholderImage)
            
        })
        // Load the image using SDWebImage
        
//        image.sd_setImage(with: reference.fullPath, placeholderImage: placeholderImage)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
