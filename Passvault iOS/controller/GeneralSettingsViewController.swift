//
//  GeneralSettingsViewController.swift
//  Passvault iOS
//
//  Created by Erik Manor on 12/5/17.
//  Copyright © 2017 Erik Manor. All rights reserved.
//

import UIKit


struct GeneralSettings {
    var saveKey: Bool = false
    var sortByMRU: Bool = true
    var accountUUID: String = ""
    var key: String = ""
    var purgeDays: Int16 = 30
    
    init(saveKey: Bool, sortByMRU: Bool, key: String, accountUUID: String, daysBeforePurgeDeletes: Int16) {
        self.saveKey = saveKey
        self.sortByMRU = sortByMRU
        self.key = key
        self.accountUUID = accountUUID
        self.purgeDays = daysBeforePurgeDeletes
    }
    
    init() {
        
    }
}

class GeneralSettingsViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var saveKeySwitch: UISwitch!
    @IBOutlet weak var sortMRUSwitch: UISwitch!
    @IBOutlet weak var purgeTextField: UITextField!
    
    let CHECK_PURGE_STRING = "0123456789"
    
    var settings: GeneralSettings!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        settings = CoreDataUtils.loadGeneralSettings()
        saveKeySwitch.isOn = settings.saveKey
        sortMRUSwitch.isOn = settings.sortByMRU
        purgeTextField.text = String(settings.purgeDays)
        purgeTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - UITextFieldDelegate calls
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if CHECK_PURGE_STRING.contains(string) || string == "" {
            return true
        } else {
            return false
        }
        
    }
    
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        if let purge = Int16(textField.text!) {
            settings.purgeDays = purge
        }
        
        return true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
