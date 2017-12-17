//
//  PasswordGeneratorSettingsViewController.swift
//  Passvault iOS
//
//  Created by Erik Manor on 12/5/17.
//  Copyright © 2017 Erik Manor. All rights reserved.
//

import UIKit


enum SendingController {
    case AddAccount
    case EditAccount
}

class PasswordGeneratorSettingsViewController: UIViewController {

    
    @IBOutlet weak var lengthLabel: UILabel!
    @IBOutlet weak var lengthStepper: UIStepper!
    @IBOutlet weak var allowLowerSwitch: UISwitch!
    @IBOutlet weak var allowUpperSwitch: UISwitch!
    @IBOutlet weak var allowDigitsSwitch: UISwitch!
    @IBOutlet weak var specialsTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    let MAX_LENGTH = 64.0
    let MIN_LENGTH = 4.0
    
    // used only when override generator initializes controller
    var sendingController: SendingController?
    var generator: RandomPasswordGenerator?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Get Generator from data store
        let generator = CoreDataUtils.getGenerator()
        let constraints = generator.contraints
        
        allowLowerSwitch.isOn = constraints?.lower ?? true
        allowUpperSwitch.isOn = constraints?.upper ?? true
        allowDigitsSwitch.isOn = constraints?.digits ?? true
        
        lengthStepper.maximumValue = MAX_LENGTH
        lengthStepper.minimumValue = MIN_LENGTH
        lengthStepper.stepValue = 1
        lengthStepper.value = Double(generator.length)
        lengthLabel.text = String(generator.length)
        //lengthStepper.value = 32
        //lengthLabel.text = "32"
        
        for s in generator.getSpecials() {
            specialsTextView.text.append(" \(s)")
        }
        
        print("parent = \(self.parent)")
        
        if self.parent == nil {
            saveButton.isHidden = false
            saveButton.isEnabled = true
            cancelButton.isHidden = false
            cancelButton.isEnabled = true
        } else {
            saveButton.isHidden = true
            saveButton.isEnabled = false
            cancelButton.isHidden = true
            cancelButton.isEnabled = false
        }
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func lengthStepperValueChanged(_ sender: UIStepper) {
        lengthLabel.text = String(Int(sender.value))
    }
    
    
    func setGenerator() {
        var allowedCharacters: [String] = []
        
        if allowLowerSwitch.isOn {
            allowedCharacters.append(contentsOf: RandomPasswordGenerator.DEFAULT_LOWER)
        }
        if allowUpperSwitch.isOn {
            allowedCharacters.append(contentsOf: RandomPasswordGenerator.DEFAULT_UPPER)
        }
        if allowDigitsSwitch.isOn {
            allowedCharacters.append(contentsOf: RandomPasswordGenerator.DEFAULT_DIGITS)
        }
        
        let specialsText = specialsTextView.text
        
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
        
        let length = Int32(lengthLabel.text!)
        
        // if allowed chars has nothing in it then allow lower/upper/digits
        if allowedCharacters.count < 1 {
            allowedCharacters.append(contentsOf: RandomPasswordGenerator.DEFAULT_LOWER)
            allowedCharacters.append(contentsOf: RandomPasswordGenerator.DEFAULT_UPPER)
            allowedCharacters.append(contentsOf: RandomPasswordGenerator.DEFAULT_DIGITS)
        }
        
        generator = RandomPasswordGenerator()
        generator?.changeGenertorSpecs(allowedCharacters: allowedCharacters, passwordLength: length ?? RandomPasswordGenerator.DEFAULT_LENGTH)
        
    }
    
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        setGenerator()
        unwind()
        /*
        if sendingController == SendingController.AddAccount {
            //unwindToAddFromOverrideWithSender
            performSegue(withIdentifier: "unwindToAddFromOverrideWithSender", sender: self)
        } else {
            //unwindToDetailsFromOverrideWithSender
            performSegue(withIdentifier: "unwindToDetailsFromOverrideWithSender", sender: self)
        }
 */
    }
    
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        generator = nil
        unwind()
    }
    
    
    func unwind() {
        if sendingController == SendingController.AddAccount {
            //unwindToAddFromOverrideWithSender
            performSegue(withIdentifier: "unwindToAddFromOverrideWithSender", sender: self)
        } else {
            //unwindToDetailsFromOverrideWithSender
            performSegue(withIdentifier: "unwindToDetailsFromOverrideWithSender", sender: self)
        }
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
