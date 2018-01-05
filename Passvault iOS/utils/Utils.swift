//
//  Utils.swift
//  Passvault iOS
//
//  Created by Erik Manor on 11/26/17.
//  Copyright © 2017 Erik Manor. All rights reserved.
//

import Foundation
import UIKit


extension UIColor {
    
    convenience init(hex: Int) {
        let components = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255
        )
        self.init(red: components.R, green: components.G, blue: components.B, alpha: 1)
    }
    
}


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
        let https = forURL[...httpsIndex]

        if http != "http://" && https != "https://" {
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
    
    
    static func addURLProtocol(forURL: String) -> String {
        var urlAsString = forURL
        
        if forURL.count == 0 {
            return forURL
        }
        
        if forURL.count > 9 {
            let httpIndex = forURL.index(forURL.startIndex, offsetBy: 6)
            let http = forURL[...httpIndex]
            let httpsIndex = forURL.index(forURL.startIndex, offsetBy: 7)
            let https = forURL[...httpsIndex]
            
            if http != "http://" && https != "https://" {
                urlAsString = "http://\(forURL)"
            }
        } else {
            urlAsString = "http://\(forURL)"
        }
        
        return urlAsString
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
    
    
    static func getUIColorForHexValue(hex: Int) -> UIColor {
        return UIColor(hex: hex)
    }
    
    
    static func adjustInsetForKeyboardShow(_ show: Bool, notification: Notification, scrollView: UIScrollView) {
        
        if show {
            let userInfo = notification.userInfo ?? [:]
            print(userInfo[UIKeyboardFrameEndUserInfoKey])
            
            let kbSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size
            print(kbSize.height)
            let insets = UIEdgeInsets.init(top: 0, left: 0, bottom: kbSize.height + 10, right: 0)
            scrollView.contentInset = insets
            scrollView.scrollIndicatorInsets = insets
        } else {
            let insets = UIEdgeInsets.zero
            scrollView.contentInset.bottom = insets.bottom
            scrollView.scrollIndicatorInsets.bottom = insets.bottom
            
        }
    }
    
    
    @objc static func keyboardWillShow(_ notification: Notification, scrollView: UIScrollView) {
        Utils.adjustInsetForKeyboardShow(true, notification: notification, scrollView: scrollView)
    }
    
    @objc static func keyboardWillHide(_ notification: Notification, scrollView: UIScrollView) {
        Utils.adjustInsetForKeyboardShow(false, notification: notification, scrollView: scrollView)
    }
    
}
