//
//  ApiEndpoints.swift
//  OAuthTest
//
//  Created by Feliciaan De Palmenaer on 27/02/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation

struct APIConfig {
    static let Zeus = "https://hydra.UGent.be/api/"
    static let Zeus1_0 = "https://hydra.UGent.be/api/1.0/"
    static let Zeus2_0 = "https://hydra.UGent.be/api/2.0/"
    static let DSA = "http://student.UGent.be/hydra/api/"
    static let SKO = "http://studentkickoff.be/"
}

struct Config {
    static let DocumentsDirectory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.be.ugent.zeus")!
    static let AssociationStoreArchive = DocumentsDirectory.appendingPathComponent("association.json")
    static let InfoStoreArchive = DocumentsDirectory.appendingPathComponent("info.json")
    static let SchamperStoreArchive = DocumentsDirectory.appendingPathComponent("schamper.json")
    static let RestoStoreArchive = DocumentsDirectory.appendingPathComponent("resto.json")
    static let SpecialEventStoreArchive = DocumentsDirectory.appendingPathComponent("specialEvent.json")
    static let SKOStoreArchive = DocumentsDirectory.appendingPathComponent("sko.json")
}
