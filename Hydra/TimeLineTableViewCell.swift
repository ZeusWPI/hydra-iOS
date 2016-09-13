//
//  TimeLineTableViewCell.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 13/09/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

class TimeLineTableViewCell: UITableViewCell {

    @IBOutlet weak var label: UILabel?
    @IBOutlet weak var switchButton: UISwitch?

    override func awakeFromNib() {
        switchButton?.addTarget(self, action: #selector(TimeLineTableViewCell.toggleAction), forControlEvents: .ValueChanged)
        self.selectionStyle = .None
    }

    var timeLineSetting: TimelineSetting? {
        didSet {
            if let timeLineSetting = timeLineSetting {
                label?.text = timeLineSetting.name
                switchButton?.on = timeLineSetting.currentValue
            }
        }
    }

    func toggleAction() {
        if let timeLineSetting = timeLineSetting, let switchButton = switchButton {
            timeLineSetting.currentValue = switchButton.on
        }
    }
}

class TimelineSetting {
    let name: String
    let defaultPreference: String

    init(name: String, defaultPref: String) {
        self.name = name
        self.defaultPreference = defaultPref
    }

    var currentValue: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey(defaultPreference)
        }
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: defaultPreference)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
}
