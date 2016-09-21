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
    var start: NSDate
    var end: NSDate?
    var location: String
    var latitude: Double
	var longitude: Double
	var descriptionText: String
	var url: String
    var facebookId: String?
	var highlighted: Bool
    private var _facebookEvent: FacebookEvent?
    var facebookEvent: FacebookEvent? {
        get {
            if let facebookEvent = _facebookEvent {
                return facebookEvent
            } else {
                if let facebookId = self.facebookId where facebookId.characters.count > 0 {
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

    init(title: String, association: Association, start: NSDate, end: NSDate?, location: String, latitude: Double, longitude: Double, descriptionText: String, url: String, highlighted: Bool) {
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
    required convenience init?(_ map: Map){
        // Give empty values, because they will get filled
        self.init(title: "", association: Association(internalName: "", displayName: ""), start: NSDate(), end: nil, location: "", latitude: 0.0, longitude: 0.0, descriptionText: "", url: "", highlighted: false)
    }

    /**
     Map a JSON object to this class using ObjectMapper
     - parameter map: A mapping from ObjectMapper
     */
    func mapping(map: Map) {
        title <- map[PropertyKey.activityTitleKey]
        association <- map[PropertyKey.activityAssociationKey]
        start <- (map[PropertyKey.activityStartKey], ISO8601DateTransform())
        end <- (map[PropertyKey.activityEndKey], ISO8601DateTransform())
        location <- map[PropertyKey.activityLocationKey]
        latitude <- map[PropertyKey.activityLatitudeKey]
        longitude <- map[PropertyKey.activityLongitudeKey]
        facebookId <- map[PropertyKey.activityFacebookIdKey]
        descriptionText <- map[PropertyKey.activitydescriptionTextKey]
        url <- map[PropertyKey.activityUrlKey]
        highlighted <- map[PropertyKey.activityHighlightedKey]
    }

    // MARK: NSCoding Protocol
    required init(coder aDecoder: NSCoder) {
		self.title = aDecoder.decodeObjectForKey(PropertyKey.activityTitleKey) as! String
		self.facebookId = aDecoder.decodeObjectForKey(PropertyKey.activityFacebookIdKey) as? String
		self.longitude = aDecoder.decodeObjectForKey(PropertyKey.activityLongitudeKey) as! Double
		self.descriptionText = aDecoder.decodeObjectForKey(PropertyKey.activitydescriptionTextKey) as! String
		self.start = aDecoder.decodeObjectForKey(PropertyKey.activityStartKey) as! NSDate
		self.latitude = aDecoder.decodeObjectForKey(PropertyKey.activityLatitudeKey) as! Double
		self.location = aDecoder.decodeObjectForKey(PropertyKey.activityLocationKey) as! String
		self.association = aDecoder.decodeObjectForKey(PropertyKey.activityAssociationKey) as! Association
		self.end = aDecoder.decodeObjectForKey(PropertyKey.activityEndKey) as? NSDate
		self.url = aDecoder.decodeObjectForKey(PropertyKey.activityUrlKey) as! String
		self.highlighted = aDecoder.decodeObjectForKey(PropertyKey.activityHighlightedKey) as! Bool
        self._facebookEvent = aDecoder.decodeObjectForKey(PropertyKey.activityFacebookEventKey) as? FacebookEvent
    }

    func encodeWithCoder(aCoder: NSCoder) {
		aCoder.encodeObject(title, forKey: PropertyKey.activityTitleKey)
		aCoder.encodeObject(facebookId, forKey: PropertyKey.activityFacebookIdKey)
		aCoder.encodeObject(longitude, forKey: PropertyKey.activityLongitudeKey)
		aCoder.encodeObject(descriptionText, forKey: PropertyKey.activitydescriptionTextKey)
		aCoder.encodeObject(start, forKey: PropertyKey.activityStartKey)
		aCoder.encodeObject(latitude, forKey: PropertyKey.activityLatitudeKey)
		aCoder.encodeObject(location, forKey: PropertyKey.activityLocationKey)
		aCoder.encodeObject(association, forKey: PropertyKey.activityAssociationKey)
		aCoder.encodeObject(end, forKey: PropertyKey.activityEndKey)
		aCoder.encodeObject(url, forKey: PropertyKey.activityUrlKey)
		aCoder.encodeObject(highlighted, forKey: PropertyKey.activityHighlightedKey)
        aCoder.encodeObject(_facebookEvent, forKey: PropertyKey.activityFacebookEventKey)
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
        static let activityTitleKey: String = "title"
        static let activityFacebookIdKey: String = "facebook_id"
        static let activityLongitudeKey: String = "longitude"
        static let activitydescriptionTextKey: String = "description"
        static let activityStartKey: String = "start"
        static let activityLatitudeKey: String = "latitude"
        static let activityLocationKey: String = "location"
        static let activityAssociationKey: String = "association"
        static let activityEndKey: String = "end"
        static let activityUrlKey: String = "url"
        static let activityHighlightedKey: String = "highlighted"
        static let activityFacebookEventKey: String = "facebookEvent"
    }
}
