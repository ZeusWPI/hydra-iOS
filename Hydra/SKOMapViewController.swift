//
//  SKOMapViewController.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 09/09/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation

class SKOMapViewController: UIViewController {

    @IBOutlet var webView: UIWebView?

    override func viewDidLoad() {
        super.viewDidLoad()

        webView?.userInteractionEnabled = true
        webView?.backgroundColor = UIColor.SKOBackgroundColor()

        let mapUrl = NSURL(string: APIConfig.Zeus1_0 + "grondplan.html")!
        webView?.loadRequest(NSURLRequest(URL: mapUrl, cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: 3600*24))
    }
}
