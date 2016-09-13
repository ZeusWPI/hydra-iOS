//
//  NotificationService.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 08/09/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation
import Firebase

class NotificationService {

    static func askSKONotification (viewController: UIViewController) {
        //let token = FIRInstanceID.instanceID().token()!
        //print(token)
        FIRMessaging.messaging().subscribeToTopic("/topics/studentkickoff")

        if PreferencesService.sharedService.notificationsEnabled || (!PreferencesService.sharedService.skoNotificationsEnabled && PreferencesService.sharedService.skoNotificationsAsked){
            return
        }
        PreferencesService.sharedService.skoNotificationsAsked = true
        
        let alertController = UIAlertController(title: "StudentKick-Off Notificaties", message: "Hydra gebruikt notificaties voor belangrijke aankondigingen, voor ieder notificatie type gaan toestemming vragen!", preferredStyle: .Alert)

        alertController.addAction(UIAlertAction(title: "Accepteer", style: .Default, handler: { (action) in
            dispatch_async(dispatch_get_main_queue()) {
                let application = UIApplication.sharedApplication()
                let settings: UIUserNotificationSettings =
                    UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
                application.registerUserNotificationSettings(settings)
                application.registerForRemoteNotifications()
            }

            PreferencesService.sharedService.skoNotificationsEnabled = true
            PreferencesService.sharedService.notificationsEnabled = true
        }))

        alertController.addAction(UIAlertAction(title: "Annuleer", style: .Destructive, handler: { (action) in
            PreferencesService.sharedService.skoNotificationsEnabled = false
        }))

        viewController.presentViewController(alertController, animated: true, completion: nil)
    }

    static func register(viewController: UIViewController, askNotifications: Bool = true) {
        if PreferencesService.sharedService.notificationsEnabled {
            return
        }
        if let lastAsked = PreferencesService.sharedService.lastAskedForNotifications where lastAsked.isEarlierThanDate(NSDate().dateBySubtractingDays(30)) {
            return
        }
        if askNotifications {
            let alertController = UIAlertController(title: "Notificaties", message: "Hydra gebruikt notificaties voor belangrijke aankondigingen, voor ieder notificatie type gaan toestemming vragen!", preferredStyle: .ActionSheet)

            alertController.addAction(UIAlertAction(title: "Accepteer", style: .Default, handler: { (action) in
                dispatch_async(dispatch_get_main_queue()) {
                    let application = UIApplication.sharedApplication()
                    let settings: UIUserNotificationSettings =
                        UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
                    application.registerUserNotificationSettings(settings)
                    application.registerForRemoteNotifications()
                }
                PreferencesService.sharedService.notificationsEnabled = true
            }))

            alertController.addAction(UIAlertAction(title: "Annuleer", style: .Destructive, handler: { (action) in
                PreferencesService.sharedService.notificationsEnabled = false
                PreferencesService.sharedService.lastAskedForNotifications = NSDate()
            }))

            viewController.presentViewController(alertController, animated: true, completion: nil)
        } else {
            dispatch_async(dispatch_get_main_queue()) {
                let application = UIApplication.sharedApplication()
                let settings: UIUserNotificationSettings =
                    UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
                application.registerUserNotificationSettings(settings)
                application.registerForRemoteNotifications()
            }
            PreferencesService.sharedService.notificationsEnabled = true
        }
    }
}