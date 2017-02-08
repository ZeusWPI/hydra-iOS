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

    fileprivate var courses = MinervaStore.sharedStore.filteredCourses

    fileprivate let dateTransformer = SORelativeDateTransformer()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        sharedInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }

    fileprivate func sharedInit() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(MinervaAnnouncementController.minervaNotification), name: NSNotification.Name(rawValue: MinervaStoreDidUpdateCourseInfoNotification), object: nil)
        notificationCenter.addObserver(self, selector: #selector(MinervaAnnouncementController.minervaNotification), name: NSNotification.Name(rawValue: MinervaStoreDidUpdateCoursesNotification), object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func minervaNotification() {
        DispatchQueue.main.async {
            self.courses = MinervaStore.sharedStore.filteredCourses
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()

            self.navigationItem.rightBarButtonItem?.isEnabled = self.courses.count > 0
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        for course in courses {
            MinervaStore.sharedStore.updateAnnouncements(course)
        }

        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.hydraTintcolor()
        refreshControl.addTarget(self, action: #selector(MinervaAnnouncementController.didPullRefreshControl), for: .valueChanged)

        self.refreshControl = refreshControl

        let button = UIBarButtonItem(title: "Cursus", style: .plain, target: self, action: #selector(MinervaAnnouncementController.pickerBarButtonPressed))
        self.navigationItem.rightBarButtonItem = button
        self.navigationItem.rightBarButtonItem?.isEnabled = self.courses.count > 0
    }

    func didPullRefreshControl() {
        self.courses = MinervaStore.sharedStore.filteredCourses
        for course in courses {
            MinervaStore.sharedStore.updateAnnouncements(course, forcedUpdate: true)
        }

        self.tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return courses.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let announcements = MinervaStore.sharedStore.announcement(courses[section]) {
            return min(announcements.count, 10)
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return courses[section].title
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let course = courses[(indexPath as NSIndexPath).section]

        if let announcements = MinervaStore.sharedStore.announcement(course) {
            guard (indexPath as NSIndexPath).row < announcements.count else {
                return UITableViewCell()
            }
            let announcement = announcements[(indexPath as NSIndexPath).row]
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
            cell.textLabel?.text = announcement.title

            cell.detailTextLabel?.text = dateTransformer.transformedValue(announcement.date) as! String?
            return cell
        }

        return UITableViewCell()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let course = courses[(indexPath as NSIndexPath).section]
        if let announcements = MinervaStore.sharedStore.announcement(course) {
            let announcement = announcements[(indexPath as NSIndexPath).row]
            let storyboard = UIStoryboard(name: "MainStoryboard", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "minerva-detail-controller") as! MinervaAnnounceDetailViewController

            vc.announcement = announcement
            self.navigationController?.pushViewController(vc, animated: true)
        }

    }

    // MARK: Implement UIPickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return courses.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return courses[row].title
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let course = self.courses[row]
        let announcements = MinervaStore.sharedStore.announcement(course)
        if let announcements = announcements, announcements.count > 0 {
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: row), at: .top, animated: true)
        }
    }

    func pickerBarButtonPressed() {
        let selectAction = RMAction(title: "Selecteer", style: .done) { (rma) in

        }

        let pickerController = RMPickerViewController(style: .default)
        pickerController?.picker.delegate = self
        pickerController?.picker.dataSource = self //TODO: fixme
        pickerController?.disableBlurEffects = true
        /*let actionController = pickerController as? RMActionController?
        actionController?.addAction(selectAction)

        if let tabBarController = self.tabBarController {
            tabBarController.present(pickerController!, animated: true, completion: nil)

        } else {
            self.present(pickerController!, animated: true, completion: nil)
        }*/
    }
}
