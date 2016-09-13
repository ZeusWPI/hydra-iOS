//
//  TimelineOnboardViewController.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 12/09/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation

class TimelineOnboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView?

    var settings = [TimelineSetting(name: "Resto menu", defaultPref: PreferencesService.PropertyKey.showRestoInFeedKey),
                    TimelineSetting(name: "Schamper Daily", defaultPref: PreferencesService.PropertyKey.showSchamperInFeedKey),
                    TimelineSetting(name: "Urgent.fm", defaultPref: PreferencesService.PropertyKey.showUrgentfmInFeedKey),
                    TimelineSetting(name: "Verenigingsnieuws", defaultPref: PreferencesService.PropertyKey.showNewsInFeedKey),
                    TimelineSetting(name: "Activiteiten", defaultPref: PreferencesService.PropertyKey.showActivitiesInFeedKey),
                    TimelineSetting(name: "Uitgelichte activiteiten", defaultPref: PreferencesService.PropertyKey.showSpecialEventsInFeedKey)
                    ]

    @IBAction func startHydra() {
        #if RELEASE
            PreferencesService.sharedService.firstLaunch = false
        #endif
        let vc = UIStoryboard(name: "MainStoryboard", bundle: nil).instantiateInitialViewController()!
        UIApplication.sharedApplication().windows[0].rootViewController = vc
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.navigationBarHidden = true
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return settings.count
        case 1:
            return 2
        default:
            fatalError("Tableview has only 2 sections")
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("timelineSettingsCell") as! TimeLineTableViewCell

            cell.timeLineSetting = settings[indexPath.row]

            return cell
        case 1:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("timelineSettingsCell") as! TimeLineTableViewCell

                cell.timeLineSetting = TimelineSetting(name: "Toon maar enkele verenigingen", defaultPref: PreferencesService.PropertyKey.filterAssociationsKey)
                
                return cell
            } else {
                let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)

                cell.textLabel?.text = "Selecteer verenigingen"
                cell.textLabel?.textColor = UIColor.whiteColor()
                cell.backgroundColor = UIColor.clearColor()

                cell.accessoryType = .DisclosureIndicator
                return cell
            }
        default:
            fatalError()
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 && indexPath.row == 1 {
            if PreferencesService.sharedService.filterAssociations {
                let c = AssociationPreferenceController()
                if let navigationController = self.navigationController {
                    navigationController.navigationBarHidden = false
                    navigationController.pushViewController(c, animated: true)
                }
            }
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
        }
    }

    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Feed instellingen"
        case 1:
            return "Verenigingen selecteren"
        default:
            return nil
        }
    }
}