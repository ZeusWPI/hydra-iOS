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
    var selectedDay:CVDate = CVDate(date: Date()) {
        didSet {
            UIView.transition(with: tableView, duration: 0.8, options: .transitionCrossDissolve, animations: {self.tableView.reloadData()}, completion: nil)
        }
    }

    var minervaCalendarItems: [Date: [CalendarItem]]?
    var associationCalendarItems: [Date: [Activity]]?

    // MARK: - Life cycle
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        selectedDay = CVDate(date: Date())
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(CalendarViewController.calendarUpdated), name: NSNotification.Name(rawValue: MinervaStoreDidUpdateCourseInfoNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CalendarViewController.loadAssociatonActivities), name: NSNotification.Name(rawValue: AssociationStoreDidUpdateActivitiesNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CalendarViewController.reloadCalendarData), name: NSNotification.Name(rawValue: PreferencesControllerDidUpdatePreferenceNotification), object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.calendarUpdated()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        menuView.commitMenuViewUpdate()
        calendarView.commitCalendarViewUpdate()
    }

    func setNavBarTitleDate(_ date: Date?) {
        guard let date = date else {
            setNavBarTitle("")
            return
        }

        let dateFormatter = DateFormatter.h_dateFormatterWithAppLocale()
        dateFormatter?.dateFormat = "MMMM YYYY"

        setNavBarTitle((dateFormatter?.string(from: date))!)
    }

    func setNavBarTitle(_ title: String) {
        self.title = title
        self.navigationController?.tabBarItem.title = "Agenda"
    }

    func reloadCalendarData() {
        calendarUpdated()
        loadAssociatonActivities()
    }

    func calendarUpdated() {
        DispatchQueue.main.async {
            self.minervaCalendarItems = MinervaStore.sharedStore.sortedByDate() as [Date : [CalendarItem]]?
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

        var grouped = [Date: [Activity]]()
        for activity in activities {
            let date: NSDate = (activity.start as NSDate).atStartOfDay() as NSDate
            if case nil = grouped[date as Date]?.append(activity) {
                grouped[date as Date] = [activity]
            }

            guard let end = activity.end else { continue }
            let endDay = (end as NSDate).atStartOfDay() as Date
            if endDay > date as Date {
                var nextDate: Date = (date as NSDate).addingDays(1)
                while (nextDate as NSDate).addingHours(8) <= endDay {
                    if case nil = grouped[nextDate]?.append(activity) {
                        grouped[nextDate] = [activity]
                    }
                    
                    nextDate = (nextDate as NSDate).addingDays(1)
                }
            }
        }

        for (k, _) in grouped {
            var activitiesDay = grouped[k]!
            activitiesDay.sort(by: { $0.start <= $1.start })
        }

        DispatchQueue.main.async {
            self.associationCalendarItems = grouped
            self.calendarView.contentController.refreshPresentedMonth()
            self.tableView.reloadData()
        }
    }
}

extension CalendarViewController: CVCalendarViewDelegate, CVCalendarMenuViewDelegate {

    func presentationMode() -> CalendarMode {
        return .weekView
    }

    func firstWeekday() -> Weekday {
        return .monday
    }

    func shouldShowWeekdaysOut() -> Bool {
        return true
    }

    func didSelectDayView(_ dayView: DayView, animationDidFinish: Bool) {
        debugPrint("\(dayView.date.commonDescription) is selected!")
        guard let date = dayView.date.convertedDate() else { return }

        selectedDay = dayView.date

        let dateFormatter = DateFormatter.h_dateFormatterWithAppLocale()
        dateFormatter?.dateFormat = "EEEE d MMMM"
        selectedDayLabel.text = dateFormatter?.string(from: date)
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

    func presentedDateUpdated(_ date: CVDate) {
        setNavBarTitleDate(date.convertedDate())
    }
}

extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let calendarSection = CalendarSection(rawValue: section) else {
            return nil
        }

        switch calendarSection {
        case .minerva:
            return "Minerva Lessenrooster"
        case .associations:
            return "Studentenactiviteiten"
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let calendarSection = CalendarSection(rawValue: section) else {
            return 0
        }
        if let date = selectedDay.convertedDate() {
            switch calendarSection {
            case .minerva:
                if let calendarItems = self.minervaCalendarItems, let items = calendarItems[date] {
                    return items.count
                }
            case .associations:
                if let associationCalendarItems = self.associationCalendarItems, let items = associationCalendarItems[date] {
                    return items.count
                }
            }
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let calendarSection = CalendarSection(rawValue: (indexPath as NSIndexPath).section), let date = selectedDay.convertedDate() else {
            return UITableViewCell()
        }

        func cellIdentifier(_ startDate: Date, endDate: Date?) -> String {
            let start = (startDate as NSDate).atStartOfDay()
            let end = (endDate as NSDate?)?.atStartOfDay()
            if (end != nil && (start == end! || start == (end! as NSDate).subtractingDays(1))) {
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
        case .minerva:
            guard let calendarItems = self.minervaCalendarItems, let items = calendarItems[date] else {
                return UITableViewCell()
            }
            
            calendarItem = items[indexPath.row]
            identifier = cellIdentifier(calendarItem!.startDate as Date, endDate: calendarItem?.endDate as Date?)
        case .associations:
            guard let associationCalendarItems = self.associationCalendarItems, let items = associationCalendarItems[date] else {
                return UITableViewCell()
            }

            activity = items[indexPath.row]
            identifier = cellIdentifier(activity!.start as Date, endDate: activity!.end as Date?)
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as! CalendarSingleTableViewCell
        cell.calendarItem = calendarItem
        cell.activity = activity

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let calendarSection = CalendarSection(rawValue: (indexPath as NSIndexPath).section), let date = selectedDay.convertedDate() else {
            return
        }

        self.tableView.deselectRow(at: indexPath, animated: true)

        switch calendarSection {
        case .minerva:
            if let calendarItems = self.minervaCalendarItems, let items = calendarItems[date] {
                let item = items[indexPath.row]
                if item.content != nil {
                    self.performSegue(withIdentifier: "calendarDetailSegue", sender: item)
                }
            }
        case .associations:
            guard let associationCalendarItems = self.associationCalendarItems, let items = associationCalendarItems[date] else {
                return
            }
            let activity = items[indexPath.row]
            let detailViewController = ActivityDetailController(activity: activity, delegate: nil)

            self.navigationController?.pushViewController(detailViewController!, animated: true)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "calendarDetailSegue" {
            guard let vc = segue.destination as? MinervaCalendarDetailViewController else { return }

            vc.calendarItem = sender as? CalendarItem
        }
    }
}

extension CalendarViewController {
    @IBAction func swipeLeft() {
        var date = selectedDay.convertedDate()!

        date = (date as NSDate).addingDays(1)
        calendarView.toggleViewWithDate(date)
    }

    @IBAction func swipeRight() {
        var date = selectedDay.convertedDate()!

        date = (date as NSDate).subtractingDays(1)
        calendarView.toggleViewWithDate(date)
    }

    @IBAction func todayButton() {
        calendarView.toggleViewWithDate(Date())
    }
}

enum CalendarSection: Int {
    case minerva = 0, associations = 1
}
