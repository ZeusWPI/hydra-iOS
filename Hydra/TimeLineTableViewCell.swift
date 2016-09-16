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
    let action: ((Bool)->())?
    let switched: Bool

    init(name: String, defaultPref: String, switched: Bool = false, action:((state: Bool) -> ())? = nil) {
        self.name = name
        self.defaultPreference = defaultPref
        self.action = action
        // boolean value to say when the value should be switched
        self.switched = !switched
    }

    var currentValue: Bool {
        get {
            return switched == NSUserDefaults.standardUserDefaults().boolForKey(defaultPreference)
        }
        set {
            if let action = action {
                action(newValue)
            }
            // newValue == switched => flip boolean if switch == false, so set as true
            NSUserDefaults.standardUserDefaults().setBool(newValue == switched, forKey: defaultPreference)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
}
