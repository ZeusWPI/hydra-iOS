//
//  SKOBackViewController.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 09/09/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import UIKit

class SKOBackViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let vc = UIStoryboard(name: "MainStoryboard", bundle: nil).instantiateInitialViewController()!
        UIApplication.shared.windows[0].rootViewController = vc
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
