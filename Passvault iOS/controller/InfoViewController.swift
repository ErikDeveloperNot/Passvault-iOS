//
//  InfoViewController.swift
//  Passvault iOS
//
//  Created by User One on 12/26/17.
//  Copyright © 2017 User One. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {
    
    let HELP_URL = "https://github.com/ErikDeveloperNot/Passvault-iOS/wiki"
    let ICON_URL = "https://www.flaticon.com/authors/dave-gandy"
    let FREE_PIX = "http://www.freepik.com"
    
    @IBOutlet weak var freePixLabel1: UILabel!
    @IBOutlet weak var freePixLabel2: UILabel!
    @IBOutlet weak var freePixLabel3: UILabel!
    @IBOutlet weak var freePixLabel4: UILabel!
    @IBOutlet weak var freePixLabel5: UILabel!
    
    
    var version: String?

    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var iconLinkLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
            let dictionary = NSDictionary(contentsOfFile: path)
            
            if let d = dictionary {
                version = d["Passvault-Version"] as? String
            }
        }
        
        versionLabel.text = "Passvault version: \(version ?? "x.x")"
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(InfoViewController.openFreePix))
        freePixLabel1.addGestureRecognizer(tap1)
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(InfoViewController.openFreePix))
        freePixLabel2.addGestureRecognizer(tap2)
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(InfoViewController.openFreePix))
        freePixLabel3.addGestureRecognizer(tap3)
        let tap4 = UITapGestureRecognizer(target: self, action: #selector(InfoViewController.openFreePix))
        freePixLabel4.addGestureRecognizer(tap4)
        let tap5 = UITapGestureRecognizer(target: self, action: #selector(InfoViewController.openFreePix))
        freePixLabel5.addGestureRecognizer(tap5)
        
        let tap6 = UITapGestureRecognizer(target: self, action: #selector(InfoViewController.openIcon))
        iconLinkLabel.addGestureRecognizer(tap6)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    @objc func openIcon() {
        let _ = Utils.launchBrowser(forURL: ICON_URL)
    }
    
    
    @objc func openFreePix() {
        let _ = Utils.launchBrowser(forURL: FREE_PIX)
    }
    
    @IBAction func helpPressed(_ sender: UIButton) {
        let _ = Utils.launchBrowser(forURL: HELP_URL)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
