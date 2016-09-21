//
//  CalendarViewController.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 14/08/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import UIKit
import CVCalendar

class CalendarViewController: UIViewController {
    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var calendarView: CVCalendarView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectedDayLabel: UILabel!
    var selectedDay:CVDate = CVDate(date: NSDate()) {
        didSet {
            UIView.transitionWithView(tableView, duration: 0.8, options: .TransitionCrossDissolve, animations: {self.tableView.reloadData()}, completion: nil)
        }
    }

    var minervaCalendarItems: [NSDate: [CalendarItem]]?
    var associationCalendarItems: [NSDate: [Activity]]?

    // MARK: - Life cycle
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        selectedDay = CVDate(date: NSDate())
        calendarView.presentedDate = selectedDay
        calendarView.toggleViewWithDate(selectedDay.convertedDate()!)
        setNavBarTitleDate(selectedDay.convertedDate())

        // only show rows that are filled
        self.tableView.tableFooterView = UIView()
        // only scroll when content doesn't fit the whole screen
        self.tableView.alwaysBounceVertical = false
        self.tableView.estimatedRowHeight = 75

        calendarUpdated()
        loadAssociatonActivities()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CalendarViewController.calendarUpdated), name: MinervaStoreDidUpdateCourseInfoNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CalendarViewController.loadAssociatonActivities), name: AssociationStoreDidUpdateActivitiesNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CalendarViewController.reloadCalendarData), name: PreferencesControllerDidUpdatePreferenceNotification, object: nil)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.calendarUpdated()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        menuView.commitMenuViewUpdate()
        calendarView.commitCalendarViewUpdate()
    }

    func setNavBarTitleDate(date: NSDate?) {
        guard let date = date else {
            setNavBarTitle("")
            return
        }

        let dateFormatter = NSDateFormatter.H_dateFormatterWithAppLocale()
        dateFormatter.dateFormat = "MMMM YYYY"

        setNavBarTitle(dateFormatter.stringFromDate(date))
    }

    func setNavBarTitle(title: String) {
        self.title = title
        self.navigationController?.tabBarItem.title = "Agenda"
    }

    func reloadCalendarData() {
        calendarUpdated()
        loadAssociatonActivities()
    }

    func calendarUpdated() {
        dispatch_async(dispatch_get_main_queue()) {
            self.minervaCalendarItems = MinervaStore.sharedStore.sortedByDate()
            self.calendarView.contentController.refreshPresentedMonth()
            self.tableView.reloadData()
        }
    }

    func loadAssociatonActivities() {
        var activities = AssociationStore.sharedStore.activities

        let prefs = PreferencesService.sharedService
        if prefs.filterAssociations {
            let associations = Set(prefs.preferredAssociations)
            activities = activities.filter { $0.highlighted || associations.contains($0.association.internalName)}
        }

        var grouped = [NSDate: [Activity]]()
        for activity in activities {
            let date = activity.start.dateAtStartOfDay()
            if case nil = grouped[date]?.append(activity) {
                grouped[date] = [activity]
            }

            if let endDay = activity.end?.dateAtStartOfDay() where endDay > date {
                var nextDate = date.dateByAddingDays(1)
                while nextDate.dateByAddingHours(8) <= endDay {
                    if case nil = grouped[nextDate]?.append(activity) {
                        grouped[nextDate] = [activity]
                    }
                    
                    nextDate = nextDate.dateByAddingDays(1)
                }
            }
        }

        for (k, _) in grouped {
            var activitiesDay = grouped[k]!
            activitiesDay.sortInPlace({ $0.start <= $1.start })
        }

        dispatch_async(dispatch_get_main_queue()) {
            self.associationCalendarItems = grouped
            self.calendarView.contentController.refreshPresentedMonth()
            self.tableView.reloadData()
        }
    }
}

extension CalendarViewController: CVCalendarViewDelegate, CVCalendarMenuViewDelegate {

    func presentationMode() -> CalendarMode {
        return .WeekView
    }

    func firstWeekday() -> Weekday {
        return .Monday
    }

    func shouldShowWeekdaysOut() -> Bool {
        return true
    }

    func didSelectDayView(dayView: DayView, animationDidFinish: Bool) {
        debugPrint("\(dayView.date.commonDescription) is selected!")
        guard let date = dayView.date.convertedDate() else { return }

        selectedDay = dayView.date

        let dateFormatter = NSDateFormatter.H_dateFormatterWithAppLocale()
        dateFormatter.dateFormat = "EEEE d MMMM"
        selectedDayLabel.text = dateFormatter.stringFromDate(date)
    }

