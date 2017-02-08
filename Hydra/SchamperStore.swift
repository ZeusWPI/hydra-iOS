//
//  SchamperStore.swift
//  OAuthTest
//
//  Created by Feliciaan De Palmenaer on 28/02/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper

let SchamperStoreDidUpdateArticlesNotification = "SchamperStoreDidUpdateArticlesNotification"

class SchamperStore: SavableStore {

    fileprivate static var _SharedStore: SchamperStore?
    static var sharedStore: SchamperStore {
        get {
            if let _SharedStore = _SharedStore {
                return _SharedStore
            } else {
                let schamperStore = NSKeyedUnarchiver.unarchiveObject(withFile: Config.SchamperStoreArchive.path) as? SchamperStore
                if let schamperStore = schamperStore {
                    _SharedStore = schamperStore
                    return schamperStore
                }
            }
            // initialize new one
            _SharedStore = SchamperStore()
            return _SharedStore!
        }
    }

    var articles: [SchamperArticle] = []
    var lastUpdated: Date = Date(timeIntervalSince1970: 0)

    init() {
        super.init(storagePath: Config.SchamperStoreArchive.path)
    }

    // MARK: NSCoding Protocol
    required init?(coder aDecoder: NSCoder) {
        super.init(storagePath: Config.SchamperStoreArchive.path)
        guard let articles = aDecoder.decodeObject(forKey: PropertyKey.articlesKey) as? [SchamperArticle],
            let lastUpdated = aDecoder.decodeObject(forKey: PropertyKey.lastUpdatedKey) as? Date else {
                return nil
        }

        self.articles = articles
        self.lastUpdated = lastUpdated
    }

    func encodeWithCoder(_ aCoder: NSCoder) {
        aCoder.encode(articles, forKey: PropertyKey.articlesKey)
        aCoder.encode(lastUpdated, forKey: PropertyKey.lastUpdatedKey)
    }

    // MARK: Store functions
    // Force reload all articles
    func reloadArticles() {
        URLCache.shared.removeAllCachedResponses()
        self.updateArticles(true)
    }

    func updateArticles(_ forceUpdate: Bool = false) {
        print("Updating Schamper Articles")

        let url = APIConfig.Zeus1_0 + "schamper/daily.json"

        self.updateResource(url, notificationName: SchamperStoreDidUpdateArticlesNotification, lastUpdated: self.lastUpdated, forceUpdate: forceUpdate) { (articles: [SchamperArticle]) in
            print("Updating Schamper articles")
            let readArticles = Set<String>(self.articles.filter({ $0.read }).map({ $0.title}))

            for article in articles {
                article.read = readArticles.contains(article.title)
            }

            self.articles = articles
            self.lastUpdated = Date()
        }

    }

    struct PropertyKey {
        static let articlesKey = "articles"
        static let lastUpdatedKey = "lastUpdated"
    }
}

// MARK: Implement FeedItemProtocol
extension SchamperStore: FeedItemProtocol {
    func feedItems() -> [FeedItem] {
        var feedItems = [FeedItem]()

        if !PreferencesService.sharedService.showSchamperInFeed {
            return feedItems
        }

        for article in articles { //TODO: test articles and sort them
            let daysOld = (article.date as NSDate).days(before: Date())
            var priority = 999
            if !article.read {
                priority = priority - daysOld*40
            } else {
                priority = priority - daysOld*150
            }
            if priority > 0 {
                feedItems.append(FeedItem(itemType: .schamperNewsItem, object: article, priority: priority))
            }
        }
        return feedItems
    }
}
