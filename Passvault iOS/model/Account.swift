//
//  Account.swift
//  Passvault iOS
//
//  Created by Erik Manor on 11/26/17.
//  Copyright © 2017 Erik Manor. All rights reserved.
//

import Foundation

class Account : CustomStringConvertible, Equatable {
    
    
   
    var accountName: String
    var userName: String
    var password: String
    var oldPassword: String
    var url: String
    var updateTime: Int64
    var deleted: Bool
    var validEncryption: Bool
    
    var description: String {
        return "\(accountName)"
    }
    
    init(accountName: String, userName: String, password: String, oldPassword: String, url: String, updateTime: Int64,
         deleted: Bool, validEncryption: Bool) {
        self.accountName = accountName
        self.userName = userName
        self.password = password
        self.oldPassword = oldPassword
        self.url = url
        self.updateTime = updateTime
        self.deleted = deleted
        self.validEncryption = validEncryption
    }
    
    convenience init(accountName: String, userName: String, password: String) {
        self.init(accountName: accountName, userName: userName, password: password, oldPassword: "", url: "", updateTime: Utils.currentTimeMillis(), deleted: false, validEncryption: true)
    }
    
    convenience init(accountName: String, userName: String, password: String, url: String) {
        self.init(accountName: accountName, userName: userName, password: password, oldPassword: "", url: url, updateTime: Utils.currentTimeMillis(), deleted: false, validEncryption: true)
    }
    
    
    static func ==(lhs: Account, rhs: Account) -> Bool {
        if lhs.accountName == rhs.accountName {
            return true
        } else {
            return false
        }
    }
    
    
}
