//
//  Crypt.swift
//  Passvault iOS
//
//  Created by User One on 11/28/17.
//  Copyright © 2017 User One. All rights reserved.
//

import Foundation


class Crypt {
    
    static let KEY_LENGTH = 32
    static let DEFAULT_KEY = "YouReallyShouldn'tUseThis1234567"
    
    
    enum CryptError: Error {
        case noKeySpecified
        case errorEncrypting
        case errorDecrypting
    }
    
    
    static func decryptString(key: String, forEncrypted: String) throws -> String {
        let crypto = CommonCrypto()
        
        if key.count == 0 {
            throw CryptError.noKeySpecified
        }
        
        if let dec1 = crypto.decryptString(key, cipherText: forEncrypted) {
            return dec1
        } else {
            throw CryptError.errorDecrypting
        }
    }
    
    
    static func encryptString(key: String, forText: String) throws -> String {
        let crypto = CommonCrypto()
        
        if key.count == 0 {
            throw CryptError.noKeySpecified
        }
        
        if let enc1 = crypto.encryptString(key, plainText: forText) {
            return enc1
        } else {
            throw CryptError.errorEncrypting
        }
    }
    
    
    static func finalizeKey(key: String) -> String {
        var toReturn: String = key
        
        if (key == nil || key.count == 0) {
            return DEFAULT_KEY
        }
        
        var amountToPad: Int = KEY_LENGTH - key.count
        
        if amountToPad > 0 {
            var mod = 256
            
            for i in 1..<amountToPad+1 {
                let i1 = i * Int(getUnicodeScalar(forString: key, atPosition: i%key.count))
                let i2 = (i+3*i) * Int(getUnicodeScalar(forString: key, atPosition: (i+2)%key.count))
                var i3 = ((i1 * i2) % mod)
                var x = 3

                while ((i3 < 65 || i3 > 122) && (i3 < 34 || i3 > 57)) {
                    i3 = ((i1 * x) % mod)
                    x += 1
                    mod -= 1
                }
                
                toReturn.append(Character(Unicode.Scalar.init(i3)!))
            }

        } else if amountToPad < 0 {
            let reducedKeyEndIndex = key.index(key.endIndex, offsetBy: (KEY_LENGTH-1)-key.count)
            toReturn = String(key[...reducedKeyEndIndex])
        }

        return toReturn
    }
    
    
    static func getUnicodeScalar(forString: String, atPosition: Int) -> UInt32 {
        let start = forString.index(forString.startIndex, offsetBy: atPosition)
        let end = forString.index(start, offsetBy: 0)
        
        return UnicodeScalar(String(forString[start...end]))!.value
    }
}
