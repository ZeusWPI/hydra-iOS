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

    fileprivate var courses: [Course] = []
    fileprivate var unselectedCourses = PreferencesService.sharedService.unselectedMinervaCourses

    fileprivate var selectAllBarButtonItem: UIBarButtonItem?

    init() {
        super.init(style: .plain)
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(MinervaCoursePreferenceViewController.loadMinervaCourses), name: NSNotification.Name(rawValue: MinervaStoreDidUpdateCoursesNotification), object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func loadMinervaCourses() {
        DispatchQueue.main.async {
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
        refreshControl.addTarget(self, action: #selector(MinervaCoursePreferenceViewController.didPullRefreshControl), for: .valueChanged)

        self.refreshControl = refreshControl

        selectAllBarButtonItem = UIBarButtonItem(title: "Selecteer alles", style: .plain, target: self, action: #selector(MinervaCoursePreferenceViewController.selectAllCourses))
        if courses.count > 0 && unselectedCourses.contains(courses[0].internalIdentifier!) {
            selectAllBarButtonItem?.title = "Deselecteer alles"
        }
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.rightBarButtonItem = selectAllBarButtonItem

        loadMinervaCourses()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        NotificationCenter.default.post(name: Notification.Name(rawValue: PreferencesControllerDidUpdatePreferenceNotification), object: nil)
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        GAI_track("Voorkeuren > Vakken")

        if courses.count == 0 {
            SVProgressHUD.show()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SVProgressHUD.dismiss()
    }

    // MARK: Tableview methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "MinervaCoursePreferenceCell"
        let course = courses[(indexPath as NSIndexPath).row]

        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        }

        cell?.textLabel?.text = course.title
        let tutorName = NSMutableAttributedString(attributedString: course.tutorName!.html2AttributedString!)
        tutorName.addAttribute(NSFontAttributeName, value: cell!.detailTextLabel!.font, range: NSMakeRange(0, tutorName.length))
        cell?.detailTextLabel?.attributedText = tutorName

        if let identifier = course.internalIdentifier, unselectedCourses.contains(identifier) {
            cell?.accessoryType = .none
        } else {
            cell?.accessoryType = .checkmark
        }

        return cell!
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let course = self.courses[(indexPath as NSIndexPath).row]
        if let id = course.internalIdentifier {
            if unselectedCourses.contains(id) {
                self.unselectedCourses.remove(id)
            } else {
                self.unselectedCourses.insert(id)
            }
            self.tableView.reloadRows(
                at: [indexPath], with: .automatic)
            PreferencesService.sharedService.unselectedMinervaCourses = unselectedCourses
        }
    }

}
