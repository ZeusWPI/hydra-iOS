//
//  AppDelegate.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 11/06/2017.
//  Copyright © 2017 Zeus WPI. All rights reserved.
//

import Foundation
import Reachability
import Firebase

class AppDelegate: UIResponder, UIApplicationDelegate {
    static var reachabilityDetermined = false
    
    var window: UIWindow?
    var navController: UINavigationController?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        DispatchQueue.global(qos: .default).async {
            let reachability = Reachability(hostname: "zeus.ugent.be")
            NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.reachabilityStatusChanged(notification:)), name: NSNotification.Name(rawValue: "kReachabilityChangedNotification"), object: nil)
            reachability?.startNotifier()
        }
        
        //TODO: facebook?
        //Configure firebase
        FirebaseApp.configure()
        
        // Configure user defaults
        PreferencesService.registerAppDefaults()
        
        // Root view controller
        let rootVC: UIViewController
        let firstLaunch = PreferencesService.sharedService.firstLaunch
        if firstLaunch {
            // Start onboarding
            let storyboard = UIStoryboard(name: "onboarding", bundle: Bundle.main)
            rootVC = storyboard.instantiateInitialViewController()!
        } else {
            // Start default storyboard
            let storyboard = UIStoryboard(name: "MainStoryboard", bundle: Bundle.main)
            rootVC = storyboard.instantiateInitialViewController()!
        }
        
        // Set root view controller and make windows visible
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = rootVC
        
        window?.makeKeyAndVisible()
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return false
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // Print message ID.
        print("Message ID: \(String(describing: userInfo["gcm.message_id"]))")
        
        // Print full message.
        print(userInfo)
        #if DEBUG
            let c = UIAlertController(title: "Notification", message: userInfo.description, preferredStyle: .alert)
            if let rvc = window?.rootViewController {
                c.show(rvc, sender: nil)
            }
        #endif
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        SchamperStore.shared.syncStorage()
        AssociationStore.shared.syncStorage()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        if PreferencesService.sharedService.skoNotificationsEnabled {
            Messaging.messaging().subscribe(toTopic: NotificationService.SKOTopic)
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
    }
    
    
    @objc func reachabilityStatusChanged(notification: Notification) {
        guard !AppDelegate.reachabilityDetermined else {
            return
        }
        
        AppDelegate.reachabilityDetermined = true
        let reachability = notification.object as! Reachability
        if !reachability.isReachable() {
            self.showMessage(title: "Geen internetverbinding", message: "Sommige onderdelen van Hydra vereisen een internetverbinding en zullen mogelijks niet correct werken.")
        }
    }
    
    func handleError(error: Error) {
        print("An error occured: \(error), \(error.localizedDescription)")
        
        let title: String
        let message: String
        
        title = "Fout"
        message = error.localizedDescription
        
        showMessage(title: title, message: message)
    }
    
    func handleError(withNSError error: NSError?) {
        guard let error = error else {
            return
        }
        
        print("An error occured: \(String(describing: error)), \(error.domain)")
        
        let title: String
        let message: String
        
        switch error.domain {
        case NSURLErrorDomain:
            title = "Netwerkfout"
            message = "Er trad een fout op het bij het ophalen van externe informatie. Gelieve later opnieuw te proberen."
            break
        default:
            title = error.userInfo["ErrorTitleKey"] as? String ?? "Fout"
            message = error.userInfo[NSLocalizedDescriptionKey] as? String ?? error.localizedDescription
        }
        
        showMessage(title: title, message: message)
    }
    
    func showMessage(title: String, message: String) {
        let c = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if let rvc = window?.rootViewController {
            c.show(rvc, sender: nil)
        }
    }
    
    func resetApp() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
        
        let fileMgr = FileManager()
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true)
        guard let documentDirectory = paths.first else {
            return
        }
        
        do {
            let files = try fileMgr.contentsOfDirectory(atPath: documentDirectory)
            for file in files {
                let fullFilePath = documentDirectory + "/" + file
                do {
                    try fileMgr.removeItem(atPath: fullFilePath)
                } catch {
                    print(error)
                }
            }
        } catch {
            print(error)
        }
        
    }
}
