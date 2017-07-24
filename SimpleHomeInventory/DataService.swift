//
//  DataService.swift
//  SimpleHomeInventory
//
//  Created by Fred on 2/9/17.
//  Copyright © 2017 Bondaruk. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage
import FirebaseDatabase

class DataService {
    static let ds = DataService()
    
    //Database reference 
    // - the value in quotes can be anything you want and will show up in firebase
    // - variable naem in uppercase can be anything you want
    // - these are references that are easier to type than the longer paths
    private var _REF_BASE = FIRDatabase.database().reference()
    private var _REF_ROOMS = FIRDatabase.database().reference().child("Rooms")
    private var _REF_ITEMS = FIRDatabase.database().reference().child("Items")
    private var _REF_USERS = FIRDatabase.database().reference().child("Users")
    private var _REF_ITEM_VALUES = FIRDatabase.database().reference().child("ItemValues")
    
    //Storage reference
    private var _REF_ROOM_PICS = FIRStorage.storage().reference().child("roomPics")
    
    var REF_BASE: FIRDatabaseReference {
        return _REF_BASE
    }
    
    var REF_ROOMS: FIRDatabaseReference {
        return _REF_ROOMS
    }
    
    var REF_ITEMS: FIRDatabaseReference {
        return _REF_ITEMS
    }
    
    var REF_USERS: FIRDatabaseReference {
        return _REF_USERS
    }

    var REF_ROOM_PICS: FIRStorageReference {
        return _REF_ROOM_PICS
    }
    
    var REF_ITEM_VALUES: FIRDatabaseReference {
        return _REF_ITEM_VALUES
    }
    
    
    func createFirebaseUser (_ uid: String, userData: Dictionary<String, String>) {
        REF_USERS.child(uid).updateChildValues(userData)
    }
    
}
