//
//  Courses.swift
//
//  Created by Feliciaan De Palmenaer on 28/02/2016
//  Copyright (c) Zeus WPI. All rights reserved.
//

import Foundation
import ObjectMapper

class Course: NSObject, Mappable, NSCoding {

    // MARK: Properties
    var title: String?
    var code: String?
    var tutorName: String?
    var internalIdentifier: String?
    var descriptionValue: String?
    var academicYear: String?

    // MARK: ObjectMapper Initalizers
    /**
    Map a JSON object to this class using ObjectMapper
    - parameter map: A mapping from ObjectMapper
    */
    required init?(map: Map) {

    }

    /**
     Map a JSON object to this class using ObjectMapper
     - parameter map: A mapping from ObjectMapper
     */
    func mapping(map: Map) {
        title <- map[PropertyKey.courseTitleKey]
        code <- map[PropertyKey.courseCodeKey]
        tutorName <- map[PropertyKey.courseTutorNameKey]
        internalIdentifier <- map[PropertyKey.courseInternalIdentifierKey]
        descriptionValue <- map[PropertyKey.courseDescriptionValueKey]
        academicYear <- map[PropertyKey.academicYearKey]
    }

    // MARK: NSCoding Protocol
    required init(coder aDecoder: NSCoder) {
        self.title = aDecoder.decodeObject(forKey: PropertyKey.courseTitleKey) as? String
        self.code = aDecoder.decodeObject(forKey: PropertyKey.courseCodeKey) as? String
        self.tutorName = aDecoder.decodeObject(forKey: PropertyKey.courseTutorNameKey) as? String
        self.internalIdentifier = aDecoder.decodeObject(forKey: PropertyKey.courseInternalIdentifierKey) as? String
        self.descriptionValue = aDecoder.decodeObject(forKey: PropertyKey.courseDescriptionValueKey) as? String
        self.academicYear = aDecoder.decodeObject(forKey: PropertyKey.academicYearKey) as? String
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: PropertyKey.courseTitleKey)
        aCoder.encode(code, forKey: PropertyKey.courseCodeKey)
        aCoder.encode(tutorName, forKey: PropertyKey.courseTutorNameKey)
        aCoder.encode(internalIdentifier, forKey: PropertyKey.courseInternalIdentifierKey)
        aCoder.encode(descriptionValue, forKey: PropertyKey.courseDescriptionValueKey)
        aCoder.encode(academicYear, forKey: PropertyKey.academicYearKey)
    }

    // MARK: Declaration for string constants to be used to decode and also serialize.
    struct PropertyKey {
        static let courseTitleKey: String = "title"
        static let courseCodeKey: String = "code"
        static let courseTutorNameKey: String = "tutor_name"
        static let courseInternalIdentifierKey: String = "id"
        static let courseDescriptionValueKey: String = "description"
        static let academicYearKey: String = "academic_year"
    }
}
