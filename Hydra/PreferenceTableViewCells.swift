//
//  PreferenceTableViewCells.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 06/07/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import UIKit

class PreferenceExtraTableViewCell: UITableViewCell {

    func configure(_ titleText: String, detailText: String) {
        self.textLabel?.text = titleText
        self.detailTextLabel?.text = detailText

        // Restore from disabled
        self.textLabel?.alpha = 1
        self.detailTextLabel?.alpha = 1
        self.selectionStyle = .blue

        // Restore from link
        self.accessoryView = nil
        self.accessoryType = .disclosureIndicator
    }

    func setDisabled() {
        self.textLabel?.alpha = 0.5
        self.detailTextLabel?.alpha = 0.5
        self.selectionStyle = .none
        self.accessoryType = .none
    }

    func setExternalLink() {
        let linkImage = UIImage(named: "external-link")
        let linkImageActive = UIImage(named: "external-link-active")
        let accessory = UIImageView(image: linkImage, highlightedImage: linkImageActive)
        accessory.contentMode = .scaleAspectFit
        self.accessoryView = accessory
    }
}

class PreferenceSwitchTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var switchButton: UISwitch?

    var toggleClosure: ((Bool)->())?

    override func awakeFromNib() {
        switchButton?.addTarget(self, action: #selector(PreferenceSwitchTableViewCell.toggleAction), for: .valueChanged)
    }

    func configure(_ titleText: String, condition: Bool, toggleClosure: ((_ newState: Bool)->())?) {
        self.titleLabel?.text = titleText
        self.switchButton?.isOn = condition
        self.toggleClosure = toggleClosure
    }

    @objc func toggleAction() {
        if let toggleClosure = toggleClosure,
            let switchButton = switchButton {
            toggleClosure(switchButton.isOn)
        }

        NotificationCenter.default.post(name: Notification.Name(rawValue: PreferencesControllerDidUpdatePreferenceNotification), object: nil)
    }
}

class PreferencesTextTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel?
}
