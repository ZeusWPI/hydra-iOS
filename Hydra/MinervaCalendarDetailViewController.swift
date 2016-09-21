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
    @IBOutlet weak var locationLabel: UILabel?
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
            courseLabel?.text = item.course?.title
            locationLabel?.text = item.location

            let longDateFormatter = NSDateFormatter.H_dateFormatterWithAppLocale()
            longDateFormatter.timeStyle = .ShortStyle
            longDateFormatter.dateStyle = .LongStyle
            longDateFormatter.doesRelativeDateFormatting = true

            let shortDateFormatter = NSDateFormatter.H_dateFormatterWithAppLocale()
            shortDateFormatter.timeStyle = .ShortStyle
            shortDateFormatter.dateStyle = .NoStyle

            if item.startDate.dateByAddingDays(1).isLaterThanDate(item.endDate) {
                dateLabel?.text = "\(longDateFormatter.stringFromDate(item.startDate)) - \(shortDateFormatter.stringFromDate(item.endDate))"
            } else {
                dateLabel?.text = "\(longDateFormatter.stringFromDate(item.startDate))\n\(longDateFormatter.stringFromDate(item.endDate))"
            }

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
