//
//  ActivityMapController.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 06/07/2017.
//  Copyright © 2017 Zeus WPI. All rights reserved.
//

import Foundation
import MapKit

class ActivityMapController: MapViewController {
    
    let activity: Activity
    
    init(activity: Activity) {
        self.activity = activity
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadMapItems() {
        let annotation = SimpleMapAnnotation(latitude: activity.latitude, longitude: activity.longitude, title: activity.title, subtitle: activity.location)
        self.mapView.addAnnotation(annotation)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Kaart"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //GAI_TRACK("Activiteit > ... > Kaart")
    }
}

class SimpleMapAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
    
    convenience init(latitude: CLLocationDegrees, longitude: CLLocationDegrees, title: String?, subtitle: String?) {
        self.init(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), title: title, subtitle: subtitle)
    }
}
