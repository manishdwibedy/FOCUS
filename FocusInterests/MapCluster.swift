//
//  MapCluster.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/20/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation

class MapCluster: NSObject, GMUClusterItem {
    var position: CLLocationCoordinate2D
    var name: String!
    var icon: UIImage
    var type: String
    var id: String
    
    init(position: CLLocationCoordinate2D, name: String, icon: UIImage, id: String, type: String) {
        self.position = position
        self.name = name
        self.icon = icon
        self.id = id
        self.type = type
    }
}
