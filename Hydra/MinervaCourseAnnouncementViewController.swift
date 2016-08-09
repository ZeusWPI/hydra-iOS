//
//  MinervaCourseAnnouncementViewController.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 26/07/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation

class MinervaAnnouncementController: UITableViewController {

    private var courses = MinervaStore.sharedStore.courses

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
            self.courses = MinervaStore.sharedStore.courses
            self.tableView.reloadData()
        }

        self.refreshControl?.endRefreshing()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        for course in courses {
            MinervaStore.sharedStore.updateWhatsnew(course)
        }

        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.hydraTintcolor()
        refreshControl.addTarget(self, action: #selector(MinervaAnnouncementController.didPullRefreshControl), forControlEvents: .ValueChanged)

        self.refreshControl = refreshControl

    }

    func didPullRefreshControl() {
        self.courses = MinervaStore.sharedStore.courses
        for course in courses {
            MinervaStore.sharedStore.updateWhatsnew(course, forcedUpdate: true)
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
            let announcement = announcements[indexPath.row]
            let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "Cell")
            cell.textLabel?.text = announcement.title

            cell.detailTextLabel?.text = dateTransformer.transformedValue(announcement.date) as! String?
            return cell
        }

        return UITableViewCell()
    }
}