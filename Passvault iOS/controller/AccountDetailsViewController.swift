//
//  AccountDetailsViewController.swift
//  Passvault iOS
//
//  Created by Erik Manor on 11/30/17.
//  Copyright © 2017 Erik Manor. All rights reserved.
//

import UIKit

class AccountDetailsViewController: UIViewController, UITextFieldDelegate {
    
    let USER = 0
    let URL = 1
    let PASS1 = 2
    let PASS2 = 3
    

    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordTextField2: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    
    // support keyboard scrolling
    @IBOutlet var masterView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    var shifted = false
    
    var account: Account?
    var deleted: Bool = false
    
    // only used if override generator is used
    var generator: RandomPasswordGenerator?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        accountNameLabel.text = account?.accountName
        urlTextField.text = account?.url
        passwordTextField.text = account?.password
        passwordTextField2.text = account?.password
        userNameTextField.text = account?.userName
        
        urlTextField.delegate = self
        userNameTextField.delegate = self
        passwordTextField.delegate = self
        passwordTextField2.delegate = self
        
        hideKeyboardOnTap()
        heightConstraint.constant = masterView.bounds.height
        outerView.layoutIfNeeded()
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(AccountDetailsViewController.keyboardWillShow(_:)),
                                               name: Notification.Name.UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(AccountDetailsViewController.keyboardWillHide(_:)),
                                               name: Notification.Name.UIKeyboardWillHide,
                                               object: nil)
        
        if !shifted {
            heightConstraint.constant -= (masterView.safeAreaInsets.bottom + masterView.safeAreaInsets.top)
            outerView.layoutIfNeeded()
            shifted = true
        }
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        //self.dismiss(animated: true, completion: nil)
        deleted = false
        self.performSegue(withIdentifier: "unwindToAccounts", sender: self)
    }
    
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
        if userNameTextField.text! == "" || passwordTextField.text! == "" || passwordTextField2.text! == "" {
            present(Utils.showErrorMessage(errorMessage: "Account name, user name, and both password fields must contain values"), animated: true, completion: nil)
            return
        }
        
        if passwordTextField.text! != passwordTextField2.text! {
            present(Utils.showErrorMessage(errorMessage: "Passwords don't match"), animated: true, completion: nil)
            return
        }
        
        account?.userName = userNameTextField.text!
        account?.password = passwordTextField.text!
        account?.url = Utils.addURLProtocol(forURL: urlTextField.text!)
        account?.updateTime = Utils.currentTimeMillis()
        
        print("Result of SaveAccount=\(CoreDataUtils.updateAccount(forAccount: account!, passwordEncrypted: false))")
        
        //self.dismiss(animated: true, completion: nil)
        deleted = false
        self.performSegue(withIdentifier: "unwindToAccounts", sender: self)
    }
    
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        deleted = true
        //unwindToAccounts
        self.performSegue(withIdentifier: "unwindToAccounts", sender: self)
    }
   
    
    @IBAction func generatePressed(_ sender: UIButton) {
        
        if generator == nil {
            generator = CoreDataUtils.getGenerator()
        }
        
        let pword = generator!.generatePassword()
        passwordTextField.text = pword
        passwordTextField2.text = pword
        
    }
    
    
    @IBAction func optionsPressed(_ sender: UIButton) {

    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        switch textField.tag {
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
    
    
    // MARK: - Support Keyboard Scrolling
    
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
        if segue.identifier == "unwindToAccounts" {
            
        } else if segue.identifier == "goToGenerator" {
            let controller = segue.destination as! PasswordGeneratorSettingsViewController
            controller.sendingController = SendingController.EditAccount
        }
        
    }
    

    
    @IBAction func unwindToDetailsFromOverride(sender: UIStoryboardSegue) {
        print(sender.source)
        generator = (sender.source as! PasswordGeneratorSettingsViewController).generator
    }
}
