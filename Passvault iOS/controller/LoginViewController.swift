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
    
    let PURGE_SLEEP: UInt32 = 86400
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    // keyboard scrolling support
    @IBOutlet var masterView: UIView!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    var shifted = false
    
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
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(LoginViewController.keyboardWillShow(_:)),
                                               name: Notification.Name.UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(LoginViewController.keyboardWillHide(_:)),
                                               name: Notification.Name.UIKeyboardWillHide,
                                               object: nil)
        
        heightConstraint.constant = masterView.bounds.height
        outerView.layoutIfNeeded()
    }

    // not sure if this is a hack or the way it needs to be done
    override func viewDidAppear(_ animated: Bool) {
        if !shifted {
            heightConstraint.constant -= (masterView.safeAreaInsets.bottom + masterView.safeAreaInsets.top)
            outerView.layoutIfNeeded()
            shifted = true
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
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
    
    
    @objc func keyboardWillShow(_ notification: Notification) {
        Utils.adjustInsetForKeyboardShow(true, notification: notification, scrollView: scrollView)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        Utils.adjustInsetForKeyboardShow(false, notification: notification, scrollView: scrollView)
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

