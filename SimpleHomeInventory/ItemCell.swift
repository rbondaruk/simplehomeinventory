//
//  ItemCell.swift
//  SimpleHomeInventory
//
//  Created by Fred on 2/20/17.
//  Copyright © 2017 Bondaruk. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseAuth
import FirebaseDatabase

class ItemCell: UITableViewCell, UINavigationControllerDelegate {

    @IBOutlet weak var labelItem: UILabel!
    
    @IBOutlet weak var labelValue: UILabel!
    
    var item: Item!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCellS(item: Item) {
        self.item = item
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        self.labelItem.text = item.item
        self.labelValue.text = item.value
        
    }

}
