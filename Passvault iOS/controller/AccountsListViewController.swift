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
//    var expanded: Bool = false
//    var expandedIndex: Int = -1
//    var expandedRows: [Int] = []
    
    // used for tableview 2.0
    let MULTIPLIER = 5
    let DARK_BUTTON = "grey_gradient_dark_button"
    let LIGHT_BUTTON = "grey_gradient_button"
    let CELL_TEXT_HEX = 0x5F4BCF
    var expandedRow = -1
    var selectedOptionRow = -1
    
    
    // used by AccountDetailsViewController to flag that an account has been deleted and index
    var accountDeletedFromDetails: Bool = false
    var accountSentToDetailsIndexPath: IndexPath?
   
    override func viewDidLoad() {
        super.viewDidLoad()

        accountsTableView.delegate = self
        accountsTableView.dataSource = self

        accountsTableView.register(UINib(nibName: "ButtonTableViewCell", bundle: nil), forCellReuseIdentifier: "buttonCellReuseIdentifier")
        accountsTableView.register(UINib(nibName: "AccountNameTableViewCell", bundle: nil), forCellReuseIdentifier: "accountNameReuseIdentifier")
        accountsTableView.register(UINib(nibName: "AccountNameSelectedTableViewCell", bundle: nil), forCellReuseIdentifier: "accountNameSelectedReuseIdentifier")
        
        if CoreDataUtils.loadGateway().server != "" {
            syncButton.isEnabled = true
        } else {
            syncButton.isEnabled = false
        }
        
        if CoreDataUtils.loadGeneralSettings().sortByMRU {
            sortType = SortType.MOA
        }
        
        MRAComparator.getInstance().debugMaps()
        
        let settings = CoreDataUtils.loadGeneralSettings()
        let days = settings.purgeDays
        CoreDataUtils.purgeDeletes(olderThenDays: days)
        
        // to support the options cells behaving like buttons instead of rows
        let colorView = UIView()
        colorView.backgroundColor = UIColor.clear
        UITableViewCell.appearance().selectedBackgroundView = colorView
        
        hideKeyboardOnTap()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if CoreDataUtils.loadGateway().server != "" {
            syncButton.isEnabled = true
        } else {
            syncButton.isEnabled = false
        }

        accounts = Utils.sort(accounts: accounts, sortType: sortType)
        accountsTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - TableView Implementations
    //
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count * MULTIPLIER
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row % MULTIPLIER == 0 {
            
            if expandedRow == indexPath.row / MULTIPLIER {
                let cell = tableView.dequeueReusableCell(withIdentifier: "accountNameSelectedReuseIdentifier")! as! AccountNameSelectedTableViewCell
                cell.accountNameLabel.text = "username: \(accounts[indexPath.row / MULTIPLIER].userName)"
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "accountNameReuseIdentifier")! as! AccountNameTableViewCell
                
                cell.accountNameLabel.text = accounts[indexPath.row / MULTIPLIER].accountName
                setAccountTableViewCellTextColor(forCell: cell, validEncryption: accounts[indexPath.row/MULTIPLIER].validEncryption, row: indexPath.row/MULTIPLIER)
                
                return cell
            }
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "buttonCellReuseIdentifier")! as! ButtonTableViewCell
//            cell.row = indexPath.row
//            cell.delegate = self
            
            // if row is selected options row make it look like a button was pressed then
            // then change back to the default
            if indexPath.row == selectedOptionRow {
                cell.buttonLabel.textColor = UIColor.white
                cell.buttonImage.image = UIImage(named: DARK_BUTTON)
                selectedOptionRow = -1
                DispatchQueue.global(qos: .background).async {
                    usleep(100000)
                    
                    DispatchQueue.main.async {
                        cell.buttonLabel.textColor = Utils.getUIColorForHexValue(hex: self.CELL_TEXT_HEX)
                        cell.buttonImage.image = UIImage(named: self.LIGHT_BUTTON)
                    }
                }
            }
            
