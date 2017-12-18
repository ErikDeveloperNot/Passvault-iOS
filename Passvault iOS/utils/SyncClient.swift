//
//  SyncClient.swift
//  Passvault iOS
//
//  Created by Erik Manor on 12/7/17.
//  Copyright © 2017 Erik Manor. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper
import AlamofireObjectMapper

/*
    since the sync server unfortunately sometimes returns strings instead of JSON for error conditions
    will mot make much use of AlamofireObjectMapper and rather work with Strings
 */


struct CallStatus {
    var returned: Any?
    var error: Error?
    var running = true
    
    init() {
    }
}


struct JSONStringEncoding : ParameterEncoding {
    private var json: String = ""
    
    init(json: String) {
        self.json = json
    }
    
    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = try urlRequest.asURLRequest()
        
        let data = self.json.data(using: String.Encoding.utf8)
        
        if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        urlRequest.httpBody = data
        
        return urlRequest
    }
}


struct SyncError : LocalizedError {
    var errorDescription: String? { return mMsg }
    var failureReason: String? { return mMsg }
    var recoverySuggestion: String? { return "" }
    var helpAnchor: String? { return "" }
    
    private var mMsg : String
    
    init(_ description: String)
    {
        mMsg = description
    }
}


class SyncClient {
    
    static let sessionmanager = createSessionManager()
    
