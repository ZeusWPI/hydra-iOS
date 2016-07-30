//
//  MinervaCoursePreferenceViewController.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 26/07/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation

class MinervaCoursePreferenceViewController: UITableViewController {

    private var courses: [Course] = []
    private var selectedCourses: [String]?

    init() {
        super.init(style: .Plain)
    }

    func loadMinervaCourses() {

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Vakken"
    }

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        GAI_track("Voorkeuren > Vakken")
    }

    // MARK: Tableview methods
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "MinervaCoursePreferenceCell"
        let course = courses[indexPath.row]

        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        if cell == nil{
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellIdentifier)
        }

        cell?.textLabel?.text = course.title
        cell?.detailTextLabel?.text = course.tutorName // TODO: html to text
        
        if let selectedCourses = self.selectedCourses, let identifier = course.internalIdentifier where selectedCourses.contains(identifier) {
            cell?.accessoryType = .Checkmark
        } else {
            cell?.accessoryType = .None
        }

        return cell!
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

    }

}