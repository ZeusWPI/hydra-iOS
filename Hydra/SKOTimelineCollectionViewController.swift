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

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Do any additional setup after loading the view.
        // REMOVE ME IF THE BUG IS FIXED, THIS IS FUCKING UGLY
        NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: #selector(SKOTimelineCollectionViewController.refreshDataTimer), userInfo: nil, repeats: false)
        timeline = SKOStore.sharedStore.timeline
    }

    func refreshDataTimer(){ // REMOVE ME WHEN THE BUG IS FIXED
        dispatch_async(dispatch_get_main_queue()) {
            self.collectionView?.reloadData()
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: false)
        timeline = SKOStore.sharedStore.timeline
        self.collectionView?.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        print(height, post.body != nil, post.media != nil || post.poster != nil)

        if post.media != nil || post.poster != nil {
            height = height + 180 //TODO: find a way to guess the image size
            print(height)
        }
        if let body = post.body {
            // limit on 1500
            height = height + body.boundingHeight(CGSize(width: width - 20, height: 1500), font: UIFont.systemFontOfSize(14)) + 10
        }

        return CGSize(width: width, height: height)
    }

    // MARK: UICollectionViewDelegate


    // Uncomment this method to specify if the specified item should be selected
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
}
