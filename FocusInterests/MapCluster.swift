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
    let type = "event"
    var id = ""
    
    init(position: CLLocationCoordinate2D, name: String, icon: UIImage, id: String) {
        self.position = position
        self.name = name
        self.icon = icon
        self.id = id
    }
    
    func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker:
        GMSMarker) {
        
        marker.icon = UIImage(named: "addUser")
//        if (marker.userData! is CustomClusterItem) {
//            
//            let customClusterItem = (marker.userData! as! CustomClusterItem)
//            
//            
//            
//            switch customClusterItem.type {
//                
//            case MarkerType.RegularMarker:
//                
//                marker.icon = appDelegate.markerImage
//                
//                break
//                
//            case MarkerType.LandmarkMarker:
//                
//                marker.icon = appDelegate.landmarkImage
//                
//                break
//                
//            case MarkerType.GovernmentMarker:
//                
//                marker.icon = appDelegate.govtImage
//                
//                break
//                
//            }
//            
//        }
        
    }
}
