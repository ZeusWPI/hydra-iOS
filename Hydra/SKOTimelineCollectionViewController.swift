//
//  SKOTimelineCollectionViewController.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 09/09/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import UIKit

class SKOTimelineCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet var collectionView: UICollectionView?

    var timeline = [TimelinePost]()

    override func viewDidLoad() {
        super.viewDidLoad()

        timeline = SKOStore.sharedStore.timeline

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SKOTimelineCollectionViewController.reloadTimeline), name: SKOStoreTimelineUpdatedNotification, object: nil)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: false)

        reloadTimeline()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func reloadTimeline() {
        timeline = SKOStore.sharedStore.timeline
        dispatch_async(dispatch_get_main_queue()) {
            self.collectionView?.reloadData()
        }
    }

    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        // this is called when changing layout :)
        self.collectionView?.collectionViewLayout.invalidateLayout()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return timeline.count
    }

    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "skoHeader", forIndexPath: indexPath)
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let post = timeline[indexPath.row]
        let identifier: String = "Cell"
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! SKOTimelineCollectionViewCell

        // Configure the cell
        cell.timelinePost = post

        return cell
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let post = timeline[indexPath.row]
        let width: CGFloat
        if self.view.frame.size.width >= 640 {
            // make all cards same size for consistency in splitview
            width = (self.view.frame.size.width / 2) - 10
        } else {
            width = self.view.frame.width - 10
        }
        var height: CGFloat = 90

        if post.media != nil || post.poster != nil {
            height = height + 180 //TODO: find a way to guess the image size
        }
        if let body = post.body {
            // limit on 1500
            height = height + body.boundingHeight(CGSize(width: width - 20, height: 1500), font: UIFont.systemFontOfSize(14)) + 10
        }

        return CGSize(width: width, height: height)
    }

    // MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let post = timeline[indexPath.row]
        if let link = post.link, let url = NSURL(string: link) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
}
