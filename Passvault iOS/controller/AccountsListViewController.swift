//
//  AccountsListController.swift
//  Passvault iOS
//
//  Created by User One on 11/28/17.
//  Copyright © 2017 User One. All rights reserved.
//

import UIKit

class AccountsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var accountsTableView: UITableView!
    
    var accounts: [Account] = []
    var key: String?
    var selectedAccount: Account?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        accountsTableView.delegate = self
        accountsTableView.dataSource = self

        print("KEY=\(key), Number of accounts=\(accounts.count)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Mark: - TableView implementation
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (accounts.count)
        //return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellReuseIdentifier")!
        
        let accountName = accounts[indexPath.row].accountName
        
        cell.textLabel?.text = accountName
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            // will end up showing a confirm but for now just delete https://www.andrewcbancroft.com/2015/07/16/uitableview-swipe-to-delete-workflow-in-swift/
            
            accountsTableView.beginUpdates()
            accounts.remove(at: indexPath.row)
            accountsTableView.deleteRows(at: [indexPath], with: .automatic)
            accountsTableView.endUpdates()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Row selected: \(indexPath.row)")
        selectedAccount = accounts[indexPath.row]
        performSegue(withIdentifier: "goToDetails", sender: self)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToDetails" {
            let destination = segue.destination as! AccountDetailsViewController
            
            if let account = selectedAccount {
                destination.accountName = account.accountName
                destination.url = account.url
                
                do {
                    destination.password = try Crypt.decryptString(key: key!, forEncrypted: account.password)
                } catch {
                    print("Error decrypting password for: \(account.accountName), \(error)")
                    destination.validEncryption = false;
                    destination.password = account.password
                }
              
                do {
                    destination.oldPassword = try Crypt.decryptString(key: key!, forEncrypted: account.oldPassword)
                } catch {
                    print("Error decrypting old password for: \(account.accountName), \(error)")
                    
                    if destination.validEncryption {
                        destination.oldPassword = destination.password
                    } else {
                        destination.oldPassword = account.oldPassword
                    }
                    
                }
            }
        }
    }
    

}
