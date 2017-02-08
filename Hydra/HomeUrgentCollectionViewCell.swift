//
//  HomeUrgentCollectionViewCell.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 02/08/15.
//  Copyright © 2015 Zeus WPI. All rights reserved.
//

import UIKit

class HomeUrgentCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var button: UIButton!

    let notificationCenter = NotificationCenter.default

    override func awakeFromNib() {
        notificationCenter.addObserver(self, selector: #selector(HomeUrgentCollectionViewCell.playerStatusChanged(_:)), name: NSNotification.Name.UrgentPlayerDidChangeState, object: nil)
        button.isSelected = UrgentPlayer.shared().isPlaying()
        self.contentView.setShadow()
    }

    deinit {
        notificationCenter.removeObserver(self)
    }

    @IBAction func playButtonTapped(_ sender: UIButton) {
        let player = UrgentPlayer.shared()
        if (player?.isPlaying())! {
            player?.pause()
        } else {
            player?.play()
        }
    }

    func playerStatusChanged(_ notification: Notification) {
        button.isSelected =  UrgentPlayer.shared().isPlaying()
    }
}
