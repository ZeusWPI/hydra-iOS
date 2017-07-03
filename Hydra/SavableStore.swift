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
    
    let storagePath: String
    
    var storageOutdated = false
    
    var currentRequests = Set<String>()
    
    func markStorageOutdated() {
        storageOutdated = true
    }
    
    func syncStorage() {
        //fatalError("syncStorage should be overriden")
    }

    /*internal func implementedSyncStorage<T: Encodable>(obj: T) {
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
                let data = try encoder.encode(obj)
                print(data)
                try data.write(to: URL(fileURLWithPath:self.storagePath))
            } catch {
                print("Saving the object failed")
                debugPrint(error)
            }
        }
    }*/
    
    init(storagePath: String) {
        self.storagePath = storagePath
    }
    
    func doLater(_ timeSec: Int = 1, function: @escaping (() -> Void)) {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).asyncAfter(deadline: DispatchTime.now() + Double(Int64(Double(timeSec)*Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
            function()
        }
    }
    
    // For array based objects
    
    internal func updateResource<T: Codable>(_ resource: String, notificationName: String, lastUpdated: Date, forceUpdate: Bool, keyPath: String? = nil, oauth: Bool = false, completionHandler: @escaping (([T]) -> Void)) {
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
    
    internal func updateResource<T: Codable>(_ resource: String, notificationName: String, lastUpdated: Date, forceUpdate: Bool, oauth: Bool = false, completionHandler: @escaping ((T) -> Void)) {
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
        
        request.responseData { (response) in
            guard let data = response.data else {
                //TODO: handle error
                return
            }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
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

/*class SavableStore: NSObject {

    let storagePath: String

    var storageOutdated = false

    var currentRequests = Set<String>()

    func markStorageOutdated() {
        storageOutdated = true
    }

    func syncStorage() {
        if !self.storageOutdated {
            return
        }

        // Immediately mark the cache as being updated, as this is an async operation
        self.storageOutdated = false

        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async { () -> Void in
            let isSuccesfulSave = NSKeyedArchiver.archiveRootObject(self, toFile: self.storagePath)
            
            if !isSuccesfulSave {
                print("Saving the object failed")
            }
        }
    }
    
    override init() {
        self.storagePath = Config.AssociationStoreArchive.path
    }
    
    init(storagePath: String) {
        self.storagePath = storagePath
    }
    
    func doLater(_ timeSec: Int = 1, function: @escaping (() -> Void)) {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).asyncAfter(deadline: DispatchTime.now() + Double(Int64(Double(timeSec)*Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
            function()
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
    
    internal func updateResource<T: Codable>(_ resource: String, notificationName: String, lastUpdated: Date, forceUpdate: Bool, keyPath: String? = nil, oauth: Bool = false, completionHandler: @escaping (([T]) -> Void)) {
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
        
        request.responseData { (response) in
            guard let data = response.data else {
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
                print("\(error.localizedDescription)")
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

    /*func handleError(_ error: NSError?, request: String) {
        print("Error \(request): \(error?.localizedDescription)")
        DispatchQueue.main.async {
            let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.handleError(withNSError: error)
        }
    }*//*
 }*/*/
