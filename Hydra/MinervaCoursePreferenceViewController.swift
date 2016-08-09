//
//  MinervaCoursePreferenceViewController.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 26/07/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation
import SVProgressHUD

class MinervaCoursePreferenceViewController: UITableViewController {

    private var courses: [Course] = []
    private var unselectedCourses = PreferencesService.sharedService.unselectedMinervaCourses

    private var selectAllBarButtonItem: UIBarButtonItem?

    init() {
        super.init(style: .Plain)
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: #selector(MinervaCoursePreferenceViewController.loadMinervaCourses), name: MinervaStoreDidUpdateCoursesNotification, object: nil)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func loadMinervaCourses() {
        dispatch_async(dispatch_get_main_queue()) {
            self.courses = MinervaStore.sharedStore.courses
            self.tableView.reloadData()

            if self.courses.count > 0 {
                SVProgressHUD.dismiss()
            }

            self.refreshControl?.endRefreshing()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Cursussen"

        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.hydraTintcolor()
        refreshControl.addTarget(self, action: #selector(MinervaCoursePreferenceViewController.didPullRefreshControl), forControlEvents: .ValueChanged)

        self.refreshControl = refreshControl

        selectAllBarButtonItem = UIBarButtonItem(title: "Selecteer alles", style: .Plain, target: self, action: #selector(MinervaCoursePreferenceViewController.selectAllCourses))
        if courses.count > 0 && unselectedCourses.contains(courses[0].internalIdentifier!) {
            selectAllBarButtonItem?.title = "Deselecteer alles"
        }
        self.navigationItem.rightBarButtonItem = selectAllBarButtonItem

        loadMinervaCourses()
    }

    func selectAllCourses() {
        if courses.count > 0 && unselectedCourses.contains(courses[0].internalIdentifier!) {
            self.unselectedCourses = Set()
            selectAllBarButtonItem?.title = "Deselecteer alles"
        } else {
            for course in courses {
                unselectedCourses.insert(course.internalIdentifier!)
            }
            selectAllBarButtonItem?.title = "Selecteer alles"
        }
        self.tableView.reloadData()
        PreferencesService.sharedService.unselectedMinervaCourses = unselectedCourses
    }


    func didPullRefreshControl() {
        MinervaStore.sharedStore.updateCourses(true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        GAI_track("Voorkeuren > Vakken")

        if courses.count == 0 {
            SVProgressHUD.show()
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        SVProgressHUD.dismiss()
    }

    // MARK: Tableview methods
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "MinervaCoursePreferenceCell"
        let course = courses[indexPath.row]

        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellIdentifier)
        }

        cell?.textLabel?.text = course.title
        let tutorName = NSMutableAttributedString(attributedString: course.tutorName!.html2AttributedString!)
        tutorName.addAttribute(NSFontAttributeName, value: cell!.detailTextLabel!.font, range: NSMakeRange(0, tutorName.length))
        cell?.detailTextLabel?.attributedText = tutorName

        if let identifier = course.internalIdentifier where unselectedCourses.contains(identifier) {
            cell?.accessoryType = .None
        } else {
            cell?.accessoryType = .Checkmark
        }

        return cell!
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let course = self.courses[indexPath.row]
        if let id = course.internalIdentifier {
            if unselectedCourses.contains(id) {
                self.unselectedCourses.remove(id)
            } else {
                self.unselectedCourses.insert(id)
            }
            self.tableView.reloadRowsAtIndexPaths(
                [indexPath], withRowAnimation: .Automatic)
            PreferencesService.sharedService.unselectedMinervaCourses = unselectedCourses
        }
    }

}