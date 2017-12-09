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
    @IBOutlet weak var allowLowerSwitch: UISwitch!
    @IBOutlet weak var allowUpperSwitch: UISwitch!
    @IBOutlet weak var allowDigitsSwitch: UISwitch!
    @IBOutlet weak var specialsTextView: UITextView!
    
    let MAX_LENGTH = 64
    let MIN_LENGTH = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Get Generator from data store
        let generator = CoreDataUtils.getGenerator()
        let constraints = generator.contraints
        
        allowLowerSwitch.isOn = constraints?.lower ?? true
        allowUpperSwitch.isOn = constraints?.upper ?? true
        allowDigitsSwitch.isOn = constraints?.digits ?? true
        
        lengthStepper.maximumValue = 64
        lengthStepper.minimumValue = 1
        lengthStepper.stepValue = 1
        lengthStepper.value = Double(generator.length)
        lengthLabel.text = String(generator.length)
        //lengthStepper.value = 32
        //lengthLabel.text = "32"
        
        for s in generator.getSpecials() {
            specialsTextView.text.append(" \(s)")
        }
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
