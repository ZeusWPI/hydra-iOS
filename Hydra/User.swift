//
//  User.swift
//
//  Created by Feliciaan De Palmenaer on 28/02/2016
//  Copyright (c) . All rights reserved.
//

import Foundation
import ObjectMapper

class User: NSObject, Mappable, NSCoding {

    // MARK: Properties
    var ugentStudentID: [String]?
    var mail: [String]?
    var lastenrolled: [String]?
    var givenname: [String]?
    var surname: [String]?
    var uid: [String]?

    var name: String {
        get {
            var _name = ""
            if let givenname = givenname {
                for gname in givenname {
                    _name.append(gname)
                    _name = _name + " "
                }
            }
            if let surname = surname {
                for sname in surname {
                    _name.append(sname)
                }
            }

            return _name
        }
    }

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
        ugentStudentID <- map[PropertyKey.userUgentStudentIDKey]
        mail <- map[PropertyKey.userMailKey]
        lastenrolled <- map[PropertyKey.userLastenrolledKey]
        givenname <- map[PropertyKey.userGivennameKey]
        surname <- map[PropertyKey.userSurnameKey]
        uid <- map[PropertyKey.userUidKey]
    }

    // MARK: NSCoding Protocol
    required init(coder aDecoder: NSCoder) {
        self.ugentStudentID = aDecoder.decodeObject(forKey: PropertyKey.userUgentStudentIDKey) as? [String]
        self.mail = aDecoder.decodeObject(forKey: PropertyKey.userMailKey) as? [String]
        self.lastenrolled = aDecoder.decodeObject(forKey: PropertyKey.userLastenrolledKey) as? [String]
        self.givenname = aDecoder.decodeObject(forKey: PropertyKey.userGivennameKey) as? [String]
        self.surname = aDecoder.decodeObject(forKey: PropertyKey.userSurnameKey) as? [String]
        self.uid = aDecoder.decodeObject(forKey: PropertyKey.userUidKey) as? [String]
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(ugentStudentID, forKey: PropertyKey.userUgentStudentIDKey)
        aCoder.encode(mail, forKey: PropertyKey.userMailKey)
        aCoder.encode(lastenrolled, forKey: PropertyKey.userLastenrolledKey)
        aCoder.encode(givenname, forKey: PropertyKey.userGivennameKey)
        aCoder.encode(surname, forKey: PropertyKey.userSurnameKey)
        aCoder.encode(uid, forKey: PropertyKey.userUidKey)
    }

    // MARK: Declaration for string constants to be used to decode and also serialize.
    struct PropertyKey {
        static let userUgentStudentIDKey: String = "ugentStudentID"
        static let userMailKey: String = "mail"
        static let userLastenrolledKey: String = "lastenrolled"
        static let userGivennameKey: String = "givenname"
        static let userSurnameKey: String = "surname"
        static let userUidKey: String = "uid"
    }
}
