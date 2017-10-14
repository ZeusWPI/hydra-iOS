//
//  SchamperDetailViewController.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 12/06/2017.
//  Copyright © 2017 Zeus WPI. All rights reserved.
//

import UIKit

class SchamperDetailViewController: WebViewController, UIGestureRecognizerDelegate, UIScrollViewDelegate {
    
    var article: SchamperArticle
    private var animationActive = false
    private var startContentOffset: CGFloat = 0
    private var lastContentOffset: CGFloat = 0
    
    init(withArticle article: SchamperArticle) {
        self.article = article
        self.isNavigationBarHidden = false
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.trackedViewName = "Schamper > " + self.article.title
        
        self.loadUrl(url: URL(string: self.article.link)!)
        
        let scrollView = self.webView?.scrollView
        scrollView?.delegate = self
        
        // Recognize taps
        let tapAction = #selector(SchamperDetailViewController.didRecognizeTap)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: tapAction)
        tapRecognizer.delegate = self
        tapRecognizer.numberOfTapsRequired = 1
        self.webView?.addGestureRecognizer(tapRecognizer)
        
        // Add share button
        let shareAction = #selector(SchamperDetailViewController.shareButtonTapped(sender:))
        let btn = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: shareAction)
        self.navigationItem.rightBarButtonItem = btn
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    @objc func shareButtonTapped(sender: Any?) {
        let items = [self.article.title, URL(string: self.article.link)!] as [Any]
        
        let c = UIActivityViewController(activityItems: items, applicationActivities: nil)
        self.present(c, animated: true, completion: nil)
    }
    
    // Inject custom css to hide schamper nav bar
    override func webViewDidFinishLoad(_ webView: UIWebView) {
        let cssString = ".navbar { display: none; }"
        
        let jsString = "var style = document.createElement('style'); style.innerHTML = '\(cssString)'; document.head.appendChild(style);"
        webView.stringByEvaluatingJavaScript(from: jsString)
    }
    
    // Gesture recognizer
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func didRecognizeTap(event: UIEvent?) {
        isNavigationBarHidden = false
    }
    
    // Navigation bar
    var isNavigationBarHidden: Bool {
        didSet {
            guard !animationActive else {
                return
            }
            
            let current = self.navigationController?.isNavigationBarHidden
            if current == isNavigationBarHidden { return }
            
            animationActive = true
            
            // Don't do anything if the content's not big enough
            if let scrollView = self.webView?.scrollView {
                let cSize = scrollView.contentSize
                if cSize.height <= self.view.frame.size.height { return }
            }
            self.navigationController?.setNavigationBarHidden(isNavigationBarHidden, animated: true)
            UIApplication.shared.isStatusBarHidden = isNavigationBarHidden
            
            animationActive = false
        }
    }
    
    // Scroll view delegate methods
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.startContentOffset = scrollView.contentOffset.y
        self.lastContentOffset = scrollView.contentOffset.y
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let diffStart = startContentOffset - currentOffset
        let diffLast = lastContentOffset - currentOffset
        lastContentOffset = currentOffset
        
        // Always show navbar in top section
        if currentOffset <= 10 {
            self.isNavigationBarHidden = false
        }
        // Ignore event from the bottom bounce
        else if currentOffset >= scrollView.contentSize.height - scrollView.frame.size.height { return }
        // Check if scrolling at high enough speed
        else if scrollView.isTracking && fabs(diffLast) > 1 {
            isNavigationBarHidden = diffStart < 0
        }
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        isNavigationBarHidden = false
        return true
    }
}
