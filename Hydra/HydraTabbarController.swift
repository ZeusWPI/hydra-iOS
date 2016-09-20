//
//  HydraTabbarController.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 11/08/15.
//  Copyright © 2015 Zeus WPI. All rights reserved.
//

import UIKit

class HydraTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self

        let newsViewController = UINavigationController(rootViewController: NewsViewController())
        let infoController = UINavigationController(rootViewController: InfoViewController())
        let schamperController = UINavigationController(rootViewController: SchamperViewController())
        let prefsController = UINavigationController(rootViewController: PreferencesController())
        let urgentController = UrgentViewController()
        
        infoController.tabBarItem.configure(nil, image: "info", tag: .Info)
        schamperController.tabBarItem.configure("Schamper Daily", image: "schamper", tag: .Schamper)
        newsViewController.tabBarItem.configure("Nieuws", image: "news", tag: .News)
        urgentController.tabBarItem.configure("Urgent.fm", image: "urgent", tag: .Urgentfm)
        prefsController.tabBarItem.configure("Voorkeuren", image: "settings", tag: .Preferences)

        var viewControllers = self.viewControllers!
        viewControllers.appendContentsOf([infoController, newsViewController, schamperController, urgentController, prefsController])
        
        self.viewControllers = orderViewControllers(viewControllers)
        
        // Fix gray tabbars
        self.tabBar.translucent = false

        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let skoDate = calendar?.dateWithEra(1, year: 2016, month: 9, day: 28, hour: 14, minute: 0, second: 0, nanosecond: 0)!
        let currentDate = NSDate()
        if currentDate.isEarlierThanDate(skoDate?.dateByAddingDays(2)) {
            var viewControllers = self.viewControllers
            let skoController = SKOHydraTabBarController()
            skoController.tabBarItem.configure("Student Kick-Off", image: "sko", tag: .SKO)
            viewControllers?.insert(skoController, atIndex: 1)
            self.viewControllers = viewControllers
        }
    }
    
    func orderViewControllers(viewControllers: [UIViewController]) -> [UIViewController]{
        let tagsOrder = PreferencesService.sharedService.hydraTabBarOrder
        if tagsOrder.count == 0 {
            return viewControllers
        }
        
        var orderedViewControllers = [UIViewController]()
        var oldViewControllers = viewControllers

        for tag in tagsOrder {
            let controller_index: Int? = oldViewControllers.indexOf({ (el) -> Bool in
                el.tabBarItem.tag == tag
            })
            if let index = controller_index {
                orderedViewControllers.append(oldViewControllers.removeAtIndex(index))
            }
        }
        
        // Add all other viewcontrollers, it's possible new ones are added
        orderedViewControllers.appendContentsOf(oldViewControllers)
        return orderedViewControllers
    }
    
    // MARK: UITabBarControllerDelegate
    func tabBarController(tabBarController: UITabBarController, didEndCustomizingViewControllers viewControllers: [UIViewController], changed: Bool) {
        debugPrint("didEndCustomizingViewControllers called")
        if !changed {
            return
        }
        
        var tagsOrder = [Int]()
        for controller in viewControllers {
            tagsOrder.append(controller.tabBarItem.tag)
        }
        
        PreferencesService.sharedService.hydraTabBarOrder = tagsOrder
    }
}

enum TabViewControllerTags: Int {
    case Home = 220
    case Resto = 221
    case Minerva = 222
    case Info = 231
    case Activities = 232
    case Schamper = 233
    case News = 234
    case Urgentfm = 235
    case Preferences = 236
    case SKO = 999
}

// MARK: UITabBarItem functions
extension UITabBarItem {
    
    // Configure UITabBarItem with string, image and tag
    func configure(title: String?, image: String, tag: TabViewControllerTags) {
        if let title = title {
            self.title = title
        }
        self.image = UIImage(named: "tabbar-" + image + ".png")
        self.tag = tag.rawValue
    }
}