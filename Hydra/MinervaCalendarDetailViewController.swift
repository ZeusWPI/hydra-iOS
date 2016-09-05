//
//  MinervaCalendarDetailViewController.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 17/08/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation

class MinervaCalendarDetailViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var authorLabel: UILabel?
    @IBOutlet weak var courseLabel: UILabel?
    @IBOutlet weak var dateLabel: UILabel?
    @IBOutlet weak var contentView: UITextView?

    let dateTransformer = SORelativeDateTransformer()

    var calendarItem: CalendarItem? {
        didSet {
            loadItem()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadItem()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        // make sure contentview is scrolled to the top
        contentView?.scrollRectToVisible(CGRectMake(0, 0, 10, 10), animated: false)
    }

    func loadItem() {
        if let item = calendarItem {
            titleLabel?.text = item.title
            authorLabel?.text = item.creator
            dateLabel?.text = dateTransformer.transformedValue(item.startDate) as? String
            courseLabel?.text = item.course?.title

            if let contentView = contentView {
                let contentAttributedText = item.content?.html2AttributedString
                if let contentAttributedText = contentAttributedText, let font = contentView.font {
                    contentAttributedText.addAttribute(NSFontAttributeName, value: font, range: NSMakeRange(0, contentAttributedText.length))
                    contentView.attributedText = contentAttributedText
                }
            }
        }
    }
    
}
