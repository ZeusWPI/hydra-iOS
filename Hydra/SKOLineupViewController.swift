//
//  SKOLineupViewController.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 09/09/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation
import SDWebImage

class SKOLineupViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet var collectionView: UICollectionView?

    fileprivate var lineup = SKOStore.sharedStore.lineup
    fileprivate var stageNames = ["Main Stage", "Red Bull Elektropedia presents Decadance"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Do any additional setup after loading the view.
        collectionView?.register(UINib(nibName: "SKOLineupStageCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "stageHeader")

        NotificationCenter.default.addObserver(self, selector: #selector(SKOLineupViewController.reloadLineup), name: NSNotification.Name(rawValue: SKOStoreLineupUpdatedNotification), object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        UIApplication.shared.setStatusBarStyle(.lightContent, animated: false)

        reloadLineup()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func reloadLineup() {
        lineup = SKOStore.sharedStore.lineup
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
        // #warning Incomplete implementation, return the number of sections
        return lineup.count + 1
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if section == 0 {
            return 0
        }
        return lineup[section-1].artists.count
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if (indexPath as NSIndexPath).section == 0 {
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "skoHeader", for: indexPath)
        }
        let stageHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "stageHeader", for: indexPath) as! SKOStageHeaderCollectionReusableView

        stageHeader.stageName = stageNames[(indexPath as NSIndexPath).section-1]

        return stageHeader
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize(width: self.view.frame.width, height: 170)
        }
        return CGSize(width: self.view.frame.width, height: 70)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LineUpCell", for: indexPath) as! SKOLineUpCollectionViewCell

        // Configure the cell
        cell.artist = lineup[(indexPath as NSIndexPath).section-1].artists[(indexPath as NSIndexPath).row]
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.view.frame.size.width >= 640 {
            // make all cards same size for consistency in splitview
            return CGSize(width: (self.view.frame.size.width / 2) - 10, height: 205)
        }

        return CGSize(width: self.view.frame.width - 10, height: 205)
    }

    // MARK: UICollectionViewDelegate

    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
     return true
     }
     */

    /*
     // Uncomment this method to specify if the specified item should be selected
     override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
     return true
     }
     */

    /*
     // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
     return false
     }

     override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
     return false
     }

     override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
     
     }
     */
    
}
