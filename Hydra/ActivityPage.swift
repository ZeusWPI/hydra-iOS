//
//  ActivityPage.swift
//  Hydra
//
//  Created by Ieben Smessaert on 13/09/2020.
//  Copyright © 2020 Zeus WPI. All rights reserved.
//

import Foundation

struct ActivityPage: Codable {
    var entries: [Activity]
    var pageNumber: Int
    var pageSize: Int
    var totalEntries: Int
    var totalPages: Int
    
    private enum CodingKeys: String, CodingKey {
        case entries
        case pageNumber = "page_number"
        case pageSize = "page_size"
        case totalEntries = "total_entries"
        case totalPages = "total_pages"
    }
}
