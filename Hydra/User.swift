//
//  User.swift
//
//  Created by Feliciaan De Palmenaer on 28/02/2016
//  Copyright (c) . All rights reserved.
//

import Foundation
import ObjectMapper

class User: NSObject, Mappable, NSCoding {

    // MARK: Declaration for string constants to be used to decode and also serialize.
    private let kUserUgentStudentIDKey: String = "ugentStudentID"
    private let kUserMailKey: String = "mail"
    private let kUserLastenrolledKey: String = "lastenrolled"
    private let kUserGivennameKey: String = "givenname"
    private let kUserSurnameKey: String = "surname"
    private let kUserUidKey: String = "uid"

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
                    _name.appendContentsOf(gname)
                    _name = _name.stringByAppendingString(" ")
                }
            }
            if let surname = surname {
                for sname in surname {
                    _name.appendContentsOf(sname)
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
    required init?(_ map: Map){

    }

    /**
     Map a JSON object to this class using ObjectMapper
     - parameter map: A mapping from ObjectMapper
     */
    func mapping(map: Map) {
        ugentStudentID <- map[kUserUgentStudentIDKey]
        mail <- map[kUserMailKey]
        lastenrolled <- map[kUserLastenrolledKey]
        givenname <- map[kUserGivennameKey]
        surname <- map[kUserSurnameKey]
        uid <- map[kUserUidKey]
    }

    // MARK: NSCoding Protocol
    required init(coder aDecoder: NSCoder) {
        self.ugentStudentID = aDecoder.decodeObjectForKey(kUserUgentStudentIDKey) as? [String]
        self.mail = aDecoder.decodeObjectForKey(kUserMailKey) as? [String]
        self.lastenrolled = aDecoder.decodeObjectForKey(kUserLastenrolledKey) as? [String]
        self.givenname = aDecoder.decodeObjectForKey(kUserGivennameKey) as? [String]
        self.surname = aDecoder.decodeObjectForKey(kUserSurnameKey) as? [String]
        self.uid = aDecoder.decodeObjectForKey(kUserUidKey) as? [String]
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(ugentStudentID, forKey: kUserUgentStudentIDKey)
        aCoder.encodeObject(mail, forKey: kUserMailKey)
        aCoder.encodeObject(lastenrolled, forKey: kUserLastenrolledKey)
        aCoder.encodeObject(givenname, forKey: kUserGivennameKey)
        aCoder.encodeObject(surname, forKey: kUserSurnameKey)
        aCoder.encodeObject(uid, forKey: kUserUidKey)
    }
    
}
