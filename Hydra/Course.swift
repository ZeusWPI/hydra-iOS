//
//  Courses.swift
//
//  Created by Feliciaan De Palmenaer on 28/02/2016
//  Copyright (c) Zeus WPI. All rights reserved.
//

import Foundation

class Course: NSObject, Codable {

    // MARK: Properties
    var title: String?
    var code: String?
    var tutorName: String?
    var internalIdentifier: String?
    var descriptionValue: String?
    var academicYear: String?

    private enum CodingKeys: String, CodingKey {
        case title, code
        case tutorName = "tutor_name"
        case internalIdentifier = "id"
        case descriptionValue = "description"
        case academicYear = "academic_year"
    }
}
