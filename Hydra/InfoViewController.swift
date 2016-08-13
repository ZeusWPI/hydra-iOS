//
//  InfoViewController.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 12/08/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import SafariServices

class InfoViewController: UITableViewController {

    var infoItems = InfoStore.sharedStore.infoItems

    init() {
        super.init(style: .Plain)

        NSNotificationCenter.defaultCenter().addObserverForName(InfoStoreDidUpdateInfoNotification, object: nil, queue: nil) { (_) in
                dispatch_async(dispatch_get_main_queue(), { 
                    self.infoItems = InfoStore.sharedStore.infoItems
                    self.tableView.reloadData()
                })
        }

        self.title = "Info"
    }

    init(content infoItems: [InfoItem]) {
        super.init(style: .Plain)
        self.infoItems = infoItems
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.bounces = false
        self.tableView.tableFooterView = UIView() // No extra divider
    }

    // MARK: - Tableview delegate and dataSource
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.infoItems.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "InfoCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellIdentifier)
            cell?.contentView.backgroundColor = UIColor.whiteColor()
            cell?.textLabel?.backgroundColor = cell?.contentView.backgroundColor
        }

        let item = self.infoItems[indexPath.row]

        cell?.textLabel?.text = item.title

        let image = item.imageLocation
        cell?.imageView?.image = image

        if item.type == .ExternalLink {
            let linkImage = UIImage(named: "external-link.png")
            let highlightedLinkImage =  UIImage(named: "external-link-active.png")

            let linkAccessory = UIImageView(image: linkImage, highlightedImage: highlightedLinkImage)
            linkAccessory.contentMode = .ScaleAspectFit
            cell?.accessoryView = linkAccessory
        } else {
            cell?.accessoryType = .DisclosureIndicator
        }

        return cell!
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = self.infoItems[indexPath.row]

        // TODO: click tracking
        if let subItems = item.subcontent {
            let c = InfoViewController(content: subItems)
            c.title = item.title
            self.navigationController?.pushViewController(c, animated: true)
        } else if let htmlLink = item.htmlURL {
            let c = WebViewController()

            c.title = item.title
            c.loadUrl(htmlLink)
            self.navigationController?.pushViewController(c, animated: true)
        } else if let urlString = item.url, let url = NSURL(string: urlString) {
            if #available(iOS 9.0, *) {
                let c = SFSafariViewController(URL: url)
                self.navigationController?.presentViewController(c, animated: true, completion: nil)
            } else {
                // Fallback on earlier versions
                UIApplication.sharedApplication().openURL(url)
            }
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        } else if let urlString = item.appStore, let url = NSURL(string: urlString) {
            UIApplication.sharedApplication().openURL(url)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
}
