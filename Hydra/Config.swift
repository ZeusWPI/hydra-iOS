//
//  ApiEndpoints.swift
//  OAuthTest
//
//  Created by Feliciaan De Palmenaer on 27/02/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation

struct APIConfig {
    static let Minerva = "https://minqas.ugent.be/api/rest/v2/"
    static let OAuth = "https://oauthq.ugent.be/"
    static let Zeus = "https://zeus.UGent.be/hydra/api/"
    static let Zeus1_0 = "https://zeus.UGent.be/hydra/api/1.0/"
    static let Zeus2_0 = "https://zeus.UGent.be/hydra/api/2.0/"
    static let DSA = "http://student.UGent.be/hydra/api/"
}

struct Config {
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let AssociationStoreArchive = DocumentsDirectory.URLByAppendingPathComponent("associationStore.archive")
    static let SchamperStoreArchive = DocumentsDirectory.URLByAppendingPathComponent("schamperStore.archive")
    static let RestoStoreArchive = DocumentsDirectory.URLByAppendingPathComponent("restoStore.archive")
    static let SpecialEventStoreArchive = DocumentsDirectory.URLByAppendingPathComponent("specialEventStore.archive")
}