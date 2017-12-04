//
//  AccountDetailsViewController.swift
//  Passvault iOS
//
//  Created by User One on 11/30/17.
//  Copyright © 2017 User One. All rights reserved.
//

import UIKit

class AccountDetailsViewController: UIViewController {

    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordTextField2: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    
    var account: Account?
    
    
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
        print("Result of SaveAccount=\(CoreDataUtils.saveAccount(forAccount: account!))")
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        
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
