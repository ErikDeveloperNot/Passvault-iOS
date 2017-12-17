//
//  Utils.swift
//  Passvault iOS
//
//  Created by Erik Manor on 11/26/17.
//  Copyright © 2017 Erik Manor. All rights reserved.
//

import Foundation
import UIKit


class Utils {
    
    
    static func currentTimeMillis() -> Int64{
        let nowDouble = NSDate().timeIntervalSince1970
        return Int64(nowDouble*1000)
    }
    
    
    static func getMRACurrentDay() -> Int64 {
        return (currentTimeMillis() / CoreDataUtils.DAY_IN_MILLI)
    }
    
    
    static func copyToClipboard(toCopy string: String) {
        UIPasteboard.general.string = string
    }
    
    
    static func deletePasswordsFromClipboard()  {
        UIPasteboard.general.strings = [""]
    }
    
    
    static func launchBrowser(forURL: String) -> Bool {
        var urlAsString = forURL

        let httpIndex = forURL.index(forURL.startIndex, offsetBy: 6)
        let http = forURL[...httpIndex]
        let httpsIndex = forURL.index(forURL.startIndex, offsetBy: 7)
        let https = forURL[...httpIndex]
        
        if http != "http://" || https != "https://" {
            urlAsString = "http://\(forURL)"
        }
        
        guard let url = URL(string: urlAsString) else {
            print("Unable to create a URL from: \(forURL)")
            return false
        }
        
        if !UIApplication.shared.canOpenURL(url) {
            print("Unable to open URL from: \(forURL)")
            return false
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
        
        return true
    }
    
    
    static func sort(accounts: [Account], sortType: SortType) -> [Account] {
        
        if sortType == SortType.MOA {
            let comparator = MRAComparator.getInstance()
            
            return accounts.sorted { (acct1, acct2) -> Bool in
                let moa = comparator.getMostAccessed(forAccountName: acct1.accountName, andAccountName: acct2.accountName)
                
                switch moa {
                case acct1.accountName:
                    return true
                case acct2.accountName:
                    return false
                default:
                    // if same return alapha
                    return acct1.accountName.lowercased() < acct2.accountName.lowercased()
                }
            }
            
        } else {
            return accounts.sorted { (acct1, acct2) -> Bool in
                return acct1.accountName.lowercased() < acct2.accountName.lowercased()
            }
        }
    }
    
    
    static func showErrorMessage(errorMessage: String) -> UIAlertController {
        let alert = UIAlertController(title: "Passvault Error", message: errorMessage, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
            
        })
        
        alert.addAction(alertAction)
        
        return alert
    }
    
    
    static func showMessage(message: String) -> UIAlertController {
        let alert = UIAlertController(title: "Passvault Confirmation", message: message, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
            
        })
        
        alert.addAction(alertAction)
        
        return alert
    }
}