    static let SYNC_SERVER = "https://ec2-13-56-39-109.us-west-1.compute.amazonaws.com:8443"
    static let REGISTER_PATH = "/PassvaultServiceRegistration/service/registerV1/sync-server"
    static let DELETE_PATH = "/PassvaultServiceRegistration/service/deleteAccount/sync-server"
    // hardcode even though it is in the Gateway, doubt it will change
    static let SYNC_INITIAL_PATH = "/PassvaultServiceRegistration/service/sync-accounts/sync-initial"
    static let SYNC_FINAL_PATH = "/PassvaultServiceRegistration/service/sync-accounts/sync-final"
    static let INTERVAL_SLEEP: useconds_t = 250000

    
    //holds running jobs
    static var jobsMap: [Int : CallStatus] = [:]
    static var jobsMapKey: Int = 0

    
    static func getConfig(email: String, password: String) -> Int {
        let key = createCallStatus()
        
        DispatchQueue.global(qos: .background).async {
            sessionmanager.request("\(SYNC_SERVER)\(REGISTER_PATH)").responseObject { (response: DataResponse<Gateway>) in
                
                if let error = response.error {
                    print("Error getting gateway config: \(error)")
                    jobsMap[key]?.error = error
                    jobsMap[key]?.running = false
                    return
                }
       
                if response.result.isSuccess {
                    var gateway = response.result.value
                    gateway?.userName = email
                    gateway?.password = password
                    jobsMap[key]?.returned = gateway
                    jobsMap[key]?.running = false
                }
            }
        }
        
        return key
    }
    
    
    static func createAccount(email: String, password: String) -> Int {
        let key = createCallStatus()
        let registerRequest = RegisterRequest(email: email, password: password)
        let jsonString = Mapper().toJSONString(registerRequest, prettyPrint: false)!
        
        DispatchQueue.global(qos: .background).async {
            sessionmanager.request("\(SYNC_SERVER)\(REGISTER_PATH)", method: .post, parameters: nil, encoding: JSONStringEncoding(json: jsonString)).responseObject { (response:
                    DataResponse<Gateway>) in
                
                if let error = response.error {
                    print("Error getting gateway config: \(error)")
                    print(String(data: response.data!, encoding: String.Encoding.utf8) as Any)
                    
                    if let errorResponse = String(data: response.data!, encoding: String.Encoding.utf8) {
                        if errorResponse == "An account with the same name already exists." {
                            jobsMap[key]?.error = SyncError("An account with the same name already exists.")
                        } else {
                            jobsMap[key]?.error = SyncError("An error occurred getting the gateway config")
                        }
                    } else {
                        jobsMap[key]?.error = SyncError("An error occurred getting the gateway config")
                    }
                    
                    jobsMap[key]?.running = false
                    return
                }
                
                if response.result.isSuccess {
                    var gateway = response.result.value
                    gateway?.userName = email
                    gateway?.password = password
                    jobsMap[key]?.returned = gateway
                    jobsMap[key]?.running = false
                }
            }
        }
        
        return key
    }
    
    
    static func deleteAccount(email: String, password: String) -> Int {
        let key = createCallStatus()
        let deleteRequest = DeleteRequest(email: email, password: password)
        let jsonString = Mapper().toJSONString(deleteRequest, prettyPrint: false)!
        
        DispatchQueue.global(qos: .background).async {
            sessionmanager.request("\(SYNC_SERVER)\(DELETE_PATH)", method: .post, parameters: nil, encoding: JSONStringEncoding(json: jsonString)).responseString { response in
                
                if let error = response.error {
                    print("Error deleting account: \(error)")
                    print(String(data: response.data!, encoding: String.Encoding.utf8) as Any)
                    
                    if let errorResponse = String(data: response.data!, encoding: String.Encoding.utf8) {
                        if errorResponse == "Account not found." {
                            jobsMap[key]?.error = SyncError("Account not found.")
                        } else if errorResponse == "Account has been logged and will be deleted." {
                            jobsMap[key]?.error = nil
                            jobsMap[key]?.returned = "Account has been logged to be removed on the server"
                        } else {
                            jobsMap[key]?.error = SyncError("An error occurred deleting the account")
                        }
                    } else {
                        jobsMap[key]?.error = SyncError("An error occurred deleting the account")
                    }
                    
                    jobsMap[key]?.running = false
                    return
                }
                
                if response.result.isSuccess {
                    let deleteResponse = response.result.value
                    jobsMap[key]?.returned = deleteResponse
                    jobsMap[key]?.running = false
                }
            }
        }
        
        return key
    }
    
    
    static func syncAccounts() -> Int {
        //need to research locking with swift since this is concurrent proof, since it is mobile dont worry
        if (CoreDataUtils.syncRunning) {
            return -1
        } else {
            CoreDataUtils.syncRunning = true
        }
        
        // get email/password and list of accountName/Update times to send
        let gateway = CoreDataUtils.loadGateway()
        var accounts: [CheckAccount] = []
        
        do {
            for account in try CoreDataUtils.loadAllAccounts(includeDeletes: true) {
                accounts.append(CheckAccount(accountName: account.accountName, updateTime: account.updateTime))
            }
        } catch {
            print("Error loading all accounts for sync initial, exiting sync")
            CoreDataUtils.syncRunning = false
            return -1
        }
        
        let syncRequestInitial = SyncRequestInitial(email: gateway.userName, password: gateway.password, accounts: accounts)
        let jsonString = Mapper().toJSONString(syncRequestInitial, prettyPrint: false)!
        
        let key = createCallStatus()
        
        // INITIAL CALL
        DispatchQueue.global(qos: .background).async {
            sessionmanager.request("\(SYNC_SERVER)\(SYNC_INITIAL_PATH)", method: .post, parameters: nil, encoding: JSONStringEncoding(json: jsonString)).validate(statusCode: 200..<300).responseString { response in
                
                if let error = response.error {
                    jobsMap[key]?.error = error
                    jobsMap[key]?.running = false
                    CoreDataUtils.syncRunning = false
                    return
                }
                
                if response.result.isSuccess && response.value != nil {
                    
                    if let syncResponse = Mapper<SyncResponseInitial>().map(JSONString: response.value!) {
                        /*
                            for accounts returned by sync run update with true to create if new
                            if the account is deleted, then it can be purged from Core Data
                         */
                        for syncAccount in syncResponse.accountsToSendBackToClient {
                            let account = Account(accountName: syncAccount.accountName, userName: syncAccount.userName, password: syncAccount.password, oldPassword: syncAccount.oldPassword, url: syncAccount.url, updateTime: syncAccount.updateTime, deleted: syncAccount.deleted, validEncryption: true)
print("Accounts sent from server, \(account.accountName), deleted=\(account.deleted)")
                            if account.deleted {
                                // purge account
print("Purging deleted account recieved from server: \(account.accountName)")
                                if CoreDataUtils.purgeAccount(forName: account.accountName) == CoreDataStatus.CoreDataError {
                                    // should never happen, but print and keep going
                                    print("Error purging account: \(account.accountName)")
                                    continue
                                }
                            } else {
//                                if CoreDataUtils.updateAccount(forAccount: account, true, new: false, passwordEncrypted: true) == CoreDataStatus.CoreDataError {
                                if CoreDataUtils.updateAccount(forAccount: account, passwordEncrypted: true) == CoreDataStatus.CoreDataError {
                                    // should never happen, but print and keep going
                                    print("Error persisting account: \(account.accountName)")
                                    continue
                                }
                            }
                        }
                        
                        /*
                            for accounts to return to server get account and add to list
                            if the account is deleted add to purge delete list which happens if call back
                            to sync server is successis success
                        */
                        var syncAccountsToSend: [SyncAccount] = []
                        var accountsToPurge: [String] = []
                        
                        for accountName in syncResponse.sendAccountsToServerList {
                            
                            if let account = CoreDataUtils.getAccount(forName: accountName) {
                                syncAccountsToSend.append(SyncAccount(accountName: account.accountName, userName: account.userName, password: account.password, oldPassword: account.oldPassword, url: account.url, updateTime: account.updateTime, deleted: account.deleted))
print("Final Request Sending back account, \(account.accountName), deleted=\(account.deleted)")
                                if account.deleted {
                                    accountsToPurge.append(account.accountName)
                                }
                            }
                        }
                        
                        // build final request
                        let finalRequest = SyncRequestFinal(user: gateway.userName, password: gateway.password, lockTime: syncResponse.lockTime, accounts: syncAccountsToSend)
                        let finalRequestAsString = Mapper().toJSONString(finalRequest, prettyPrint: false)!
                        
                        // FINAL CALL
                        DispatchQueue.global(qos: .background).async {
                            sessionmanager.request("\(SYNC_SERVER)\(SYNC_FINAL_PATH)", method: .post, parameters: nil, encoding: JSONStringEncoding(json: finalRequestAsString)).validate(statusCode: 200..<300).responseString { response in
                                
                                if let error = response.error {
                                    print("Error running final sync: \(error.localizedDescription)")
                                    jobsMap[key]?.error = error
                                } else if response.result.isSuccess && response.value != nil {
print("FINAL REQUEST value=\(response.value)")
                                    jobsMap[key]?.returned = response.value!
                                    
                                    // purge accounts
                                    for accountToPurge in accountsToPurge {
print("After FINAL REquest Purging account: \(accountToPurge)")
                                        CoreDataUtils.purgeAccount(forName: accountToPurge)   // ignore any error returned
                                    }
                                }
                                
                                jobsMap[key]?.running = false
                                CoreDataUtils.syncRunning = false
                                return
                            }
                        }
                    }
                    
                } else {
                    jobsMap[key]?.error = SyncError("Unable to Sync Accounts")
                    jobsMap[key]?.running = false
                    CoreDataUtils.syncRunning = false
                    return
                }
            }
        }
        
        return key
    }
    
    
    static func createCallStatus() -> Int {
        jobsMapKey += 1
        let key = jobsMapKey
        jobsMap[jobsMapKey] = CallStatus()
        return key
    }

    
    static func createSessionManager() -> SessionManager {
        let serverTrustPolicy = ServerTrustPolicy.disableEvaluation
        
        var policies: [String : ServerTrustPolicy] = [:]
        policies["ec2-13-56-39-109.us-west-1.compute.amazonaws.com"] = serverTrustPolicy
        policies["httpbin.org"] = serverTrustPolicy
        policies["73.222.80.66"] = serverTrustPolicy
        
        let serverTrustPolicyManager = ServerTrustPolicyManager(policies: policies)
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        
        let sessionManager = Alamofire.SessionManager(configuration: configuration, delegate: SessionDelegate(), serverTrustPolicyManager: serverTrustPolicyManager)
        
        return sessionManager
    }
    
    
    static func waitForCall(callStatusKey: Int) {
        var running = true
        
        while running {
            let status = SyncClient.jobsMap[callStatusKey]!
            
            if status.running {
                usleep(SyncClient.INTERVAL_SLEEP)
            } else {
                running = false
            }
        }
    }
    
    
    static func test() {
        //sessionManager.request("https://httpbin.org/get").responseJSON { response in
        //Alamofire.request("https://httpbin.org/get").responseJSON { response in
        sessionmanager.request("https://ec2-13-56-39-109.us-west-1.compute.amazonaws.com:8443/PassvaultServiceRegistration/service/registerV1").responseJSON { response in
            //print("Request: \(String(describing: response.request))")   // original url request
            //print("Response: \(String(describing: response.response))") // http url response
            //print("Result: \(response.result)")                         // response serialization result
            
            if let error = response.error {
                print("Error is: \(error)")
            }
            
            if let json = response.result.value {
                print("JSON: \(json)") // serialized json response
                
                let responseAsMap = json as! [String : Any]
                for s in responseAsMap {
                    print(s)
                    
                }
                
                let g = Mapper<Gateway>().map(JSONObject: json)
                print(g?.server)
                
//                let g = Gateway(server: "server", proto: "https", port: 99, path: "/some/path", userName: "user", password: "secret")
//                print(g.toJSONString(prettyPrint: true))
            }
            
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("Data: \(utf8Text)") // original server data as UTF8 string
            }
            
            
        }
        
       /*
        sessionmanager.request("\(REGISTER_SERVER)\(GET_CONFIG_PATH)").responseObject { (response: DataResponse<Gateway>) in
            
            if let error = response.error {
                print("Error: \(error)")
                return
            }
            
            print("isSuccess: \(response.result.isSuccess)")
            print("response: \(response.response?.statusCode)")
            
            let gateway = response.result.value
            print(gateway?.server)
            
            
        }*/
        
        print()
        print()
        var request = RegisterRequest(email: "", password: "")
        request.email = "a@a.com"
        request.password = "secret"
        print(Mapper().toJSONString(request, prettyPrint: false)!)
        let string = Mapper().toJSONString(request, prettyPrint: false)!
        
        let data = string.data(using: String.Encoding.utf8)
    }
    
    
    
}
