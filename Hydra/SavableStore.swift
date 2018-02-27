//
//  SavableStore.swift
//  OAuthTest
//
//  Created by Feliciaan De Palmenaer on 28/02/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation
import Alamofire

let TIME_BETWEEN_REFRESH: TimeInterval = 60 * 15

class SavableStore: NSObject {
    
    var storageOutdated = false
    
    var currentRequests = Set<String>()
    
    static func loadStore<T>(_ type: T.Type, from path: URL) -> T where T: SavableStore & Codable {
        let store: T
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            let data = try Data(contentsOf: path)
            store = try decoder.decode(type, from: data)
        } catch {
            //TODO: report error
            print("\(type): loading error \(error.localizedDescription)")
            store = T.init()
        }
        return store
    }
    
    required override init() {
        super.init()
    }
    
    func markStorageOutdated() {
        storageOutdated = true
    }
    
    func syncStorage() {
        fatalError("Should be implemented in child class")
    }
    
    func syncStorage<T: SavableStore>(obj: T, storageURL: URL) where T: Encodable  {
        if !self.storageOutdated {
            return
        }
        
        // Immediately mark the cache as being updated, as this is an async operation
        self.storageOutdated = false
        DispatchQueue.global(qos: .background).async {            
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            do {
                let data = try encoder.encode(obj)
                try data.write(to: storageURL)
            } catch {
                print("Saving the object failed")
                debugPrint(error)
            }
        }
    }
    
    func doLater(_ timeSec: Int = 1, function: @escaping (() -> Void)) {
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + Double(Int64(Double(timeSec)*Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
            function()
        }
    }
    
    // For array based objects
    
    internal func updateResource<T: Codable>(_ resource: String, notificationName: String, lastUpdated: Date, forceUpdate: Bool, oauth: Bool = false, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .iso8601, completionHandler: @escaping (([T]) -> Void)) {
        if lastUpdated.timeIntervalSinceNow > -TIME_BETWEEN_REFRESH && !forceUpdate {
            return
        }
        
        #if !TODAY_EXTENSION
        if oauth && !UGentOAuth2Service.sharedService.isLoggedIn() {
            print("Request \(resource): cannot be executed because the user is not logged in")
            return
        }
        #endif
        
        objc_sync_enter(currentRequests)
        if currentRequests.contains(resource) {
            return
        }
        currentRequests.insert(resource)
        objc_sync_exit(currentRequests)
        
        let request: DataRequest
        #if TODAY_EXTENSION
            request = Alamofire.request(resource)
            #else
        if !oauth {
            request = Alamofire.request(resource)
        } else {
            request = UGentOAuth2Service.sharedService.ugentSessionManager.request(resource).validate()
            
        }
        #endif
        
        request.response { (res) in
            guard let data = res.data else {
                //TODO: handle error
                return
            }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = dateDecodingStrategy
            
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
    
    internal func updateResource<T: Codable>(_ resource: String, notificationName: String, lastUpdated: Date, forceUpdate: Bool, oauth: Bool = false, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .iso8601, completionHandler: @escaping ((T) -> Void)) {
        if lastUpdated.timeIntervalSinceNow > -TIME_BETWEEN_REFRESH && !forceUpdate {
            return
        }
        
        #if !TODAY_EXTENSION
            if oauth && !UGentOAuth2Service.sharedService.isLoggedIn() {
                print("Request \(resource): cannot be executed because the user is not logged in")
                return
            }
        #endif
        
        if currentRequests.contains(resource) {
            return
        }
        currentRequests.insert(resource)
        let request: DataRequest
        
        #if TODAY_EXTENSION
            request = Alamofire.request(resource)
        #else
            if !oauth {
                request = Alamofire.request(resource)
            } else {
                request = UGentOAuth2Service.sharedService.ugentSessionManager.request(resource).validate()
                
            }
        #endif
        
        request.responseData { (response) in
            guard let data = response.data else {
                //TODO: handle error
                return
            }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = dateDecodingStrategy
            
            do {
                let items = try decoder.decode(T.self, from: data)
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
                debugPrint("\(resource) has errored")
                debugPrint(error)
            }
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
}
