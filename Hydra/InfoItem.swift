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
                return UIImage(named: image.stringByReplacingOccurrencesOfString("_", withString: "-"))
            }
            return nil
        }
    }

    var htmlURL: NSURL? {
        get {
            if let html = html {
                return NSURL(string: "\(APIConfig.Zeus2_0)info/\(html)")
            }
            return nil
        }
    }
    var type: InfoItemType {
        get {
            if (url != nil) || (appStore != nil) {
                return .ExternalLink
            }
            return .InternalLink
        }
    }

    required init?(_ map: Map) {

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
        title = aDecoder.decodeObjectForKey(PropertyKey.titleKey) as! String
        image = aDecoder.decodeObjectForKey(PropertyKey.imageKey) as? String
        url = aDecoder.decodeObjectForKey(PropertyKey.urlKey) as? String
        appStore = aDecoder.decodeObjectForKey(PropertyKey.appStoreKey) as? String
        html = aDecoder.decodeObjectForKey(PropertyKey.htmlKey) as? String
        subcontent = aDecoder.decodeObjectForKey(PropertyKey.subcontentKey) as? [InfoItem]
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(title, forKey: PropertyKey.titleKey)
        aCoder.encodeObject(image, forKey: PropertyKey.imageKey)
        aCoder.encodeObject(url, forKey: PropertyKey.urlKey)
        aCoder.encodeObject(appStore, forKey: PropertyKey.appStoreKey)
        aCoder.encodeObject(html, forKey: PropertyKey.htmlKey)
        aCoder.encodeObject(subcontent, forKey: PropertyKey.subcontentKey)
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
    case InternalLink
    case ExternalLink
}
