//
//  MinervaCourseAnnouncementViewController.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 26/07/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation
import RMPickerViewController

class MinervaAnnouncementController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    private var courses = MinervaStore.sharedStore.filteredCourses

    private let dateTransformer = SORelativeDateTransformer()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        sharedInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }

    private func sharedInit() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(MinervaAnnouncementController.minervaNotification), name: MinervaStoreDidUpdateCourseInfoNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(MinervaAnnouncementController.minervaNotification), name: MinervaStoreDidUpdateCoursesNotification, object: nil)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func minervaNotification() {
        dispatch_async(dispatch_get_main_queue()) {
            self.courses = MinervaStore.sharedStore.filteredCourses
            self.tableView.reloadData()
        }

        self.refreshControl?.endRefreshing()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        for course in courses {
            MinervaStore.sharedStore.updateAnnouncements(course)
        }

        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.hydraTintcolor()
        refreshControl.addTarget(self, action: #selector(MinervaAnnouncementController.didPullRefreshControl), forControlEvents: .ValueChanged)

        self.refreshControl = refreshControl

        let button = UIBarButtonItem(title: "Cursus", style: .Plain, target: self, action: #selector(MinervaAnnouncementController.pickerBarButtonPressed))
        self.navigationItem.rightBarButtonItem = button

    }

    func didPullRefreshControl() {
        self.courses = MinervaStore.sharedStore.filteredCourses
        for course in courses {
            MinervaStore.sharedStore.updateAnnouncements(course, forcedUpdate: true)
        }

        self.tableView.reloadData()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return courses.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let announcements = MinervaStore.sharedStore.announcement(courses[section]) {
            return min(announcements.count, 10)
        }
        return 0
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return courses[section].title
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let course = courses[indexPath.section]

        if let announcements = MinervaStore.sharedStore.announcement(course) {
            guard indexPath.row < announcements.count else {
                return UITableViewCell()
            }
            let announcement = announcements[indexPath.row]
            let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "Cell")
            cell.textLabel?.text = announcement.title

            cell.detailTextLabel?.text = dateTransformer.transformedValue(announcement.date) as! String?
            return cell
        }

        return UITableViewCell()
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let course = courses[indexPath.section]
        if let announcements = MinervaStore.sharedStore.announcement(course) {
            let announcement = announcements[indexPath.row]
            let storyboard = UIStoryboard(name: "MainStoryboard", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("minerva-detail-controller") as! MinervaAnnounceDetailViewController

            vc.announcement = announcement
            self.navigationController?.pushViewController(vc, animated: true)
        }

    }

    // MARK: Implement UIPickerView
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return courses.count
    }

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return courses[row].title
    }

    func pickerBarButtonPressed() {
        let selectAction = RMAction(title: "Selecteer", style: .Done) { (rma) in
            if let rmpvc = rma as? RMPickerViewController {
                let selectedSection = rmpvc.picker.selectedRowInComponent(0)
                let course = self.courses[selectedSection]
                let announcements = MinervaStore.sharedStore.announcement(course)
                if let announcements = announcements where announcements.count > 0 {
                    self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: selectedSection), atScrollPosition: .Top, animated: true)
                }
            }
        }

        let pickerController = RMPickerViewController(style: RMActionControllerStyle.Default, selectAction: selectAction, andCancelAction: nil)
        pickerController?.picker.delegate = self
        pickerController?.picker.dataSource = self

        if let tabBarController = self.tabBarController {
            tabBarController.presentViewController(pickerController!, animated: true, completion: nil)

        } else {
            self.presentViewController(pickerController!, animated: true, completion: nil)
        }
    }
}