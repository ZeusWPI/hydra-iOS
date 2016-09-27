//
//  RestoLocation.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 05/03/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation
import ObjectMapper

class RestoLocation: NSObject, NSCoding, MKAnnotation, Mappable {

    var name: String
    var address: String
    var type: RestoType
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
        self.type = type
        self.latitude = latitude
        self.longitude = longitude
        self.endpoint = endpoint
    }

    // MARK: NSCoding
    required init?(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObject(forKey: PropertyKey.nameKey) as! String
        self.address = aDecoder.decodeObject(forKey: PropertyKey.addressKey) as! String
        self.type = RestoType(rawValue: aDecoder.decodeObject(forKey: PropertyKey.typeKey) as! String)!
        self.latitude = aDecoder.decodeObject(forKey: PropertyKey.latitudeKey) as! CLLocationDegrees
        self.longitude = aDecoder.decodeObject(forKey: PropertyKey.longitudeKey) as! CLLocationDegrees
        self.endpoint = aDecoder.decodeObject(forKey: PropertyKey.endpointKey) as! String

    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.nameKey)
        aCoder.encode(address, forKey: PropertyKey.addressKey)
        aCoder.encode(type.rawValue, forKey: PropertyKey.typeKey)
        aCoder.encode(latitude, forKey: PropertyKey.latitudeKey)
        aCoder.encode(longitude, forKey: PropertyKey.longitudeKey)
        aCoder.encode(endpoint, forKey: PropertyKey.endpointKey)
    }

    // MARK: Mappable
    required convenience init?(map: Map) {
        self.init(name: "", address: "", type: .Other, latitude: 0.0, longitude: 0.0, endpoint: "")
    }

    func mapping(map: Map) {
        let restoTypeTransform = TransformOf<RestoType, String>(fromJSON: { (jsonString) -> RestoLocation.RestoType? in
            return RestoType(rawValue: jsonString!)
            }) { (restoType) -> String? in
                return restoType?.rawValue
        }

        self.name <- map[PropertyKey.nameKey]
        self.address <- map[PropertyKey.addressKey]
        self.type <- (map[PropertyKey.typeKey], restoTypeTransform)
        self.latitude <- map[PropertyKey.latitudeKey]
        self.longitude <- map[PropertyKey.longitudeKey]
        self.endpoint <- map[PropertyKey.endpointKey]
    }

    struct PropertyKey {
        static let nameKey = "name"
        static let addressKey = "address"
        static let typeKey = "type"
        static let latitudeKey = "latitude"
        static let longitudeKey = "longitude"
        static let endpointKey = "endpoint"
    }

    enum RestoType: String {
        case Resto = "resto"
        case Cafetaria = "cafetaria"
        case Club = "club"
        case Other = "other" // Keep this for the future if an other type is added
    }
}
