//
//  NewsDetailViewController.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 27/02/2018.
//  Copyright © 2018 Zeus WPI. All rights reserved.
//

import Foundation
import WebKit

class NewsDetailViewController: UIViewController {
    
    var newsItem: NewsItem? {
        didSet {
            updateNewsItem()
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var dateTimeLabel: UILabel?
    @IBOutlet weak var authorLabel: UILabel?
    @IBOutlet weak var textView: UITextView?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateNewsItem()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .default
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        GAI_track("News > \(newsItem?.title ?? "")")
    }
    func updateNewsItem() {
        let longFormatter = DateFormatter.h_dateFormatterWithAppLocale()
        longFormatter?.timeStyle = .short
        longFormatter?.dateStyle = .long
        longFormatter?.doesRelativeDateFormatting = true
        
        guard let longDateFormatter = longFormatter else { return }
        
        guard let newsItem = newsItem else { return }
        titleLabel?.text = newsItem.title
        dateTimeLabel?.text = longDateFormatter.string(from: newsItem.date)
        authorLabel?.text = newsItem.association.displayName
        if let textView = textView, let font = textView.font {
            textView.attributedText = newsItem.content.html2AttributedString(font)
        } else {
            textView?.attributedText = newsItem.content.html2AttributedString
        }
      }
}
