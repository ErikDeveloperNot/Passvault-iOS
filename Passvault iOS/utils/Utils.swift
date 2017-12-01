//
//  Utils.swift
//  Passvault iOS
//
//  Created by User One on 11/26/17.
//  Copyright © 2017 User One. All rights reserved.
//

import Foundation
import UIKit


class Utils {
    
    
    static func currentTimeMillis() -> Int64{
        let nowDouble = NSDate().timeIntervalSince1970
        return Int64(nowDouble*1000)
    }
    
    
    static func copyToClipboard(toCopy string: String) {
        UIPasteboard.general.string = string
    }
    
    
    static func deletePasswordsFromClipboard()  {
        UIPasteboard.general.strings = [""]
    }
}
