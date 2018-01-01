//
//  AddAccountViewController.swift
//  Passvault iOS
//
//  Created by Erik Manor on 12/7/17.
//  Copyright © 2017 Erik Manor. All rights reserved.
//

import UIKit

class AddAccountViewController: UIViewController, UITextFieldDelegate {
    
    let NAME = 0
    let USER = 1
    let URL = 2
    let PASS1 = 3
    let PASS2 = 4

    @IBOutlet weak var accountNameTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordTextField2: UITextField!
    
    // used to support scrolling to show textfields when keyboard is present
    @IBOutlet var masterView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    var account: Account?
    var accountAdded: Bool = false
    
    // only used when override generator is used
    var generator: RandomPasswordGenerator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        accountNameTextField.delegate = self
        userNameTextField.delegate = self
        urlTextField.delegate = self
        passwordTextField.delegate = self
        passwordTextField2.delegate = self
        
        hideKeyboardOnTap()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(AddAccountViewController.keyboardWillShow(_:)),
                                               name: Notification.Name.UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(AddAccountViewController.keyboardWillHide(_:)),
                                               name: Notification.Name.UIKeyboardWillHide,
                                               object: nil)
        
        heightConstraint.constant = masterView.bounds.height
        outerView.layoutIfNeeded()
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        heightConstraint.constant -= (masterView.safeAreaInsets.bottom + masterView.safeAreaInsets.top)
        outerView.layoutIfNeeded()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func generatePressed(_ sender: UIButton) {
        
        if generator == nil {
            generator = CoreDataUtils.getGenerator()
        }
        
        let pword = generator!.generatePassword()
        passwordTextField.text = pword
        passwordTextField2.text = pword
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
        
        account = Account(accountName: accountName!, userName: userName!, password: password!, url: Utils.addURLProtocol(forURL: url!))
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
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        switch textField.tag {
        case NAME:
            userNameTextField.becomeFirstResponder()
            break
        case USER:
            urlTextField.becomeFirstResponder()
            break
        case URL:
            passwordTextField.becomeFirstResponder()
            break
        case PASS1:
            passwordTextField2.becomeFirstResponder()
            break
        case PASS2:
            break
        default:
            break
        }
        
        return true
    }
    
    
    // MARK: - Scrolling for keyboard support
    
    
    @objc func keyboardWillShow(_ notification: Notification) {
        Utils.adjustInsetForKeyboardShow(true, notification: notification, scrollView: scrollView)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        Utils.adjustInsetForKeyboardShow(false, notification: notification, scrollView: scrollView)
    }

    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "goToGenerator" {
            let controller = segue.destination as! PasswordGeneratorSettingsViewController
            controller.sendingController = SendingController.AddAccount
        }
    }
 
    
    
    @IBAction func unwindToAddFromOverride(sender: UIStoryboardSegue) {
        print(sender.source)
        generator = (sender.source as! PasswordGeneratorSettingsViewController).generator
    }

}
