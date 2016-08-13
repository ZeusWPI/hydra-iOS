//
//  MinervaAnnounceDetailViewController.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 09/08/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation

class MinervaAnnounceDetailViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var authorLabel: UILabel?
    @IBOutlet weak var dateLabel: UILabel?
    @IBOutlet weak var contentView: UITextView?

    let dateTransformer = SORelativeDateTransformer()

    var announcement: Announcement? {
        didSet {
            loadAnnouncement()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadAnnouncement()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        // make sure contentview is scrolled to the top
        contentView?.scrollRectToVisible(CGRectMake(0, 0, 10, 10), animated: false)
    }

    func loadAnnouncement() {
        if let announcement = announcement {
            titleLabel?.text = announcement.title
            authorLabel?.text = announcement.editUser
            dateLabel?.text = dateTransformer.transformedValue(announcement.date) as? String

            if let contentView = contentView {
                let contentAttributedText = announcement.content.html2AttributedString
                if let contentAttributedText = contentAttributedText, let font = contentView.font {
                    contentAttributedText.addAttribute(NSFontAttributeName, value: font, range: NSMakeRange(0, contentAttributedText.length))
                    contentView.attributedText = contentAttributedText
                }
            }
        }
    }

}
