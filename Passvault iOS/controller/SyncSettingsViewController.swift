//
//  SyncSettingsViewController.swift
//  Passvault iOS
//
//  Created by Erik Manor on 12/5/17.
//  Copyright © 2017 Erik Manor. All rights reserved.
//

import UIKit
import SVProgressHUD

class SyncSettingsViewController: UIViewController, UITextFieldDelegate {

    let NO_SYNC_MSG = "In order to sync passwords with the free service an account is needed. In order to create an account enter a valid email address/password and click Create. If a account already exists for this email address enter it along with the existing password and click Configure."
    
    let YES_SYNC_MSG = "An account to sync with the free service is already configured. To delete the account on this device along with removing the account on the free service click Delete. To remove the account from this device but keep the account active on the free service click Remove."
    
    let NO_SYNC_LEFT_BUTTON = "Create"
    let NO_SYNC_RIGHT_BUTTON = "Configure"
    
    let YES_SYNC_LEFT_BUTTON = "Delete"
    let YES_SYNC_RIGHT_BUTTON = "Remove"
    
    let EMAIL = 0
    let PASS = 1
    
    
    @IBOutlet weak var explanationLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    // support scrolling keyboard
    @IBOutlet var masterView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    var shifted = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let gateway = CoreDataUtils.loadGateway()
        
