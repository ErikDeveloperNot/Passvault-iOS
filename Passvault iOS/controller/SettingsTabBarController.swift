//
//  SettingsTabBarController.swift
//  Passvault iOS
//
//  Created by Erik Manor on 12/5/17.
//  Copyright © 2017 Erik Manor. All rights reserved.
//

import UIKit

class SettingsTabBarController: UITabBarController {

    var current: String = "General"
    var last: String = "General"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - TabBar calls
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        last = current
        current = item.title!
        saveSettings()
    }
    
    
    func saveSettings() {
        // save settings from tab
        switch last {
        case "General":
            let controller = selectedViewController as! GeneralSettingsViewController
            saveGeneralTabSettings(controller: controller)
            break
        case "Generator":
            let controller = selectedViewController as! PasswordGeneratorSettingsViewController
            saveGeneratorTabSettings(controller: controller)
            break
        case "Sync":
            // should end up noop since this view will contain its own save since it requires a call
            break
        default:
            break
        }
    }
    
    
    
    // MARK: - Data Store calls
    
    func saveGeneralTabSettings(controller: GeneralSettingsViewController) {
        let settings = GeneralSettings(saveKey: controller.saveKeySwitch.isOn, sortByMRU: controller.sortMRUSwitch.isOn, key: controller.settings.key, accountUUID: controller.settings.accountUUID)
        
        if CoreDataUtils.saveGeneralSettings(settings: settings) != CoreDataStatus.CoreDataSuccess {
            present(Utils.showErrorMessage(errorMessage: "There was an error saving the General Tab Settings"), animated: true, completion: nil)
        }
    }
    
    
    func saveGeneratorTabSettings(controller: PasswordGeneratorSettingsViewController) {
        var allowedCharacters: [String] = []
        
        if controller.allowLowerSwitch.isOn {
            allowedCharacters.append(contentsOf: RandomPasswordGenerator.DEFAULT_LOWER)
        }
        if controller.allowUpperSwitch.isOn {
            allowedCharacters.append(contentsOf: RandomPasswordGenerator.DEFAULT_UPPER)
        }
        if controller.allowDigitsSwitch.isOn {
            allowedCharacters.append(contentsOf: RandomPasswordGenerator.DEFAULT_DIGITS)
        }
        
        let specialsText = controller.specialsTextView.text
        
        for s in (specialsText?.split(separator: " "))! {
            
            if s.count > 0 {
                // there will be instructions to seperate chars from a space, so ASSUME it is the first char
                // TODO - May change this to better check and WARN
                let index = s.index(s.startIndex, offsetBy: 0)
                let character = String(s[...index])
   
                if allowedCharacters.contains(character) {
                    continue
                }
                
                allowedCharacters.append(character)
            }
        }
        
        let length = Int32(controller.lengthLabel.text!)
        
        if CoreDataUtils.saveGenerator(length: length!, allowedCharacters: allowedCharacters) != CoreDataStatus.CoreDataSuccess {
            present(Utils.showErrorMessage(errorMessage: "There was an error saving the Generator Tab Settings"), animated: true, completion: nil)
        }
    }
    
    
    // MARK: - UIViewController overloads
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        last = current
        saveSettings()
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
