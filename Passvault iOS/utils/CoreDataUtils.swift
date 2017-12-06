//
//  CoreDataUtils.swift
//  Passvault iOS
//
//  Created by User One on 11/28/17.
//  Copyright © 2017 User One. All rights reserved.
//

import Foundation
import CoreData
import UIKit


enum CoreDataStatus {
    case AccountCreated
    case AccountDeleted
    case AccountUpdated
    case AccountNotFound
    case CoreDataSuccess
    case CoreDataError
}


class CoreDataUtils {
    
    static var key: String = ""
    
    static let PASSWORD_KEY = "password"
    static let OLD_PASSWORD_KEY = "old_password"
    static let VALID_ENCRYPTION_KEY = "valid_encryption_key"
    
    
    static func loadAllAccounts() -> [Account] {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        var accounts: [Account] = []
        var accountCDs: [AccountCD] = []
       
        do {
            accountCDs = try context.fetch(AccountCD.fetchRequest())
            
            
var i = 1
            for accountCD in accountCDs {
                if !accountCD.accountDeleted {
                    
                    guard let name = accountCD.accountName else {
                        print("accountName not set, not loading")
                        continue
                    }
                    
                    guard let user = accountCD.userName else {
                        print("userName not set, not loading")
                        continue
                    }
                    
                    guard let password = accountCD.password else {
                        print("password not set, not loading")
                        continue
                    }
                    
                    let oldPassword = accountCD.oldPassword ?? password
                    let url = accountCD.url ?? ""
                    let updateTime = accountCD.updateTime ?? Utils.currentTimeMillis()
                    
                    let decryptPasswordsResult = decryptPasswords(password: password, oldPassword: oldPassword)
                    
                    var validEncryption: Bool = Bool(decryptPasswordsResult[VALID_ENCRYPTION_KEY]!)!
                    var decryptedPassword: String = decryptPasswordsResult[PASSWORD_KEY]!
                    var decryptedOldPassword: String = decryptPasswordsResult[OLD_PASSWORD_KEY]!
                   
if i%5 == 0 {
   validEncryption = false
}
i += 1
                    accounts.append(Account(accountName: name, userName: user, password: decryptedPassword, oldPassword: decryptedOldPassword, url: url, updateTime: updateTime, deleted: false, validEncryption: validEncryption))
                    
                    //accounts.append(Account(accountName: accountCD.accountName!, userName: accountCD.userName!, password: accountCD.password!, oldPassword: accountCD.oldPassword!, url: accountCD.url ?? "", updateTime: accountCD.updateTime, deleted: accountCD.accountDeleted, validEncryption: true))
                } else {
                    print("Not Loading deleted account: " + accountCD.accountName!)
                }
            }
            
            
            
        } catch {
            //TODO - show error
            print(error)
        }
       
        
        /*
        for account in accounts {
            context.delete(account)
            do {
                try context.save()
            } catch {
                print(error)
            }
        }
        */
        
        return accounts
    }
    
    
    static func purgeAccount(forName account: String) -> CoreDataStatus {
        var toReturn: CoreDataStatus = .AccountDeleted
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "AccountCD")
        fetchRequest.predicate = NSPredicate(format: "accountName == %@", account)
        
        do {
            let currentAccounts = try context.fetch(fetchRequest) as! [AccountCD]
            
            // whether found or not return success as long as there is no CoreData access error
            for toRemove in currentAccounts {
                context.delete(toRemove)
            }
            
            try context.save()
        } catch {
            print("Error attempting to delete Account: \(account), error: \(error)")
            toReturn = .CoreDataError
        }
        