//if expandedRow == indexPath.row/MULTIPLIER {
//cell.isHidden = false
            switch indexPath.row % MULTIPLIER {
            case 1:
                cell.buttonLabel.text = "Copy Password"
//                setButtonTitleForAllStates(titleToSet: "Copy Password", forButton: cell.button)
                break
            case 2:
                cell.buttonLabel.text = "Copy Old Password"
//                setButtonTitleForAllStates(titleToSet: "Copy Old Password", forButton: cell.button)
                break
            case 3:
                cell.buttonLabel.text = "Open URL"
//                let url = accounts[indexPath.row/MULTIPLIER].url.lowercased()
//                if ((url.starts(with: "http://") || url.starts(with: "https://")) && url.count >= 11) {
//                    setButtonTitleForAllStates(titleToSet: "Open URL", forButton: cell.button)
//                } else {
//                    cell.isHidden = true
//                }
                break
            case 4:
                cell.buttonLabel.text = "Edit Account"
//              setButtonTitleForAllStates(titleToSet: "Edit Account", forButton: cell.button)
                break
            default:
                print("Error, should never see this, index=\(indexPath.row % MULTIPLIER)")
                break
            }


//    //cell.isHidden = false
//} else {
//    cell.isHidden = true
//}
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row % MULTIPLIER == 0 {
            return 44.0
            //return 35.0
        }
        
        if indexPath.row / MULTIPLIER == expandedRow && accounts[indexPath.row/MULTIPLIER].validEncryption {
            let url = accounts[indexPath.row/MULTIPLIER].url.lowercased()
            let cells = ((url.starts(with: "http://") || url.starts(with: "https://")) && url.count >= 11) ? 4 : 3
            
            switch indexPath.row % MULTIPLIER {
            case 3:
                if cells == 4 {
                    return 50.0
                } else {
                    return 0.0
                }
            default:
                return 50.0
            }
            
        } else {
            return 0.0
        }
        
    }
 
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var rowsToReload: [IndexPath] = []
        
        if indexPath.row % MULTIPLIER == 0 {
            
            if !accounts[indexPath.row / MULTIPLIER].validEncryption {
                handleInvalidEncryption(forAccountIndex: indexPath.row/MULTIPLIER, indexPath: indexPath)
                return
            }
            
            if indexPath.row / MULTIPLIER == expandedRow {
                expandedRow = -1
                rowsToReload = buildIndexPaths(forRow: indexPath)
            } else {
                
                if expandedRow != -1 {
                    rowsToReload = buildIndexPaths(forRow: IndexPath(row: expandedRow*MULTIPLIER, section: 0))
                }
                
                rowsToReload.append(contentsOf: buildIndexPaths(forRow: indexPath))
                expandedRow = indexPath.row / MULTIPLIER
            }
            
            accountsTableView.reloadRows(at: rowsToReload, with: .fade)
        } else {
            
            switch indexPath.row % MULTIPLIER {
            case 1:
                MRAComparator.getInstance().incrementAccessCount(forAccount: accounts[expandedRow].accountName)
                Utils.copyToClipboard(toCopy: accounts[expandedRow].password)
                break
            case 2:
                MRAComparator.getInstance().incrementAccessCount(forAccount: accounts[expandedRow].accountName)
                Utils.copyToClipboard(toCopy: accounts[expandedRow].oldPassword)
                break
            case 3:
                MRAComparator.getInstance().incrementAccessCount(forAccount: accounts[expandedRow].accountName)
                Utils.copyToClipboard(toCopy: accounts[expandedRow].password)
                
                if !Utils.launchBrowser(forURL: accounts[expandedRow].url) {
                    present(Utils.showErrorMessage(errorMessage: "Unable to open browser for: \(accounts[expandedRow].url))"), animated: true, completion: nil)
                }

                break
            default:
                self.selectedAccount = self.accounts[indexPath.row / MULTIPLIER]
                self.accountSentToDetailsIndexPath = indexPath
                self.performSegue(withIdentifier: "goToDetails", sender: self)
                break
            }
            
            // reload low to make it look like button was clicked
            selectedOptionRow = indexPath.row
            accountsTableView.reloadRows(at: [indexPath], with: .none)
            
        }
        
    }
    
    
    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if indexPath.row % MULTIPLIER == 0 {
            return true
        } else {
            return false
        }
    }
    
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            deleteAccount(indexPath: indexPath)
        }
    }
    
    
    // MARK: - OptionsButton implementation
    
    /*func buttonPressed(forRow: Int?) {
        print("Button Pressed for row: \(forRow)")
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
            
            if accountAdded {
                let account = addAccountViewController.account
               
                do {
                    accounts = try CoreDataUtils.loadAllAccounts()
                } catch {
                    print("Error loading accounts from datastore, \(error)")
                    Utils.showErrorMessage(errorMessage: "Error loading accounts from datastore, \(error)")
                }
                
                accounts = Utils.sort(accounts: accounts, sortType: sortType)
                accountsTableView.reloadData()
            }
        }
    }
    
    
    @IBAction func syncButtonPressed(_ sender: UIBarButtonItem) {
        SVProgressHUD.show()
        resetExpandedAcount()
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
   
    
    @IBAction func infoPressed(_ sender: UIBarButtonItem) {
    }
    
    // MARK: utility functions
    //
    
    func setButtonTitleForAllStates(titleToSet title: String, forButton button: UIButton) {
        button.setTitle(title, for: .disabled)
        button.setTitle(title, for: .normal)
        button.setTitle(title, for: .selected)
    }
    
    func deleteAccount(indexPath: IndexPath) {
        
        if indexPath.row / MULTIPLIER == expandedRow {
            expandedRow = -1
        } else if expandedRow > -1 {
            let rowsToUpdate = buildIndexPaths(forRow: IndexPath(row: expandedRow * MULTIPLIER, section: 0))
            expandedRow = -1
            accountsTableView.reloadRows(at: rowsToUpdate, with: .fade)
        }
        
//        if indexPath.row / MULTIPLIER == expandedRow {
//            expandedRow = -1
//        }
        
        if CoreDataUtils.deleteAccount(forName: accounts[indexPath.row/MULTIPLIER]) == CoreDataStatus.AccountDeleted {
            accounts.remove(at: indexPath.row/MULTIPLIER)
            accountsTableView.deleteRows(at: buildIndexPaths(forRow: indexPath), with: .fade)
        } else {
            print("Error deleting account from Data Store")
            present(Utils.showErrorMessage(errorMessage: "Error deleting account from Data Store"), animated: true, completion: nil)
        }
    }
    
    
    func setAccountTableViewCellTextColor(forCell: AccountNameTableViewCell, validEncryption: Bool, row: Int) {
        if validEncryption {
            forCell.accountNameLabel.textColor = UIColor.black
            forCell.lockImage.isHidden = true
        } else {
            forCell.accountNameLabel.textColor = UIColor.lightGray
            forCell.lockImage.isHidden = false
        }
    }
    
    
    func buildIndexPaths(forRow path: IndexPath) -> [IndexPath] {
        var paths: [IndexPath] = []
        paths.append(path)
        
        for i in 1...4 {
            paths.append(IndexPath(row: path.row+i, section: 0))
        }
        
        return paths
    }
    
    
    func resetExpandedAcount() {
        
        if expandedRow > -1 {
            let indexPath = IndexPath(row: expandedRow * MULTIPLIER, section: 0)
            expandedRow = -1
            
            accountsTableView.reloadRows(at: buildIndexPaths(forRow: indexPath), with: .fade)
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
        })
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        alert.addAction(decryptAction)
        
        alert.view.backgroundColor = UIColor.darkGray
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
                        self.accounts[index].validEncryption = true
                        
                        if CoreDataUtils.updateAccount(forAccount: self.accounts[index], passwordEncrypted: false) != CoreDataStatus.AccountUpdated {
                            print("Error saving account: \(self.accounts[index])")
                           self.present(Utils.showErrorMessage(errorMessage: "The account was decrypted, but could not be saved."), animated: true, completion: nil)
                        } else {
                            self.accountsTableView.reloadRows(at: [IndexPath(row: index * self.MULTIPLIER, section: 0)], with: .fade)
                        }
                        
                    } else {
                        self.present(Utils.showErrorMessage(errorMessage: "The account could not be decrypted with the supplied key"), animated: true, completion: nil)
                    }
                } else {
                    self.present(Utils.showErrorMessage(errorMessage: "The account could not be decrypted with the supplied key"), animated: true, completion: nil)
                }
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (UIAlertAction) in
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
