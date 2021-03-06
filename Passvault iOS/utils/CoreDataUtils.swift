//
//  CoreDataUtils.swift
//  Passvault iOS
//
//  Created by Erik Manor on 11/28/17.
//  Copyright © 2017 Erik Manor. All rights reserved.
//

import Foundation
import CoreData
import UIKit


enum CoreDataStatus {
    case AccountCreated
    case AccountDeleted
    case AccountUpdated
    case AccountNotFound
    case AccountAlreadyExists
    case CoreDataSuccess
    case CoreDataError
}


class CoreDataUtils {
    
    static var key: String = ""
    static var syncRunning = false
    
    static let PASSWORD_KEY = "password"
    static let OLD_PASSWORD_KEY = "old_password"
    static let VALID_ENCRYPTION_KEY = "valid_encryption_key"
    static let DAY_IN_MILLI: Int64 = 86400000
    
    static func loadAllAccounts() throws -> [Account] {
            return try loadAllAccounts(includeDeletes: false)
    }
    
    
    static func loadAllAccounts(includeDeletes: Bool) throws -> [Account] {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        var accounts: [Account] = []
        var accountCDs: [AccountCD] = []
       
        do {
            accountCDs = try context.fetch(AccountCD.fetchRequest())
            
            
//var i = 1
            for accountCD in accountCDs {
                if !accountCD.accountDeleted || includeDeletes {
                   
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
                    let updateTime = accountCD.updateTime
                    
                    let decryptPasswordsResult = decryptPasswords(password: password, oldPassword: oldPassword)
                    
                    let validEncryption: Bool = Bool(decryptPasswordsResult[VALID_ENCRYPTION_KEY]!)!
                    let decryptedPassword: String = decryptPasswordsResult[PASSWORD_KEY]!
                    let decryptedOldPassword: String = decryptPasswordsResult[OLD_PASSWORD_KEY]!
                    let deleted = accountCD.accountDeleted
//if i%5 == 0 {
//   validEncryption = false
//}
//i += 1
                    accounts.append(Account(accountName: name, userName: user, password: decryptedPassword, oldPassword: decryptedOldPassword, url: url, updateTime: updateTime, deleted: deleted, validEncryption: validEncryption))
                    
                } else {
                    print("Not Loading deleted account: " + accountCD.accountName!)
                }
            }
            
            
            
        } catch {
            print("Error loading all accounts: \(error)")
            throw error
        }
       
        //return Utils.sort(accounts: accounts)
        return accounts
    }
    
    
    static func purgeDeletes(olderThenDays: Int16) {
        print("Running purge deletes for accounts older then: \(olderThenDays)")
        let check = DAY_IN_MILLI * Int64(olderThenDays)
        let current = Utils.currentTimeMillis()
        
        do {
            let accounts = try loadAllAccounts(includeDeletes: true)
            
            for account in accounts {
print("\(account.accountName), deleted=\(account.deleted), \(current - account.updateTime > check)")
                if account.deleted && current - account.updateTime > check {
                    if purgeAccount(forName: account.accountName, withUpdateTime: account.updateTime) == CoreDataStatus.CoreDataError {
                        print("Error purging: \(account.accountName)")
                    }
                }
            }
        } catch {
            print("Error loading accounts in purgeDeletes, \(error)")
        }
    }
    
    
    static func purgeAccount(forName account: String) -> CoreDataStatus {
        return purgeAccount(forName: account, withUpdateTime: -1)
    }
    
    
    static func purgeAccount(forName account: String, withUpdateTime time: Int64) -> CoreDataStatus {
        var toReturn: CoreDataStatus = .AccountDeleted
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "AccountCD")
        
        if time == -1 {
            fetchRequest.predicate = NSPredicate(format: "accountName == %@", account)
        } else {
            fetchRequest.predicate = NSPredicate(format: "%K == %@ AND %K == %@", argumentArray: ["accountName", account, "updateTime", time])
        }
        
        do {
            let currentAccounts = try context.fetch(fetchRequest) as! [AccountCD]
            
            // whether found or not return success as long as there is no CoreData access error
            for toRemove in currentAccounts {
                print("purging account: \(toRemove.accountName!)")
                context.delete(toRemove)
            }
            
            try context.save()
        } catch {
            print("Error attempting to purge Account: \(account), error: \(error)")
            toReturn = .CoreDataError
        }
        
