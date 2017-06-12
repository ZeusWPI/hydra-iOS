//
//  AssociationStore.swift
//  OAuthTest
//
//  Created by Feliciaan De Palmenaer on 27/02/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper
import AlamofireObjectMapper

let AssociationStoreDidUpdateNewsNotification = "AssociationStoreDidUpdateNewsNotification"
let AssociationStoreDidUpdateActivitiesNotification = "AssociationStoreDidUpdateActivitiesNotification"
let AssociationStoreDidUpdateAssociationsNotification = "AssociationStoreDidUpdateAssociationsNotification"

class AssociationStore: NSObject, Codable {

    fileprivate static var _SharedStore: AssociationStore?
    @objc static var sharedStore: AssociationStore {
        get {
            //TODO: make lazy, and catch NSKeyedUnarchiver errors
            if let _SharedStore = _SharedStore {
                return _SharedStore
            }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            do {
                let data = try Data(contentsOf: Config.AssociationStoreArchive)
                _SharedStore = try decoder.decode(AssociationStore.self, from: data)
            } catch {
                //TODO: report error
                print("AssociationStore: loading error \(error.localizedDescription)")
                _SharedStore = AssociationStore()
            }
            return _SharedStore!
        }
    }
    
    @objc func syncStorage() {
        if !self.storageOutdated {
            return
        }
        
        // Immediately mark the cache as being updated, as this is an async operation
        self.storageOutdated = false
        DispatchQueue.global(qos: .background).async {
            print(self.storagePath)
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            do {
                let data = try encoder.encode(self)
                print(data)
                try data.write(to: URL(fileURLWithPath:self.storagePath))
            } catch {
                print("Saving the object failed")
                debugPrint(error)
            }
        }
    }
    
    var associationLookup: [String: Association]

    fileprivate var _associations: [Association]
    var associations: [Association] {
        get {
            self.reloadAssociations()
            return self._associations
        }
    }
    fileprivate var _activities: [Activity]
    var activities: [Activity] {
        get {
            self.reloadActivities()
            return self._activities
        }
    }
    fileprivate var _newsItems: [NewsItem]
    var newsItems: [NewsItem] {
        get {
            self.reloadNewsItems()
            return self._newsItems
        }
    }

    var associationsLastUpdated: Date
    var activitiesLastUpdated: Date
    var newsLastUpdated: Date
    
    let storagePath = Config.AssociationStoreArchive.path
    
    var storageOutdated = false
    
    var currentRequests = Set<String>()
    

    override init() {
        associationsLastUpdated = Date(timeIntervalSince1970: 0)
        activitiesLastUpdated = Date(timeIntervalSince1970: 0)
        newsLastUpdated = Date(timeIntervalSince1970: 0)

        associationLookup = [:]
        _associations = []
        _activities = []
        _newsItems = []
        
        super.init()
        self.sharedInit()
    }

