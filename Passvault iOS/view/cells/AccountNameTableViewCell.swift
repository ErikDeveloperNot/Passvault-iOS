//
//  AccountNameTableViewCell.swift
//  Passvault iOS
//
//  Created by User One on 12/20/17.
//  Copyright © 2017 User One. All rights reserved.
//

import UIKit

class AccountNameTableViewCell: UITableViewCell {

    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var lockImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
