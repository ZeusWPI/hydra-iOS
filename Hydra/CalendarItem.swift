//
//  Calendar.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 30/07/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation

class CalendarItem: NSObject, Codable {
    var title: String = ""
    var content: String?
    var startDate: Date = Date(timeIntervalSince1970: 0)
    var endDate: Date = Date(timeIntervalSince1970: 0)
    var location: String?
    var itemId: Int64 = 0
    var courseId: String = ""
    var creator: String?
    var created: Date = Date(timeIntervalSince1970: 0)

    var course: Course? {
        get {
            return MinervaStore.shared.course(courseId)
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case title, content, location
        case startDate = "start_date"
        case endDate = "end_date"
        case itemId = "item_id"
        case courseId = "course_id"
        case creator = "last_edit_user"
        case created = "last_edit_time"
    }
}
