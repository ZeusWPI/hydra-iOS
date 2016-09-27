//
//  InfoItem.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 11/08/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import ObjectMapper

class InfoItem: NSObject, NSCoding, Mappable {

    var title: String = ""
    var image: String?
    var url: String?
    var appStore: String?
    var html: String?
    var subcontent: [InfoItem]?

    var imageLocation: UIImage? {
        get {
            if let image = self.image {
                // TODO: fix this some time in the future
                return UIImage(named: image.replacingOccurrences(of: "_", with: "-"))
            }
            return nil
        }
    }

    var htmlURL: URL? {
        get {
            if let html = html {
                return URL(string: "\(APIConfig.Zeus2_0)info/\(html)")
            }
            return nil
        }
    }
    var type: InfoItemType {
        get {
            if (url != nil) || (appStore != nil) {
                return .externalLink
            }
            return .internalLink
        }
    }

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        title <- map[PropertyKey.titleKey]
        url <- map[PropertyKey.urlKey]
        appStore <- map[PropertyKey.appStoreKey]
        html <- map[PropertyKey.htmlKey]
        image <- map[PropertyKey.imageKey]
        subcontent <- map[PropertyKey.subcontentKey]
    }

    required init?(coder aDecoder: NSCoder) {
        title = aDecoder.decodeObject(forKey: PropertyKey.titleKey) as! String
        image = aDecoder.decodeObject(forKey: PropertyKey.imageKey) as? String
        url = aDecoder.decodeObject(forKey: PropertyKey.urlKey) as? String
        appStore = aDecoder.decodeObject(forKey: PropertyKey.appStoreKey) as? String
        html = aDecoder.decodeObject(forKey: PropertyKey.htmlKey) as? String
        subcontent = aDecoder.decodeObject(forKey: PropertyKey.subcontentKey) as? [InfoItem]
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: PropertyKey.titleKey)
        aCoder.encode(image, forKey: PropertyKey.imageKey)
        aCoder.encode(url, forKey: PropertyKey.urlKey)
        aCoder.encode(appStore, forKey: PropertyKey.appStoreKey)
        aCoder.encode(html, forKey: PropertyKey.htmlKey)
        aCoder.encode(subcontent, forKey: PropertyKey.subcontentKey)
    }

    struct PropertyKey {
        static let titleKey = "title"
        static let urlKey = "url"
        static let appStoreKey = "url-ios"
        static let imageKey = "image"
        static let htmlKey = "html"
        static let subcontentKey = "subcontent"
    }
}

enum InfoItemType {
    case internalLink
    case externalLink
}
