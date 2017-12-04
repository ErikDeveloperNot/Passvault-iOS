//
//  ViewController.swift
//  Passvault iOS
//
//  Created by User One on 11/26/17.
//  Copyright © 2017 User One. All rights reserved.
//

import UIKit
import CoreData


class LoginViewController: UIViewController {

    @IBOutlet weak var passwordTextField: UITextField!
    
    var accounts: [Account]?
    var key: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        /*
            Eventually do this like access Core data and check for saved key
        */
        
        
        
        
        
        
        
        
        
        
        /*
            EVERYTHING BELOW THIS IS JUST FOR TESTING
        */
        
        
       
        print(Utils.currentTimeMillis())
        let a1 = Account(accountName: "test account", userName: "user", password: "pass")
        print(a1)
        
        
        /////////// Core Data Testing
        
        
        //let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        //let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"TestCore2")
        
        //let entityDescription = NSEntityDescription.entity(forEntityName: "TestCore2", in: context)
        
        
        do {
            //let results = try context.execute(fetchRequest)
            var tcs: [TestCore3] = try context.fetch(TestCore3.fetchRequest())
            print(tcs.count)
            
            for tc in tcs {
                print("\(tc.name) \(tc.password)")
                print(tc)
            }
            
        } catch {
            print(error)
        }
        
        
        let tc = TestCore3(context: context)
        tc.name = "test"
        tc.password = "password"
        
        do {
            try context.save()
        } catch {
            print(error)
        }
        
     ////////////////////////  More Core Data Testing where I created the Managed Object class
        
        do {
            //let results = try context.execute(fetchRequest)
            var tcs: [TestClass] = try context.fetch(TestClass.fetchRequest())
            print(tcs.count)
            
            for tc in tcs {
                print("\(tc.name) \(tc.password)")
                print(tc)
            }
            
        } catch {
            print(error)
        }
        
        
        let tclz = TestClass(context: context)
        tclz.name = "test"
        tclz.password = "password"
        
        do {
            try context.save()
        } catch {
            print(error)
        }
        
    /////////////////////////// Crypto Testing
        print("Count = \("passwordpasswordpasswordpassword".count)")
        var enc1 = ""
        var dec1 = ""
        
        do {
            enc1 = try Crypt.encryptString(key: "passwordpasswordpasswordpassword", forText: "Here we go Again!@?")
            print("enc1=" + enc1)
        } catch {
            print(error)
        }
        enc1 += "R"
        do {
            dec1 = try Crypt.decryptString(key: "passwordpasswordpasswordpassword", forEncrypted: enc1)
            print("dec1=" + dec1)
        } catch {
            print(error)
        }
        
        
    //////////////////////////
        /*
        print(UnicodeScalar("a")!.value)
        
        let key = "Here we go Again!@?"
        print(String(describing: key.index(key.endIndex, offsetBy: 5-key.count)))
        let index = key.index(key.endIndex, offsetBy: -(key.count-7))
        let s = key[...index]
        print(s)
        
        let start = key.index(key.startIndex, offsetBy: 3)
        let end = key.index(start, offsetBy: 0)
        print(key[start...end])
        print(Character(Unicode.Scalar.init(97)))//print(String())
        var newS = "ababab"
        newS.append(Character(Unicode.Scalar.init(111)))
        print(newS)
        
        let key2 = "notreal"
        let i = 1
        let i1 = i * Int(Crypt.getUnicodeScalar(forString: key2, atPosition: i%key2.count))
        print("\(i1), \(key2.count)")
        */
        print(Crypt.finalizeKey(key: "notreal"))
        print(Crypt.finalizeKey(key: "passwordpasswordpasswordpasswordPASSWORDPASSWORD"))
        print(Crypt.finalizeKey(key: ""))
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func loginPressed(_ sender: UIButton) {
        key = Crypt.finalizeKey(key: passwordTextField.text!)
        accounts = populateAccountsList(usingKey: key!)
        
        
        
        //performSegue(withIdentifier: "goToAccounts", sender: self)
        
        /*
        print("\(finalKey), count: \(accounts.count)")
        
        let a1 = Account(accountName: "a1", userName: "user", password: "password", oldPassword: "password", url: "", updateTime: 999999, deleted: false, validEncryption: true)
        let a2 = Account(accountName: "a1", userName: "user", password: "password", oldPassword: "password", url: "", updateTime: 999999, deleted: false, validEncryption: true)
        let a3 = Account(accountName: "a1o", userName: "user", password: "password", oldPassword: "password", url: "", updateTime: 99999898978979, deleted: false, validEncryption: true)
        
        
        //var act: [Account] = []
        act.append(a1)
        act.append(a2)
        
        if a1 == a2 {
            print("EQUAL")
        } else {
            print("NOT EQUAL")
        }
        
        if act.contains(a3) {
            print("CONTAINS")
        }
        */
        
        //CoreDataUtils.createTestAccounts(numberOfAccounts: 3, encryptionKey: key!)
 
    }
    
    
    private func populateAccountsList(usingKey key: String) -> [Account] {
        CoreDataUtils.key = key
        let accounts = CoreDataUtils.loadAllAccounts()
        
        return accounts
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToAccounts" {
            let destination = segue.destination as! AccountsListViewController
            destination.accounts = accounts!
            destination.key = key!
            //print("key=\(key!) accounts=\(accounts!.count)" )
        }
    }
}

