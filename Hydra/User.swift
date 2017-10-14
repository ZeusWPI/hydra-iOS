//
//  User.swift
//
//  Created by Feliciaan De Palmenaer on 28/02/2016
//  Copyright (c) . All rights reserved.
//

import Foundation

class User: NSObject, Codable {

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
    
    private enum CodingKeys: String, CodingKey {
        case ugentStudentID, mail, lastenrolled, givenname, surname, uid
    }
}
