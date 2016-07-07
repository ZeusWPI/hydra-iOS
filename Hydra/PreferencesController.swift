//
//  PreferencesController.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 06/07/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import UIKit
import AcknowList

class PreferencesController: UITableViewController {

    init() {
        super.init(style: UITableViewStyle.Grouped)
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: #selector(PreferencesController.updateState), name: FacebookEventDidUpdateNotification, object: nil)
        center.addObserver(self, selector: #selector(PreferencesController.updateState), name: FacebookUserInfoUpdatedNotifcation, object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func updateState() {
        self.tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Voorkeuren"

        func registerNib(nibName: String, reuseIdentifier: String) {
            let nib = UINib.init(nibName: nibName, bundle: nil)
            self.tableView.registerNib(nib, forCellReuseIdentifier: reuseIdentifier)
        }

        registerNib("PreferencesExtraTableViewCells", reuseIdentifier: "PreferenceExtraCell")
        registerNib("PreferencesSwitchTableViewCells", reuseIdentifier: "PreferenceSwitchCell")
        registerNib("PreferencesTextTableViewCell", reuseIdentifier: "PreferencesTextTableViewCell")
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return numberOfSections()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = Sections(rawValue: section)
        if let section = section {
            switch section {
            case .UserAccount:
                return 2
            case .Activity:
                return 2
            case .Feed:
                return 6
            case .Info:
                return 3
            }
        }
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let section = Sections(rawValue: indexPath.section) {
            switch section {
            case .UserAccount:
                if let userAccount = UserAccountSection(rawValue: indexPath.row) {
                    let cell = tableView.dequeueReusableCellWithIdentifier("PreferenceExtraCell") as! PreferenceExtraTableViewCell

                    switch userAccount {
                    case .Facebook:
                        let detailText: String
                        let fbSession = FacebookSession.sharedSession
                        if fbSession.open {
                            if let name = fbSession.userInfo?.name {
                                detailText = name
                            } else {
                                detailText = "Aangemeld"
                            }
                        } else {
                            detailText = "Niet aangemeld"
                        }

                        cell.configure("Facebook", detailText: detailText)

                    case .UGent:
                        cell.configure("UGent", detailText: "Niet aangemeld")
                        // TODO: modfiy when OAuth is added
                    }

                    return cell
                }
            case .Activity:
                let prefs = PreferencesService.sharedService
                if let activityS = ActivitySection(rawValue: indexPath.row) {
                    switch activityS {
                    case .ShowAll:
                        let cell = tableView.dequeueReusableCellWithIdentifier("PreferenceSwitchCell") as! PreferenceSwitchTableViewCell
                        cell.configure("Toon alle verenigingen", condition: !prefs.filterAssociations, toggleClosure: { (newState) in
                            PreferencesService.sharedService.filterAssociations = !newState
                            self.tableView.reloadData()
                        })
                        return cell
                    case .Select:
                        let detailText: String
                        let count = prefs.preferredAssociations.count
                        let cell = tableView.dequeueReusableCellWithIdentifier("PreferenceExtraCell") as! PreferenceExtraTableViewCell
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
            case .Feed:
                let prefs = PreferencesService.sharedService
                let cell = tableView.dequeueReusableCellWithIdentifier("PreferenceSwitchCell") as! PreferenceSwitchTableViewCell
                if let feedSection = FeedSection(rawValue: indexPath.row) {
                    switch feedSection {
                    case .Activities:
                        cell.configure("Toon activiteiten", condition: prefs.showActivitiesInFeed, toggleClosure: { (newState) in
                            PreferencesService.sharedService.showActivitiesInFeed = newState
                            self.tableView.reloadData()
                        })
                    case .News:
                        cell.configure("Toon verenigingen nieuws", condition: prefs.showNewsInFeed, toggleClosure: { (newState) in
                            PreferencesService.sharedService.showNewsInFeed = newState
                            self.tableView.reloadData()
                        })
                    case .Schamper:
                        cell.configure("Toon Schamper Dailies", condition: prefs.showSchamperInFeed, toggleClosure: { (newState) in
                            PreferencesService.sharedService.showSchamperInFeed = newState
                            self.tableView.reloadData()
                        })
                    case .Resto:
                        cell.configure("Toon de resto menus", condition: prefs.showRestoInFeed, toggleClosure: { (newState) in
                            PreferencesService.sharedService.showRestoInFeed = newState
                            self.tableView.reloadData()
                        })
                    case .SpecialEvent:
                        cell.configure("Toon uitgelichte activiteiten", condition: prefs.showSpecialEventsInFeed, toggleClosure: { (newState) in
                            PreferencesService.sharedService.showSpecialEventsInFeed = newState
                            self.tableView.reloadData()
                        })
                    case .Urgentfm:
                        cell.configure("Toon Urgent.fm-kaartje", condition: prefs.showUrgentfmInFeed, toggleClosure: { (newState) in
                            PreferencesService.sharedService.showUrgentfmInFeed = newState
                            self.tableView.reloadData()
                        })
                    }
                }

                return cell
            case .Info:
                switch InfoSection(rawValue: indexPath.row)! {
                case .ZeusText:
                    return tableView.dequeueReusableCellWithIdentifier("PreferencesTextTableViewCell")!
                case .ExternalLink:
                    let cell = tableView.dequeueReusableCellWithIdentifier("PreferenceExtraCell") as! PreferenceExtraTableViewCell

                    cell.configure("Meer informatie", detailText: "")
                    cell.setExternalLink()
                    return cell
                case .Acknowledgements:
                    let cell = tableView.dequeueReusableCellWithIdentifier("PreferenceExtraCell") as! PreferenceExtraTableViewCell

                    cell.configure("Externe componenten", detailText: "")
                    return cell
                }
            }
        }
        fatalError("All cells should be reached before")
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == Sections.Info.rawValue && indexPath.row == InfoSection.ZeusText.rawValue {
            return 68
        }

        return 44
    }

    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch Sections(rawValue: section)! {
        case .Activity:
            return 68
        default:
            return 0
        }
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Sections(rawValue: section)! {
        case .UserAccount:
            return "Gebruikeraccounts"
        case .Activity:
            return "Instellingen activiteiten"
        case .Feed:
            return "Modules home scherm" //TODO: find better title
        case .Info:
            return "De ontwikkelaars"
        }
    }

    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch Sections(rawValue: section)! {
        case .Activity:
            let label = UILabel(frame: CGRectMake(10, 0, self.view.frame.size.width - 20, 68))

            label.text = "Selecteer verenigingen om activiteiten en nieuws"
                       + "berichten te filteren. Berichten die in de kijker "
                       + "staan worden steeds getoond."
            label.backgroundColor = UIColor.clearColor()
            label.textAlignment = .Center
            label.textColor = UIColor.blackColor()
            label.font = UIFont.systemFontOfSize(13)
            label.numberOfLines = 0

            let view = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, 68))
            view.backgroundColor = UIColor.clearColor()

            view.addSubview(label)

            view.layoutIfNeeded()
            return view //TODO: fix footer
        default:
            return nil
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch Sections(rawValue: indexPath.section)! {
        case .UserAccount:
            switch UserAccountSection(rawValue: indexPath.row)! {
            case .Facebook:
                let session = FacebookSession.sharedSession
                if session.open {
                    let action = UIAlertController(title: "Facebook", message: "", preferredStyle: .ActionSheet)
                    action.addAction(UIAlertAction(title: "Afmelden", style: .Destructive, handler: { _ in
                        FacebookSession.sharedSession.close()
                        self.tableView.reloadData()
                    }))
                    action.addAction(UIAlertAction(title: "Annuleren", style: .Cancel, handler: nil))
                    presentViewController(action, animated: true, completion: nil)
                } else {
                    session.openWithAllowLoginUI(true)
                }
            case .UGent:
                break //TODO: fill in when OAuth is added
            }
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        case .Info:
            switch InfoSection(rawValue: indexPath.row)! {
            case .ExternalLink:
                let url = NSURL(string: "https://zeus.UGent.be/hydra")!
                UIApplication.sharedApplication().openURL(url)
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
            case .Acknowledgements:
                let viewController = AcknowListViewController()
                if let navigationController = self.navigationController {
                    navigationController.pushViewController(viewController, animated: true)
                }
            default:
                break
            }
        case .Activity:
            switch ActivitySection(rawValue: indexPath.row)! {
            case .Select:
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
    case UserAccount
    case Activity
    case Feed
    case Info
}

enum UserAccountSection: Int {
    case Facebook
    case UGent
}

enum ActivitySection: Int {
    case ShowAll
    case Select
}

enum FeedSection: Int {
    case Resto
    case Schamper
    case Activities
    case Urgentfm
    case News
    case SpecialEvent
}

enum InfoSection: Int {
    case ZeusText
    case ExternalLink
    case Acknowledgements
}

func numberOfSections() -> Int {
    return [Sections.UserAccount, Sections.Activity, Sections.Feed, Sections.Info].count
}
