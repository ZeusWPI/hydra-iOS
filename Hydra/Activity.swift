//
//  Activity.swift
//
//  Created by Feliciaan De Palmenaer on 27/02/2016
//  Copyright (c) . All rights reserved.
//

import Foundation
import ObjectMapper

class Activity: NSObject, NSCoding, Mappable {

    // MARK: Declaration for string constants to be used to decode and also serialize.
	private let kActivityTitleKey: String = "title"
	private let kActivityFacebookIdKey: String = "facebook_id"
	private let kActivityLongitudeKey: String = "longitude"
	private let kActivitydescriptionTextKey: String = "description"
	private let kActivityStartKey: String = "start"
	private let kActivityLatitudeKey: String = "latitude"
	private let kActivityLocationKey: String = "location"
	private let kActivityAssociationKey: String = "association"
	private let kActivityEndKey: String = "end"
	private let kActivityUrlKey: String = "url"
	private let kActivityHighlightedKey: String = "highlighted"


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
    var facebookEvent: FacebookEvent?

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
        title <- map[kActivityTitleKey]
        association <- map[kActivityAssociationKey]
        start <- (map[kActivityStartKey], ISO8601DateTransform())
        end <- (map[kActivityEndKey], ISO8601DateTransform())
        location <- map[kActivityLocationKey]
        latitude <- map[kActivityLatitudeKey]
        longitude <- map[kActivityLongitudeKey]
        descriptionText <- map[kActivitydescriptionTextKey]
        url <- map[kActivityUrlKey]
        highlighted <- map[kActivityHighlightedKey]
    }

    // MARK: NSCoding Protocol
    required init(coder aDecoder: NSCoder) {
		self.title = aDecoder.decodeObjectForKey(kActivityTitleKey) as! String
		self.facebookId = aDecoder.decodeObjectForKey(kActivityFacebookIdKey) as? String
		self.longitude = aDecoder.decodeObjectForKey(kActivityLongitudeKey) as! Double
		self.descriptionText = aDecoder.decodeObjectForKey(kActivitydescriptionTextKey) as! String
		self.start = aDecoder.decodeObjectForKey(kActivityStartKey) as! NSDate
		self.latitude = aDecoder.decodeObjectForKey(kActivityLatitudeKey) as! Double
		self.location = aDecoder.decodeObjectForKey(kActivityLocationKey) as! String
		self.association = aDecoder.decodeObjectForKey(kActivityAssociationKey) as! Association
		self.end = aDecoder.decodeObjectForKey(kActivityEndKey) as? NSDate
		self.url = aDecoder.decodeObjectForKey(kActivityUrlKey) as! String
		self.highlighted = aDecoder.decodeObjectForKey(kActivityHighlightedKey) as! Bool
    }

    func encodeWithCoder(aCoder: NSCoder) {
		aCoder.encodeObject(title, forKey: kActivityTitleKey)
		aCoder.encodeObject(facebookId, forKey: kActivityFacebookIdKey)
		aCoder.encodeObject(longitude, forKey: kActivityLongitudeKey)
		aCoder.encodeObject(descriptionText, forKey: kActivitydescriptionTextKey)
		aCoder.encodeObject(start, forKey: kActivityStartKey)
		aCoder.encodeObject(latitude, forKey: kActivityLatitudeKey)
		aCoder.encodeObject(location, forKey: kActivityLocationKey)
		aCoder.encodeObject(association, forKey: kActivityAssociationKey)
		aCoder.encodeObject(end, forKey: kActivityEndKey)
		aCoder.encodeObject(url, forKey: kActivityUrlKey)
		aCoder.encodeObject(highlighted, forKey: kActivityHighlightedKey)
    }

    func hasCoordinates() -> Bool {
        return longitude != 0.0 && latitude != 0.0
    }

    func hasFacebookEvent() -> Bool {
        if let facebookEvent = facebookEvent {
            return facebookEvent.valid
        }
        return false
    }
}
