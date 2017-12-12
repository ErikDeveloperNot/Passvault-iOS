//
//  RandomPasswordGenerator.swift
//  Passvault iOS
//
//  Created by Erik Manor on 12/4/17.
//  Copyright © 2017 Erik Manor. All rights reserved.
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
    var speicalCharactersOnly: [String] = []
    var contraints: Constraints?
    var length = RandomPasswordGenerator.DEFAULT_LENGTH

    init() {
        
        allowedCharacters.append(contentsOf: RandomPasswordGenerator.DEFAULT_LOWER)
        allowedCharacters.append(contentsOf: RandomPasswordGenerator.DEFAULT_UPPER)
        allowedCharacters.append(contentsOf: RandomPasswordGenerator.DEFAULT_DIGITS)
        allowedCharacters.append(contentsOf: RandomPasswordGenerator.DEFAULT_SPECIALS)
        speicalCharactersOnly = RandomPasswordGenerator.DEFAULT_SPECIALS
        contraints = Constraints(lower: true, upper: true, digits: true, special: true)
    }
    
    init(withGenerator generator: GeneratorCD) {
        allowedCharacters = generator.allowedCharacters as! [String]
        length = generator.length
        changeGenertorSpecs(allowedCharacters: self.allowedCharacters, passwordLength: self.length)
        computeSpecials()
    }


    func generatePassword() -> String {
        var toReturn = ""
        let size = allowedCharacters.count
        var met = false

        while !met {
            toReturn = ""
            
            for _ in 1...length {
                toReturn.append(allowedCharacters[(Int(arc4random()) % size)])
            }
            
            met = checkContraints(forPassword: toReturn)
        }
 
        return toReturn
    }
    
    
    func checkContraints(forPassword pword: String) -> Bool {
        /*let pwordArray = pword.characters.map { (Character) -> String in
            return String(Character)
        }*/
        
        var p = pword
        var pwordArray: [String] = []
        
        while p.count > 0 {
            pwordArray.append(String(p.removeFirst()))
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
        var lower: Bool?
        var upper: Bool?
        var digits: Bool?
        var special: Bool?
        
        if constraintMet(forContraintArray: allowedCharacters, forCharactersToCheck: RandomPasswordGenerator.DEFAULT_LOWER) {
            lower = true
        } else {
            lower = false
        }
       
        if constraintMet(forContraintArray: allowedCharacters, forCharactersToCheck: RandomPasswordGenerator.DEFAULT_UPPER) {
            upper = true
        } else {
            upper = false
        }
        
        if constraintMet(forContraintArray: allowedCharacters, forCharactersToCheck: RandomPasswordGenerator.DEFAULT_DIGITS) {
            digits = true
        } else {
            digits = false
        }
        
        if constraintMet(forContraintArray: allowedCharacters, forCharactersToCheck: RandomPasswordGenerator.DEFAULT_SPECIALS) {
            special = true
        } else {
            special = false
        }
        
        contraints = Constraints(lower: lower!, upper: upper!, digits: digits!, special: special!)
    }
    
    
    func computeSpecials() {
        
        for s in allowedCharacters {
            if RandomPasswordGenerator.DEFAULT_LOWER.contains(s) {
                continue
            }
            if RandomPasswordGenerator.DEFAULT_UPPER.contains(s) {
                continue
            }
            if RandomPasswordGenerator.DEFAULT_DIGITS.contains(s) {
                continue
            }
            
            speicalCharactersOnly.append(s)
        }
    }
    
    
    func getSpecials() -> [String] {
        return speicalCharactersOnly
    }
    
}
