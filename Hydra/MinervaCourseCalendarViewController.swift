//
//  MinervaCourseCalendarViewController.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 14/08/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import UIKit
import CVCalendar

class MinervaCourseCalendarViewController: UIViewController {
    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var calendarView: CVCalendarView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectedDayLabel: UILabel!
    var selectedDay:CVDate = CVDate(date: NSDate()) {
        didSet {
            self.tableView.reloadData()
        }
    }

    var calendarItems: [NSDate: [CalendarItem]]?
    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        selectedDay = CVDate(day: 20, month: 9, week: 0, year: 2015)
        calendarView.presentedDate = selectedDay
        calendarView.toggleViewWithDate(selectedDay.convertedDate()!)
        setNavBarTitle(selectedDay.globalDescription)

        self.tableView.tableFooterView = UIView()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.calendarItems = MinervaStore.sharedStore.sortedByDate()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        menuView.commitMenuViewUpdate()
        calendarView.commitCalendarViewUpdate()
    }

    func setNavBarTitle(title: String) {
        self.title = title
        self.navigationController?.tabBarItem.title = "Lessenrooster"
    }
}

extension MinervaCourseCalendarViewController: CVCalendarViewDelegate, CVCalendarMenuViewDelegate {

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
        selectedDayLabel.text = dayView.date.commonDescription
        selectedDay = dayView.date
    }

    func dotMarker(shouldShowOnDayView dayView: DayView) -> Bool {
        if let date = dayView.date.convertedDate(), let calendarItems = self.calendarItems, let items = calendarItems[date] {
            return items.count > 0
        }

        return false
    }

    func dotMarker(colorOnDayView dayView: DayView) -> [UIColor] {
        return [UIColor.hydraTintcolor()]
    }

    func dotMarker(sizeOnDayView dayView: DayView) -> CGFloat {
        if let date = dayView.date.convertedDate(), let calendarItems = self.calendarItems, let items = calendarItems[date] {
            return CGFloat(min(items.count*2 + 10, 18))
        }

        return CGFloat(14)
    }

    func presentedDateUpdated(date: CVDate) {
        setNavBarTitle(date.globalDescription)
    }
}

extension MinervaCourseCalendarViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let date = selectedDay.convertedDate(), let calendarItems = self.calendarItems, let items = calendarItems[date] {
            return items.count
        }
        return 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("hourCalendarCell") as! MinervaCourseCalendarSingleTableViewCell

        if let date = selectedDay.convertedDate(), let calendarItems = self.calendarItems, let items = calendarItems[date] {
            let item = items[indexPath.row] 
            cell.calendarItem = item
        }

        return cell
    }

}

extension MinervaCourseCalendarViewController {
    @IBAction func swipeLeft() {
        var date = selectedDay.convertedDate()!

        date = date.dateByAddingDays(1)
        calendarView.toggleViewWithDate(date)
        selectedDay = CVDate(date: date)
    }

    @IBAction func swipeRight() {
        var date = selectedDay.convertedDate()!

        date = date.dateBySubtractingDays(1)
        calendarView.toggleViewWithDate(date)
        selectedDay = CVDate(date: date)
    }
}