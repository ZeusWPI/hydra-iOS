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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // make sure contentview is scrolled to the top
        contentView?.scrollRectToVisible(CGRect(x: 0, y: 0, width: 10, height: 10), animated: false)
    }

    func loadItem() {
        if let item = calendarItem {
            titleLabel?.text = item.title
            authorLabel?.text = item.creator
            courseLabel?.text = item.course?.title
            locationLabel?.text = item.location

            let longDateFormatter = DateFormatter.h_dateFormatterWithAppLocale()
            longDateFormatter?.timeStyle = .short
            longDateFormatter?.dateStyle = .long
            longDateFormatter?.doesRelativeDateFormatting = true

            let shortDateFormatter = DateFormatter.h_dateFormatterWithAppLocale()
            shortDateFormatter?.timeStyle = .short
            shortDateFormatter?.dateStyle = .none

            if (item.startDate as! NSDate).addingDays(1) >= item.endDate {
                dateLabel?.text = "\(longDateFormatter?.string(from: item.startDate as Date)) - \(shortDateFormatter?.string(from: item.endDate as Date))"
            } else {
                dateLabel?.text = "\(longDateFormatter?.string(from: item.startDate as Date))\n\(longDateFormatter?.string(from: item.endDate as Date))"
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
