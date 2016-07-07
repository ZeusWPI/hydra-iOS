//
//  Courses.swift
//
//  Created by Feliciaan De Palmenaer on 28/02/2016
//  Copyright (c) Zeus WPI. All rights reserved.
//

import Foundation
import ObjectMapper

class Course: NSObject, Mappable, NSCoding {

    // MARK: Declaration for string constants to be used to decode and also serialize.
    private let kCourseTitleKey: String = "title"
    private let kCourseCodeKey: String = "code"
    private let kCourseTutorNameKey: String = "tutor_name"
    private let kCourseInternalIdentifierKey: String = "id"
    private let kCourseDescriptionValueKey: String = "description"

    // MARK: Properties
    var title: String?
    var code: String?
    var tutorName: String?
    var internalIdentifier: String?
    var descriptionValue: String?

    // MARK: ObjectMapper Initalizers
    /**
    Map a JSON object to this class using ObjectMapper
    - parameter map: A mapping from ObjectMapper
    */
    required init?(_ map: Map){

    }

    /**
     Map a JSON object to this class using ObjectMapper
     - parameter map: A mapping from ObjectMapper
     */
    func mapping(map: Map) {
        title <- map[kCourseTitleKey]
        code <- map[kCourseCodeKey]
        tutorName <- map[kCourseTutorNameKey]
        internalIdentifier <- map[kCourseInternalIdentifierKey]
        descriptionValue <- map[kCourseDescriptionValueKey]
    }

    // MARK: NSCoding Protocol
    required init(coder aDecoder: NSCoder) {
        self.title = aDecoder.decodeObjectForKey(kCourseTitleKey) as? String
        self.code = aDecoder.decodeObjectForKey(kCourseCodeKey) as? String
        self.tutorName = aDecoder.decodeObjectForKey(kCourseTutorNameKey) as? String
        self.internalIdentifier = aDecoder.decodeObjectForKey(kCourseInternalIdentifierKey) as? String
        self.descriptionValue = aDecoder.decodeObjectForKey(kCourseDescriptionValueKey) as? String
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(title, forKey: kCourseTitleKey)
        aCoder.encodeObject(code, forKey: kCourseCodeKey)
        aCoder.encodeObject(tutorName, forKey: kCourseTutorNameKey)
        aCoder.encodeObject(internalIdentifier, forKey: kCourseInternalIdentifierKey)
        aCoder.encodeObject(descriptionValue, forKey: kCourseDescriptionValueKey)
    }
    
}
