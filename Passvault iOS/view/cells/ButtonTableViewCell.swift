//
//  ButtonTableViewCell.swift
//  Passvault iOS
//
//  Created by User One on 12/11/17.
//  Copyright © 2017 User One. All rights reserved.
//

import UIKit


/*protocol OptionsButton {
    func buttonPressed(forRow: Int?)
}*/

class ButtonTableViewCell: UITableViewCell {

    @IBOutlet weak var buttonLabel: UILabel!
    @IBOutlet weak var buttonImage: UIImageView!
    //@IBOutlet weak var button: UIButton!
    
    /*var row: Int?
    var delegate: OptionsButton?*/
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    /*@IBAction func buttonPressed(_ sender: UIButton) {
        print("Button Pressed inside")
        
        delegate?.buttonPressed(forRow: row)
    }
    @IBAction func buttonOutside(_ sender: UIButton) {
        print("Button Pressed outside")
    }*/
}
