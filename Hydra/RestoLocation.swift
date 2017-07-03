//
//  RestoLocation.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 05/03/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation

class RestoLocation: NSObject, Codable, MKAnnotation {

    var name: String
    var address: String
    private var type_s: String
    var type: RestoType {
        get {
            return RestoType(rawValue: type_s)!
        }
    }
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    var endpoint: String
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
        self.type_s = type.rawValue
        self.latitude = latitude
        self.longitude = longitude
        self.endpoint = endpoint
    }
    
    private enum CodingKeys: String, CodingKey {
        case name, address, latitude, longitude, endpoint
        case type_s = "type"
    }

    enum RestoType: String {
        case Resto = "resto"
        case Cafetaria = "cafetaria"
        case Club = "club"
        case Other = "other" // Keep this for the future if an other type is added
    }
}
