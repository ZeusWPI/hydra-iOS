//
//  WebViewController.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 12/06/2017.
//  Copyright © 2017 Zeus WPI. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var webView: UIWebView? {
        get {
            return self.view as? UIWebView
        }
    }
    internal(set) public var trackedViewName: String = "WebView"
    
    override func loadView() {
        let webView = UIWebView(frame: CGRect.zero)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.delegate = self
        self.view = webView
    }
    
    func loadHtml(path: String) {
        // Trigger view load
        _ = self.view
        
        guard let url = Bundle.main.url(forResource: path, withExtension: nil) else {
            return
        }
        self.loadUrl(url: url)
    }
    
    func loadUrl(url: URL) {
        self.webView?.loadRequest(URLRequest(url: url))
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == .other {
            return true
        }
        guard let url = request.url else {
            return false
        }
        UIApplication.shared.open(url, options: [:])
        return false
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
    }
}
