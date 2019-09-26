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
                    TimelineSetting(name: "Verenigingsnieuws", defaultPref: PreferencesService.PropertyKey.showNewsInFeedKey),
                    TimelineSetting(name: "Activiteiten", defaultPref: PreferencesService.PropertyKey.showActivitiesInFeedKey),
                    TimelineSetting(name: "Uitgelichte activiteiten", defaultPref: PreferencesService.PropertyKey.showSpecialEventsInFeedKey)
                    ]

    @IBAction func startHydra() {
        PreferencesService.sharedService.firstLaunch = false
        let vc = UIStoryboard(name: "MainStoryboard", bundle: nil).instantiateInitialViewController()!
        UIApplication.shared.windows[0].rootViewController = vc
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.isNavigationBarHidden = true
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return settings.count
        case 1:
            return 2
        default:
            fatalError("Tableview has only 2 sections")
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath as NSIndexPath).section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "timelineSettingsCell") as! TimeLineTableViewCell

            cell.timeLineSetting = settings[(indexPath as NSIndexPath).row]

            return cell
        case 1:
            if (indexPath as NSIndexPath).row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "timelineSettingsCell") as! TimeLineTableViewCell

                cell.timeLineSetting = TimelineSetting(name: "Toon alle verenigingen", defaultPref: PreferencesService.PropertyKey.filterAssociationsKey, switched: true) { (state: Bool) -> () in
                    self.tableView?.reloadData()
                }

                return cell
            } else {
                let cell = UITableViewCell(style: .default, reuseIdentifier: nil)

                cell.textLabel?.text = "Selecteer verenigingen"
                cell.textLabel?.textColor = UIColor.white
                cell.backgroundColor = UIColor.clear

                cell.accessoryType = .disclosureIndicator

                if !PreferencesService.sharedService.filterAssociations {
                    cell.textLabel?.alpha = 0.5
                    cell.detailTextLabel?.alpha = 0.5
                    cell.selectionStyle = .none
                    cell.accessoryType = .none
                }
                return cell
            }
        default:
            fatalError()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 1 {
            if PreferencesService.sharedService.filterAssociations {
                let c = AssociationPreferenceController()
                if let navigationController = self.navigationController {
                    navigationController.isNavigationBarHidden = false
                    navigationController.pushViewController(c, animated: true)
                }
            }
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
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
