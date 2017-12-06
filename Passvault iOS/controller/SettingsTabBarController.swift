//
//  SettingsTabBarController.swift
//  Passvault iOS
//
//  Created by User One on 12/5/17.
//  Copyright © 2017 User One. All rights reserved.
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
        /*
        // save settings from tab
        switch last {
        case "General":
            let controller = selectedViewController as! GeneralSettingsViewController
            saveGeneralTabSettings(controller: controller)
            break
        case "Generator":
            let controller = selectedViewController as! PasswordGeneratorSettingsViewController
            break
        case "Sync":
            // should end up noop since this view will contain its own save since it requires a call
            let controller = selectedViewController as! SyncSettingsViewController
            print(controller.testField)
            break
        default:
            break
        }
 */
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
            break
        case "Sync":
            // should end up noop since this view will contain its own save since it requires a call
            let controller = selectedViewController as! SyncSettingsViewController
            print(controller.testField)
            break
        default:
            break
        }
    }
    
    
    
    // MARK: - Data Store calls
    
    func saveGeneralTabSettings(controller: GeneralSettingsViewController) {
        let settings = GeneralSettings(saveKey: controller.saveKeySwitch.isOn, sortByMRU: controller.sortMRUSwitch.isOn)
        
        if CoreDataUtils.saveGeneralSettings(settings: settings) != CoreDataStatus.CoreDataSuccess {
            Utils.showErrorMessage(errorMessage: "There was an error saving the General Tab Settings")
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
