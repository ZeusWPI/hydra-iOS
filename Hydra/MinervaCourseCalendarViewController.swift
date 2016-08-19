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
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        selectedDay = CVDate(day: 20, month: 9, week: 0, year: 2015)
        calendarView.presentedDate = selectedDay
        calendarView.toggleViewWithDate(selectedDay.convertedDate()!)
        setNavBarTitle(selectedDay.globalDescription)

        // only show rows that are filled
        self.tableView.tableFooterView = UIView()
        // only scroll when content doesn't fit the whole screen
        self.tableView.alwaysBounceVertical = false
        self.tableView.estimatedRowHeight = 75
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MinervaCourseCalendarViewController.calendarUpdated), name: MinervaStoreDidUpdateCourseInfoNotification, object: nil)
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

    func setNavBarTitle(title: String) {
        self.title = title
        self.navigationController?.tabBarItem.title = "Lessenrooster"
    }

    func calendarUpdated() {
        self.calendarItems = MinervaStore.sharedStore.sortedByDate()
        self.calendarView.contentController.refreshPresentedMonth()
        self.tableView.reloadData()
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
        return false
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
    }

    @IBAction func swipeRight() {
        var date = selectedDay.convertedDate()!

        date = date.dateBySubtractingDays(1)
        calendarView.toggleViewWithDate(date)
    }

    @IBAction func todayButton() {
        var date = NSDate()

        calendarView.toggleViewWithDate(date)
    }
}