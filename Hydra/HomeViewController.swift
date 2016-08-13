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
    var lastUpdated = NSDate()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        sharedInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    private func sharedInit() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(HomeViewController.homeFeedUpdatedNotification(_:)), name: HomeFeedDidUpdateFeedNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func homeFeedUpdatedNotification(notification: NSNotification) {
        self.feedItems = HomeFeedService.sharedService.createFeed()
        dispatch_async(dispatch_get_main_queue()) {
            self.feedCollectionView?.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    // MARK - View initialization
    override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl.tintColor = .whiteColor()
        refreshControl.addTarget(self, action: #selector(HomeViewController.startRefresh), forControlEvents: .ValueChanged)
        feedCollectionView.addSubview(refreshControl)

        // REMOVE ME IF THE BUG IS FIXED, THIS IS FUCKING UGLY
        NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: #selector(HomeViewController.refreshDataTimer), userInfo: nil, repeats: false)
    }
    
    func refreshDataTimer(){ // REMOVE ME WHEN THE BUG IS FIXED
        dispatch_async(dispatch_get_main_queue()) {
            self.feedCollectionView?.reloadData()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = true
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: false)
        
        HomeFeedService.sharedService.refreshStoresIfNecessary()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBarHidden = false
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: false)
    }
    
    override func viewDidAppear(animated: Bool) {
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: animated)

        GAI_track("Home")
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        // this is called when changing layout :)
        self.feedCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    func startRefresh() {
        self.homeFeedService.refreshStores()
    }
    
    // MARK: - UICollectionViewDataSource and Delegate methods
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feedItems.count;
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let feedItem = feedItems[indexPath.row]
        
        switch feedItem.itemType {
        case .RestoItem:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("restoCell", forIndexPath: indexPath) as? HomeRestoCollectionViewCell
            cell?.restoMenu = feedItem.object as? RestoMenu
            cell?.layoutIfNeeded() // iOS 9 bug
            return cell!
        case .SchamperNewsItem:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("schamperCell", forIndexPath: indexPath) as? HomeSchamperCollectionViewCell
            cell!.article = feedItem.object as? SchamperArticle
            cell?.layoutIfNeeded() // iOS 9 bug
            return cell!
        case .ActivityItem:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("activityCell", forIndexPath: indexPath) as? HomeActivityCollectionViewCell
            cell?.activity = feedItem.object as? Activity
            cell?.layoutIfNeeded() // iOS 9 bug
            return cell!
        case .NewsItem:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("newsItemCell", forIndexPath: indexPath) as? HomeNewsItemCollectionViewCell
            cell?.article = feedItem.object as? NewsItem
            return cell!
        case .MinervaAnnouncementItem:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("minervaAnnouncementCell", forIndexPath: indexPath) as? HomeMinervaAnnouncementCell
            cell?.announcement = feedItem.object as? Announcement
            return cell!
        case .SpecialEventItem:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("specialEventBasicCell", forIndexPath: indexPath) as? HomeSpecialEventBasicCollectionViewCell
            cell?.specialEvent = feedItem.object as? SpecialEvent
            return cell!
        case .UrgentItem:
            return collectionView.dequeueReusableCellWithReuseIdentifier("urgentfmCell", forIndexPath: indexPath)
        case .AssociationsSettingsItem:
            return collectionView.dequeueReusableCellWithReuseIdentifier("settingsCell", forIndexPath: indexPath)
        case .MinervaSettingsItem:
            return collectionView.dequeueReusableCellWithReuseIdentifier("minervaSettingsCell", forIndexPath: indexPath)
        default:
            return collectionView.dequeueReusableCellWithReuseIdentifier("testCell", forIndexPath: indexPath)
        }
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "homeHeader", forIndexPath: indexPath)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let feedItem = feedItems[indexPath.row]
        let width: CGFloat
        if self.view.frame.size.width < 640 {
            width = self.view.frame.size.width
        } else {
            width = self.view.frame.size.width / 2
            // make all cards same size for consistency in splitview
            return CGSizeMake(width, 180)
        }
        switch feedItem.itemType {
        case .RestoItem:
            let restoMenu = feedItem.object as? RestoMenu
            var count = 1
            if (restoMenu != nil && restoMenu!.open) {
                count = restoMenu!.mainDishes!.count
            }

            return CGSizeMake(width, CGFloat(90+count*15))
        case .ActivityItem:
            guard let activity = feedItem.object as? Activity else {
                return CGSizeMake(width, 120)
            }

            let descriptionHeight = activity.descriptionText.boundingHeight(CGSizeMake(width, 150))

            return CGSizeMake(width, descriptionHeight + 120)
        case .MinervaAnnouncementItem:
            guard let announcement = feedItem.object as? Announcement else {
                return CGSizeMake(width, 120)
            }

            let contentHeight: CGFloat
            if announcement.content.isEmpty {
                contentHeight = 0
            } else {
                contentHeight = 80
            }
            return CGSizeMake(width, 100 + contentHeight)
        case .AssociationsSettingsItem, .MinervaSettingsItem:
            return CGSizeMake(width, 80)
        case .NewsItem:
            return CGSizeMake(width, 100)
        case .SpecialEventItem:
            return CGSizeMake(width, 130)
        default:
            return CGSizeMake(width, 135) //TODO: per type
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(10, 0, 0, 0)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let feedItem = feedItems[indexPath.row]
        
        switch feedItem.itemType {
        case .RestoItem:
            let index = self.tabBarController?.viewControllers?.indexOf({$0.tabBarItem.tag == 221}) // using hardcoded tag of Resto Menu viewcontroller
            self.tabBarController?.selectedIndex = index!
            let navigationController = self.tabBarController?.viewControllers![index!] as? UINavigationController
            if let menuController = navigationController?.visibleViewController as? RestoMenuViewController {
                let menu = feedItem.object as! RestoMenu
                menuController.scrollToDate(menu.date)
            }
        case .ActivityItem:
            self.navigationController?.pushViewController(ActivityDetailController(activity: feedItem.object as! Activity, delegate: nil), animated: true)
        case .SchamperNewsItem:
            let article = feedItem.object as! SchamperArticle
            if !article.read {
                article.read = true
                SchamperStore.sharedStore.syncStorage()
            }
            
            self.navigationController?.pushViewController(SchamperDetailViewController(article: article), animated: true)
        case .MinervaAnnouncementItem:
            self.performSegueWithIdentifier("homeMinervaDetailSegue", sender: feedItem.object)
        case .NewsItem:
            self.navigationController?.pushViewController(NewsDetailViewController(newsItem: feedItem.object as! NewsItem), animated: true)
        case .AssociationsSettingsItem:
            self.navigationController?.pushViewController(PreferencesController(), animated: true)
        case .MinervaSettingsItem:
            let oauthService = UGentOAuth2Service.sharedService
            let oauth2 = oauthService.oauth2
            if oauth2.accessToken == nil {
                oauth2.authConfig.authorizeEmbedded = true
                oauth2.authConfig.authorizeContext = self
                oauth2.authorize()
            }
        case .SpecialEventItem:
            let specialEvent = feedItem.object as! SpecialEvent
            let url = NSURL(string: specialEvent.link)!
            if #available(iOS 9.0, *) {
                let svc = SFSafariViewController(URL: url)
                self.presentViewController(svc, animated: true, completion: nil)
            } else {
                // Fallback on earlier versions
                let wvc = WebViewController()
                wvc.loadUrl(url)
                self.navigationController?.pushViewController(wvc, animated: true)
            }
        default: break
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "homeMinervaDetailSegue" {
            guard let announcement = sender as? Announcement, let vc = segue.destinationViewController as? MinervaAnnounceDetailViewController else {
                return
            }
            vc.title = ""
            vc.announcement = announcement
        }
    }
}