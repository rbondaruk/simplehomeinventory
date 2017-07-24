//
//  RoomCell.swift
//  SimpleHomeInventory
//
//  Created by Fred on 2/15/17.
//  Copyright © 2017 Bondaruk. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseAuth
import FirebaseDatabase


class RoomCell: UITableViewCell, UINavigationControllerDelegate {
    
    @IBOutlet weak var imgRoom: UIImageView!

    @IBOutlet weak var labelRoom: UILabel!
    
    @IBOutlet weak var labelLocation: UILabel!
    
    var room: Room!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCellS(room: Room, img: UIImage? = nil) {
        self.room = room
        
        self.labelRoom.text = "Room: " + room.room
        self.labelLocation.text = "Location: " + room.location
        
        if img != nil {
            self.imgRoom.image = img
        }
        else {
            let imgUrl = room.imgURL
            if imgUrl != "" {
                let ref = FIRStorage.storage().reference(forURL: imgUrl)
                ref.data(withMaxSize: 2*1024*1024, completion: {(data, error) in
                    if error != nil {
                        print("Unable to download image from Firebase")
                    }
                    else {
                        if let imgData = data {
                            if let img = UIImage(data:imgData) {
                                self.imgRoom.image = img
                                roomsVC.imageCache.setObject(img, forKey: room.imgURL as NSString)
                            }
                        }
                    }
                })
            }
            else {
                self.imgRoom.isHidden = true
            }
        }
    }
    
} // end of class

