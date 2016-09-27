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
    var date: Date
    var author: String?
    var body: String
    var image: String?
    var category: String?
    var read: Bool = false

    convenience override init() {
        self.init(title: "", link: "", date: Date(), author: nil, body: "", image: nil)
    }

    init(title: String, link: String, date: Date, author: String?, body: String, image: String?, category: String? = nil, read: Bool = false) {
        self.title = title
        self.link = link
        self.date = date
        self.author = author
        self.body = body
        self.image = image
        self.read = read
        self.category = category
    }

    required convenience init?(map: Map) {
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
        self.body <- map["text"]
        self.image <- map[PropertyKey.imageKey]
        self.category <- map[PropertyKey.categoryKey]
        self.read <- map[PropertyKey.readKey]
    }

    // MARK: NSCoding Protocol
    required convenience init?(coder aDecoder: NSCoder) {
        guard let title = aDecoder.decodeObject(forKey: PropertyKey.titleKey) as? String,
            let link = aDecoder.decodeObject(forKey: PropertyKey.linkKey) as? String,
            let date = aDecoder.decodeObject(forKey: PropertyKey.dateKey) as? Date,
            let body = aDecoder.decodeObject(forKey: PropertyKey.bodyKey) as? String,
            let read = aDecoder.decodeObject(forKey: PropertyKey.readKey) as? Bool
            else {return nil}

        let author = aDecoder.decodeObject(forKey: PropertyKey.authorKey) as? String
        let image = aDecoder.decodeObject(forKey: PropertyKey.imageKey) as? String
        let category = aDecoder.decodeObject(forKey: PropertyKey.categoryKey) as? String

        self.init(title: title, link: link, date: date, author: author, body: body, image: image, category: category, read: read)
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: PropertyKey.titleKey)
        aCoder.encode(link, forKey: PropertyKey.linkKey)
        aCoder.encode(date, forKey: PropertyKey.dateKey)
        aCoder.encode(author, forKey: PropertyKey.authorKey)
        aCoder.encode(body, forKey: PropertyKey.bodyKey)
        aCoder.encode(image, forKey: PropertyKey.imageKey)
        aCoder.encode(category, forKey: PropertyKey.categoryKey)
        aCoder.encode(read, forKey: PropertyKey.readKey)
    }

    struct PropertyKey {
        static let titleKey = "title"
        static let linkKey = "link"
        static let dateKey = "date"
        static let authorKey = "author"
        static let bodyKey = "body"
        static let imageKey = "image"
        static let categoryKey = "category"
        static let readKey = "read"
    }
}