    func dotMarker(shouldShowOnDayView dayView: DayView) -> Bool {
        var count = 0
        if let date = dayView.date.convertedDate() {
            if let calendarItems = self.minervaCalendarItems, let items = calendarItems[date] {
                count = count + items.count
            }

            if let associationCalendarItems = self.associationCalendarItems, let items = associationCalendarItems[date] {
                count = count + items.count
            }
        }

        return count > 0
    }

    func dotMarker(colorOnDayView dayView: DayView) -> [UIColor] {
        var colors = [UIColor]()

        if let date = dayView.date.convertedDate() {
            if let calendarItems = self.minervaCalendarItems, let items = calendarItems[date] {
                if items.count > 0 {
                    colors.append(UIColor.hydraTintcolor())
                }
            }

            if let associationCalendarItems = self.associationCalendarItems, let items = associationCalendarItems[date] {
                if items.count > 0 {
                    colors.append(UIColor.hydraBackgroundColor())
                }
            }
        }

        return colors
    }

    func dotMarker(sizeOnDayView dayView: DayView) -> CGFloat {
        return CGFloat(14)
    }

    func presentedDateUpdated(date: CVDate) {
        setNavBarTitleDate(date.convertedDate())
    }
}

extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let calendarSection = CalendarSection(rawValue: section) else {
            return nil
        }

        switch calendarSection {
        case .Minerva:
            return "Minerva Lessenrooster"
        case .Associations:
            return "Studentenactiviteiten"
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let calendarSection = CalendarSection(rawValue: section) else {
            return 0
        }
        if let date = selectedDay.convertedDate() {
            switch calendarSection {
            case .Minerva:
                if let calendarItems = self.minervaCalendarItems, let items = calendarItems[date] {
                    return items.count
                }
            case .Associations:
                if let associationCalendarItems = self.associationCalendarItems, let items = associationCalendarItems[date] {
                    return items.count
                }
            }
        }
        return 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let calendarSection = CalendarSection(rawValue: indexPath.section), let date = selectedDay.convertedDate() else {
            return UITableViewCell()
        }

        func cellIdentifier(startDate: NSDate, endDate: NSDate?) -> String {
            let start = startDate.dateAtStartOfDay()
            let end = endDate?.dateAtStartOfDay()
            if (end != nil && (start == end! || start == end!.dateBySubtractingDays(1))) {
                return "hourCalendarCell"
            } else if end == nil || start == date {
                return "startDayCell"
            } else if end! == date {
                return "endDayCell"
            } else {
                return "allDayCell"
            }
        }

        var calendarItem: CalendarItem?
        var activity: Activity?
        let identifier: String

        switch calendarSection {
        case .Minerva:
            guard let calendarItems = self.minervaCalendarItems, let items = calendarItems[date] else {
                return UITableViewCell()
            }
            
            calendarItem = items[indexPath.row]
            identifier = cellIdentifier(calendarItem!.startDate, endDate: calendarItem?.endDate)
        case .Associations:
            guard let associationCalendarItems = self.associationCalendarItems, let items = associationCalendarItems[date] else {
                return UITableViewCell()
            }

            activity = items[indexPath.row]
            identifier = cellIdentifier(activity!.start, endDate: activity!.end)
        }

        let cell = tableView.dequeueReusableCellWithIdentifier(identifier) as! CalendarSingleTableViewCell
        cell.calendarItem = calendarItem
        cell.activity = activity

        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let calendarSection = CalendarSection(rawValue: indexPath.section), let date = selectedDay.convertedDate() else {
            return
        }

        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)

        switch calendarSection {
        case .Minerva:
            if let calendarItems = self.minervaCalendarItems, let items = calendarItems[date] {
                let item = items[indexPath.row]
                if item.content != nil {
                    self.performSegueWithIdentifier("calendarDetailSegue", sender: item)
                }
            }
        case .Associations:
            guard let associationCalendarItems = self.associationCalendarItems, let items = associationCalendarItems[date] else {
                return
            }
            let activity = items[indexPath.row]
            let detailViewController = ActivityDetailController(activity: activity, delegate: nil)

            self.navigationController?.pushViewController(detailViewController, animated: true)
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "calendarDetailSegue" {
            guard let vc = segue.destinationViewController as? MinervaCalendarDetailViewController else { return }

            vc.calendarItem = sender as? CalendarItem
        }
    }
}

extension CalendarViewController {
    @IBAction func swipeLeft() {
        var date = selectedDay.convertedDate()!

        date = date.dateByAddingDays(1)
        calendarView.toggleViewWithDate(date)
    }

    @IBAction func swipeRight() {
        var date = selectedDay.convertedDate()!

        date = date.dateBySubtractingDays(1)
        calendarView.toggleViewWithDate(date)
    }

    @IBAction func todayButton() {
        calendarView.toggleViewWithDate(NSDate())
    }
}

enum CalendarSection: Int {
    case Minerva = 0, Associations = 1
}