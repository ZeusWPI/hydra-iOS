//
//  UGentNews.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 11/12/2017.
//  Copyright © 2017 Zeus WPI. All rights reserved.
//

import Foundation

@objc class UGentNewsItem: NSObject, Codable {
    
    // MARK: Properties
    var title: String
    var content: String
    var identifier: String
    var creators: [String]
    var date: Date
    private var _read: Int?
    var read: Bool {
        set {
            _read = read ? 1 : 0
        }
        get {
            return _read == 1
        }
    }
    override var description: String {
        get {
            return "UGentNewsItem: \(self.title)"
        }
    }
    
    init(title: String, content: String, identifier: String, creators: [String], highlighted: Bool, date: Date, read: Bool = false) {
        self.title = title
        self.content = content
        self.date = date
        self.identifier = identifier
        self.creators = creators
        self._read = read ? 1 : 0
    }
    
    private enum CodingKeys: String, CodingKey {
        case title
        case content = "description"
        case date = "created"
        case _read = "read"
        case identifier
        case creators
    }
}
