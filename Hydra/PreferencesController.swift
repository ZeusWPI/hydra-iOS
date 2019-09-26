//
//  PreferencesController.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 06/07/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import UIKit
import AcknowList
import Firebase

let PreferencesControllerDidUpdatePreferenceNotification = "PreferencesControllerDidUpdatePreference"

class PreferencesController: UITableViewController {

    var showRestoPicker = false {
        didSet {
            if let tableView = tableView {
                tableView.reloadData()
            }
        }
    }

    init() {
        super.init(style: UITableView.Style.grouped)
        let center = NotificationCenter.default
        let notifications = [FacebookEventDidUpdateNotification, FacebookUserInfoUpdatedNotifcation, RestoStoreDidUpdateInfoNotification]
        for notification in notifications {
            center.addObserver(self, selector: #selector(PreferencesController.updateState), name: NSNotification.Name(rawValue: notification), object: nil)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func updateState() {
        self.tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Voorkeuren"

        func registerNib(_ nibName: String, reuseIdentifier: String) {
            let nib = UINib.init(nibName: nibName, bundle: nil)
            self.tableView.register(nib, forCellReuseIdentifier: reuseIdentifier)
        }

        registerNib("PreferencesExtraTableViewCells", reuseIdentifier: "PreferenceExtraCell")
        registerNib("PreferencesSwitchTableViewCells", reuseIdentifier: "PreferenceSwitchCell")
        registerNib("PreferencesTextTableViewCell", reuseIdentifier: "PreferencesTextTableViewCell")
        registerNib("PreferencesPickerViewTableViewCell", reuseIdentifier: "preferencesPickerViewTableViewCell")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        GAI_track("Voorkeuren")
        self.tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return [Sections.activity, Sections.feed, Sections.notification, Sections.info].count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = Sections(rawValue: section)
        if let section = section {
            switch section {
            case .resto:
                return showRestoPicker ? 2 : 1
            case .activity:
                return 2
            case .feed:
                return 5
            case .notification:
                return 1
            case .info:
                return 3
            }
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let section = Sections(rawValue: (indexPath as NSIndexPath).section) {
            switch section {
            case .resto:
                if indexPath.row == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "PreferenceExtraCell") as! PreferenceExtraTableViewCell
                    cell.configure("Toon menu van?", detailText: RestoStore.shared.selectedResto.name)
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "preferencesPickerViewTableViewCell") as! PreferencesPickerViewTableViewCell
                    cell.options = RestoStore.shared.locations.filter({ $0.endpoint != nil })
                    cell.optionSelectedClosure = { (titleObject: TitleProtocol) -> () in
                        if let restoLocation = titleObject as? RestoLocation {
                            RestoStore.shared.selectedResto = restoLocation
                            RestoStore.shared.markStorageOutdated()
                            RestoStore.shared.saveLater()
                        }
                    }
                    return cell
                }

            case .activity:
                let prefs = PreferencesService.sharedService
                if let activityS = ActivitySection(rawValue: (indexPath as NSIndexPath).row) {
                    switch activityS {
                    case .showAll:
                        let cell = tableView.dequeueReusableCell(withIdentifier: "PreferenceSwitchCell") as! PreferenceSwitchTableViewCell
                        cell.configure("Toon alle verenigingen", condition: !prefs.filterAssociations, toggleClosure: { (newState) in
                            PreferencesService.sharedService.filterAssociations = !newState
                            self.tableView.reloadData()
                        })
                        return cell
                    case .select:
                        let detailText: String
                        let count = prefs.preferredAssociations.count
                        let cell = tableView.dequeueReusableCell(withIdentifier: "PreferenceExtraCell") as! PreferenceExtraTableViewCell
                        if count > 1 {
                            detailText = "\(count) verenigingen"
                        } else if count == 1 {
                            detailText = "1 vereniging"
                        } else {
                            detailText = "geen geselecteerd"
                        }

                        cell.configure("Selectie", detailText: detailText)
                        if !prefs.filterAssociations {
                            cell.setDisabled()
                        }

                        return cell
                    }
                }
            case .feed:
                let prefs = PreferencesService.sharedService
                let cell = tableView.dequeueReusableCell(withIdentifier: "PreferenceSwitchCell") as! PreferenceSwitchTableViewCell
                if let feedSection = FeedSection(rawValue: (indexPath as NSIndexPath).row) {
                    switch feedSection {
                    case .activities:
                        cell.configure("Toon activiteiten", condition: prefs.showActivitiesInFeed, toggleClosure: { (newState) in
                            PreferencesService.sharedService.showActivitiesInFeed = newState
                            self.tableView.reloadData()
                        })
                    case .news:
                        cell.configure("Toon verenigingen nieuws", condition: prefs.showNewsInFeed, toggleClosure: { (newState) in
                            PreferencesService.sharedService.showNewsInFeed = newState
                            self.tableView.reloadData()
                        })
                    case .schamper:
                        cell.configure("Toon Schamper Dailies", condition: prefs.showSchamperInFeed, toggleClosure: { (newState) in
                            PreferencesService.sharedService.showSchamperInFeed = newState
                            self.tableView.reloadData()
                        })
                    case .resto:
                        cell.configure("Toon de resto menus", condition: prefs.showRestoInFeed, toggleClosure: { (newState) in
                            PreferencesService.sharedService.showRestoInFeed = newState
                            self.tableView.reloadData()
                        })
                    case .specialEvent:
                        cell.configure("Toon uitgelichte activiteiten", condition: prefs.showSpecialEventsInFeed, toggleClosure: { (newState) in
                            PreferencesService.sharedService.showSpecialEventsInFeed = newState
                            self.tableView.reloadData()
                        })
                    }
                }

                return cell
            case .notification:
                let cell = tableView.dequeueReusableCell(withIdentifier: "PreferenceSwitchCell") as! PreferenceSwitchTableViewCell
                switch NotificationSection(rawValue: (indexPath as NSIndexPath).row)! {
                case .sko:
                    cell.configure("Student Kick-Off", condition: PreferencesService.sharedService.skoNotificationsEnabled, toggleClosure: { (newState) in
                        PreferencesService.sharedService.skoNotificationsEnabled = newState
                        if newState {
                            Messaging.messaging().subscribe(toTopic: NotificationService.SKOTopic)
                        } else {
                            Messaging.messaging().unsubscribe(fromTopic: NotificationService.SKOTopic)
                        }
                        self.tableView.reloadData()
                    })
                }
                return cell
            case .info:
                switch InfoSection(rawValue: (indexPath as NSIndexPath).row)! {
                case .zeusText:
                    return tableView.dequeueReusableCell(withIdentifier: "PreferencesTextTableViewCell")!
                case .externalLink:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "PreferenceExtraCell") as! PreferenceExtraTableViewCell

                    cell.configure("Meer informatie", detailText: "")
                    cell.setExternalLink()
                    return cell
                case .acknowledgements:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "PreferenceExtraCell") as! PreferenceExtraTableViewCell

                    cell.configure("Externe componenten", detailText: "")
                    return cell
                }
            }
        }
        fatalError("All cells should be reached before")
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == Sections.info.rawValue && (indexPath as NSIndexPath).row == InfoSection.zeusText.rawValue {
            return 68
        }

        if indexPath.section == Sections.resto.rawValue && indexPath.row == 1 {
            return 218
        }
        return 44
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch Sections(rawValue: section)! {
        case .activity:
            return "Selecteer verenigingen om activiteiten en nieuws"
                 + "berichten te filteren. Berichten die in de kijker "
                 + "staan worden steeds getoond."
        case .feed:
            return "Kies hier welke kaarten er zichtbaar zijn op het home tabblad.\n"
                 + "Uitgeschakelde kaarten kunnen nog zichtbaar zijn als ze uitgelicht worden."
        case .notification:
            return "Kies hierboven van welke bronnen je notificaties kan krijgen."
        default:
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Sections(rawValue: section)! {
        case .resto:
            return "Resto"
        case .activity:
            return "Studentenverenigingen"
        case .feed:
            return "Home scherm"
        case .notification:
            return "Notifications"
        case .info:
            return "De ontwikkelaars"
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Sections(rawValue: (indexPath as NSIndexPath).section)! {
        case .resto:
            if indexPath.row == 0 {
                showRestoPicker = !showRestoPicker
                tableView.deselectRow(at: indexPath, animated: true)
            }
        case .info:
            switch InfoSection(rawValue: (indexPath as NSIndexPath).row)! {
            case .externalLink:
                let url = URL(string: "https://zeus.UGent.be/hydra")!
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                tableView.deselectRow(at: indexPath, animated: true)
            case .acknowledgements:
                let viewController = AcknowListViewController()
                if let navigationController = self.navigationController {
                    navigationController.pushViewController(viewController, animated: true)
                }
            default:
                break
            }
        case .activity:
            switch ActivitySection(rawValue: (indexPath as NSIndexPath).row)! {
            case .select:
                if PreferencesService.sharedService.filterAssociations {
                    let c = AssociationPreferenceController()
                    if let navigationController = self.navigationController {
                        navigationController.pushViewController(c, animated: true)
                    }
                }
            default:
                break
            }
        default:
            break
        }
    }
}

enum Sections: Int {
    case resto
    case activity
    case feed
    case notification
    case info
}

enum RestoSection: Int {
    case selection
}

enum ActivitySection: Int {
    case showAll
    case select
}

enum FeedSection: Int {
    case resto
    case schamper
    case activities
    case news
    case specialEvent
}

enum NotificationSection: Int {
    case sko
}

enum InfoSection: Int {
    case zeusText
    case externalLink
    case acknowledgements
}
