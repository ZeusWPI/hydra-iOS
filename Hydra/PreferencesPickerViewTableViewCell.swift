//
//  PreferencesPickerViewTableViewCell.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 07/02/2017.
//  Copyright © 2017 Zeus WPI. All rights reserved.
//

import UIKit

class PreferencesPickerViewTableViewCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var pickerView: UIPickerView?

    var optionSelectedClosure: ((TitleProtocol)->())?
    var options = [TitleProtocol]() {
        didSet {
            if let pickerView = pickerView {
                pickerView.reloadAllComponents()
            }
        }
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return options[row].repr()
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if options.count > row {
            print(options[row])
        }

        if let optionSelectedClosure = optionSelectedClosure {
            optionSelectedClosure(options[row])
        }
    }
}

protocol TitleProtocol {
    func repr() -> String
}

extension RestoLocation: TitleProtocol {

    internal func repr() -> String {
        return name
    }

}
