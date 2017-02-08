//
//  CalendarViewController.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 16/08/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

class CalendarSingleTableViewCell: UITableViewCell {

    @IBOutlet weak var startTimeLabel: UILabel?
    @IBOutlet weak var endTimeLabel: UILabel?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var courseLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!

    let shortDateFormatter = DateFormatter.h_dateFormatterWithAppLocale()

    override func awakeFromNib() {
        super.awakeFromNib()
        shortDateFormatter?.timeStyle = .short
        shortDateFormatter?.dateStyle = .none
    }
    var calendarItem: CalendarItem? {
        didSet {
            if let calendarItem = calendarItem {
                startTimeLabel?.text = shortDateFormatter?.string(from: calendarItem.startDate as Date)
                endTimeLabel?.text = shortDateFormatter?.string(from: calendarItem.endDate as Date)

                titleLabel.text = calendarItem.title
                courseLabel.text = calendarItem.course?.title
                locationLabel.text = calendarItem.location
                if calendarItem.content != nil {
                    self.accessoryType = .disclosureIndicator
                } else {
                    self.accessoryType = .none
                }
            }
        }
    }

    var activity: Activity? {
        didSet {
            if let activity = activity {
                startTimeLabel?.text = shortDateFormatter?.string(from: activity.start as Date)
                if let end = activity.end {
                    endTimeLabel?.text = shortDateFormatter?.string(from: end as Date)
                } else {
                    endTimeLabel?.text = ""
                }

                titleLabel.text = activity.title
                courseLabel.text = activity.association.displayName
                locationLabel.text = activity.location

                self.accessoryType = .disclosureIndicator
            }
        }
    }
}
