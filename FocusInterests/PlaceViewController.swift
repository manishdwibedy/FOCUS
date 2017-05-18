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

protocol Comments {
    func gotComments(comments: [PlaceRating])
}
class PlaceViewController: UIViewController {
    var delegate: Comments?
    var place: Place?
    var rating = [PlaceRating]()
    
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
        self.getLatestComments()
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
            rating.placeVC = self
            rating.place = self.place
            rating.ratings = self.rating
        }
    }
    
    func getLatestComments(){
        let place = Constants.DB.places
        let comments = place.child((self.place?.id)!).child("comments")
        
        comments.queryOrdered(byChild: "date").queryLimited(toLast: 5).observeSingleEvent(of: .value, with: {snapshot in
            
            if let comments = snapshot.value as? [String: [String: Any]]{
                for (_, comment) in comments.enumerated(){
                    print(comment.key)
                    let id = comment.value["user"] as! String
                    let commentText = comment.value["comment"] as! String
                    let rating = comment.value["rating"] as! Double
                    let date = comment.value["date"] as! Double
                    
                    let placeComment = PlaceRating(uid: id, date: Date(timeIntervalSince1970: date), rating: rating)
                    
                    Constants.DB.user.child(id).observeSingleEvent(of: .value, with: {snapshot in
                        let value = snapshot.value as! [String: Any]
                        let username = value["username"] as! String
                        placeComment.setUsername(username: username)
                        
                        self.delegate?.gotComments(comments: self.rating)
                    })
                    
                    
                    
                    if commentText.characters.count > 0{
                        placeComment.addComment(comment: commentText)
                    }
                    self.rating.append(placeComment)
                }
            }
            
            
        })
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
