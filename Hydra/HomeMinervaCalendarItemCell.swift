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

    var calendarItem: CalendarItem? {
        didSet {
            if let calendarItem = calendarItem {
                titleLabel.text = calendarItem.title

                if let location = calendarItem.location {
                    locationLabel.text = location
                    locationIcon.hidden = false
                } else {
                    locationLabel.text = nil
                    locationIcon.hidden = true
                }

                descriptionLabel.text = calendarItem.content?.stripHtmlTags
                courseLabel.text = calendarItem.course?.title?.stripHtmlTags

                let longDateFormatter = NSDateFormatter.H_dateFormatterWithAppLocale()
                longDateFormatter.timeStyle = .ShortStyle
                longDateFormatter.dateStyle = .LongStyle
                longDateFormatter.doesRelativeDateFormatting = true

                let shortDateFormatter = NSDateFormatter.H_dateFormatterWithAppLocale()
                shortDateFormatter.timeStyle = .ShortStyle
                shortDateFormatter.dateStyle = .NoStyle

                if calendarItem.startDate.dateByAddingDays(1).isLaterThanDate(calendarItem.endDate) {
                    dateLabel.text = "\(longDateFormatter.stringFromDate(calendarItem.startDate)) - \(shortDateFormatter.stringFromDate(calendarItem.endDate))"
                } else {
                    dateLabel.text = "\(longDateFormatter.stringFromDate(calendarItem.startDate)) - \(longDateFormatter.stringFromDate(calendarItem.endDate))"
                }
            } else {
                titleLabel.text = nil
                locationLabel.text = nil
                locationIcon.hidden = true
                descriptionLabel.text = nil
                courseLabel.text = nil
                dateLabel.text = nil
            }
        }
    }
}
