//
//  AccountsListController.swift
//  Passvault iOS
//
//  Created by Erik Manor on 11/28/17.
//  Copyright © 2017 Erik Manor. All rights reserved.
//

import UIKit
import SVProgressHUD

class AccountsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let INVALID_ENCRYPTION_MESSAGE = "Tha password for this account could not be decrypted with the login key entered. If the incorrect key was entered at login, logout and log back in. If this account was setup with a different login key then what is currently being used, the account can be recovered by entering the key used to encrypt this account. Press the decrypt button to enter the key. If the key is unknown, the other options are to delete the account, or just cancel and leave the account in this state."
    
    @IBOutlet weak var accountsTableView: UITableView!
    @IBOutlet weak var syncButton: UIBarButtonItem!
    
    var accounts: [Account] = []
    var key: String?
    var sortType: SortType = SortType.Alpha
    
    // used for tableview
    var selectedAccount: Account?
    var expanded: Bool = false
    var expandedIndex: Int = -1
    var expandedRows: [Int] = []
    
    // used by AccountDetailsViewController to flag that an account has been deleted and index
    var accountDeletedFromDetails: Bool = false
    var accountSentToDetailsIndexPath: IndexPath?
   
    override func viewDidLoad() {
        super.viewDidLoad()

        accountsTableView.delegate = self
        accountsTableView.dataSource = self

        accountsTableView.register(UINib(nibName: "AccountTableViewCell", bundle: nil), forCellReuseIdentifier: "accountCellReuseIdentifier")
        accountsTableView.register(UINib(nibName: "ButtonTableViewCell", bundle: nil), forCellReuseIdentifier: "buttonCellReuseIdentifier")
        
        if CoreDataUtils.loadGateway().server != "" {
            syncButton.isEnabled = true
        } else {
            syncButton.isEnabled = false
        }
        
        if CoreDataUtils.loadGeneralSettings().sortByMRU {
            sortType = SortType.MOA
        }
        
        MRAComparator.getInstance().debugMaps()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if CoreDataUtils.loadGateway().server != "" {
            syncButton.isEnabled = true
        } else {
            syncButton.isEnabled = false
        }

        accounts = Utils.sort(accounts: accounts, sortType: sortType)
        resetExpandedRows()
        accountsTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - TableView Implementations
    //
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if expanded {
            return accounts.count + expandedRows.count
        } else {
            return accounts.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellToReturn: UITableViewCell?
        
        if expanded {
            if indexPath.row <= expandedIndex {
                let cell = tableView.dequeueReusableCell(withIdentifier: "accountCellReuseIdentifier")! as! AccountTableViewCell
                let accountName = accounts[indexPath.row].accountName
                setAccountTableViewCellTextColor(forCell: cell, validEncryption: accounts[indexPath.row].validEncryption)
                cell.accountNameLabel.text = accountName
                cellToReturn = cell
            } else {
                if expandedRows.contains(indexPath.row) {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "buttonCellReuseIdentifier")! as! ButtonTableViewCell
                    
                    if expandedRows.count == 3 {
                        if indexPath.row == expandedIndex + 1 {
                            cell.buttonLabel.text = "Copy Password"
                        } else if indexPath.row == expandedIndex + 2 {
                            cell.buttonLabel.text = "Copy Old Password"
                        } else {
                            cell.buttonLabel.text = "Browser"
                        }
                    } else {
                        if indexPath.row == expandedIndex + 1 {
                            cell.buttonLabel.text = "Copy Password"
                        } else {
                            cell.buttonLabel.text = "Copy Old Password"
                        }
                    }
                    
                    cellToReturn = cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "accountCellReuseIdentifier")! as! AccountTableViewCell
                    let accountName = accounts[indexPath.row - expandedRows.count].accountName
                    cell.accountNameLabel.text = accountName
                    setAccountTableViewCellTextColor(forCell: cell, validEncryption: accounts[indexPath.row - expandedRows.count].validEncryption)
                    cellToReturn = cell
                }
            }
        } else {
            let accountName = accounts[indexPath.row].accountName
            let cell = tableView.dequeueReusableCell(withIdentifier: "accountCellReuseIdentifier")! as! AccountTableViewCell
            cell.accountNameLabel.text = accountName
            setAccountTableViewCellTextColor(forCell: cell, validEncryption: accounts[indexPath.row].validEncryption)
            cellToReturn = cell
        }

        return cellToReturn!
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if expandedRows.contains(indexPath.row) {
            return CGFloat(80.0)
        } else {
            return CGFloat(44.0)
        }
        
        //return CGFloat(#your desired size#)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /*
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            // will end up showing a confirm but for now just delete https://www.andrewcbancroft.com/2015/07/16/uitableview-swipe-to-delete-workflow-in-swift/
            
            accountsTableView.beginUpdates()
            accounts.remove(at: indexPath.row)
            accountsTableView.deleteRows(at: [indexPath], with: .automatic)
            accountsTableView.endUpdates()
        }
    }
    */
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Row selected: \(indexPath.row)")
        var reloadData = true
        
        if expanded {
            if indexPath.row == expandedIndex {
                resetExpandedRows()
            } else {
                if indexPath.row < expandedIndex {
                    if !accounts[indexPath.row].validEncryption {
                        reloadData = false
                        handleInvalidEncryption(forAccountIndex: indexPath.row, indexPath: indexPath)
                    } else {
                        expandedIndex = indexPath.row
                        setExpandedRows(forIndex: expandedIndex)
                    }
                } else {
                    if expandedRows.contains(indexPath.row) {
                        
//                        if !accounts[expandedIndex].validEncryption {
//                            // do nothing, just return
//                            return
//                        }
                        MRAComparator.getInstance().incrementAccessCount(forAccount: accounts[expandedIndex].accountName)
                        
                        switch indexPath.row {
                        case expandedIndex+1:
                            Utils.copyToClipboard(toCopy: accounts[expandedIndex].password)
                            break
                        case expandedIndex+2:
                            Utils.copyToClipboard(toCopy: accounts[expandedIndex].oldPassword)
                            break
                        case expandedIndex+3:
                            Utils.copyToClipboard(toCopy: accounts[expandedIndex].password)
                            
                            if !Utils.launchBrowser(forURL: accounts[expandedIndex].url) {
                                present(Utils.showErrorMessage(errorMessage: "Unable to open browser for: \(accounts[expandedIndex].url))"), animated: true, completion: nil)
                            }
                            
                            break
                        default:
                            print("Invalid Button label")
                        }
                        
                        resetExpandedRows()
                    
                        if sortType == SortType.MOA {
                            accounts = Utils.sort(accounts: accounts, sortType: sortType)
                        }
                        
                        
                    } else {
                        if !accounts[indexPath.row - expandedRows.count].validEncryption {
                            reloadData = false
                            handleInvalidEncryption(forAccountIndex: indexPath.row - expandedRows.count, indexPath: indexPath)
                        } else {
                            expandedIndex = indexPath.row - expandedRows.count
                            setExpandedRows(forIndex: expandedIndex)
                        }
                    }
                }
            }
        } else {
            if !accounts[indexPath.row].validEncryption {
                reloadData = false
                handleInvalidEncryption(forAccountIndex: indexPath.row, indexPath: indexPath)
            } else {
                expanded = true
                expandedIndex = indexPath.row
                setExpandedRows(forIndex: expandedIndex)
            }
        }
        
        if reloadData {
            accountsTableView.reloadData()
            var scrollIndex = indexPath.row
            
            if expandedRows.count > 0 {
                scrollIndex = expandedRows[expandedRows.count - 1]
            }
            
            //let scrollToIndex = IndexPath(row: indexPath.row + expandedRows.count, section: 0)
            let scrollToIndex = IndexPath(row: scrollIndex, section: 0)
            
            if expanded && !expandedRows.contains(indexPath.row) {
                accountsTableView.scrollToRow(at: scrollToIndex, at: .none, animated: true)
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        if expanded && expandedRows.contains(indexPath.row) {
            return []
        }
        
       
        let edit = UITableViewRowAction(style: .default, title: "Edit") { (edit, indexPath) in
            print("Edit Action Selected")
            var index = indexPath.row
            
            if self.expanded && self.expandedIndex < index {
                index -= self.expandedRows.count
            }
            
            self.selectedAccount = self.accounts[index]
            self.accountSentToDetailsIndexPath = indexPath
            self.performSegue(withIdentifier: "goToDetails", sender: self)
        }
        edit.backgroundColor = UIColor.lightGray
        
        // delete is always shown
        let delete = UITableViewRowAction(style: .default, title: "Delete") { (delete, indexPath) in
            self.deleteAccount(indexPath: indexPath)
        }
        delete.backgroundColor = UIColor.red
        
        return [delete, edit]
    }
    
    /*func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row%5 == 0 {
            return 70.0
        } else {
            return 45.0
        }
    }*/
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToDetails" {
            let destination = segue.destination as! AccountDetailsViewController
            
            if let account = selectedAccount {
                destination.account = account
            }
        } else if segue.identifier == "goToSettings" {
            let destination = segue.destination as! SettingsTabBarController
            destination.accountListViewController = self
        }
    }
    
    // called from Accontdetails to signal if account has been deleted
    @IBAction func unwindFromDetailsController(sender: UIStoryboardSegue) {
        if let accountDetailsViewController = sender.source as? AccountDetailsViewController {
            accountDeletedFromDetails = accountDetailsViewController.deleted
            //print("DELETED=\(accountDeletedFromDetails), for accout: \(selectedAccount)")
            if accountDeletedFromDetails {
                if let indexPath = accountSentToDetailsIndexPath {
                    deleteAccount(indexPath: indexPath)
                }
            }
            
            accountDeletedFromDetails = false
        }
    }
    
    // called from addAccount to return a new account
    @IBAction func unwindFromAddController(sender: UIStoryboardSegue) {
        if let addAccountViewController = sender.source as? AddAccountViewController {
            let accountAdded = addAccountViewController.accountAdded
            //print("DELETED=\(accountDeletedFromDetails), for accout: \(selectedAccount)")
            if accountAdded {
                let account = addAccountViewController.account
                accounts.append(account!)
                accounts = Utils.sort(accounts: accounts, sortType: sortType)
                accountsTableView.reloadData()
            }
        }
    }
    
    
    @IBAction func syncButtonPressed(_ sender: UIBarButtonItem) {
        SVProgressHUD.show()
        let callStatusKey = SyncClient.syncAccounts()
        
        if callStatusKey == -1 {
            self.present(Utils.showErrorMessage(errorMessage: "Unable to run sync right now"), animated: true, completion: nil)
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            SyncClient.waitForCall(callStatusKey: callStatusKey)
            
            DispatchQueue.main.async {
                if let error = SyncClient.jobsMap[callStatusKey]!.error {
                    SVProgressHUD.dismiss()
                    self.present(Utils.showErrorMessage(errorMessage: error.localizedDescription), animated: true, completion: nil)
                    return
                }
                
                do {
                    self.accounts = try CoreDataUtils.loadAllAccounts()
                    self.accountsTableView.reloadData()
                    SVProgressHUD.dismiss()
                    self.present(Utils.showMessage(message: "Accounts Synchronized"), animated: true, completion: nil)
                } catch {
                    self.present(Utils.showErrorMessage(errorMessage: "Error loading accounts"), animated: true, completion: nil)
                }
            }
        }
    }
   
    
    // MARK: utility functions
    //
    
    func deleteAccount(indexPath: IndexPath) {
        var deleteRowIndexes: [IndexPath] = []
        
        if expanded {
            
            if indexPath.row <= expandedIndex {
                accounts[indexPath.row].updateTime = Utils.currentTimeMillis()
                
                if CoreDataUtils.deleteAccount(forName: accounts[indexPath.row]) == CoreDataStatus.AccountDeleted {
                    accounts.remove(at: indexPath.row)
                    deleteRowIndexes.append(indexPath)
                    deleteRowIndexes.append(contentsOf: getIndexPathsToDelete())
                } else {
                    print("Error deleting account from Data Store")
                    present(Utils.showErrorMessage(errorMessage: "Error deleting account from Data Store"), animated: true, completion: nil)
                }
            } else {
                accounts[indexPath.row - expandedRows.count].updateTime = Utils.currentTimeMillis()
                
                if CoreDataUtils.deleteAccount(forName: accounts[indexPath.row - expandedRows.count]) == CoreDataStatus.AccountDeleted {
                    accounts.remove(at: indexPath.row - expandedRows.count)
                    deleteRowIndexes.append(IndexPath(row: indexPath.row, section: 0))
                    deleteRowIndexes.append(contentsOf: getIndexPathsToDelete())
                } else {
                    print("Error deleting account from Data Store")
                    present(Utils.showErrorMessage(errorMessage: "Error deleting account from Data Store"), animated: true, completion: nil)
                }
            }
            
            resetExpandedRows()
            
        } else {
            accounts[indexPath.row].updateTime = Utils.currentTimeMillis()
            
            if CoreDataUtils.deleteAccount(forName: accounts[indexPath.row]) == CoreDataStatus.AccountDeleted {
                accounts.remove(at: indexPath.row)
                deleteRowIndexes.append(indexPath)
            } else {
                print("Error deleting account from Data Store")
                present(Utils.showErrorMessage(errorMessage: "Error deleting account from Data Store"), animated: true, completion: nil)
            }
        }
        
        accountsTableView.beginUpdates()
        accountsTableView.deleteRows(at: deleteRowIndexes, with: .automatic)
        accountsTableView.endUpdates()
    }
    
    
    func getIndexPathsToDelete() -> [IndexPath] {
        var toReturn: [IndexPath] = []
        
        for i in expandedRows {
            toReturn.append(IndexPath(row: i, section: 0))
        }
        
        return toReturn
    }
    
    
    func setExpandedRows(forIndex index: Int) {
        if accounts[index].url != "" {
            expandedRows = [index+1, index+2, index+3]
        } else {
            expandedRows = [index+1, index+2]
        }
    }
    
    
    func resetExpandedRows() {
        expanded = false
        expandedIndex = -1
        expandedRows = []
    }
    
    
    func setAccountTableViewCellTextColor(forCell: AccountTableViewCell, validEncryption: Bool) {
        if validEncryption {
            forCell.accountNameLabel.textColor = UIColor.black
        } else {
            forCell.accountNameLabel.textColor = UIColor.lightGray
        }
    }
    
    
    func handleInvalidEncryption(forAccountIndex index: Int, indexPath: IndexPath) {
        print("Account=\(accounts[index].accountName)")
        let alert = UIAlertController(title: "Account Password Recovery", message: INVALID_ENCRYPTION_MESSAGE, preferredStyle: .alert)
        
        let decryptAction = UIAlertAction(title: "Decrypt", style: .default, handler: { (UIAlertAction) in
            self.showDecryptKey(forAccountIndex: index)
        })
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (UIAlertAction) in
            self.deleteAccount(indexPath: indexPath)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (UIAlertAction) in
//            self.resetExpandedRows()
//            self.accountsTableView.reloadData()
        })
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        alert.addAction(decryptAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    func showDecryptKey(forAccountIndex index: Int) {
        let alert = UIAlertController(title: "Decrypt Key", message: "Enter the key that was used to encrypt this account and press Decrypt.", preferredStyle: .alert)
        
        let decryptAction = UIAlertAction(title: "Decrypt", style: .default, handler: { (UIAlertAction) in
            
            if let key = alert.textFields?[0].text {
                
                if key.count > 0 {
                    let finalKey = Crypt.finalizeKey(key: key)
                    var decryptedPass = ""
                    var decryptedOldPass = ""
                    var failed = false
                    
                    do {
                        decryptedPass = try Crypt.decryptString(key: finalKey, forEncrypted: self.accounts[index].password)
                        decryptedOldPass = try Crypt.decryptString(key: finalKey, forEncrypted: self.accounts[index].oldPassword)
                    } catch {
                        // check if pass was decrypted, if so just set old pass to current pass
                        if decryptedPass != "" {
                            decryptedOldPass = decryptedPass
                        } else {
                            print("Error decrypting password while trying to recover account: \(self.accounts[index].accountName), error: \(error)")
                            failed = true
                        }
                    }
                    
                    if !failed {
                        self.accounts[index].password = decryptedPass
                        self.accounts[index].oldPassword = decryptedOldPass
                        
                        if CoreDataUtils.updateAccount(forAccount: self.accounts[index], false) != CoreDataStatus.AccountUpdated {
                            print("Error saving account: \(self.accounts[index])")
//                            self.resetExpandedRows()
//                            self.accountsTableView.reloadData()
                            self.present(Utils.showErrorMessage(errorMessage: "The account was decrypted, but could not be saved."), animated: true, completion: nil)
                        } else {
                            self.resetExpandedRows()
                            
                            do {
                                self.accounts = try CoreDataUtils.loadAllAccounts()
                            } catch {
                                // shouldn't ever really happen but account should show correctly at next login
                                print("Error reloading accounts")
                            }
                            
                            self.accountsTableView.reloadData()
                        }
                        
                    } else {
//                        self.resetExpandedRows()
                        self.present(Utils.showErrorMessage(errorMessage: "The account could not be decrypted with the supplied key"), animated: true, completion: nil)
                    }
                } else {
                    self.present(Utils.showErrorMessage(errorMessage: "The account could not be decrypted with the supplied key"), animated: true, completion: nil)
                }
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (UIAlertAction) in
//            self.resetExpandedRows()
        })
        
        alert.addTextField { (decryptTextField) in
            decryptTextField.placeholder = "Enter Key"
            decryptTextField.isSecureTextEntry = true
            decryptTextField.textAlignment = NSTextAlignment.center
        }
        
        alert.addAction(cancelAction)
        alert.addAction(decryptAction)
        
        present(alert, animated: true, completion: nil)
    }

    
}
