//
//  HomeMinervaCalendarItemCell.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 13/08/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import FontAwesome_swift

class HomeMinervaCalendarItemCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationIcon: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var courseLabel: UILabel!

    /// bhjphiuphiuphiuhpioijpopijo
    var calendarItem: CalendarItem? {
        didSet {
            if let calendarItem = calendarItem {
                titleLabel.text = calendarItem.title

                if let location = calendarItem.location {
                    locationLabel.text = location
                    locationIcon.isHidden = false
                } else {
                    locationLabel.text = nil
                    locationIcon.isHidden = true
                }

                descriptionLabel.text = calendarItem.content?.stripHtmlTags
                courseLabel.text = calendarItem.course?.title?.stripHtmlTags

                let longFormatter = DateFormatter.h_dateFormatterWithAppLocale()
                longFormatter?.timeStyle = .short
                longFormatter?.dateStyle = .long
                longFormatter?.doesRelativeDateFormatting = true

                let shortFormatter = DateFormatter.h_dateFormatterWithAppLocale()
                shortFormatter?.timeStyle = .short
                shortFormatter?.dateStyle = .none

                guard let longDateFormatter = longFormatter,
                    let shortDateFormatter = shortFormatter
                    else { return }

                if (calendarItem.startDate as NSDate).addingDays(1) >= calendarItem.endDate {
                    dateLabel.text = "\(longDateFormatter.string(from: calendarItem.startDate)) - \(shortDateFormatter.string(from: calendarItem.endDate))"
                } else {
                    dateLabel.text = "\(longDateFormatter.string(from: calendarItem.startDate)) - \(longDateFormatter.string(from: calendarItem.endDate))"
                }
            } else {
                titleLabel.text = nil
                locationLabel.text = nil
                locationIcon.isHidden = true
                descriptionLabel.text = nil
                courseLabel.text = nil
                dateLabel.text = nil
            }
        }
    }
}
