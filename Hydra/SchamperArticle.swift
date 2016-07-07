//
//  SchamperArticle.swift
//  OAuthTest
//
//  Created by Feliciaan De Palmenaer on 28/02/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation
import ObjectMapper
class SchamperArticle: NSObject, NSCoding, Mappable {

    // MARK: Properties
    var title: String
    var link: String
    var date: NSDate
    var author: String?
    var body: String
    var image: String?
    var read: Bool = false

    convenience override init() {
        self.init(title: "", link: "", date: NSDate(), author: nil, body: "", image: nil)
    }

    init(title: String, link: String, date: NSDate, author: String?, body: String, image: String?, read: Bool = false) {
        self.title = title
        self.link = link
        self.date = date
        self.author = author
        self.body = body
        self.image = image
        self.read = read
    }

    required convenience init?(_ map: Map) {
        self.init()
    }

    override var description: String {
        get {
            return "SchamperArticle: \(self.title)"
        }
    }

    func mapping(map: Map) {
        self.title <- map[PropertyKey.titleKey]
        self.link <- map[PropertyKey.linkKey]
        self.date <- (map["pub_date"], ISO8601DateTransform())
        self.author <- map[PropertyKey.authorKey]
        self.body <- map[PropertyKey.bodyKey]
        self.image <- map[PropertyKey.imageKey]
        self.read <- map[PropertyKey.readKey]
    }

    // MARK: NSCoding Protocol
    required init?(coder aDecoder: NSCoder) {
        title = aDecoder.decodeObjectForKey(PropertyKey.titleKey) as! String
        link = aDecoder.decodeObjectForKey(PropertyKey.linkKey) as! String
        date = aDecoder.decodeObjectForKey(PropertyKey.dateKey) as! NSDate
        author = aDecoder.decodeObjectForKey(PropertyKey.authorKey) as? String
        body = aDecoder.decodeObjectForKey(PropertyKey.bodyKey) as! String
        image = aDecoder.decodeObjectForKey(PropertyKey.imageKey) as? String
        read = aDecoder.decodeObjectForKey(PropertyKey.readKey) as! Bool
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(title, forKey: PropertyKey.titleKey)
        aCoder.encodeObject(link, forKey: PropertyKey.linkKey)
        aCoder.encodeObject(date, forKey: PropertyKey.dateKey)
        aCoder.encodeObject(author, forKey: PropertyKey.authorKey)
        aCoder.encodeObject(body, forKey: PropertyKey.bodyKey)
        aCoder.encodeObject(image, forKey: PropertyKey.imageKey)
        aCoder.encodeObject(read, forKey: PropertyKey.readKey)
    }

    struct PropertyKey {
        static let titleKey = "title"
        static let linkKey = "link"
        static let dateKey = "date"
        static let authorKey = "author"
        static let bodyKey = "body"
        static let imageKey = "image"
        static let readKey = "read"
    }
}