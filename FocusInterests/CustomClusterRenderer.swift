//
//  MyCustomRenderer.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/20/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation

class CustomClusterRenderer: GMUDefaultClusterRenderer {
    
    let GMUAnimationDuration: Double = 0.5
    var mapView: GMSMapView?
    
    override init(mapView: GMSMapView, clusterIconGenerator iconGenerator: GMUClusterIconGenerator) {
        super.init(mapView: mapView, clusterIconGenerator: iconGenerator)
        self.mapView = mapView
    }
    
    func markerWith(position: CLLocationCoordinate2D, from: CLLocationCoordinate2D, userData: AnyObject, clusterIcon: UIImage, animated: Bool) -> GMSMarker {
        
        let initialPosition = animated ? from : position
        let marker = GMSMarker(position: initialPosition)
        marker.userData = userData
        
        marker.icon = clusterIcon
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        
        if clusterIcon == nil{
            
            let customView = MapMarkerView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            customView.markerBadge.text = "2"
            
            if let item = userData as? MapCluster {
                customView.markerImage.image = item.icon
            }
            
            marker.iconView = customView
            
//            marker.icon = getCustomUIImageItem(userData: userData)
        }
        marker.map = mapView
        if animated {
            CATransaction.begin()
            CAAnimation.init().duration = GMUAnimationDuration
            marker.layer.latitude = position.latitude
            marker.layer.longitude = position.longitude
            CATransaction.commit()
        }
        return marker
    }
    
    func getCustomUIImageItem(userData: AnyObject) -> UIImage {
        if let item = userData as? MapCluster {
            
            return item.icon
        }
        return UIImage()
    }
}

