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
	var date: Date
    var read: Bool

    override var description: String {
        get {
            return "NewsItem: \(self.title)"
        }
    }

    init(title: String, content: String, association: Association, internalIdentifier: Int, highlighted: Bool, date: Date, read: Bool = false) {
        self.title = title
        self.content = content
        self.association = association
        self.internalIdentifier = internalIdentifier
        self.highlighted = highlighted
        self.date = date
        self.read = read
    }

    // MARK: Mappable Protocol
    convenience required init?(map: Map) {
        self.init(title: "", content: "", association: Association(internalName: "", displayName: ""), internalIdentifier: 0, highlighted: false, date: Date())
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
		self.title = aDecoder.decodeObject(forKey: PropertyKey.newsItemTitleKey) as! String
		self.content = aDecoder.decodeObject(forKey: PropertyKey.newsItemContentKey) as! String
		self.association = aDecoder.decodeObject(forKey: PropertyKey.newsItemAssociationKey) as! Association
		self.internalIdentifier = aDecoder.decodeObject(forKey: PropertyKey.newsIteminternalIdentifierKey) as! Int
		self.highlighted = aDecoder.decodeObject(forKey: PropertyKey.newsItemHighlightedKey) as! Bool
		self.date = aDecoder.decodeObject(forKey: PropertyKey.newsItemDateKey) as! Date
        self.read = aDecoder.decodeObject(forKey: PropertyKey.newsItemReadKey) as! Bool
    }

    func encode(with aCoder: NSCoder) {
		aCoder.encode(title, forKey: PropertyKey.newsItemTitleKey)
		aCoder.encode(content, forKey: PropertyKey.newsItemContentKey)
		aCoder.encode(association, forKey: PropertyKey.newsItemAssociationKey)
		aCoder.encode(internalIdentifier, forKey: PropertyKey.newsIteminternalIdentifierKey)
		aCoder.encode(highlighted, forKey: PropertyKey.newsItemHighlightedKey)
		aCoder.encode(date, forKey: PropertyKey.newsItemDateKey)
        aCoder.encode(read, forKey: PropertyKey.newsItemReadKey)
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
