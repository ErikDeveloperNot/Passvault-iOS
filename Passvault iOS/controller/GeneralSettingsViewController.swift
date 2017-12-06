//
//  GeneralSettingsViewController.swift
//  Passvault iOS
//
//  Created by User One on 12/5/17.
//  Copyright © 2017 User One. All rights reserved.
//

import UIKit


struct GeneralSettings {
    var saveKey: Bool = false
    var sortByMRU: Bool = true
    
    init(saveKey: Bool, sortByMRU: Bool) {
        self.saveKey = saveKey
        self.sortByMRU = sortByMRU
    }
    
    init() {
        
    }
}

class GeneralSettingsViewController: UIViewController {

    @IBOutlet weak var saveKeySwitch: UISwitch!
    @IBOutlet weak var sortMRUSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let settings = CoreDataUtils.loadGeneralSettings()
        saveKeySwitch.isOn = settings.saveKey
        sortMRUSwitch.isOn = settings.sortByMRU
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