    func sharedInit() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(AssociationStore.facebookEventUpdated(_:)), name: NSNotification.Name(rawValue: FacebookEventDidUpdateNotification), object: nil)
    }
    
    fileprivate static func createAssociationLookup(_ associations: [Association]) -> [String: Association] {
        var associationsLookup = [String: Association]()
        for association in associations {
            associationsLookup[association.internalName] = association
        }
        return associationsLookup
    }

    func associationWithName(_ internalName: String) -> Association? {
        let association = associationLookup[internalName]
        return association
    }

    func reloadAssociations(_ forceUpdate: Bool = false) {
        updateResource(APIConfig.DSA + "2.0/associations.json",
            notificationName: AssociationStoreDidUpdateAssociationsNotification,
            lastUpdated: self.associationsLastUpdated,
            forceUpdate: forceUpdate) { (associations: [Association]) -> () in
            print("Updating associations")
            self._associations = associations
            self.associationsLastUpdated = Date()

            self.associationLookup = AssociationStore.createAssociationLookup(associations)
        }
    }

    func reloadActivities(_ forceUpdate: Bool = false) {
        updateResourceC(APIConfig.DSA + "2.0/all_activities.json", notificationName: AssociationStoreDidUpdateActivitiesNotification, lastUpdated: self.activitiesLastUpdated, forceUpdate: forceUpdate) { (activities: [Activity]) -> () in
            print("Updating activities")
            var facebookEvents: Dictionary<String, FacebookEvent> = [:]
            // cache all facebookEvents to dict
            for activity in self._activities where activity.hasFacebookEvent() {
                facebookEvents[activity.facebookId!] = activity.facebookEvent
            }

            // add them to the new objects
            /*for activity in activities where activity.facebookId != nil {
                if let facebookEvent = facebookEvents[activity.facebookId!] {
                    //TODO: activity.facebookEvent = facebookEvent
                }
            }*/
            self._activities = activities
            self.activitiesLastUpdated = Date()
        }
    }

    func reloadNewsItems(_ forceUpdate: Bool = false) {
        updateResource(APIConfig.DSA + "2.0/all_news.json", notificationName: AssociationStoreDidUpdateNewsNotification, lastUpdated: self.newsLastUpdated, forceUpdate: forceUpdate) { (newsItems: [NewsItem]) -> () in
            print("Updating News Items")
            let readItems = Set<Int>(self._newsItems.filter({ $0.read }).map({ $0.internalIdentifier}))
            for item in newsItems {
                if readItems.contains(item.internalIdentifier) {
                    item.read = true
                }
            }

            self._newsItems = newsItems
            self.newsLastUpdated = Date()
        }
    }

    // MARK: notifications
    @objc func facebookEventUpdated(_ notification: Notification) {
        self.markStorageOutdated()
        self.doLater {
            self.syncStorage()
        }
    }
    
    // For array based objects
    internal func updateResource<T: Mappable>(_ resource: String, notificationName: String, lastUpdated: Date, forceUpdate: Bool, keyPath: String? = nil, oauth: Bool = false, completionHandler: @escaping (([T]) -> Void)) {
        if lastUpdated.timeIntervalSinceNow > -TIME_BETWEEN_REFRESH && !forceUpdate {
            return
        }
        
        if oauth && !UGentOAuth2Service.sharedService.isLoggedIn() {
            print("Request \(resource): cannot be executed because the user is not logged in")
            return
        }
        
        objc_sync_enter(currentRequests)
        if currentRequests.contains(resource) {
            return
        }
        currentRequests.insert(resource)
        objc_sync_exit(currentRequests)
        
        let request: DataRequest
        if !oauth {
            request = Alamofire.request(resource)
        } else {
            request = UGentOAuth2Service.sharedService.ugentSessionManager.request(resource).validate()
        }
        
        request.responseArray(queue: nil, keyPath: keyPath) { (response: DataResponse<[T]>) -> Void in
            if let value = response.result.value, response.result.isSuccess {
                completionHandler(value)
                self.markStorageOutdated()
                self.syncStorage()
            } else {
                //TODO: Handle error
                print("Request array \(resource) errored")
                //self.handleError(response.result.error!, request: resource)
            }
            self.postNotification(notificationName)
            self.doLater(function: { () -> Void in
                objc_sync_enter(self.currentRequests)
                if self.currentRequests.contains(resource) {
                    self.currentRequests.remove(resource)
                }
                objc_sync_exit(self.currentRequests)
            })
        }
        
    }
    
    internal func updateResourceC<T: Codable>(_ resource: String, notificationName: String, lastUpdated: Date, forceUpdate: Bool, keyPath: String? = nil, oauth: Bool = false, completionHandler: @escaping (([T]) -> Void)) {
        if lastUpdated.timeIntervalSinceNow > -TIME_BETWEEN_REFRESH && !forceUpdate {
            return
        }
        
        if oauth && !UGentOAuth2Service.sharedService.isLoggedIn() {
            print("Request \(resource): cannot be executed because the user is not logged in")
            return
        }
        
        objc_sync_enter(currentRequests)
        if currentRequests.contains(resource) {
            return
        }
        currentRequests.insert(resource)
        objc_sync_exit(currentRequests)
        
        let request: DataRequest
        if !oauth {
            request = Alamofire.request(resource)
        } else {
            request = UGentOAuth2Service.sharedService.ugentSessionManager.request(resource).validate()
        }
        
        request.response { (res) in
            guard let data = res.data else {
                //TODO: handle error
                return
            }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            do {
                let items = try decoder.decode([T].self, from: data)
                completionHandler(items)
                self.markStorageOutdated()
                self.syncStorage()
                self.postNotification(notificationName)
                self.doLater(function: { () -> Void in
                    objc_sync_enter(self.currentRequests)
                    if self.currentRequests.contains(resource) {
                        self.currentRequests.remove(resource)
                    }
                    objc_sync_exit(self.currentRequests)
                })
            } catch {
                debugPrint(error)
            }
        }
    }
    
    internal func updateResource<T: Mappable>(_ resource: String, notificationName: String, lastUpdated: Date, forceUpdate: Bool, oauth: Bool = false, completionHandler: @escaping ((T) -> Void)) {
        if lastUpdated.timeIntervalSinceNow > -TIME_BETWEEN_REFRESH && !forceUpdate {
            return
        }
        
        if currentRequests.contains(resource) {
            return
        }
        currentRequests.insert(resource)
        let request: DataRequest
        if !oauth {
            request = Alamofire.request(resource)
        } else {
            request = UGentOAuth2Service.sharedService.ugentSessionManager.request(resource).validate()
        }
        
        request.responseObject { (response: DataResponse<T>) in
            if let value = response.result.value, response.result.isSuccess {
                completionHandler(value)
                self.markStorageOutdated()
                self.syncStorage()
            } else {
                //TODO: Handle error
                print("Request object \(resource) errored")
                //self.handleError(response.result.error., request: resource)
            }
            self.postNotification(notificationName)
            self.doLater(function: { () -> Void in
                if self.currentRequests.contains(resource) {
                    self.currentRequests.remove(resource)
                }
            })
        }
    }

    
    func saveLater(_ timeSec: Double = 10) {
        self.markStorageOutdated()
        DispatchQueue.global(qos: .background).asyncAfter(deadline: DispatchTime.now() + timeSec) { () -> Void in
            self.syncStorage()
        }
    }
    
    func postNotification(_ notificationName: String) {
        let center = NotificationCenter.default
        center.post(name: Notification.Name(rawValue: notificationName), object: self)
    }
    
    func handleError(_ error: NSError?, request: String) {
        print("Error \(request): \(error?.localizedDescription)")
        DispatchQueue.main.async {
            let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.handleError(withNSError: error)
        }
    }
    
    func markStorageOutdated() {
        storageOutdated = true
    }
    func doLater(_ timeSec: Int = 1, function: @escaping (() -> Void)) {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).asyncAfter(deadline: DispatchTime.now() + Double(Int64(Double(timeSec)*Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
            function()
        }
    }
    

    // MARK: field information struct
    struct PropertyKey {
        static let associationsKey = "associations"
        static let activitiesKey = "activities"
        static let newsItemsKey = "newsItems"

        static let associationsLastUpdatedKey = "associationsLastUpdated"
        static let activitiesLastUpdatedKey = "activitiesLastUpdated"
        static let newsItemsLastUpdatedKey = "newsItemsLastUpdated"
    }
}

