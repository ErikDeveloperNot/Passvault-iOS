//
//  SyncMessages.swift
//  Passvault iOS
//
//  Created by Erik Manor on 12/10/17.
//  Copyright © 2017 Erik Manor. All rights reserved.
//

import Foundation
import ObjectMapper

struct Gateway : Mappable {
    
    var userName = ""
    var password = ""
    var server = ""
    var port = -1
    var proto = ""
    var path = ""
    
    init(server: String, proto: String, port: Int, path: String, userName: String, password: String) {
        self.server = server
        self.proto = proto
        self.port = port
        self.path = path
        self.userName = userName
        self.password = password
    }
    
    init() {
    }
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        server      <- map["server"]
        path        <- map["bucket"]
        proto       <- map["protocol"]
        userName    <- map["userName"]
        password    <- map["password"]
        port        <- map["port"]
    }
}


struct RegisterRequest : Mappable {
    var email = ""
    var password = ""
    var version = "v1.0"
    
    init?(map: Map) {
    }
    
    init(email: String, password: String) {
        self.email = email
        self.password = password
    }
    
    mutating func mapping(map: Map) {
        email       <- map["email"]
        password    <- map["password"]
        version     <- map["version"]
    }
    
}


struct DeleteRequest : Mappable {
    var email = ""
    var password = ""
    
    init?(map: Map) {
    }
    
    init(email: String, password: String) {
        self.email = email
        self.password = password
    }
    
    mutating func mapping(map: Map) {
        email       <- map["user"]
        password    <- map["password"]
    }
    
    
}


struct DeleteResponse : Mappable {
    var success = false
    var error = "";
    var returnMessage = "";
    
    init?(map: Map) {
    }
    
    init(success: Bool, error: String, message: String) {
        self.success = success
        self.error = error
        self.returnMessage = message
    }
    
    mutating func mapping(map: Map) {
        success         <- map["success"]
        error           <- map["error"]
        returnMessage   <- map["returnMessage"]
    }
}


struct CheckAccount : Mappable {
    var accountName = ""
    var updateTime: Int64 = -1

    init?(map: Map) {
    }
    
    init(accountName: String, updateTime: Int64) {
        self.accountName = accountName
        self.updateTime = updateTime
    }
    
    mutating func mapping(map: Map) {
        accountName     <- map["accountName"]
        updateTime      <- map["updateTime"]
    }
    
}


struct SyncRequestInitial : Mappable {
    var email = ""
    var password = ""
    var accounts: [CheckAccount] = []

    init?(map: Map) {
    }
    
    init(email: String, password: String, accounts: [CheckAccount]) {
        self.email = email
        self.password = password
        self.accounts = accounts
    }
    
    mutating func mapping(map: Map) {
        email       <- map["user"]
        password    <- map["password"]
        accounts    <- map["accounts"]
    }
}


struct SyncResponseInitial : Mappable {
    var responseCode: Int = -1
    var lockTime: Int64 = -1
    var sendAccountsToServerList: [String] = []
    var accountsToSendBackToClient: [SyncAccount] = []
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        responseCode                <- map["responseCode"]
        lockTime                    <- map["lockTime"]
        sendAccountsToServerList    <- map["sendAccountsToServerList"]
        accountsToSendBackToClient  <- map["accountsToSendBackToClient"]
    }
}


struct SyncRequestFinal : Mappable {
    var user = ""
    var password = ""
    var lockTime: Int64 = -1
    var accounts: [SyncAccount] = []
    
    init(user: String, password: String, lockTime: Int64, accounts: [SyncAccount]) {
        self.user = user
        self.password = password
        self.lockTime = lockTime
        self.accounts = accounts
    }
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        user            <- map["user"]
        password        <- map["password"]
        lockTime        <- map["lockTime"]
        accounts        <- map["accounts"]
    }
}


struct SyncAccount : Mappable {
    var accountName = ""
    var userName = ""
    var password = ""
    var oldPassword = ""
    var url = ""
    var updateTime: Int64 = -1
    var deleted = false
    
    init(accountName: String, userName: String, password: String, oldPassword: String, url: String, updateTime: Int64, deleted: Bool) {
        self.accountName = accountName
        self.userName = userName
        self.password = password
        self.oldPassword = oldPassword
        self.url = url
        self.updateTime = updateTime
        self.deleted = deleted
    }
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        accountName     <- map["accountName"]
        userName        <- map["userName"]
        password        <- map["password"]
        oldPassword     <- map["oldPassword"]
        url             <- map["url"]
        updateTime      <- map["updateTime"]
        deleted         <- map["deleted"]
    }
}










