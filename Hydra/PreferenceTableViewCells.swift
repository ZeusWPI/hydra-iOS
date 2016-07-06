//
//  PreferenceTableViewCells.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 06/07/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation

class PreferenceExtraTableViewCell: UITableViewCell {

    func configure(titleText: String, detailText: String) {
        self.textLabel?.text = titleText
        self.detailTextLabel?.text = detailText

        // Restore from disabled
        self.textLabel?.alpha = 1
        self.detailTextLabel?.alpha = 1
        self.selectionStyle = .Blue

        // Restore from link
        self.accessoryView = nil
        self.accessoryType = .DisclosureIndicator
    }

    func setDisabled() {
        self.textLabel?.alpha = 0.5
        self.detailTextLabel?.alpha = 0.5
        self.selectionStyle = .None
    }

    func setExternalLink() {
        let linkImage = UIImage(named: "external-link")
        let linkImageActive = UIImage(named: "external-link-active")
        let accessory = UIImageView(image: linkImage, highlightedImage: linkImageActive)
        accessory.contentMode = .ScaleAspectFit
        self.accessoryView = accessory


    }
}

class PreferenceSwitchTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var switchButton: UISwitch?

    var toggleClosure: ((Bool)->())?

    override func awakeFromNib() {
        switchButton?.addTarget(self, action: #selector(PreferenceSwitchTableViewCell.toggleAction), forControlEvents: .ValueChanged)
    }

    func configure(titleText: String, condition: Bool, toggleClosure: ((newState: Bool)->())?) {
        self.titleLabel?.text = titleText
        self.switchButton?.on = condition
        self.toggleClosure = toggleClosure
    }

    func toggleAction() {
        if let toggleClosure = toggleClosure,
            let switchButton = switchButton {
            toggleClosure(switchButton.on)
        }
    }
}

class PreferencesTextTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel?
}