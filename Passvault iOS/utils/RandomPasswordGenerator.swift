//
//  RandomPasswordGenerator.swift
//  Passvault iOS
//
//  Created by User One on 12/4/17.
//  Copyright © 2017 User One. All rights reserved.
//

import Foundation
//import CoreData

struct Constraints {
    var lower: Bool = false
    var upper: Bool = false
    var digits: Bool = false
    var special: Bool = false
    var lowerMet: Bool = false
    var upperMet: Bool = false
    var digitsMet: Bool = false
    var specialMet: Bool = false
    
    init(lower: Bool, upper: Bool, digits: Bool, special: Bool) {
        self.lower = lower
        self.upper = upper
        self.digits = digits
        self.special = special
    }
}

class RandomPasswordGenerator {
    
    static let DEFAULT_UPPER: [String] = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
    static let DEFAULT_LOWER: [String] = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
    static let DEFAULT_DIGITS: [String] = ["1","2","3","4","5","6","7","8","9","0"]
    static let DEFAULT_SPECIALS: [String] = ["@", "_", "$", "&", "!", "?", "*", "-"]
    static let DEFAULT_LENGTH: Int32 = 32
    
    var allowedCharacters: [String] = []
    var contraints: Constraints?
    var length = RandomPasswordGenerator.DEFAULT_LENGTH

    init() {
        
        allowedCharacters.append(contentsOf: RandomPasswordGenerator.DEFAULT_LOWER)
        allowedCharacters.append(contentsOf: RandomPasswordGenerator.DEFAULT_UPPER)
        allowedCharacters.append(contentsOf: RandomPasswordGenerator.DEFAULT_DIGITS)
        allowedCharacters.append(contentsOf: RandomPasswordGenerator.DEFAULT_SPECIALS)
        contraints = Constraints(lower: true, upper: true, digits: true, special: true)
    }
    
    init(withGenerator generator: GeneratorCD) {
        allowedCharacters = generator.allowedCharacters as! [String]
        length = generator.length
        changeGenertorSpecs(allowedCharacters: self.allowedCharacters, passwordLength: self.length)
    }


    func generatePassword() -> String {
        var toReturn = ""
        let size = allowedCharacters.count
        var met = false

        while !met {
            toReturn = ""
            
            for i in 1...length {
                toReturn.append(allowedCharacters[(Int(arc4random()) % size)])
            }
            
            met = checkContraints(forPassword: toReturn)
        }
 
        return toReturn
    }
    
    
    func checkContraints(forPassword pword: String) -> Bool {
        let pwordArray = pword.characters.map { (Character) -> String in
            return String(Character)
        }
        
        contraints?.upperMet = false
        contraints?.lowerMet = false
        contraints?.digitsMet = false
        contraints?.specialMet = false
        
        if (contraints?.lower)! {
            if !constraintMet(forContraintArray: RandomPasswordGenerator.DEFAULT_LOWER, forCharactersToCheck: pwordArray) {
                return false
            }
        }
        
        if (contraints?.upper)! {
            if !constraintMet(forContraintArray: RandomPasswordGenerator.DEFAULT_UPPER, forCharactersToCheck: pwordArray) {
                return false
            }
        }
        
        if (contraints?.digits)! {
            if !constraintMet(forContraintArray: RandomPasswordGenerator.DEFAULT_DIGITS, forCharactersToCheck: pwordArray) {
                return false
            }
        }
        
        if (contraints?.special)! {
            if !constraintMet(forContraintArray: RandomPasswordGenerator.DEFAULT_SPECIALS, forCharactersToCheck: pwordArray) {
                return false
            }
        }
        
        return true
    }
    
    
    func constraintMet(forContraintArray stringArray: [String], forCharactersToCheck toCheck: [String]) -> Bool {
        for c in toCheck {
            
            if stringArray.contains(c) {
                return true
            }
        }
        
        return false
    }
    
    
    func changeGenertorSpecs(allowedCharacters allowed: [String], passwordLength length: Int32) {
        
        if allowedCharacters.count < 1 || length < 1 {
            return
        }
        
        allowedCharacters = allowed
        self.length = length
        
        if constraintMet(forContraintArray: allowedCharacters, forCharactersToCheck: RandomPasswordGenerator.DEFAULT_LOWER) {
            contraints?.lower = true
        } else {
            contraints?.lower = false
        }
        
        if constraintMet(forContraintArray: allowedCharacters, forCharactersToCheck: RandomPasswordGenerator.DEFAULT_UPPER) {
            contraints?.upper = true
        } else {
            contraints?.upper = false
        }
        
        if constraintMet(forContraintArray: allowedCharacters, forCharactersToCheck: RandomPasswordGenerator.DEFAULT_DIGITS) {
            contraints?.digits = true
        } else {
            contraints?.digits = false
        }
        
        if constraintMet(forContraintArray: allowedCharacters, forCharactersToCheck: RandomPasswordGenerator.DEFAULT_SPECIALS) {
            contraints?.special = true
        } else {
            contraints?.special = false
        }
    }
    
}