        return toReturn
    }
    
    
    static func saveAccount(forAccount account: Account) -> CoreDataStatus {
        return updateAccount(forAccount: account, true)
    }
    
    
    static func deleteAccount(forName account: Account) -> CoreDataStatus {
        account.deleted = true
        
        if updateAccount(forAccount: account, false) == .AccountUpdated {
            return CoreDataStatus.AccountDeleted
        } else {
            return CoreDataStatus.CoreDataError
        }
    }
    
    
    static func updateAccount(forAccount account: Account, _ insertIfDoesNotExist: Bool) -> CoreDataStatus {
        var toReturn: CoreDataStatus = .AccountUpdated
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "AccountCD")
        fetchRequest.predicate = NSPredicate(format: "accountName == %@", account.accountName)
        
        do {
            let currentAccount = try context.fetch(fetchRequest) as! [AccountCD]
            
            if currentAccount.count < 1 && !insertIfDoesNotExist {
                toReturn = .AccountNotFound
            } else if currentAccount.count > 0 {
                //assume never more than one, need to figure out how to make sure of this
                let cryptResults = encryptPasswords(password: account.password, oldPassword: account.oldPassword)
              
                currentAccount[0].userName = account.userName
                currentAccount[0].url = account.url
                currentAccount[0].accountDeleted = account.deleted
                currentAccount[0].updateTime = account.updateTime
                
                if currentAccount[0].password != cryptResults[PASSWORD_KEY] {
                    currentAccount[0].oldPassword = currentAccount[0].password
                    currentAccount[0].password = cryptResults[PASSWORD_KEY]
                }
                
                try context.save()
                toReturn = .AccountUpdated
            } else if insertIfDoesNotExist {
                let toAdd = AccountCD(context: context)
                let cryptResults = encryptPasswords(password: account.password, oldPassword: account.oldPassword)
                
                toAdd.accountName = account.accountName
                toAdd.userName = account.userName
                toAdd.password = cryptResults[PASSWORD_KEY]
                toAdd.oldPassword = cryptResults[OLD_PASSWORD_KEY]
                toAdd.url = account.url
                toAdd.updateTime = account.updateTime
                toAdd.accountDeleted = account.deleted
               
                try context.save()
                toReturn = .AccountCreated
            }
        } catch {
            print("Error accessing CoreData: , \(error)")
            toReturn = .CoreDataError
        }
   
        return toReturn
    }
    
    
    static func decryptPasswords(password: String, oldPassword: String) -> Dictionary<String, String> {
        var toReturn: Dictionary<String, String> = [:]
        toReturn[VALID_ENCRYPTION_KEY] = "true"
        
        do {
            toReturn[PASSWORD_KEY] = try Crypt.decryptString(key: key, forEncrypted: password)
        } catch {
            toReturn[VALID_ENCRYPTION_KEY] = "false"
            print("Error decrypting password, error: \(error)")
            toReturn[PASSWORD_KEY] = password
        }
        
        do {
            toReturn[OLD_PASSWORD_KEY] = try Crypt.decryptString(key: key, forEncrypted: oldPassword)
        } catch {
            print("Error decrypting old password, error: \(error)")
            // like with java just use current password if it was decrypted
            if toReturn[VALID_ENCRYPTION_KEY] == "true" {
                toReturn[OLD_PASSWORD_KEY] = toReturn[PASSWORD_KEY]
            } else {
                toReturn[OLD_PASSWORD_KEY] = oldPassword
            }
        }
        
        return toReturn
    }
    
    
    static func encryptPasswords(password: String, oldPassword: String) -> Dictionary<String, String> {
        var toReturn: Dictionary<String, String> = [:]
        toReturn[VALID_ENCRYPTION_KEY] = "true"
        
        do {
            toReturn[PASSWORD_KEY] = try Crypt.encryptString(key: key, forText: password)
        } catch {
            toReturn[VALID_ENCRYPTION_KEY] = "false"
            print("Error encrypting password, error: \(error)")
            toReturn[PASSWORD_KEY] = password
        }
        
        do {
            toReturn[OLD_PASSWORD_KEY] = try Crypt.encryptString(key: key, forText: oldPassword)
        } catch {
            print("Error encrypting old password, error: \(error)")
            // like with java just use current password if it was decrypted
            if toReturn[VALID_ENCRYPTION_KEY] == "true" {
                toReturn[OLD_PASSWORD_KEY] = toReturn[PASSWORD_KEY]
            } else {
                toReturn[OLD_PASSWORD_KEY] = oldPassword
            }
        }
        
        return toReturn
    }
    
    
    // MARK: Settings routines
    
    static func getGenerator() -> RandomPasswordGenerator {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        var generators: [GeneratorCD] = []
        var generatorToReturn = RandomPasswordGenerator()
        
        do {
            generators = try context.fetch(GeneratorCD.fetchRequest()) as! [GeneratorCD]
print("Loaded \(generators.count)")
            if generators.count > 0 {
                generatorToReturn.changeGenertorSpecs(allowedCharacters: generators[0].allowedCharacters as! [String], passwordLength: generators[0].length)
            }
            
        } catch {
            print("Error getting GeneratorCD from CoreData, error: \(error)")
        }
        
        return generatorToReturn
    }
    
    
    static func saveGenerator(generator: RandomPasswordGenerator) -> CoreDataStatus {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do {
            let generators = try context.fetch(GeneratorCD.fetchRequest()) as! [GeneratorCD]
            
            if generators.count > 0 {
                generators[0].allowedCharacters = generator.allowedCharacters as NSObject
                generators[0].length = generator.length
            } else {
                let newGenerator = GeneratorCD(context: context)
                newGenerator.allowedCharacters = generator.allowedCharacters as NSObject
                newGenerator.length = generator.length
            }
            
            try context.save()
        } catch {
            print("Error saving Generator to CoreData, error: \(error)")
            return CoreDataStatus.CoreDataError
        }
        
        return CoreDataStatus.CoreDataSuccess
    }
    
    
    static func saveGeneralSettings(settings: GeneralSettings) -> CoreDataStatus {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do {
            let generalCDs = try context.fetch(GeneralCD.fetchRequest()) as! [GeneralCD]
            var generalCD: GeneralCD?
            
            if generalCDs.count > 0 {
                generalCD = generalCDs[0]
            } else {
                generalCD = GeneralCD(context: context)
            }
            
            generalCD?.saveKey = settings.saveKey
            generalCD?.sortMRU = settings.sortByMRU
            
            try context.save()
            
        } catch {
            print("Error saving General Settings to CoreData, error: \(error)")
            return CoreDataStatus.CoreDataError
        }
        
        return CoreDataStatus.CoreDataSuccess
    }
    
    
    static func loadGeneralSettings() -> GeneralSettings {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        var settings: GeneralSettings?
        
        do {
            let generalCD = try context.fetch(GeneralCD.fetchRequest()) as! [GeneralCD]
            
            if generalCD.count > 0 {
                settings = GeneralSettings(saveKey: generalCD[0].saveKey, sortByMRU: generalCD[0].sortMRU)
            } else {
                settings = GeneralSettings()
            }
        } catch {
            print("Error loading General Settings from CoreData, error: \(error)")
            settings = GeneralSettings()
        }
        
        return settings!
    }
    
    
    
    // load test data into core data,
    static func createTestAccounts(numberOfAccounts: Int, encryptionKey: String) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let key = Crypt.finalizeKey(key: "notreal")
        var password: String = ""
        
        do {
            password = try Crypt.encryptString(key: key, forText: "password")
        } catch {
            print("Error encrypting password")
            password = "clearText"
        }
        
        for i in 1...numberOfAccounts {
            let toAdd = AccountCD(context: context)
            toAdd.accountName = "Test Account \(i)"
            toAdd.userName = "User"
            toAdd.password = password
            toAdd.oldPassword = password
            /*
            if i%5 == 0 {
                toAdd.accountDeleted = true
            } else {
                toAdd.accountDeleted = false
            }
            */
            if i%3 == 0 {
                toAdd.url = "www.yahoo.com"
            }
            
            toAdd.updateTime = Utils.currentTimeMillis()
        }
        
        do {
            try context.save()
        } catch {
            print(error)
        }
        
    }
}
