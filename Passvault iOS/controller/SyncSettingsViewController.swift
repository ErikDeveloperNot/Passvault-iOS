//
//  SyncSettingsViewController.swift
//  Passvault iOS
//
//  Created by User One on 12/5/17.
//  Copyright © 2017 User One. All rights reserved.
//

import UIKit
import SVProgressHUD

class SyncSettingsViewController: UIViewController {

    let NO_SYNC_MSG = "In order to sync passwords with the free service an account is needed. In order to create an account enter a valid email address/password and click Create. If a account already exists for this email address enter it along with the existing password and click Configure."
    
    let YES_SYNC_MSG = "An account to sync with the free service is already configured. To delete the account on this device along with removing the account on the free service click Delete. To remove the account from this device but keep the account active on the free service click Remove."
    
    let NO_SYNC_LEFT_BUTTON = "Create"
    let NO_SYNC_RIGHT_BUTTON = "Configure"
    
    let YES_SYNC_LEFT_BUTTON = "Delete"
    let YES_SYNC_RIGHT_BUTTON = "Remove"
    
    let INTERVAL_SLEEP: useconds_t = 250000
    
    @IBOutlet weak var explanationLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    
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
    }
    
    
    func flipToNoGateway() {
        explanationLabel.text = NO_SYNC_MSG
        leftButton.setTitle(NO_SYNC_LEFT_BUTTON, for: .normal)
        rightButton.setTitle(NO_SYNC_RIGHT_BUTTON, for: .normal)
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    
    func waitForCall(callStatusKey: Int) {
        var running = true
        
        while running {
            let status = SyncClient.jobsMap[callStatusKey]!
            
            if status.running {
                usleep(self.INTERVAL_SLEEP)
            } else {
                running = false
            }
        }
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
        
        if sender.title(for: .normal) == YES_SYNC_LEFT_BUTTON {
            // Delete Sync Account
            // call to sync server to delete account
            
            // remove local gateway config
            removeGatewayFromLocalConfig()
        } else {
            // Create Sync Account
            SyncClient.test()
        }
    }
    
    
    @IBAction func rightButtonPressed(_ sender: UIButton) {
        
        if sender.title(for: .normal) == YES_SYNC_RIGHT_BUTTON {
            // Remove Sync Account
            removeGatewayFromLocalConfig()
        } else {
            // Configure for existing sync account
            if !verifyFields() {
                    return
            }
            
            let email = emailTextField.text
            let password = passwordTextField.text
            // make call to registration server
            let callStatusKey = SyncClient.getConfig(email: email!, password: password!)
            SVProgressHUD.show()
            
            DispatchQueue.global(qos: .background).async {
                self.waitForCall(callStatusKey: callStatusKey)
                
                DispatchQueue.main.async {
                    if let error = SyncClient.jobsMap[callStatusKey]!.error {
                        SVProgressHUD.dismiss()
                        self.present(Utils.showErrorMessage(errorMessage: "There was an error getting the server configuration"), animated: true, completion: nil)
                        
                        return
                    }
                    
                    let gateway = SyncClient.jobsMap[callStatusKey]!.returned as! Gateway
                    
                    if CoreDataUtils.saveGateway(gateway: gateway) != CoreDataStatus.CoreDataSuccess {
                        print("Error saving gateway config to data store")
                        SVProgressHUD.dismiss()
                        self.present(Utils.showErrorMessage(errorMessage: "Error saving config to database"), animated: true, completion: nil)
                        
                        return
                    }
  
                    self.flipToYesGateway(gateway: gateway)
                    SVProgressHUD.dismiss()
                }
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
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
