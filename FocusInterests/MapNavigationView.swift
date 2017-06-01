//
//  MapNavigationView.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/5/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

protocol NavigationInteraction {
    func messagesClicked()
    func notificationsClicked()
    func userProfileClicked()
    func searchClicked()
}

class MapNavigationView: UIView, UISearchBarDelegate {
    var delegate: NavigationInteraction?
    
    @IBOutlet weak var userProfileButton: UIButton!
    @IBOutlet var view: MapNavigationView!
    @IBOutlet weak var messagesButton: UIButton!
    
    @IBOutlet weak var notificationsButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var showSearchBar = true
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit(){
        Bundle.main.loadNibNamed("MapNavigationView", owner: self, options: nil)
        self.addSubview(self.view)
        
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.backgroundColor = UIColor.darkGray
        
        for view in searchBar.subviews.last!.subviews {
            if view.isKind(of: NSClassFromString("UISearchBarBackground")!)
            {
                view.removeFromSuperview()
            }
        }
//        
//        userProfileButton.contentMode = .center
//        userProfileButton.imageView?.contentMode = .scaleAspectFit
//        userProfileButton.imageEdgeInsets = UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100)

    }
    
    @IBAction func profileButtonPressed(_ sender: UIButton) {
        delegate?.userProfileClicked()
    }
    
    @IBAction func messagesButtonPressed(_ sender: UIButton) {
        delegate?.messagesClicked()
    }
    
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        delegate?.searchClicked()
//        if showSearchBar{
//            if searchBar.alpha == 0{
//                searchBar.alpha = 1
//            }
//            else{
//                searchBar.alpha = 0
//                searchBar.text = ""
//                searchBar.resignFirstResponder()
//            }
//        }
//        else{
//            print("show search!!")
//        }
    }
    
    @IBAction func notificationsButtonPressed(_ sender: UIButton) {
        delegate?.notificationsClicked()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("searching.. \(searchBar.text)")
        
        delegate?.searchClicked()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("cancel")
    }
}
