//
//  NotificationService.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 08/09/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation
import Firebase
import UserNotifications

class NotificationService: NSObject {

    static let SKOTopic = "/topics/studentkickoff"
    static func askSKONotification (_ viewController: UIViewController) {
        if PreferencesService.sharedService.notificationsEnabled || (!PreferencesService.sharedService.skoNotificationsEnabled && PreferencesService.sharedService.skoNotificationsAsked) {
            return
        }

        if PreferencesService.sharedService.skoNotificationsEnabled {
            Messaging.messaging().subscribe(toTopic: SKOTopic)
        }
        PreferencesService.sharedService.skoNotificationsAsked = true

        let alertController = UIAlertController(title: "StudentKick-Off Notificaties", message: "Hydra gebruikt notificaties voor belangrijke aankondigingen, voor ieder notificatie type gaan toestemming vragen!", preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "Accepteer", style: .default, handler: { (action) in
            DispatchQueue.main.async {
                let application = UIApplication.shared
                
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) {_,_ in
                    application.registerForRemoteNotifications()
                }
                
            }

            PreferencesService.sharedService.skoNotificationsEnabled = true
            PreferencesService.sharedService.notificationsEnabled = true
        }))

        alertController.addAction(UIAlertAction(title: "Annuleer", style: .destructive, handler: { (action) in
            PreferencesService.sharedService.skoNotificationsEnabled = false
        }))

        viewController.present(alertController, animated: true, completion: nil)
    }

    static func register(_ viewController: UIViewController, askNotifications: Bool = true) {
        if PreferencesService.sharedService.notificationsEnabled {
            return
        }
        if let lastAsked = PreferencesService.sharedService.lastAskedForNotifications, (lastAsked as NSDate).isEarlierThanDate((Date() as NSDate).subtractingDays(30)) {
            return
        }
        if askNotifications {
            let alertController = UIAlertController(title: "Notificaties", message: "Hydra gebruikt notificaties voor belangrijke aankondigingen, voor ieder notificatie type gaan toestemming vragen!", preferredStyle: .actionSheet)

            alertController.addAction(UIAlertAction(title: "Accepteer", style: .default, handler: { (action) in
                DispatchQueue.main.async {
                    let application = UIApplication.shared
                    let settings: UIUserNotificationSettings =
                        UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
                    application.registerUserNotificationSettings(settings)
                    application.registerForRemoteNotifications()
                }
                PreferencesService.sharedService.notificationsEnabled = true
            }))

            alertController.addAction(UIAlertAction(title: "Annuleer", style: .destructive, handler: { (action) in
                PreferencesService.sharedService.notificationsEnabled = false
                PreferencesService.sharedService.lastAskedForNotifications = Date()
            }))

            viewController.present(alertController, animated: true, completion: nil)
        } else {
            DispatchQueue.main.async {
                let application = UIApplication.shared
                let settings: UIUserNotificationSettings =
                    UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
                application.registerUserNotificationSettings(settings)
                application.registerForRemoteNotifications()
            }
            PreferencesService.sharedService.notificationsEnabled = true
        }
    }
}
