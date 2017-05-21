//
//  search_place.swift
//  FocusInterests
//
//  Created by Andrew Simpson on 5/19/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import SDWebImage

class SearchPlacesViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var navTitle: UINavigationItem!
    
    var places = [Place]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 6
        tableView.clipsToBounds = true
        let nib = UINib(nibName: "SearchPlaceCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "SearchPlaceCell")


        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:SearchPlaceCell = self.tableView.dequeueReusableCell(withIdentifier: "SearchPlaceCell") as! SearchPlaceCell!
        let place = places[indexPath.row]
        cell.placeNameLabel.text = place.name
        
        if place.address.count > 0{
            if place.address.count == 1{
                cell.addressTextView.text = "\(place.address[0])"
            }
            else{
                cell.addressTextView.text = "\(place.address[0])\n\(place.address[1])"
            }
        }
        
        cell.ratingLabel.text = "\(place.rating) (\(place.reviewCount) ratings)"
        cell.categoryLabel.text = place.categories[0].name
        
        let placeHolderImage = UIImage(named: "empty_event")
        cell.placeImage.sd_setImage(with: URL(string :place.image_url), placeholderImage: placeHolderImage)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
        
    }
    

   

}
