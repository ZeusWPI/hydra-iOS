//
//  NewsItem.swift
//
//  Created by Feliciaan De Palmenaer on 28/02/2016
//  Copyright (c) . All rights reserved.
//

import Foundation
import ObjectMapper

@objc class NewsItem: NSObject, NSCoding, Mappable {

    // MARK: Properties
	var title: String
	var content: String
	var association: Association
	var internalIdentifier: Int
	var highlighted: Bool
	var date: NSDate
    var read: Bool

    override var description: String {
        get {
            return "NewsItem: \(self.title)"
        }
    }

    init(title: String, content: String, association: Association, internalIdentifier: Int, highlighted: Bool, date: NSDate, read: Bool = false) {
        self.title = title
        self.content = content
        self.association = association
        self.internalIdentifier = internalIdentifier
        self.highlighted = highlighted
        self.date = date
        self.read = read
    }

    // MARK: Mappable Protocol
    convenience required init?(_ map: Map) {
        self.init(title: "", content: "", association: Association(internalName: "", displayName: ""), internalIdentifier: 0, highlighted: false, date: NSDate())
    }

    func mapping(map: Map) {
        title <- map[PropertyKey.newsItemTitleKey]
        content <- map[PropertyKey.newsItemContentKey]
        association <- map[PropertyKey.newsItemAssociationKey]
        internalIdentifier <- map[PropertyKey.newsIteminternalIdentifierKey]
        highlighted <- map[PropertyKey.newsItemHighlightedKey]
        date <- (map[PropertyKey.newsItemDateKey], ISO8601DateTransform())
    }

    // MARK: NSCoding Protocol
    required init(coder aDecoder: NSCoder) {
		self.title = aDecoder.decodeObjectForKey(PropertyKey.newsItemTitleKey) as! String
		self.content = aDecoder.decodeObjectForKey(PropertyKey.newsItemContentKey) as! String
		self.association = aDecoder.decodeObjectForKey(PropertyKey.newsItemAssociationKey) as! Association
		self.internalIdentifier = aDecoder.decodeObjectForKey(PropertyKey.newsIteminternalIdentifierKey) as! Int
		self.highlighted = aDecoder.decodeObjectForKey(PropertyKey.newsItemHighlightedKey) as! Bool
		self.date = aDecoder.decodeObjectForKey(PropertyKey.newsItemDateKey) as! NSDate
        self.read = aDecoder.decodeObjectForKey(PropertyKey.newsItemReadKey) as! Bool
    }

    func encodeWithCoder(aCoder: NSCoder) {
		aCoder.encodeObject(title, forKey: PropertyKey.newsItemTitleKey)
		aCoder.encodeObject(content, forKey: PropertyKey.newsItemContentKey)
		aCoder.encodeObject(association, forKey: PropertyKey.newsItemAssociationKey)
		aCoder.encodeObject(internalIdentifier, forKey: PropertyKey.newsIteminternalIdentifierKey)
		aCoder.encodeObject(highlighted, forKey: PropertyKey.newsItemHighlightedKey)
		aCoder.encodeObject(date, forKey: PropertyKey.newsItemDateKey)
        aCoder.encodeObject(read, forKey: PropertyKey.newsItemReadKey)
    }

    struct PropertyKey {
        // MARK: Declaration for string constants to be used to decode and also serialize.
        static let newsItemTitleKey: String = "title"
        static let newsItemContentKey: String = "content"
        static let newsItemAssociationKey: String = "association"
        static let newsIteminternalIdentifierKey: String = "id"
        static let newsItemHighlightedKey: String = "highlighted"
        static let newsItemDateKey: String = "date"
        static let newsItemReadKey: String = "read"
    }
}
