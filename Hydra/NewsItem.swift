//
//  NewsItem.swift
//
//  Created by Feliciaan De Palmenaer on 28/02/2016
//  Copyright (c) . All rights reserved.
//

import Foundation
import ObjectMapper

@objc class NewsItem: NSObject, NSCoding, Mappable {

    // MARK: Declaration for string constants to be used to decode and also serialize.
	private let kNewsItemTitleKey: String = "title"
	private let kNewsItemContentKey: String = "content"
	private let kNewsItemAssociationKey: String = "association"
	private let kNewsIteminternalIdentifierKey: String = "id"
	private let kNewsItemHighlightedKey: String = "highlighted"
    private let kNewsItemDateKey: String = "date"
    private let kNewsItemReadKey: String = "read"


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
        title <- map[kNewsItemTitleKey]
        content <- map[kNewsItemContentKey]
        association <- map[kNewsItemAssociationKey]
        internalIdentifier <- map[kNewsIteminternalIdentifierKey]
        highlighted <- map[kNewsItemHighlightedKey]
        date <- (map[kNewsItemDateKey], ISO8601DateTransform())
    }

    // MARK: NSCoding Protocol
    required init(coder aDecoder: NSCoder) {
		self.title = aDecoder.decodeObjectForKey(kNewsItemTitleKey) as! String
		self.content = aDecoder.decodeObjectForKey(kNewsItemContentKey) as! String
		self.association = aDecoder.decodeObjectForKey(kNewsItemAssociationKey) as! Association
		self.internalIdentifier = aDecoder.decodeObjectForKey(kNewsIteminternalIdentifierKey) as! Int
		self.highlighted = aDecoder.decodeObjectForKey(kNewsItemHighlightedKey) as! Bool
		self.date = aDecoder.decodeObjectForKey(kNewsItemDateKey) as! NSDate
        self.read = aDecoder.decodeObjectForKey(kNewsItemReadKey) as! Bool
    }

    func encodeWithCoder(aCoder: NSCoder) {
		aCoder.encodeObject(title, forKey: kNewsItemTitleKey)
		aCoder.encodeObject(content, forKey: kNewsItemContentKey)
		aCoder.encodeObject(association, forKey: kNewsItemAssociationKey)
		aCoder.encodeObject(internalIdentifier, forKey: kNewsIteminternalIdentifierKey)
		aCoder.encodeObject(highlighted, forKey: kNewsItemHighlightedKey)
		aCoder.encodeObject(date, forKey: kNewsItemDateKey)
        aCoder.encodeObject(read, forKey: kNewsItemReadKey)
    }

}
