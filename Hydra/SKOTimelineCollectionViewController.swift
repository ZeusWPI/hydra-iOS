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

        NotificationCenter.default.addObserver(self, selector: #selector(SKOTimelineCollectionViewController.reloadTimeline), name: NSNotification.Name(rawValue: SKOStoreTimelineUpdatedNotification), object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        UIApplication.shared.setStatusBarStyle(.lightContent, animated: false)

        reloadTimeline()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func reloadTimeline() {
        timeline = SKOStore.sharedStore.timeline
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
    }

    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
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

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return timeline.count
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "skoHeader", for: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let post = timeline[(indexPath as NSIndexPath).row]
        let identifier: String = "Cell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! SKOTimelineCollectionViewCell

        // Configure the cell
        cell.timelinePost = post

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let post = timeline[(indexPath as NSIndexPath).row]
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
            height = height + body.boundingHeight(CGSize(width: width - 30, height: 1500), font: UIFont.systemFont(ofSize: 14)) + 10
        }

        return CGSize(width: width, height: height)
    }

    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post = timeline[(indexPath as NSIndexPath).row]
        if let link = post.link, let url = URL(string: link) {
            UIApplication.shared.openURL(url)
        }
    }
}
