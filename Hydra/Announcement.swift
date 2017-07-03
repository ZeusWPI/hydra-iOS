//
//  Announcement.swift
//  OAuthTest
//
//  Created by Feliciaan De Palmenaer on 21/06/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation

class Announcement: NSObject, Codable {
    var title: String
    var content: String
    var emailSent: Bool
    var itemId: Int
    var editUser: String
    var date: Date
    var read: Bool {
        didSet {
            MinervaStore.shared.saveLater()
        }
    }

    var course: Course?
    
    init(title: String, content: String, emailSent: Bool, itemId: Int, editUser: String, date: Date, read: Bool = false) {
        self.title = title
        self.content = content
        self.emailSent = emailSent
        self.itemId = itemId
        self.editUser = editUser
        self.date = date
        self.read = read
    }
    
    private enum CodingKeys: String, CodingKey {
        case title, content
        case emailSent = "email_sent"
        case itemId = "item_id"
        case editUser = "last_edit_user"
        case date = "last_edit_time"
        case read = "read"
        case course = "course"
    }
}
