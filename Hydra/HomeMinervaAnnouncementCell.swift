//
//  HomeMinervaAnnouncementCell.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 13/08/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

class HomeMinervaAnnouncementCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var courseLabel: UILabel!

    override func awakeFromNib() {
        self.contentView.setShadow()
    }

    var announcement: Announcement? {
        didSet {
            if let announcement = announcement {
                titleLabel.text = announcement.title
                authorLabel.text = announcement.editUser
                descriptionLabel.text = announcement.content.stripHtmlTags
                courseLabel.text = announcement.course?.title?.stripHtmlTags

                let longDateFormatter = DateFormatter.h_dateFormatterWithAppLocale()
                longDateFormatter?.timeStyle = .short
                longDateFormatter?.dateStyle = .long
                longDateFormatter?.doesRelativeDateFormatting = true
                dateLabel.text = longDateFormatter?.string(from: announcement.date as Date)
            } else {
                titleLabel.text = ""
                authorLabel.text = ""
                descriptionLabel.text = ""
                courseLabel.text = ""
                dateLabel.text = ""
            }
        }
    }

}
