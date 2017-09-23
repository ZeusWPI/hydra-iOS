//
//  HomeViewController.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 30/07/15.
//  Copyright © 2015 Zeus WPI. All rights reserved.
//

import UIKit
import SafariServices

class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var feedCollectionView: UICollectionView!

    let homeFeedService = HomeFeedService.sharedService

    var feedItems = HomeFeedService.sharedService.createFeed()
    let refreshControl = UIRefreshControl()
    var lastUpdated = Date()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        sharedInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }

    fileprivate func sharedInit() {
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.homeFeedUpdatedNotification(_:)), name: NSNotification.Name(rawValue: HomeFeedDidUpdateFeedNotification), object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func homeFeedUpdatedNotification(_ notification: Notification) {
        self.feedItems = HomeFeedService.sharedService.createFeed()
        DispatchQueue.main.async {
            self.feedCollectionView?.reloadData()
            self.refreshControl.endRefreshing()
        }
    }

    // MARK - View initialization
    override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl.tintColor = UIColor.white
        refreshControl.addTarget(self, action: #selector(HomeViewController.startRefresh), for: .valueChanged)
        feedCollectionView.addSubview(refreshControl)

        // REMOVE ME IF THE BUG IS FIXED, THIS IS FUCKING UGLY
        Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(HomeViewController.refreshDataTimer), userInfo: nil, repeats: false)
    }

    @objc func refreshDataTimer() { // REMOVE ME WHEN THE BUG IS FIXED
        DispatchQueue.main.async {
            self.feedCollectionView?.reloadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.isNavigationBarHidden = true

        HomeFeedService.sharedService.refreshStoresIfNecessary()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.navigationController?.isNavigationBarHidden = false
    }

    override func viewDidAppear(_ animated: Bool) {
        GAI_track("Home")
        self.navigationController?.isNavigationBarHidden = true
    }

    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        // this is called when changing layout :)
        self.feedCollectionView.collectionViewLayout.invalidateLayout()
    }

    @objc func startRefresh() {
        self.homeFeedService.refreshStores()
    }

    // MARK: - UICollectionViewDataSource and Delegate methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feedItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let feedItem = feedItems[(indexPath as NSIndexPath).row]

        switch feedItem.itemType {
        case .restoItem:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "restoCell", for: indexPath) as? HomeRestoCollectionViewCell
            cell?.restoMenu = feedItem.object as? RestoMenu
            cell?.layoutIfNeeded() // iOS 9 bug
            return cell!
        case .schamperNewsItem:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "schamperCell", for: indexPath) as? HomeSchamperCollectionViewCell
            cell!.article = feedItem.object as? SchamperArticle
            cell?.layoutIfNeeded() // iOS 9 bug
            return cell!
        case .activityItem:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "activityCell", for: indexPath) as? HomeActivityCollectionViewCell
            cell?.activity = feedItem.object as? Activity
            cell?.layoutIfNeeded() // iOS 9 bug
            return cell!
        case .newsItem:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "newsItemCell", for: indexPath) as? HomeNewsItemCollectionViewCell
            cell?.article = feedItem.object as? NewsItem
            return cell!
        case .minervaAnnouncementItem:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "minervaAnnouncementCell", for: indexPath) as? HomeMinervaAnnouncementCell
            cell?.announcement = feedItem.object as? Announcement
            return cell!
        case .minervaCalendarItem:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "minervaCalendarItemCell", for: indexPath) as? HomeMinervaCalendarItemCell
            cell?.calendarItem = feedItem.object as? CalendarItem
            return cell!
        case .specialEventItem:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "specialEventBasicCell", for: indexPath) as? HomeSpecialEventBasicCollectionViewCell
            cell?.specialEvent = feedItem.object as? SpecialEvent
            cell?.layoutIfNeeded()
            return cell!
        case .urgentItem:
            return collectionView.dequeueReusableCell(withReuseIdentifier: "urgentfmCell", for: indexPath)
        case .associationsSettingsItem:
            return collectionView.dequeueReusableCell(withReuseIdentifier: "settingsCell", for: indexPath)
        case .minervaSettingsItem:
            return collectionView.dequeueReusableCell(withReuseIdentifier: "minervaSettingsCell", for: indexPath)
        default:
            return collectionView.dequeueReusableCell(withReuseIdentifier: "testCell", for: indexPath)
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "homeHeader", for: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let feedItem = feedItems[(indexPath as NSIndexPath).row]
        let width: CGFloat
        if self.view.frame.size.width < 640 {
            width = self.view.frame.size.width
        } else {
            width = self.view.frame.size.width / 2
            // make all cards same size for consistency in splitview
            return CGSize(width: width, height: 180)
        }
        switch feedItem.itemType {
        case .restoItem:
            let restoMenu = feedItem.object as? RestoMenu
            var count = 1
            if (restoMenu != nil && restoMenu!.open) {
                count = restoMenu!.mainDishes!.count
            }

            return CGSize(width: width, height: CGFloat(90+count*15))
        case .activityItem:
            guard let activity = feedItem.object as? Activity else {
                return CGSize(width: width, height: 120)
            }

            let descriptionHeight: CGFloat = 0 //activity.descriptionText.boundingHeight(CGSize(width: width - 50, height: 150), font: UIFont.systemFont(ofSize: 14))

            return CGSize(width: width, height: descriptionHeight + 120)
        case .minervaAnnouncementItem:
            guard let announcement = feedItem.object as? Announcement else {
                return CGSize(width: width, height: 120)
            }

            let contentHeight: CGFloat
            if announcement.content.isEmpty {
                contentHeight = 0
            } else {
                contentHeight = 80
            }
            return CGSize(width: width, height: 100 + contentHeight)
        case .minervaCalendarItem:
            guard let calendarItem = feedItem.object as? CalendarItem else {
                return CGSize(width: width, height: 120)
            }

            let contentHeight: CGFloat
            if let content = calendarItem.content, !content.isEmpty {
                contentHeight = 80
            } else {
                contentHeight = 0
            }
            return CGSize(width: width, height: 100 + contentHeight)
        case .associationsSettingsItem, .minervaSettingsItem:
            return CGSize(width: width, height: 80)
        case .newsItem:
            return CGSize(width: width, height: 100)
        case .specialEventItem:
            return CGSize(width: width, height: 130)
        default:
            return CGSize(width: width, height: 135) //TODO: per type
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let feedItem = feedItems[(indexPath as NSIndexPath).row]

        switch feedItem.itemType {
        case .restoItem:
            //FIXME: using hardcoded tag of Resto Menu viewcontroller
            guard let index = self.tabBarController?.viewControllers?.index(where: {$0.tabBarItem.tag == TabViewControllerTags.resto.rawValue}) else {
                break
            }

            self.tabBarController?.selectedIndex = index
            if let restoMenu = feedItem.object as? RestoMenu {
                NotificationCenter.default.post(name: Notification.Name(rawValue: RestoMenuViewControllerShouldScrollToNotification), object: restoMenu.date)
            }
        case .activityItem:
            //self.navigationController?.pushViewController(ActivityDetailController(activity: feedItem.object as! Activity, delegate: nil), animated: true)
            break
        case .schamperNewsItem:
            let article = feedItem.object as! SchamperArticle
            if !article.read {
                article.read = true
                SchamperStore.shared.syncStorage()
            }

            self.navigationController?.pushViewController(SchamperDetailViewController(withArticle: article) , animated: true)
        case .minervaAnnouncementItem:
            self.performSegue(withIdentifier: "homeMinervaDetailSegue", sender: feedItem.object)
        case .minervaCalendarItem:
            self.performSegue(withIdentifier: "homeCalendarDetailSegue", sender: feedItem.object)
        case .newsItem:
            //self.navigationController?.pushViewController(NewsDetailViewController(newsItem: feedItem.object as! NewsItem), animated: true)
            break
        case .associationsSettingsItem:
            self.navigationController?.pushViewController(PreferencesController(), animated: true)
        case .minervaSettingsItem:
            let oauthService = UGentOAuth2Service.sharedService
            let oauth2 = oauthService.oauth2
            if !oauthService.isLoggedIn() {
                oauthService.login(context: self)
            }
        case .specialEventItem:
            let specialEvent = feedItem.object as! SpecialEvent
            let url = URL(string: specialEvent.link)!
            let svc = SFSafariViewController(url: url)
            self.present(svc, animated: true, completion: nil)
        default: break
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        switch identifier {
        case "homeMinervaDetailSegue":
            guard let announcement = sender as? Announcement, let vc = segue.destination as? MinervaAnnounceDetailViewController else {
                return
            }
            vc.title = ""
            vc.announcement = announcement
        case "homeCalendarDetailSegue":
            guard let item = sender as? CalendarItem, let vc = segue.destination as? MinervaCalendarDetailViewController else { return }
            vc.title = ""
            vc.calendarItem = item
        default:
            break
        }
    }
}
