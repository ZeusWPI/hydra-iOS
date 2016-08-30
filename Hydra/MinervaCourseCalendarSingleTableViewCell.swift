//
//  MinervaCourseCalendarSingleTableViewCell.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 16/08/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

class MinervaCourseCalendarSingleTableViewCell: UITableViewCell {

    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var courseLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!

    let shortDateFormatter = NSDateFormatter.H_dateFormatterWithAppLocale()

    override func awakeFromNib() {
        super.awakeFromNib()
        shortDateFormatter.timeStyle = .ShortStyle
        shortDateFormatter.dateStyle = .NoStyle
    }
    var calendarItem: CalendarItem? {
        didSet {
            if let calendarItem = calendarItem {
                startTimeLabel.text = shortDateFormatter.stringFromDate(calendarItem.startDate)
                endTimeLabel.text = shortDateFormatter.stringFromDate(calendarItem.endDate)

                titleLabel.text = calendarItem.title
                courseLabel.text = calendarItem.course?.title
                locationLabel.text = calendarItem.location
                if calendarItem.content != nil {
                    self.accessoryType = .DisclosureIndicator
                } else {
                    self.accessoryType = .None
                }
            }
        }
    }

    var activity: Activity? {
        didSet {
            if let activity = activity {
                startTimeLabel.text = shortDateFormatter.stringFromDate(activity.start)
                if let end = activity.end {
                    endTimeLabel.text = shortDateFormatter.stringFromDate(end)
                } else {
                    endTimeLabel.text = ""
                }

                titleLabel.text = activity.title
                courseLabel.text = activity.association.displayName
                locationLabel.text = activity.location

                self.accessoryType = .DisclosureIndicator
            }
        }
    }
}
