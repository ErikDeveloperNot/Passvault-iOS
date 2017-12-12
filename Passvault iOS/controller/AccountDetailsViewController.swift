//
//  AccountDetailsViewController.swift
//  Passvault iOS
//
//  Created by Erik Manor on 11/30/17.
//  Copyright © 2017 Erik Manor. All rights reserved.
//

import UIKit

class AccountDetailsViewController: UIViewController {

    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordTextField2: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    
    var account: Account?
    var deleted: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        accountNameLabel.text = account?.accountName
        urlTextField.text = account?.url
        passwordTextField.text = account?.password
        passwordTextField2.text = account?.password
        userNameTextField.text = account?.userName
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func saveButtonPressed(_ sender: Any) {
// TODO - chack values, passwords match, etc
        account?.userName = userNameTextField.text!
        account?.password = passwordTextField.text!
        account?.url = urlTextField.text!
        account?.updateTime = Utils.currentTimeMillis()
        print("Result of SaveAccount=\(CoreDataUtils.saveNewAccount(forAccount: account!))")
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        deleted = true
        //unwindToAccounts
        self.performSegue(withIdentifier: "unwindToAccounts", sender: self)
    }
   
    
    @IBAction func generatePressed(_ sender: UIButton) {
        let generator = CoreDataUtils.getGenerator()
        let pword = generator.generatePassword()
        passwordTextField.text = pword
        passwordTextField2.text = pword
    }
    
    
    @IBAction func optionsPressed(_ sender: UIButton) {
// TODO
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
