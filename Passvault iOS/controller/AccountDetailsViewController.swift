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
    
    var accountName: String = ""
    var url: String = ""
    var password: String = ""
    var oldPassword: String = ""
    var validEncryption = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        accountNameLabel.text = accountName
        urlTextField.text = url
        passwordTextField.text = password
        passwordTextField2.text = password
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
    }
    
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        Utils.deletePasswordsFromClipboard()
    }
    
    
    @IBAction func copyButtonPressed(_ sender: Any) {
        Utils.copyToClipboard(toCopy: passwordTextField.text!)
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
