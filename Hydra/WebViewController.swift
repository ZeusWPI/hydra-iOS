//
//  WebViewController.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 12/06/2017.
//  Copyright © 2017 Zeus WPI. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKUIDelegate {
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var webView: WKWebView? {
        get {
            return self.view as? WKWebView
        }
    }
    internal(set) public var trackedViewName: String = "WebView"
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: CGRect.zero, configuration: webConfiguration)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.uiDelegate = self
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
        self.webView?.load(URLRequest(url: url))
    }
    
    func webView(_ webView: WKWebView, shouldStartLoadWith request: URLRequest, navigationAction: WKNavigationAction) -> Bool {
        if navigationAction.navigationType == .other {
            return true
        }
        guard let url = request.url else {
            return false
        }
        UIApplication.shared.open(url, options: [:])
        return false
    }
    
    func webViewDidFinishLoad(_ webView: WKWebView) {
    }
}
