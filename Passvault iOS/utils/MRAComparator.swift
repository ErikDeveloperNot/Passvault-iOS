//
//  MRAComparator.swift
//  Passvault iOS
//
//  Created by User One on 12/16/17.
//  Copyright © 2017 User One. All rights reserved.
//

import Foundation


enum SortType {
    case Alpha
    case MOA
}


class MRAComparator {
    
    let INTERVALS = [7, 14, 28]
    let NUMBER_OF_DAYS = 28
    
    var mraMapCD: MRAMapCD
    var currentDay: Int64
    var maps: [String : [Int32]] = [:]
    
    static var instance: MRAComparator?
    
    
    private init(mraMapCD: MRAMapCD) {
        self.mraMapCD = mraMapCD
        currentDay = Utils.getMRACurrentDay()
        
        if mraMapCD.map == nil {
            maps = [:]
        } else {
            maps = mraMapCD.map as! [String : [Int32]]
        }
        
        if currentDay != self.mraMapCD.mraTime {
            print("Need to shif MRA Maps")
            shiftMaps()
            CoreDataUtils.saveMRA()
        }
        
        MRAComparator.instance = self
    }
    
    
    static func getInstance() -> MRAComparator {
        
        if instance == nil {
            instance = MRAComparator.init(mraMapCD: CoreDataUtils.loadMRA())
        }
        
        return instance!
    }
    
    
    func incrementAccessCount(forAccount account: String) {
        
        if currentDay != Utils.getMRACurrentDay() {
            currentDay = Utils.getMRACurrentDay()
            MRAComparator.getInstance().shiftMaps()
        }
        
        if maps[account] == nil {
            createMap(account: account)
        }
        
        maps[account]![0] += 1
        mraMapCD.map = maps as NSObject
    }
    
    
    func getMostAccessed(forAccountName account1: String, andAccountName account2: String) -> String {
        var account1Map = maps[account1]
        var account2Map = maps[account2]
        
        if account1Map == nil {
            createMap(account: account1)
            account1Map = maps[account1]
        }
        
        if account2Map == nil {
            createMap(account: account2)
            account2Map = maps[account2]
        }
        
        // total up each interval, anytime there is a winner return
        var start = 0
        for interval in INTERVALS {
            var a1Total: Int32 = 0
            var a2Total: Int32 = 0
            
            for index in start..<interval {
                //print("index = \(index), total = \(a1Total), value = \(maps[account1]![index])")
                a1Total += maps[account1]![index]
                a2Total += maps[account2]![index]
            }
            
            if a1Total > a2Total {
                return account1
            } else if a2Total > a1Total {
                return account2
            }
            
            // keep going
            start = interval
        }
        
        // in the case of equal return an empty String
        return ""
    }
    
    
    func shiftMaps() {
        let daysToShift = currentDay - mraMapCD.mraTime
        print("Shifting MRA Maps by \(daysToShift) days")
        
        if daysToShift >= NUMBER_OF_DAYS {
            clearMaps()
        } else {
        
            for key in maps.keys {
                var values = maps[key]!
                
                for _ in 1...daysToShift {
                    values.popLast()
                    values.insert(0, at: 0)
                }
                
//print("Map count = \(values.count)")
                maps[key] = values
            }
            
            mraMapCD.map = maps as NSObject
        }
        
        mraMapCD.mraTime = currentDay
    }
    
    
    func createMap(account: String) {
        print("Creating map for account: \(account)")
        var values: [Int32] = []

        for _ in 0..<NUMBER_OF_DAYS {
            values.append(0)
        }
        
        maps[account] = values
        mraMapCD.map = maps as NSObject
    }
    
    
    func clearMaps() {
        
        for key in maps.keys {
            for x in 0..<NUMBER_OF_DAYS {
                maps[key]![x] = 0
            }
        }
        
        mraMapCD.map = maps as NSObject
    }
    
    
    func deleteMap(forAccount account: String) {
        maps.removeValue(forKey: account)
        mraMapCD.map = maps as NSObject
    }
    
    
    func debugMaps() {
        print("Dumping all MRA Maps...")
        for key in maps.keys {
            print("account=\(key), map=\(maps[key])")
        }
    }
    
}
