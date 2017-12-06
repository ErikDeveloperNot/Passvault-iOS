//
//  PasswordGeneratorSettingsViewController.swift
//  Passvault iOS
//
//  Created by User One on 12/5/17.
//  Copyright © 2017 User One. All rights reserved.
//

import UIKit

class PasswordGeneratorSettingsViewController: UIViewController {

    
    @IBOutlet weak var lengthLabel: UILabel!
    @IBOutlet weak var lengthStepper: UIStepper!
   
    let maxLength = 64
    let minLength = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        lengthStepper.maximumValue = 64
        lengthStepper.minimumValue = 1
        lengthStepper.stepValue = 1
        lengthStepper.value = 32
        lengthLabel.text = "32"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func lengthStepperValueChanged(_ sender: UIStepper) {
        lengthLabel.text = String(Int(sender.value))
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
