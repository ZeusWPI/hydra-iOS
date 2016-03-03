//
//  SavableStore.swift
//  OAuthTest
//
//  Created by Feliciaan De Palmenaer on 28/02/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation

class SavableStore: NSObject {

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

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            let isSuccesfulSave = NSKeyedArchiver.archiveRootObject(self, toFile: self.storagePath)

            if !isSuccesfulSave {
                print("Saving the object failed")
            }
        }
    }

    init(storagePath: String) {
        self.storagePath = storagePath
    }

    func doLater(timeSec: Int = 10, function: (()->Void)) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(Double(timeSec)*Double(NSEC_PER_SEC))), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            function()
        }

    }

    func saveLater(timeSec: Int = 10) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(Double(timeSec)*Double(NSEC_PER_SEC))), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            self.syncStorage()
        }
    }

    func postNotification(notificationName: String) {
        let center = NSNotificationCenter.defaultCenter()
        center.postNotificationName(notificationName, object: self)
    }

    func handleError(error: NSError?) {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.handleError(error)
    }
}