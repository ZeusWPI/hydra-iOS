//
//  SKOStudentVillageDetailViewController.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 21/09/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import UIKit

class SKOStudentVillageDetailViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var imageView: UIImageView?
    @IBOutlet weak var contentText: UITextView?

    var exihibitor: Exihibitor? {
        didSet {
            loadExihibitor()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        loadExihibitor()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.navigationBarHidden = false
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        self.navigationController?.navigationBarHidden = true
    }

    func loadExihibitor() {
        if let exihibitor = exihibitor {
            self.nameLabel?.text = exihibitor.name
            self.contentText?.text = exihibitor.content
            if let url = NSURL(string: exihibitor.logo) {
                imageView?.sd_setImageWithURL(url)
            }
        }
    }
}
