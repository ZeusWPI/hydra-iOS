//
//  InfoItem.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 11/08/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

class InfoItem: NSObject, Codable {

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

    private enum CodingKeys: String, CodingKey {
        case title, url, image, html, subcontent
        case appStore = "url-ios"
    }
}

enum InfoItemType {
    case internalLink
    case externalLink
}