        if gateway.server != "" {
            // setup view for a gateway
            flipToYesGateway(gateway: gateway)
        } else {
            // setup view for no gateway
            flipToNoGateway()
        }
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        hideKeyboardOnTap()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(SyncSettingsViewController.keyboardWillShow(_:)),
                                               name: Notification.Name.UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(SyncSettingsViewController.keyboardWillHide(_:)),
                                               name: Notification.Name.UIKeyboardWillHide,
                                               object: nil)
        
        heightConstraint.constant = masterView.bounds.height
        outerView.layoutIfNeeded()
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        if !shifted {
            heightConstraint.constant -= (masterView.safeAreaInsets.bottom + masterView.safeAreaInsets.top)
            outerView.layoutIfNeeded()
            shifted = true
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func flipToYesGateway(gateway: Gateway) {
        explanationLabel.text = YES_SYNC_MSG
        leftButton.setTitle(YES_SYNC_LEFT_BUTTON, for: .normal)
        rightButton.setTitle(YES_SYNC_RIGHT_BUTTON, for: .normal)
        emailTextField.text = gateway.userName
        passwordTextField.text = gateway.password
        emailTextField.isEnabled = false
        passwordTextField.isEnabled = false
    }
    
    
    func flipToNoGateway() {
        explanationLabel.text = NO_SYNC_MSG
        leftButton.setTitle(NO_SYNC_LEFT_BUTTON, for: .normal)
        rightButton.setTitle(NO_SYNC_RIGHT_BUTTON, for: .normal)
        emailTextField.text = ""
        passwordTextField.text = ""
        emailTextField.isEnabled = true
        passwordTextField.isEnabled = true
    }
    
    
    func disableButtons() {
        leftButton.isEnabled = false
        rightButton.isEnabled = false
    }
    
    
    func enableButtons() {
        leftButton.isEnabled = true
        rightButton.isEnabled = true
    }
    
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    
    func verifyFields() -> Bool {
        let password = passwordTextField.text
        
        if password == nil || (password?.count)! < 1 || (password?.count)! > 64 {
            present(Utils.showErrorMessage(errorMessage: "Invalid password"), animated: true, completion: nil)
            return false
        }
        
        let email = emailTextField.text
        
        if email == nil || !isValidEmail(testStr: email!) {
            present(Utils.showErrorMessage(errorMessage: "Invalid email"), animated: true, completion: nil)
            return false
        }
        
        return true
    }

    
    @IBAction func leftButtonPressed(_ sender: UIButton) {
        disableButtons()
        
        if !verifyFields() {
            enableButtons()
            return
        }
        
        let email = emailTextField.text
        let password = passwordTextField.text
        
        if sender.title(for: .normal) == YES_SYNC_LEFT_BUTTON {
            // Delete Sync Account
            // call to sync server to delete account
            SVProgressHUD.show()
            let callStatusKey = SyncClient.deleteAccount(email: email!, password: password!)
            
            DispatchQueue.global(qos: .background).async {
                SyncClient.waitForCall(callStatusKey: callStatusKey)
                
                DispatchQueue.main.async {
                    if let error = SyncClient.jobsMap[callStatusKey]!.error {
                        SVProgressHUD.dismiss()
                        self.present(Utils.showErrorMessage(errorMessage: error.localizedDescription), animated: true, completion: nil)
                        
                        self.enableButtons()
                        return
                    }
                    
                    let returnMessage = SyncClient.jobsMap[callStatusKey]!.returned as! String
                    self.removeGatewayFromLocalConfig()
                    self.flipToNoGateway()
                    self.enableButtons()
                    SVProgressHUD.dismiss()
                    self.present(Utils.showMessage(message: returnMessage), animated: true, completion: nil)
                }
            }
            
        } else {
            // Create Sync Account
            SVProgressHUD.show()
            // make call to registration server
            let callStatusKey = SyncClient.createAccount(email: email!, password: password!)
            waitForGatewayConfig(callStatusKey: callStatusKey)
        }
    }
    
    
    @IBAction func rightButtonPressed(_ sender: UIButton) {
        disableButtons()
        
        if sender.title(for: .normal) == YES_SYNC_RIGHT_BUTTON {
            // Remove Sync Account
            removeGatewayFromLocalConfig()
            enableButtons()
        } else {
            // Configure for existing sync account
            if !verifyFields() {
                    enableButtons()
                    return
            }
            
            SVProgressHUD.show()
            let email = emailTextField.text
            let password = passwordTextField.text
            // make call to registration server
            let callStatusKey = SyncClient.getConfig(email: email!, password: password!)
            waitForGatewayConfig(callStatusKey: callStatusKey)
        }
    }
    
    
    func waitForGatewayConfig(callStatusKey: Int) {
        DispatchQueue.global(qos: .background).async {
            SyncClient.waitForCall(callStatusKey: callStatusKey)
            
            DispatchQueue.main.async {
                if let error = SyncClient.jobsMap[callStatusKey]!.error {
                    SVProgressHUD.dismiss()
                    self.present(Utils.showErrorMessage(errorMessage: error.localizedDescription), animated: true, completion: nil)
                    
                    self.enableButtons()
                    return
                }
                
                let gateway = SyncClient.jobsMap[callStatusKey]!.returned as! Gateway
                
                if CoreDataUtils.saveGateway(gateway: gateway) != CoreDataStatus.CoreDataSuccess {
                    print("Error saving gateway config to data store")
                    SVProgressHUD.dismiss()
                    self.present(Utils.showErrorMessage(errorMessage: "Error saving config to database"), animated: true, completion: nil)
                    
                    self.enableButtons()
                    return
                }
                
                self.flipToYesGateway(gateway: gateway)
                self.enableButtons()
                SVProgressHUD.dismiss()
            }
        }
    }
    
    
    func removeGatewayFromLocalConfig() {
        var settings = CoreDataUtils.loadGeneralSettings()
        settings.accountUUID = ""
        
        if CoreDataUtils.saveGeneralSettings(settings: settings) != CoreDataStatus.CoreDataSuccess {
            // just print and keep going
            print("Error saving GeneralSettings while removing sync account")
        }
        
        let gateway = Gateway()
        
        if CoreDataUtils.saveGateway(gateway: gateway) != CoreDataStatus.CoreDataSuccess {
            // just print and keep going
            print("Error saving Gateway while removing sync account")
        }
        
        flipToNoGateway()
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        switch textField.tag {
        case EMAIL:
            passwordTextField.becomeFirstResponder()
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
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
