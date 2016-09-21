//
//  ApiEndpoints.swift
//  OAuthTest
//
//  Created by Feliciaan De Palmenaer on 27/02/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation

struct APIConfig {
    static let Minerva = "https://minerva.ugent.be/api/rest/v2/"
    static let OAuth = "https://oauth.ugent.be/"
    static let Zeus = "https://zeus.UGent.be/hydra/api/"
    static let Zeus1_0 = "https://zeus.UGent.be/hydra/api/1.0/"
    static let Zeus2_0 = "https://zeus.UGent.be/hydra/api/2.0/"
    static let DSA = "http://student.UGent.be/hydra/api/"
    static let SKO = "http://live.studentkickoff.be/"
}

struct Config {
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let AssociationStoreArchive = DocumentsDirectory.URLByAppendingPathComponent("association.archive")
    static let InfoStoreArchive = DocumentsDirectory.URLByAppendingPathComponent("info.archive")
    static let SchamperStoreArchive = DocumentsDirectory.URLByAppendingPathComponent("schamper.archive")
    static let RestoStoreArchive = DocumentsDirectory.URLByAppendingPathComponent("resto.archive")
    static let SpecialEventStoreArchive = DocumentsDirectory.URLByAppendingPathComponent("specialEvent.archive")
    static let MinervaStoreArchive = DocumentsDirectory.URLByAppendingPathComponent("minerva.archive")
    static let SKOStoreArchive = DocumentsDirectory.URLByAppendingPathComponent("sko.archive")
}