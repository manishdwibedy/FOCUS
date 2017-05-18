//
//  PlaceViewController.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/15/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class PlaceViewController: UIViewController {

    var place: Place?
    
    @IBOutlet weak var ratingView: UIView!
    @IBOutlet weak var pinView: UIView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationBar.topItem?.title = place?.name
        ratingLabel.text = "\(place!.rating)"
        
        imageView.sd_setImage(with: URL(string: (place?.image_url)!), placeholderImage: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func valueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            UIView.animate(withDuration: 0.5, animations: {
                self.pinView.alpha = 1
                self.ratingView.alpha = 0
            })
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.pinView.alpha = 0
                self.ratingView.alpha = 1
            })
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pinInfo"{
            let pin = segue.destination as! PinViewController
            pin.place = self.place
        }
        else if segue.identifier == "rating"{
            let rating = segue.destination as! RatingViewController
            rating.place = self.place
        }
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
