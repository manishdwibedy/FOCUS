//
//  MapNavigationView.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/5/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import MIBadgeButton_Swift

protocol NavigationInteraction {
    func messagesClicked()
    func notificationsClicked()
    func userProfileClicked()
    func invitationClicked()
}

class MapNavigationView: UIView, UISearchBarDelegate{
    var delegate: NavigationInteraction?
    
    @IBOutlet weak var userProfileButton: UIButton!
    @IBOutlet var view: MapNavigationView!
    @IBOutlet weak var messagesButton: MIBadgeButton!
    
    @IBOutlet weak var notificationsButton: MIBadgeButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var invatationButton: MIBadgeButton!
    
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
        view.frame = self.bounds
//        view.autoresizingMask = .FlexibleHeight | .FlexibleWidth

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
        delegate?.userProfileClicked()
    }
    
    @IBAction func messagesButtonPressed(_ sender: MIBadgeButton) {
        delegate?.messagesClicked()
    }
    
    @IBAction func notificationsButtonPressed(_ sender: UIButton) {
        delegate?.notificationsClicked()
    }
    @IBAction func invitationClicked(_ sender: Any) {
        delegate?.invitationClicked()
    }
}