        return toReturn
    }
    
    
    static func deleteAccount(forName account: Account) -> CoreDataStatus {
        account.deleted = true
        account.updateTime = Utils.currentTimeMillis()
        
        if updateAccount(forAccount: account, passwordEncrypted: false) == .AccountUpdated {
            return CoreDataStatus.AccountDeleted
        } else {
            return CoreDataStatus.CoreDataError
        }
    }
    
    
    static func saveNewAccount(forAccount account: Account) -> CoreDataStatus {
        
        if let existingAccount = getAccount(forName: account.accountName) {
            
            if !existingAccount.deleted {
                return CoreDataStatus.AccountAlreadyExists
            }
        }
        
        if updateAccount(forAccount: account, passwordEncrypted: false) != CoreDataStatus.CoreDataError {
            return CoreDataStatus.AccountCreated
        } else {
            return CoreDataStatus.CoreDataError
        }
    }
    
    
    static func updateAccount(forAccount account: Account, passwordEncrypted: Bool) -> CoreDataStatus {
        var toReturn: CoreDataStatus = .CoreDataError
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "AccountCD")
        fetchRequest.predicate = NSPredicate(format: "accountName == %@", account.accountName)
        
        do {
            let currentAccount = try context.fetch(fetchRequest) as! [AccountCD]
            
            if currentAccount.count > 0 {
                // update
                let toUpdate = currentAccount[0]
                
                if currentAccount.count > 1 {
                    // should never happen but delete all others
                    for index in 1..<currentAccount.count {
                        print("Purging extra account for account: \(currentAccount[index].accountName!), results=\(purgeAccount(forName: currentAccount[index].accountName!, withUpdateTime: currentAccount[index].updateTime))")
                    }
                }
                
                if !passwordEncrypted {
                    let cryptResults = encryptPasswords(password: account.password, oldPassword: account.oldPassword)
                    
                    if toUpdate.password != cryptResults[PASSWORD_KEY] {
                        toUpdate.oldPassword = cryptResults[OLD_PASSWORD_KEY]
                        toUpdate.password = cryptResults[PASSWORD_KEY]
                    }
                } else {
                    toUpdate.password = account.password
                    toUpdate.oldPassword = account.oldPassword
                }
                
                toUpdate.userName = account.userName
                toUpdate.url = account.url
                toUpdate.accountDeleted = account.deleted
                toUpdate.updateTime = account.updateTime
                
                try context.save()
                toReturn = .AccountUpdated
            } else {
                // new
                let toAdd = AccountCD(context: context)
                
                if !passwordEncrypted {
                    let cryptResults = encryptPasswords(password: account.password, oldPassword: account.oldPassword)
                    toAdd.password = cryptResults[PASSWORD_KEY]
                    toAdd.oldPassword = cryptResults[OLD_PASSWORD_KEY]
                } else {
                    toAdd.password = account.password
                    toAdd.oldPassword = account.oldPassword
                }
                
                toAdd.accountName = account.accountName
                toAdd.userName = account.userName
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
   
    
    static func getAccount(forName: String) -> Account? {
        var account: Account?
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "AccountCD")
        fetchRequest.predicate = NSPredicate(format: "accountName == %@", forName)
        
        do {
            let currentAccount = try context.fetch(fetchRequest) as! [AccountCD]
            
            if currentAccount.count > 0 {
                let acct = currentAccount[0]
                account = Account(accountName: acct.accountName!, userName: acct.userName!, password: acct.password!, oldPassword: acct.oldPassword!, url: acct.url ?? "", updateTime: acct.updateTime, deleted: acct.accountDeleted, validEncryption: true)
            }
        } catch {
            print("Error accessing CoreData: , \(error)")
            return account
        }
        
        return account
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
        var generatorToReturn: RandomPasswordGenerator?
        
        do {
            generators = try context.fetch(GeneratorCD.fetchRequest()) as! [GeneratorCD]

            if generators.count > 0 {
                generatorToReturn = RandomPasswordGenerator(withGenerator: generators[0])
            }
            
        } catch {
            print("Error getting GeneratorCD from CoreData, error: \(error)")
        }
        
        return generatorToReturn ?? RandomPasswordGenerator()
    }
    
    
    static func saveGenerator(generator: RandomPasswordGenerator) -> CoreDataStatus {
        return saveGenerator(length: generator.length, allowedCharacters: generator.allowedCharacters)
    }
    
    
    static func saveGenerator(length: Int32, allowedCharacters: [String]) -> CoreDataStatus {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do {
            let generators = try context.fetch(GeneratorCD.fetchRequest()) as! [GeneratorCD]
            
            if generators.count > 0 {
                generators[0].allowedCharacters = allowedCharacters as NSObject
                generators[0].length = length
            } else {
                let newGenerator = GeneratorCD(context: context)
                newGenerator.allowedCharacters = allowedCharacters as NSObject
                newGenerator.length = length
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
            generalCD?.key = settings.key
            generalCD?.accountUUID = settings.accountUUID
            generalCD?.purgeDays = settings.purgeDays
            
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
                settings = GeneralSettings(saveKey: generalCD[0].saveKey, sortByMRU: generalCD[0].sortMRU, key: generalCD[0].key ?? "", accountUUID: generalCD[0].accountUUID ?? "", daysBeforePurgeDeletes: generalCD[0].purgeDays)
            } else {
                settings = GeneralSettings()
            }
        } catch {
            print("Error loading General Settings from CoreData, error: \(error)")
            settings = GeneralSettings()
        }
        
        return settings!
    }
    
    
    static func saveMRA() -> CoreDataStatus {
        //Testing for now
        /*var map: [String : [Int8]] = [:]
        map["test1"] = [2,4,5,0,7,9,10]
        map["test2"] = [1,0,0,3,8,8,1]*/
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do {
            var mraMaps = try context.fetch(MRAMapCD.fetchRequest()) as! [MRAMapCD]
            var mraMap: MRAMapCD?
            
            if mraMaps.count > 0 {
                //mraMap = mraMaps[0]
                //mraMaps[0] = mraMapCD
            } else {
                //mraMap = MRAMapCD(context: context)
            }
            
            //mraMap?.mraTime = Utils.getMRACurrentDay()
            //mraMap?.map = map as NSObject
            
            
            try context.save()
        } catch {
            print(error)
        }
        
        return CoreDataStatus.CoreDataSuccess
    }
    
    
    static func loadMRA() -> MRAMapCD {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do {
            let mraMaps = try context.fetch(MRAMapCD.fetchRequest()) as! [MRAMapCD]
print(mraMaps.count)
            
            if mraMaps.count > 0 {
                return mraMaps[0]
            } else {
                return MRAMapCD(context: context)
            }
            
        } catch {
            print(error)
        }
        
        return MRAMapCD(context: context)
    }
    
    
    static func loadGateway() -> Gateway {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        var gateway: Gateway?
        
        do {
            let syncCD = try context.fetch(SyncCD.fetchRequest()) as! [SyncCD]
            
            if syncCD.count > 0 {
                gateway = Gateway(server: syncCD[0].server!, proto: syncCD[0].proto!, port: Int(syncCD[0].port), path: syncCD[0].path!, userName: syncCD[0].userName!, password: syncCD[0].password!)
            } else {
                gateway = Gateway()
            }
            
        } catch {
            print("Error loading Gateway from CoreData, error: \(error)")
            gateway = Gateway()
        }
        
        return gateway!
    }
    
    
    static func saveGateway(gateway: Gateway) -> CoreDataStatus {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        var syncCD: SyncCD?
        
        do {
            let syncCDArray = try context.fetch(SyncCD.fetchRequest()) as! [SyncCD]
            
            if syncCDArray.count > 0 {
                syncCD = syncCDArray[0]
            } else {
                syncCD = SyncCD(context: context)
            }
            
            syncCD?.server = gateway.server
            syncCD?.proto = gateway.proto
            syncCD?.port = Int32(gateway.port)
            syncCD?.path = gateway.path
            syncCD?.userName = gateway.userName
            syncCD?.password = gateway.password
            
            try context.save()
        } catch {
            print("Error save Gateway Configuration, error: \(error)")
            return CoreDataStatus.CoreDataError
        }
        
        return CoreDataStatus.CoreDataSuccess
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
