//
//  RestoMenuViewController.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 14/08/15.
//  Copyright © 2015 Zeus WPI. All rights reserved.
//

import UIKit

let RestoMenuViewControllerShouldScrollToNotification = "RestoMenuViewControllerShouldScrollTo"

class RestoMenuViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView?
    @IBOutlet weak var restoMenuHeader: RestoMenuHeaderView?

    var days: [Date] = []
    var menus: [RestoMenu?] = []
    var sandwiches: [RestoSandwich]?
    var message: String

    var currentIndex: Int = 1

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.message = ""
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        initialize()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            if self.parent != self.tabBarController?.moreNavigationController {
                return .lightContent
            }
            return .default
        }
    }

    required init?(coder aDecoder: NSCoder) {
        self.message = ""
        super.init(coder: aDecoder)
        initialize()
    }

    func initialize() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(RestoMenuViewController.reloadMenu), name: NSNotification.Name(rawValue: RestoStoreDidReceiveMenuNotification), object: nil)
        center.addObserver(self, selector: #selector(RestoMenuViewController.reloadInfo), name: NSNotification.Name(rawValue: RestoStoreDidUpdateInfoNotification), object: nil)
        center.addObserver(self, selector: #selector(RestoMenuViewController.reloadInfo), name: NSNotification.Name(rawValue: RestoStoreDidUpdateSandwichesNotification), object: nil)
        center.addObserver(self, selector: #selector(RestoMenuViewController.reloadClosedMessage), name: NSNotification.Name(rawValue: RestoStoreDidUpdateClosedMessageNotification), object: nil)
        center.addObserver(self, selector: #selector(RestoMenuViewController.applicationDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        center.addObserver(self, selector: #selector(RestoMenuViewController.scrollToIndexNotification(_:)), name: NSNotification.Name(rawValue: RestoMenuViewControllerShouldScrollToNotification), object: nil)

        days = calculateDays()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadMenu()

        self.sandwiches = RestoStore.shared.sandwiches

        // update days and reloadData
        self.restoMenuHeader?.updateDays()
        //self.collectionView?.reloadData() // Uncomment when bug is fixed
        //self.scrollToIndex(self.currentIndex, animated: false)

        // REMOVE ME IF THE BUG IS FIXED, THIS IS UGLY
        Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(RestoMenuViewController.refreshDataTimer(_:)), userInfo: nil, repeats: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        GAI_track("Resto Menu")
        if self.parent != self.tabBarController?.moreNavigationController {
            self.navigationController?.isNavigationBarHidden = true
        }
    }

    @objc func refreshDataTimer(_ timer: Timer) { // REMOVE ME WHEN THE BUG IS FIXED
        self.collectionView?.reloadData()
        self.scrollToIndex(self.currentIndex, animated: false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.days = calculateDays()
        self.restoMenuHeader?.updateDays()
        //do not hide if in moreController
        if self.parent != self.tabBarController?.moreNavigationController {
            if UIApplication.shared.statusBarStyle != .lightContent {
            }
            self.navigationController?.isNavigationBarHidden = true
        }
        // scroll to today
        self.scrollToIndex(currentIndex, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.navigationController?.isNavigationBarHidden = false
    }

    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        // this is called when changing layout :)
        self.collectionView?.collectionViewLayout.invalidateLayout()
        self.scrollToIndex(currentIndex, animated: true)
    }

    func loadMenu() {
        // New menus are available
        let store = RestoStore.shared
        var menus = [RestoMenu?]()
        for day in days {
            let menu = store.menuForDay(day) as RestoMenu?
            menus.append(menu)
        }
        self.menus = menus
    }

    @objc func reloadMenu() {
        debugPrint("Reloading menu")
        DispatchQueue.main.async {
            self.loadMenu()
            self.collectionView?.reloadData()
        }
    }

    @objc func reloadInfo() {
        // New info is available
        debugPrint("Reloading info")
        self.sandwiches = RestoStore.shared.sandwiches

        self.collectionView?.reloadData()
    }

    @objc func reloadClosedMessage() {
        // New info is available
        debugPrint("Reloading closed screen")

        self.collectionView?.reloadData()
    }

    @objc func applicationDidBecomeActive(_ notification: Notification) {
        let firstDay = self.days[0]
        self.days = self.calculateDays()

        if !(firstDay as NSDate).isEqual(toDateIgnoringTime: self.days[0]) {
            self.reloadMenu()
        }
    }

    func calculateDays() -> [Date] {
        // Find the next x days to display
        var day = Date()
        var days = [Date]()
        while (days.count < 5) {
            if (day as NSDate).isTypicallyWorkday() {
                days.append(day)
            }
            day = (day as NSDate).addingDays(1)
        }
        return days
    }

    // MARK: - Headerview actions

    @IBAction func mapViewPressed(_ gestureRecognizer: UITapGestureRecognizer) {
        debugPrint("Map view pressed!")
        if let navigationController = self.navigationController {
            navigationController.pushViewController(RestoMapController(), animated: true)
        } else {
            fatalError("An navigationcontroller should be present")
        }
    }
}

// MARK: - Collection view data source & delegate
extension RestoMenuViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.days.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        switch (indexPath as NSIndexPath).row {
        case 0: // info cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "infoCell", for: indexPath) as! RestoMenuInfoCollectionViewCell

            cell.sandwiches = self.sandwiches
            return cell
        case 1...self.days.count:
            let menu = self.menus[(indexPath as NSIndexPath).row-1]
            if let menu = menu, menu.open {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "restoMenuOpenCell", for: indexPath) as! RestoMenuCollectionCell

                cell.restoMenu = menu
                cell.extraMessage.isHidden = menu.message == nil
                cell.extraMessage.text = menu.message
                cell.extraMessage.sizeToFit()
                
                return cell
            }

            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "restoMenuClosedCell", for: indexPath) as! RestoMenuClosedMessageCollectionCell
            cell.closedExtraMessage = menu?.message ?? ""
            return cell
        default:
            debugPrint("Shouldn't be here")
            return collectionView.dequeueReusableCell(withReuseIdentifier: "infoCell", for: indexPath)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height) // cells always fill the whole screen
    }
}

