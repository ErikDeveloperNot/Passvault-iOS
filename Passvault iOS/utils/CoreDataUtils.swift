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


class CoreDataUtils {
    
    
    
    static func loadAllAccounts() -> [AccountCD] {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        var accounts: [AccountCD] = []
        
        do {
            accounts = try context.fetch(AccountCD.fetchRequest())
        } catch {
            //TODO - show error
            print(error)
        }
        
        return accounts
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
            
            if i%5 == 0 {
                toAdd.accountDeleted = true
            } else {
                toAdd.accountDeleted = false
            }
            
            toAdd.url = "www.yahoo.com"
            toAdd.updateTime = Utils.currentTimeMillis()
        }
        
        do {
            try context.save()
        } catch {
            print(error)
        }
        
    }
}
