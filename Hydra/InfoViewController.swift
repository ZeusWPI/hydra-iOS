//
//  InfoViewController.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 12/08/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import SafariServices

class InfoViewController: UITableViewController {

    var infoItems = InfoStore.shared.infoItems

    init() {
        super.init(style: .plain)

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: InfoStoreDidUpdateInfoNotification), object: nil, queue: nil) { (_) in
                DispatchQueue.main.async(execute: {
                    self.infoItems = InfoStore.shared.infoItems
                    self.tableView.reloadData()
                })
        }

        self.title = "Info"
    }

    init(content infoItems: [InfoItem]) {
        super.init(style: .plain)
        self.infoItems = infoItems
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.bounces = false
        self.tableView.tableFooterView = UIView() // No extra divider
    }

    // MARK: - Tableview delegate and dataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.infoItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "InfoCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }

        let item = self.infoItems[(indexPath as NSIndexPath).row]

        cell?.textLabel?.text = item.title

        let image = item.imageLocation
        cell?.imageView?.image = image

        if item.type == .externalLink {
            let linkImage = UIImage(named: "external-link.png")
            let highlightedLinkImage =  UIImage(named: "external-link-active.png")

            let linkAccessory = UIImageView(image: linkImage, highlightedImage: highlightedLinkImage)
            linkAccessory.contentMode = .scaleAspectFit
            cell?.accessoryView = linkAccessory
        } else {
            cell?.accessoryType = .disclosureIndicator
        }

        return cell!
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.infoItems[(indexPath as NSIndexPath).row]

        // TODO: click tracking
        if let subItems = item.subcontent {
            let c = InfoViewController(content: subItems)
            c.title = item.title
            self.navigationController?.pushViewController(c, animated: true)
        } else if let htmlLink = item.htmlURL {
            let c = WebViewController()

            c.title = item.title
            c.loadUrl(url: htmlLink)
            self.navigationController?.pushViewController(c, animated: true)
        } else if let urlString = item.url, let url = URL(string: urlString) {
            if #available(iOS 9.0, *) {
                let c = SFSafariViewController(url: url)
                self.navigationController?.present(c, animated: true, completion: nil)
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(url)
            }
            tableView.deselectRow(at: indexPath, animated: true)
        } else if let urlString = item.appStore, let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