extension RestoMenuViewController: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // Stop if velocity is 0
        if velocity.x == 0 {
            return
        }

        let pageWidth = Float(self.collectionView!.frame.size.width)
        let currentOffset = Float(scrollView.contentOffset.x)
        let targetOffset = Float(targetContentOffset.pointee.x) + pageWidth/2

        let index = max(min(Int(round(targetOffset / pageWidth))-1, (self.collectionView?.numberOfItems(inSection: 0))!-1), 0)

        targetContentOffset.pointee = CGPoint(x: CGFloat(currentOffset), y: 0)

        self.scrollToIndex(index, animated: true)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate {
            let index = Int((scrollView.contentOffset.x + self.collectionView!.frame.size.width/2) / self.collectionView!.frame.size.width)
            scrollToIndex(index)
        }
    }

    // MARK: - Header view actions

    @objc func scrollToIndexNotification(_ notification: Notification) {
        if let date = notification.object as? Date {
            self.scrollToDate(date)
        }
    }

    func scrollToIndex(_ index: Int, animated: Bool = true) {
        self.collectionView?.scrollToItem(at: IndexPath(row: index, section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: animated)
        self.restoMenuHeader?.selectedIndex(index)
        currentIndex = index
    }

    func scrollToDate(_ date: Date) {
        for (index, day) in days.enumerated() {
            if ((day as NSDate).atStartOfDay() as NSDate).isEqual(to: (date as NSDate).atStartOfDay()) {
                self.scrollToIndex(index+1)
                return
            }
        }
    }
}
