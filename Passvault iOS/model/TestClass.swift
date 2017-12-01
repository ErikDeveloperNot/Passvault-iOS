//
//  TestClass.swift
//  Passvault iOS
//
//  Created by User One on 11/27/17.
//  Copyright © 2017 User One. All rights reserved.
//

import Foundation
import CoreData


@objc(TestClass)
class TestClass: NSManagedObject {

    
    @NSManaged public var name: String?
    @NSManaged public var password: String?
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TestClass> {
        return NSFetchRequest<TestClass>(entityName: "TestClass")
    }
}
