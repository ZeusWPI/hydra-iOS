//
//  SKOStageHeaderCollectionReusableView.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 10/09/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

class SKOStageHeaderCollectionReusableView: UICollectionReusableView {

    @IBOutlet var label: UILabel?

    var stageName: String? {
        didSet {
            label?.text = stageName
        }
    }
}
