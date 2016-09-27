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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.isNavigationBarHidden = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.navigationController?.isNavigationBarHidden = true
    }

    func loadExihibitor() {
        if let exihibitor = exihibitor {
            self.nameLabel?.text = exihibitor.name
            self.contentText?.text = exihibitor.content
            if let url = URL(string: exihibitor.logo) {
                imageView?.sd_setImage(with: url)
            }
        }
    }
}
