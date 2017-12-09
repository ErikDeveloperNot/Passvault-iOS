//
//  AddAccountViewController.swift
//  Passvault iOS
//
//  Created by User One on 12/7/17.
//  Copyright © 2017 User One. All rights reserved.
//

import UIKit

class AddAccountViewController: UIViewController {

    @IBOutlet weak var accountNameTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordTextField2: UITextField!
    
    var account: Account?
    var accountAdded: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func generatePressed(_ sender: UIButton) {
        let generator = CoreDataUtils.getGenerator()
        let password = generator.generatePassword()
        passwordTextField.text = password
        passwordTextField2.text = password
    }
    
    
    @IBAction func overridePressed(_ sender: UIButton) {
    }
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func savePressed(_ sender: UIBarButtonItem) {
        let accountName = accountNameTextField.text
        let userName = userNameTextField.text
        let url = urlTextField.text
        let password = passwordTextField.text
        let password2 = passwordTextField2.text
        
        if accountName == "" || userName == "" || password == "" || password2 == "" {
            present(Utils.showErrorMessage(errorMessage: "Account name, user name, and both password fields must contain values"), animated: true, completion: nil)
            return
        }
        
        if password != password2 {
            present(Utils.showErrorMessage(errorMessage: "Passwords don't match"), animated: true, completion: nil)
            return
        }
        
        account = Account(accountName: accountName!, userName: userName!, password: password!, url: url!)
        let status = CoreDataUtils.saveNewAccount(forAccount: account!)
        
        if status != CoreDataStatus.AccountCreated {
            if status == CoreDataStatus.AccountAlreadyExists {
                present(Utils.showErrorMessage(errorMessage: "An account with the same account name already exists"), animated: true, completion: nil)
            } else {
                present(Utils.showErrorMessage(errorMessage: "Error saving account"), animated: true, completion: nil)
            }
            
            return
        }
        
        accountAdded = true
        self.performSegue(withIdentifier: "unwindToAccountsList", sender: self)
        //self.dismiss(animated: true, completion: nil)
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
