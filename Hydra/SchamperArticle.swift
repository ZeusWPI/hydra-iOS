//
//  SchamperArticle.swift
//  OAuthTest
//
//  Created by Feliciaan De Palmenaer on 28/02/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation

class SchamperArticle: NSObject, Codable {

    // MARK: Properties
    var title: String
    var link: String
    var date: Date?
    var author: String?
    var body: String
    var image: String?
    var category: String?
    var read: Bool = false

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
    
    override var description: String {
        get {
            return "SchamperArticle: \(self.title)"
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case title, link, author, image, category
        case date = "pub_date"
        case body = "text"
    }
}
