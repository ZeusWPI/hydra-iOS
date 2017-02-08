//
//  Activity.swift
//
//  Created by Feliciaan De Palmenaer on 27/02/2016
//  Copyright (c) . All rights reserved.
//

import Foundation
import ObjectMapper

class Activity: NSObject, NSCoding, Mappable {

    // MARK: Properties
	var title: String
    var association: Association
    var start: Date
    var end: Date?
    var location: String
    var latitude: Double
	var longitude: Double
	var descriptionText: String
	var url: String
    var facebookId: String?
	var highlighted: Bool
    fileprivate var _facebookEvent: FacebookEvent?
    var facebookEvent: FacebookEvent? {
        get {
            if let facebookEvent = _facebookEvent {
                return facebookEvent
            } else {
                if let facebookId = self.facebookId, facebookId.characters.count > 0 {
                    print("Created facebookEvent")
                    _facebookEvent = FacebookEvent(eventId: facebookId)
                    return _facebookEvent
                }

                return nil
            }
        }

        set (newValue) {
            _facebookEvent = newValue
        }
    }

    override var description: String {
        get {
            return "Activity: \(self.title)"
        }
    }

    init(title: String, association: Association, start: Date, end: Date?, location: String, latitude: Double, longitude: Double, descriptionText: String, url: String, highlighted: Bool) {
        self.title = title
        self.association = association
        self.start = start
        self.end = end
        self.location = location
        self.latitude = latitude
        self.longitude = longitude
        self.descriptionText = descriptionText
        self.url = url
        self.highlighted = highlighted
    }

    // MARK: ObjectMapper Initalizers
    /**
    Map a JSON object to this class using ObjectMapper
    - parameter map: A mapping from ObjectMapper
    */
    required convenience init?(map: Map) {
        // Give empty values, because they will get filled
        self.init(title: "", association: Association(internalName: "", displayName: ""), start: Date(), end: nil, location: "", latitude: 0.0, longitude: 0.0, descriptionText: "", url: "", highlighted: false)
    }

    /**
     Map a JSON object to this class using ObjectMapper
     - parameter map: A mapping from ObjectMapper
     */
    func mapping(map: Map) {
        title <- map[PropertyKey.TitleKey]
        association <- map[PropertyKey.AssociationKey]
        start <- (map[PropertyKey.StartKey], ISO8601DateTransform())
        end <- (map[PropertyKey.EndKey], ISO8601DateTransform())
        location <- map[PropertyKey.LocationKey]
        latitude <- map[PropertyKey.LatitudeKey]
        longitude <- map[PropertyKey.LongitudeKey]
        facebookId <- map[PropertyKey.FacebookIdKey]
        descriptionText <- map[PropertyKey.descriptionTextKey]
        url <- map[PropertyKey.UrlKey]
        highlighted <- map[PropertyKey.HighlightedKey]
    }

    // MARK: NSCoding Protocol
    required init?(coder aDecoder: NSCoder) {
        guard let title = aDecoder.decodeObject(forKey: PropertyKey.TitleKey) as? String,
            let descriptionText = aDecoder.decodeObject(forKey: PropertyKey.descriptionTextKey) as? String,
            let start = aDecoder.decodeObject(forKey: PropertyKey.StartKey) as? Date,
            let location = aDecoder.decodeObject(forKey: PropertyKey.LocationKey) as? String,
            let association = aDecoder.decodeObject(forKey: PropertyKey.AssociationKey) as? Association,
            let url = aDecoder.decodeObject(forKey: PropertyKey.UrlKey) as? String
            else { return nil }

        let longitude = aDecoder.decodeDouble(forKey: PropertyKey.LongitudeKey)
        let latitude = aDecoder.decodeDouble(forKey: PropertyKey.LatitudeKey)
        let highlighted = aDecoder.decodeBool(forKey: PropertyKey.HighlightedKey)

        self.facebookId = aDecoder.decodeObject(forKey: PropertyKey.FacebookIdKey) as? String
        self._facebookEvent = aDecoder.decodeObject(forKey: PropertyKey.FacebookEventKey) as? FacebookEvent
        self.end = aDecoder.decodeObject(forKey: PropertyKey.EndKey) as? Date

        self.title = title
        self.longitude = longitude
        self.descriptionText = descriptionText
        self.start = start
        self.latitude = latitude
        self.location = location
        self.association = association
        self.url = url
        self.highlighted = highlighted
    }

    func encode(with aCoder: NSCoder) {
		aCoder.encode(title, forKey: PropertyKey.TitleKey)
		aCoder.encode(facebookId, forKey: PropertyKey.FacebookIdKey)
		aCoder.encode(longitude, forKey: PropertyKey.LongitudeKey)
		aCoder.encode(descriptionText, forKey: PropertyKey.descriptionTextKey)
		aCoder.encode(start, forKey: PropertyKey.StartKey)
		aCoder.encode(latitude, forKey: PropertyKey.LatitudeKey)
		aCoder.encode(location, forKey: PropertyKey.LocationKey)
		aCoder.encode(association, forKey: PropertyKey.AssociationKey)
		aCoder.encode(end, forKey: PropertyKey.EndKey)
		aCoder.encode(url, forKey: PropertyKey.UrlKey)
		aCoder.encode(highlighted, forKey: PropertyKey.HighlightedKey)
        aCoder.encode(_facebookEvent, forKey: PropertyKey.FacebookEventKey)
    }

    func hasCoordinates() -> Bool {
        return longitude != 0.0 && latitude != 0.0
    }

    func hasFacebookEvent() -> Bool {
        if let facebookEvent = _facebookEvent {
            return facebookEvent.valid
        }
        return false
    }

    struct PropertyKey {
        // MARK: Declaration for string constants to be used to decode and also serialize.
        static let TitleKey: String = "title"
        static let FacebookIdKey: String = "facebook_id"
        static let LongitudeKey: String = "longitude"
        static let descriptionTextKey: String = "description"
        static let StartKey: String = "start"
        static let LatitudeKey: String = "latitude"
        static let LocationKey: String = "location"
        static let AssociationKey: String = "association"
        static let EndKey: String = "end"
        static let UrlKey: String = "url"
        static let HighlightedKey: String = "highlighted"
        static let FacebookEventKey: String = "facebookEvent"
    }
}
