//
//  RestoLocation.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 05/03/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation
import MapKit

class RestoLocation: NSObject, Codable, MKAnnotation {

    @objc var name: String
    var address: String
    var type: RestoType
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    var endpoint: String?
    var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
        }
    }

    var title: String? {
        get {
            return self.name
        }
    }

    override var description: String {
        get {
            return "<RestoLocation: \(self.name)>"
        }
    }

    init(name: String, address: String, type: RestoType, latitude: CLLocationDegrees, longitude: CLLocationDegrees, endpoint: String) {
        self.name = name
        self.address = address
        self.type = type
        self.latitude = latitude
        self.longitude = longitude
        self.endpoint = endpoint
    }
    
    private enum CodingKeys: String, CodingKey {
        case name, address, latitude, longitude, endpoint, type
    }

    enum RestoType: String, Codable {
        case Resto = "resto"
        case Cafetaria = "cafetaria"
        case Club = "club"
        case Other = "other" // Keep this for the future if an other type is added
    }
}
