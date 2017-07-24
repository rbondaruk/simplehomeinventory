//
//  Room.swift
//  SimpleHomeInventory
//
//  Created by Fred on 2/15/17.
//  Copyright © 2017 Bondaruk. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class Room {
    private var _room: String!
    private var _location: String!
    
    private var _roomkey: String!
    private var _userEmail: String!
    private var _imgURL: String!
    
    private var _roomRef: FIRDatabaseReference!
    
    var room: String {
        return _room
    }
    
    var location: String {
        return _location
    }

    var roomkey: String {
        return _roomkey
    }
    
    var userEmail: String {
        return _userEmail
    }
    
    var imgURL: String {
        return _imgURL
    }
    
    init(room:String, location:String, userID:String, imageUrl:String) {
        self._room = room
        self._location = location
        self._userEmail = userEmail
        self._imgURL = imgURL
    }
    
    init(roomkey: String, dictionary: Dictionary<String, AnyObject>) {
        self._roomkey = roomkey
        
        if let rm = dictionary ["room"] as? String {
            self._room = rm
        }
        
        if let loc = dictionary ["location"] as? String {
            self._location = loc
        }
        
        if let usr = dictionary ["userEmail"] as? String {
            self._userEmail = usr
        }
        
        if let imgURL = dictionary ["imageUrl"] as? String {
            
            if imgURL != nil {
                self._imgURL = imgURL
            }
            else {
                self._imgURL = ""  // this is the default social post image
            }
        }
        
        self._roomRef = DataService.ds.REF_ROOMS.child(self._roomkey)
    }
}
