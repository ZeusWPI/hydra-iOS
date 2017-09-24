//
//  SKOHydraTabBarController.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 09/09/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation

class SKOHydraTabBarController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 11.0, *) {
        let vc = UIStoryboard(name: "sko", bundle: nil).instantiateInitialViewController()!
        UIApplication.shared.windows[0].rootViewController = vc
        }
    }
}
