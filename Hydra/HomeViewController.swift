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
        self.refreshControl.endRefreshing()
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
        case .ugentNewsItem:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ugentNewsItemCell", for: indexPath) as? HomeUGentNewsItemCollectionViewCell
            cell?.article = feedItem.object as? UGentNewsItem
            return cell!
        case .specialEventItem:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "specialEventBasicCell", for: indexPath) as? HomeSpecialEventBasicCollectionViewCell
            cell?.specialEvent = feedItem.object as? SpecialEvent
            cell?.layoutIfNeeded()
            return cell!
        case .associationsSettingsItem:
            return collectionView.dequeueReusableCell(withReuseIdentifier: "settingsCell", for: indexPath)
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
        case .associationsSettingsItem:
            return CGSize(width: width, height: 80)
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
            guard let index = self.tabBarController?.viewControllers?.firstIndex(where: {$0.tabBarItem.tag == TabViewControllerTags.resto.rawValue}) else {
                break
            }

            self.tabBarController?.selectedIndex = index
            if let restoMenu = feedItem.object as? RestoMenu {
                NotificationCenter.default.post(name: Notification.Name(rawValue: RestoMenuViewControllerShouldScrollToNotification), object: restoMenu.date)
            }
        case .activityItem:
            self.performSegue(withIdentifier: "homeActivityDetailSegue", sender: feedItem.object)
        case .schamperNewsItem:
            let article = feedItem.object as! SchamperArticle
            if !article.read {
                article.read = true
                SchamperStore.shared.syncStorage()
            }

            self.navigationController?.pushViewController(SchamperDetailViewController(withArticle: article) , animated: true)
        case .ugentNewsItem:
            let newsItem = feedItem.object as! UGentNewsItem
            let url = URL(string: newsItem.identifier)!
            let svc = SFSafariViewController(url: url)
            UIApplication.shared.windows[0].rootViewController?.present(svc, animated: true, completion: nil)
        case .associationsSettingsItem:
            self.navigationController?.pushViewController(PreferencesController(), animated: true)
        case .specialEventItem:
            let specialEvent = feedItem.object as! SpecialEvent
            if let inApp = specialEvent.inApp {
                switch inApp {
                case "be.ugent.zeus.hydra.special.sko":
                    let vc = UIStoryboard(name: "sko", bundle: nil).instantiateInitialViewController()!
                    UIApplication.shared.windows[0].rootViewController = vc
                    return
                default: break
                }
            }
            let url = URL(string: specialEvent.link)!
            let svc = SFSafariViewController(url: url)
            UIApplication.shared.windows[0].rootViewController?.present(svc, animated: true, completion: nil)
        default: break
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        switch identifier {
        case "homeActivityDetailSegue":
            guard let item = sender as? Activity, let vc = segue.destination as? ActivityDetailController else { return }
            vc.title = ""
            vc.activity = item
        default:
            break
        }
    }
}
