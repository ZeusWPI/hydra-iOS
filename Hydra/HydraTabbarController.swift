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

        let infoController = UINavigationController(rootViewController: InfoViewController())
        let prefsController = UINavigationController(rootViewController: PreferencesController())
        let urgentController = UrgentViewController()

        infoController.tabBarItem.configure(nil, image: "info", tag: .info)
        urgentController.tabBarItem.configure("Urgent.fm", image: "urgent", tag: .urgentfm)
        prefsController.tabBarItem.configure("Voorkeuren", image: "settings", tag: .preferences)

        var viewControllers = self.viewControllers!
        viewControllers.append(contentsOf: [infoController, urgentController, prefsController])

        self.viewControllers = orderViewControllers(viewControllers)

        // Fix gray tabbars
        self.tabBar.isTranslucent = false

        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let skoDate = (calendar as NSCalendar?)?.date(era: 1, year: 2017, month: 9, day: 27, hour: 14, minute: 0, second: 0, nanosecond: 0)!
        let currentDate = Date()
        if (currentDate as NSDate).isEarlierThanDate((skoDate as NSDate?)?.addingDays(2)) {
            var viewControllers = self.viewControllers
            let skoController = SKOHydraTabBarController()
            skoController.tabBarItem.configure("Student Kick-Off", image: "sko", tag: .sko)
            viewControllers?.insert(skoController, at: 1)
            self.viewControllers = viewControllers
        }
    }

    func orderViewControllers(_ viewControllers: [UIViewController]) -> [UIViewController] {
        let tagsOrder = PreferencesService.sharedService.hydraTabBarOrder
        if tagsOrder.count == 0 {
            return viewControllers
        }

        var orderedViewControllers = [UIViewController]()
        var oldViewControllers = viewControllers

        for tag in tagsOrder {
            let controller_index: Int? = oldViewControllers.index(where: { (el) -> Bool in
                el.tabBarItem.tag == tag
            })
            if let index = controller_index {
                orderedViewControllers.append(oldViewControllers.remove(at: index))
            }
        }

        // Add all other viewcontrollers, it's possible new ones are added
        orderedViewControllers.append(contentsOf: oldViewControllers)
        return orderedViewControllers
    }

    // MARK: UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, didEndCustomizing viewControllers: [UIViewController], changed: Bool) {
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
    case home = 220
    case resto = 221
    case minerva = 222
    case info = 231
    case calendar = 232
    case schamper = 233
    case news = 234
    case urgentfm = 235
    case preferences = 236
    case sko = 999
}

// MARK: UITabBarItem functions
extension UITabBarItem {

    // Configure UITabBarItem with string, image and tag
    func configure(_ title: String?, image: String, tag: TabViewControllerTags) {
        if let title = title {
            self.title = title
        }
        self.image = UIImage(named: "tabbar-" + image + ".png")
        self.tag = tag.rawValue
    }
}
