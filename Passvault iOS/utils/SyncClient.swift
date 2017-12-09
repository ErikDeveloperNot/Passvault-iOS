//
//  SyncClient.swift
//  Passvault iOS
//
//  Created by User One on 12/7/17.
//  Copyright © 2017 User One. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper
import AlamofireObjectMapper


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


struct CallStatus {
    var returned: Any?
    var error: Error?
    var running = true
    
    init() {
    }
}


class SyncClient {
    
    static let sessionmanager = createSessionManager()
    
    static let REGISTER_SERVER = "https://ec2-13-56-39-109.us-west-1.compute.amazonaws.com:8443"
    static let GET_CONFIG_PATH = "/PassvaultServiceRegistration/service/registerV1/sync-server"
    
    //holds running jobs
    static var jobsMap: [Int : CallStatus] = [:]
    static var jobsMapKey: Int = 0

    
    static func getConfig(email: String, password: String) -> Int {
        jobsMapKey += 1
        let key = jobsMapKey
        jobsMap[jobsMapKey] = CallStatus()
        
        DispatchQueue.global(qos: .background).async {
            sessionmanager.request("\(REGISTER_SERVER)\(GET_CONFIG_PATH)").responseObject { (response: DataResponse<Gateway>) in
                
                if let error = response.error {
                    print("Error getting gateway config: \(error)")
                    jobsMap[jobsMapKey]?.error = error
                    jobsMap[jobsMapKey]?.running = false
                    return
                }
       
                if response.result.isSuccess {
                    var gateway = response.result.value
                    gateway?.userName = email
                    gateway?.password = password
                    jobsMap[jobsMapKey]?.returned = gateway
                    jobsMap[jobsMapKey]?.running = false
                }
            }
        }
        
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
    
    
    static func test() {
        //sessionManager.request("https://httpbin.org/get").responseJSON { response in
        //Alamofire.request("https://httpbin.org/get").responseJSON { response in
        /*sessionmanager.request("https://ec2-13-56-39-109.us-west-1.compute.amazonaws.com:8443/PassvaultServiceRegistration/service/registerV1").responseJSON { response in
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result
            
            if let error = response.error {
                print("Error is: \(error)")
            }
            
            if let json = response.result.value {
                print("JSON: \(json)") // serialized json response
                
                let responseAsMap = json as! [String : Any]
                for s in responseAsMap {
                    print(s)
                    
                }
                
                let g = Gateway(server: "server", proto: "https", port: 99, path: "/some/path", userName: "user", password: "secret")
                print(g.toJSONString(prettyPrint: true))
            }
            
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("Data: \(utf8Text)") // original server data as UTF8 string
            }
            
            
        }*/
        
        
        sessionmanager.request("\(REGISTER_SERVER)\(GET_CONFIG_PATH)").responseObject { (response: DataResponse<Gateway>) in
            
            if let error = response.error {
                print("Error: \(error)")
                return
            }
            
            print("isSuccess: \(response.result.isSuccess)")
            print("response: \(response.response?.statusCode)")
            
            let gateway = response.result.value
            print(gateway?.server)
            
            
        }
    }
    
    
    
}
