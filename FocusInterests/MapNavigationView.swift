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
}

class MapNavigationView: UIView, UISearchBarDelegate {
    var delegate: NavigationInteraction?
    
    @IBOutlet var view: MapNavigationView!
    
    @IBOutlet weak var searchBar: UISearchBar!
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
    }
    
    @IBAction func profileButtonPressed(_ sender: UIButton) {
        print("profile")
    }
    
    @IBAction func messagesButtonPressed(_ sender: UIButton) {
        delegate?.messagesClicked()
    }
    
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        if searchBar.alpha == 0{
            searchBar.alpha = 1
        }
        else{
            searchBar.alpha = 0
            searchBar.text = ""
            searchBar.resignFirstResponder()
        }
    }
    
    @IBAction func notificationsButtonPressed(_ sender: UIButton) {
        print("notifications")
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("searching.. \(searchBar.text)")
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("cancel")
    }
}
