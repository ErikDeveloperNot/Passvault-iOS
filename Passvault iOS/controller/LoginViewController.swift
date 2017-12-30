//
//  ViewController.swift
//  Passvault iOS
//
//  Created by Erik Manor on 11/26/17.
//  Copyright © 2017 Erik Manor. All rights reserved.
//

import UIKit
import CoreData


// hide the keyboard throughout app on tap
extension UIViewController {
    
    func hideKeyboardOnTap() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
 }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    //let PURGE_SLEEP: UInt32 = 86400
    let PURGE_SLEEP: UInt32 = 60        
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    var accounts: [Account]?
    var key: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        let settings = CoreDataUtils.loadGeneralSettings()
        
        // check if key is saved
        if settings.saveKey {
            key = settings.key
            
            if key == "" {
                print("Save key set, but key is not set, going to login")
            } else {
                accounts = populateAccountsList(usingKey: key!)
                performSegue(withIdentifier: "goToAccounts", sender: nil)
            }
        }
        
        DispatchQueue.global(qos: .background).async {
            while true {
                // run purge
                DispatchQueue.main.async {
                    let settings = CoreDataUtils.loadGeneralSettings()
                    let days = settings.purgeDays
                    CoreDataUtils.purgeDeletes(olderThenDays: days)
                }
                
                //usleep(self.PURGE_SLEEP)
                sleep(self.PURGE_SLEEP)
            }
        }
     
        passwordTextField.delegate = self
        hideKeyboardOnTap()
    }


    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        login()
        performSegue(withIdentifier: "goToAccounts", sender: self)
        textField.resignFirstResponder()
        return true
    }


    @IBAction func loginPressed(_ sender: UIButton) {
        login()
    }
    
    
    private func login() {
        key = Crypt.finalizeKey(key: passwordTextField.text!)
        accounts = populateAccountsList(usingKey: key!)
    }
    
    
    private func populateAccountsList(usingKey key: String) -> [Account] {
        CoreDataUtils.key = key
        
        do {
            let accounts = try CoreDataUtils.loadAllAccounts()
            return accounts
        } catch {
            print("Error Loading Accounts, error: \(error)")
            present(Utils.showErrorMessage(errorMessage: "Error loading accounts"), animated: true, completion: nil)
        }
        
        return []
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToAccounts" {
            let destination = segue.destination as! AccountsListViewController
            destination.accounts = accounts!
            destination.key = key!
            //print("key=\(key!) accounts=\(accounts!.count)" )
        }
    }
}