// MARK: Implement FeedItemProtocol
extension AssociationStore: FeedItemProtocol {
    func feedItems() -> [FeedItem] {
        return getActivities() + getNewsItems()
    }

    fileprivate func getActivities() -> [FeedItem] {
        var feedItems = [FeedItem]()
        let preferencesService = PreferencesService.sharedService
        var filter: ((Activity) -> (Bool))
        if preferencesService.showActivitiesInFeed {
            if preferencesService.filterAssociations {
                let associations = preferencesService.preferredAssociations
                filter = { activity in activity.highlighted || associations.contains { activity.association.internalName == ($0) } }
            } else {
                filter = { _ in true }
            }
        } else {
            filter = { $0.highlighted }
            feedItems.append(FeedItem(itemType: .associationsSettingsItem, object: nil, priority: 850))
        }

        for activity in activities.filter(filter) {
            // Force load facebookEvent
            if let facebookEvent = activity.facebookEvent {
                facebookEvent.update()
            }
            var priority = 950 //TODO: calculate priorities, with more options
            priority -= max((activity.start as NSDate).hours(after: Date()), 0)
            if priority > 0 {
                feedItems.append(FeedItem(itemType: .activityItem, object: activity, priority: priority))
            }
        }
        return feedItems
    }

    fileprivate func getNewsItems() -> [FeedItem] {
        var feedItems = [FeedItem]()
        var filter: ((NewsItem) -> (Bool))

        if PreferencesService.sharedService.showNewsInFeed {
            filter = { _ in true }
        } else {
            filter = { $0.highlighted }
        }

        for newsItem in newsItems.filter(filter) {
            var priority = 999
            let daysOld = (newsItem.date as NSDate).days(before: Date())
            if newsItem.highlighted {
                priority -= 25*daysOld
            } else {
                priority -= 90*daysOld
            }

            if priority > 0 {
                feedItems.append(FeedItem(itemType: .newsItem, object: newsItem, priority: priority))
            }
        }

        return feedItems
    }
}
